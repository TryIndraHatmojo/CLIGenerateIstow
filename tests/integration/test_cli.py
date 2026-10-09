"""Black-box CLI tests; fixture schema contains no source application records."""
import concurrent.futures
from contextlib import closing
import hashlib
import json
import os
from pathlib import Path
import sqlite3
import struct
import subprocess
import sys
import tempfile
import unittest
import zlib

BINARY = Path(sys.argv.pop(1)).resolve()
SCHEMA = Path(__file__).resolve().parents[1] / "fixtures/schema.sql"

def legacy(entries):
    result = b""
    for path, data in entries:
        name = path.encode("utf-16-be")
        compressed = struct.pack(">I", len(data)) + (zlib.compress(data) if data else b"")
        result += struct.pack(">I", len(name)) + name + struct.pack(">I", len(compressed)) + compressed
    return result

def unpack(data):
    entries = {}
    while data:
        n, = struct.unpack(">I", data[:4]); name = data[4:4+n].decode("utf-16-be"); data = data[4+n:]
        n, = struct.unpack(">I", data[:4]); block = data[4:4+n]; data = data[4+n:]
        entries[name] = zlib.decompress(block[4:]) if len(block) > 4 else b""
    return entries

class CliTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="istow tests ")
        self.root = Path(self.temp.name); self.input = self.root / "input"; self.input.mkdir()
        self.output = self.root / "output.istow"; self.db = self.input / "12_MVPranala.db"
        with closing(sqlite3.connect(self.db)) as c:
            c.executescript(SCHEMA.read_text(encoding="utf-8"))
            c.execute("INSERT INTO shiptypetbl(id,name) VALUES(1,'Container')")
            c.execute("INSERT INTO operatortbl(id,name,pathlogo) VALUES(1,'Synthetic Company','logo.png')")
            c.execute("INSERT INTO shiptbl(id,name,shiptype_id,operator_id) VALUES(12,'MV Pranala',1,1)")
            c.execute("INSERT INTO infotbl(id,param,val,ship_id) VALUES(1,'version','1.2.3',12)")
            c.commit()
        image = self.input / "assets/images/12_MVPranala_logo.png"; image.parent.mkdir(parents=True)
        image.write_bytes(bytes(range(256)) * 10)
        self.request = {"schema_version": 1,"request_id": "test-12", "ship": {"id":12,"name":"MV Pranala"},"database":{"source":self.db.name},"assets":[{"source":image.relative_to(self.input).as_posix(),"archive_path":image.relative_to(self.input).as_posix()}]}
        self.manifest = self.root / "request.json"

    def tearDown(self): self.temp.cleanup()

    def invoke(self, args, expected=0):
        p = subprocess.run([str(BINARY), *map(str,args)], capture_output=True, timeout=30)
        self.assertEqual(p.returncode, expected, p.stdout.decode(errors="replace") + p.stderr.decode(errors="replace"))
        self.assertEqual(len(p.stdout.splitlines()), 1, p.stdout)
        result = json.loads(p.stdout); self.assertEqual(result.get("ok"), expected == 0)
        self.assertNotIn(b"QSqlDatabasePrivate::removeDatabase", p.stderr)
        return result

    def export(self, expected=0, extra=(), output=None):
        self.manifest.write_text(json.dumps(self.request), encoding="utf-8")
        result = self.invoke(["export","--manifest",self.manifest,"--input-dir",self.input,"--output",output or self.output,"--format","legacy-v1","--json",*extra],expected)
        if expected and output is None: self.assertFalse(self.output.exists())
        return result

    def sql(self, statement, params=()):
        with closing(sqlite3.connect(self.db)) as c:
            c.execute(statement, params); c.commit()

    def verify_bytes(self, data, expected=6, extra=()):
        archive = self.root / "diagnostic.istow"; archive.write_bytes(data)
        return self.invoke(["verify","--archive",archive,"--json",*extra],expected)

    def test_roundtrip_payload_metadata_and_checksum(self):
        empty = self.input / "assets/nested/12_MVPranala_empty.dat"; empty.parent.mkdir(parents=True); empty.touch()
        self.request["assets"].append({"source":empty.relative_to(self.input).as_posix(),"archive_path":empty.relative_to(self.input).as_posix()})
        result = self.export(); raw = self.output.read_bytes(); entries = unpack(raw)
        self.assertEqual(entries["/"+self.db.name],self.db.read_bytes())
        self.assertEqual(entries["/assets/images/12_MVPranala_logo.png"],bytes(range(256))*10)
        self.assertEqual(entries["/assets/nested/12_MVPranala_empty.dat"],b"")
        details = json.loads(entries["/tmp/12_MVPranala_ship.details"])
        self.assertEqual(details["version"],"1.2.3"); self.assertEqual(details["company"],"Synthetic Company")
        self.assertEqual(details["idship"],12); self.assertNotIn("id",details)
        self.assertEqual(result["output"]["sha256"],hashlib.sha256(raw).hexdigest())
        self.assertEqual(result["output"]["size_bytes"],len(raw)); self.assertTrue(result["verified"])
        self.invoke(["verify","--archive",self.output,"--json"])

    def test_parser(self):
        cases=[[],["bad","--json"],["export","--json"],["export","--wat","x","--json"],["verify","--archive"],["export","--json","--json"],["verify","--archive",self.output,"--format","zip"],["verify","--archive",self.output,"--max-entries","0"],["verify","--archive",self.output,"--max-file-bytes","99999999999999999"]]
        for args in cases:
            with self.subTest(args=args): self.invoke(args,2)
        p=subprocess.run([str(BINARY),"--version"],capture_output=True,check=True); self.assertEqual(json.loads(p.stdout)["stream_version"],"Qt_5_15")
        p=subprocess.run([str(BINARY),"--help"],capture_output=True,check=True); self.assertIn(b"export",p.stdout)

    def test_manifest_types(self):
        for key,value in [("schema_version",2),("schema_version",True),("request_id",None),("assets",{}),("database",{})]:
            old=self.request[key]; self.request[key]=value
            with self.subTest(key=key,value=value): self.export(2)
            self.request[key]=old
        for value in [True,1.5,-1,"12"]:
            self.request["ship"]["id"]=value; self.export(2)

    def test_invalid_json_and_null_request_id(self):
        self.manifest.write_text('{broken',encoding='utf-8')
        result=self.invoke(["export","--manifest",self.manifest,"--input-dir",self.input,"--output",self.output],2)
        self.assertIsNone(result["request_id"])

    def test_path_attacks(self):
        for path in ["../evil.png","/evil.png","C:/evil.png","\\\\host\\evil.png","a\\b.png","a//b.png","a/./b.png","a/NUL.png","a/trailing. ","a/COM1.png","a/evil\x00.png","a/b:stream"]:
            self.request["assets"][0]["archive_path"]=path
            with self.subTest(path=path): self.export(3)

    def test_case_collision(self):
        asset=dict(self.request["assets"][0]); asset["archive_path"]=asset["archive_path"].upper(); self.request["assets"].append(asset)
        self.assertEqual(self.export(3)["error"]["code"],"DUPLICATE_ENTRY")

    def test_missing_or_wrong_assets(self):
        self.request["assets"]=[]; self.export(3)
        self.request["assets"]=[{"source":"missing","archive_path":"assets/12_MVPranala_a.png"}]; self.export(3)
        self.request["assets"][0]["archive_path"]="assets/99_Other_logo.png"; self.export(3)

    def test_asset_type_exclusions(self):
        for suffix in ["db","details","istow","log","license","db-wal","db-shm"]:
            self.request["assets"][0]["archive_path"]="assets/12_MVPranala_x."+suffix
            with self.subTest(suffix=suffix): self.export(3)

    def test_identity_schema_version_and_corruption(self):
        self.request["ship"]["id"]=13; self.export(4); self.request["ship"]["id"]=12
        self.request["ship"]["name"]="Other"; self.export(4); self.request["ship"]["name"]="MV Pranala"
        self.sql("INSERT INTO infotbl(id,param,val,ship_id) VALUES(2,'version','duplicate',12)"); self.export(4)
        self.sql("DELETE FROM infotbl WHERE id=2"); self.sql("INSERT INTO shiptbl(id,name,shiptype_id) VALUES(13,'Other',1)"); self.export(4)
        self.sql("DELETE FROM shiptbl WHERE id=13"); self.sql("DROP TABLE tanktbl"); self.export(4)
        self.db.write_bytes(b'corrupt'); self.export(4)

    def test_canonical_database_name(self):
        self.db.rename(self.input / "snapshot.db"); self.request["database"]["source"]="snapshot.db"; self.export(4)

    def test_unsupported_external_asset_mapping(self):
        self.sql("UPDATE shiptbl SET pathconfig='config.obj'")
        self.assertEqual(self.export(4)["error"]["code"],"ASSET_MAPPING_UNSUPPORTED")

    def test_optional_version_operator_and_ferry_profile(self):
        self.sql("DROP TABLE infotbl"); self.sql("UPDATE shiptbl SET operator_id=NULL")
        self.sql("UPDATE shiptypetbl SET name='Ferry / RoRo'"); self.request["assets"]=[]
        self.export(); details=json.loads(unpack(self.output.read_bytes())["/tmp/12_MVPranala_ship.details"])
        self.assertEqual(details["company"],""); self.assertEqual(details["version"],"")

    def test_wal_shm_snapshot(self):
        for suffix in ["-wal","-shm"]:
            sidecar=Path(str(self.db)+suffix); sidecar.touch(); self.export(4); sidecar.unlink()

    def test_limits(self):
        for args in [("--max-file-bytes","100"),("--max-total-bytes","100"),("--max-entries","2")]:
            with self.subTest(args=args): self.export(3,args)

    def test_output_existing_and_inside_input(self):
        self.output.write_bytes(b"keep")
        self.manifest.write_text(json.dumps(self.request),encoding="utf-8")
        self.invoke(["export","--manifest",self.manifest,"--input-dir",self.input,"--output",self.output],5)
        self.assertEqual(self.output.read_bytes(),b"keep"); self.output.unlink()
        self.export(3,output=self.input / "bad.istow")

    def test_symlink(self):
        link=self.input / "linked.png"
        try: link.symlink_to(self.input / self.request["assets"][0]["source"])
        except OSError: self.skipTest("OS does not permit unprivileged symlinks")
        self.request["assets"][0]["source"]="linked.png"; self.export(3)

    def test_parallel_isolation_and_output_lock(self):
        self.manifest.write_text(json.dumps(self.request),encoding="utf-8")
        def run(path): return subprocess.run([str(BINARY),"export","--manifest",str(self.manifest),"--input-dir",str(self.input),"--output",str(path)],capture_output=True,timeout=30)
        paths=[self.root / (str(i)+".istow") for i in range(2)]
        with concurrent.futures.ThreadPoolExecutor(2) as pool: results=list(pool.map(run,paths))
        self.assertTrue(all(p.returncode==0 for p in results),results)
        self.assertEqual(unpack(paths[0].read_bytes()),unpack(paths[1].read_bytes()))
        with concurrent.futures.ThreadPoolExecutor(2) as pool: results=list(pool.map(run,[self.output]*2))
        self.assertEqual(sorted(p.returncode for p in results),[0,5])

    def test_hostile_archives(self):
        good=legacy([('/12_Test.db',b'database'),('/tmp/12_Test_ship.details',b'{}')])
        self.verify_bytes(good,0)
        for data in [good[:-1],good+b'\0',struct.pack('>I',0x7ffffffe),legacy([('/../12_Test.db',b'x')]),legacy([('/12_Test.db',b'x'),('/12_test.DB',b'y')]),legacy([('/nested/12_Test.db',b'x')]),legacy([('/tmp/12_Test_ship.details',b'{}')])]:
            with self.subTest(data=data[:20]): self.verify_bytes(data,3 if b'..' in data.decode('utf-16-be',errors='ignore').encode() else 6)

    def test_decompression_bomb_and_forged_header(self):
        data=legacy([('/12_Test.db',b'A'*10000),('/tmp/12_Test_ship.details',b'{}')])
        self.verify_bytes(data,3,("--max-file-bytes","100"))
        name='/12_Test.db'.encode('utf-16-be'); block=struct.pack('>I',1)+zlib.compress(b'A'*10000)
        data=struct.pack('>I',len(name))+name+struct.pack('>I',len(block))+block
        self.verify_bytes(data,3,("--max-file-bytes","100"))

if __name__ == '__main__': unittest.main(verbosity=2)
