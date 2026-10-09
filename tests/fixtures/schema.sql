-- Schema only from ship-configure/res/db/container.db; no original rows or credentials.
CREATE TABLE "allowabletbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	INTEGER,
	"lever"	REAL,
	"min_sf"	REAL,
	"max_sf"	REAL,
	"min_bm"	REAL,
	"max_bm"	REAL,
	"min_tm"	REAL,
	"max_tm"	REAL,
	"created_at"	integer,
	"updated_at"	integer,
	"code"	INTEGER,
	"mode"	INTEGER,
	"global_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE "baystbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	INTEGER,
	"name"	TEXT,
	"prevbay"	INTEGER,
	"disttoprev"	INTEGER,
	"nextbay"	INTEGER,
	"disttonext"	INTEGER,
	"linkbay"	INTEGER,
	"disttolink"	INTEGER,
	"inhold"	TEXT,
	"baselcg"	INTEGER,
	"p"	REAL,
	"l"	REAL,
	"path"	TEXT,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	"inholdcenter"	INTEGER,
	"ondeckcenter"	INTEGER, max_weight_inhold REAL, max_weight_ondeck REAL, max_inhold_height REAL, cargohold_id INTEGER,
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE 'billloadingtbl' (
 'id' INTEGER NOT NULL ,
'plan_id' INTEGER  ,
'volume' REAL  ,
'gsv' REAL  ,
'barrels' REAL  ,
'longton' REAL  ,
'mton' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE boltbl (id INTEGER,plan_id INTEGER,volume REAL,nettkl15 REAL,barrels REAL,longton REAL,mton REAL,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE "bonjeantbl" (
	"id"	INTEGER,
	"ship_id"	integer,
	"lever"	REAL,
	"draft"	REAL,
	"value"	REAL,
	"created_at"	integer,
	"updated_at"	integer,
	PRIMARY KEY("id")
);
CREATE TABLE 'calcparamtbl' (
 'id' INTEGER NOT NULL ,
'label' TEXT  ,
'value' TEXT  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'ship_id' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'calcsettingtbl' (
 'id' INTEGER NOT NULL ,
'label' TEXT  ,
'value' TEXT  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'ship_id' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "cargoholdtbl" (
	"id"	INTEGER,
	"ship_id"	INTEGER,
	"name"	TEXT,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "cargotypetbl" (
	"id"	INTEGER,
	"ship_id"	INTEGER,
	"name"	TEXT,
	"density"	REAL,
	"status"	INTEGER,
	"perm"	REAL,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id")
);
CREATE TABLE 'cargoview' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'name' TEXT  ,
'image' TEXT  ,
'length' REAL  ,
'width' REAL  ,
'type' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'classtbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT NOT NULL  ,
'pathlogo' TEXT  ,
'info' TEXT  ,
'created_at' integer  ,
'shortname' TEXT  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE 'compartmenttbl' (
 'id' INTEGER NOT NULL ,
'damagecase_id' INTEGER  ,
'tank_id' INTEGER  ,
'status' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(damagecase_id) REFERENCES damagecasetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'containersizetbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT  ,
'p' INTEGER  ,
'l' INTEGER  ,
't' INTEGER  ,
'hc' INTEGER  ,
'bk' INTEGER  ,
'lcg' INTEGER  ,
'vcg' INTEGER  ,
'tcg' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER,
'created_at' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE "containertbl" (
	"id"	INTEGER NOT NULL,
	"number"	TEXT,
	"shipper"	TEXT,
	"PPAL"	NUMERIC,
	"OPS"	TEXT,
	"STUFF"	TEXT,
	"weight"	REAL,
	"size_id"	INTEGER,
	"kt"	INTEGER,
	"fe"	TEXT,
	"seal"	TEXT,
	"comodity"	TEXT,
	"LOK"	TEXT,
	"voyage_id"	INTEGER,
	"type_id"	INTEGER,
	"status"	INTEGER,
	"stowagepos"	TEXT,
	"loadport_id"	INTEGER,
	"dischport_id"	INTEGER,
	"dgsmin"	TEXT,
	"reefertemp"	TEXT,
	"fc"	TEXT,
	"overtop"	TEXT,
	"overleft"	TEXT,
	"overright"	TEXT,
	"overfront"	TEXT,
	"overback"	TEXT,
	"lcg"	INTEGER,
	"tcg"	INTEGER,
	"vcg"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	"description"	TEXT,
	"isocode"	TEXT,
	"dg_class"	INTEGER,
	"dg_un"	INTEGER,
	"created_at"	INTEGER,
	"handling_instruction"	TEXT,
	"initial_handling_instruction"	TEXT,
	"previous_stowage"	TEXT,
	FOREIGN KEY("voyage_id") REFERENCES "voyagetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("dischport_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("loadport_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE 'containertypetbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT  ,
'corrp' INTEGER  ,
'corrl' INTEGER  ,
'corrt' INTEGER  ,
'corrbk' INTEGER  ,
'path' TEXT  ,
'updated_at' INTEGER  ,
'global_id' INTEGER,
'created_at' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE 'countrytbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT  ,
'isocode' TEXT  ,
'status' INTEGER  ,
'prioritas' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE cranehatchcovertbl (id INTEGER,crane_split_plan_id INTEGER,crane_id INTEGER,number_of_hatch_cover INTEGER,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE craneoutreachtbl (id INTEGER,ship_id INTEGER,crane_id INTEGER,bay_id INTEGER,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE cranesplitcalculationtbl (id INTEGER,crane_id INTEGER,scenario_id INTEGER,crane_split_plan_id INTEGER,duration INTEGER,container_id INTEGER,is_overlap INTEGER,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE cranesplitplantbl (id INTEGER,plan_id INTEGER,boxes INTEGER,teus INTEGER,berthing_window_start INTEGER,berthing_window_end INTEGER,loading_time_start INTEGER,loading_time_end INTEGER,time_close_hatch_cover INTEGER);
CREATE TABLE cranesplitscenariotbl (id INTEGER,name TEXT,crane_split_plan_id INTEGER,status INTEGER,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE cranetbl (id INTEGER,ship_id INTEGER,name TEXT,location TEXT,crane_type INTEGER,move_type TEXT,productivity INTEGER,outreach INTEGER,distance_from_ap INTEGER,height INTEGER,row_on_ship INTEGER,lifted_load INTEGER,duration_of_bay_moves INTEGER,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE cranetypetbl (id INTEGER,name TEXT,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE 'd_limitingtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'damagecase_id' INTEGER  ,
'draft' REAL  ,
'value' REAL  ,
'percent' REAL  ,
'sg' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(damagecase_id) REFERENCES damagecasetbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'damagecasetbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'name' TEXT  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'status' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "ddttbl" (
	"id"	INTEGER,
	"ship_id"	integer,
	"draft"	REAL,
	"trim"	REAL,
	"value"	REAL,
	"created_at"	integer,
	"updated_at"	integer,
	PRIMARY KEY("id"),
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE 'decktbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'nama' TEXT  ,
'image' TEXT  ,
'koordinat' TEXT  ,
'deflcg' REAL  DEFAULT 0.00 ,
'defvcg' REAL  DEFAULT 0.00 ,
'deftcg' REAL  DEFAULT 0.00 ,
'created_at' integer  ,
'updated_at' integer  ,
'object3d' TEXT  ,
'panjang' REAL  ,
'lebar' REAL  ,
'tinggi' REAL  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE deckxpropertytbl (id INTEGER,deck_id INTEGER,x REAL,z REAL);
CREATE TABLE deckypropertytbl (id INTEGER,deck_id INTEGER,y REAL,z REAL);
CREATE TABLE deletedtbl (
            id	INTEGER,
            table_name	TEXT,
            table_id	integer,
            created_at	integer,
            PRIMARY KEY(id)
        );
CREATE TABLE 'dfpointtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'x' REAL  ,
'y' REAL  ,
'z' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'dftbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'dfpoint_id' INTEGER  ,
'draft' REAL  ,
'value' REAL  ,
'trim' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(dfpoint_id) REFERENCES dfpointtbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'dg_classtbl' (
 'id' INTEGER NOT NULL ,
'class' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE 'dg_divisiontbl' (
 'id' INTEGER NOT NULL ,
'dg_class_id' INTEGER  ,
'division' TEXT  ,
'classification' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE 'dg_listtbl' (
 'id' INTEGER NOT NULL ,
'dg_division_id' INTEGER  ,
'unnumber' TEXT  ,
'packinggroup' TEXT  ,
'psn' TEXT  ,
'mp' TEXT  ,
'classdiv' TEXT  ,
'hazard' TEXT  ,
'special_provision' TEXT  ,
'limitetd_quantities' TEXT  ,
'excepted_quantities' TEXT  ,
'emergency_schedule' TEXT  ,
'ins_packing' TEXT  ,
'ins_ibcs' TEXT  ,
'ins_tanks' TEXT  ,
'prov_packing' TEXT  ,
'prov_ibcs' TEXT  ,
'prov_tanks' TEXT  ,
'stow_handling' TEXT  ,
'segregation' TEXT  ,
'prop_obsevation' TEXT  ,
'label' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE "dg_segregation_containertbl" (
	"id"	INTEGER,
	"segregation_type"	INTEGER,
	"inhold"	INTEGER,
	"orientation"	TEXT,
	"container_versus"	TEXT,
	"restriction"	TEXT,
	"separator"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "dg_segregationtbl" (
	"id"	INTEGER,
	"dg_division_id1"	INTEGER,
	"dg_division_id2"	INTEGER,
	"type"	INTEGER,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "dg_segregationtypetbl" (
	"id"	INTEGER,
	"name"	TEXT,
	"details"	TEXT,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE 'dipointtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'x' REAL  ,
'y' REAL  ,
'z' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'ditbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'dipoint_id' INTEGER  ,
'draft' REAL  ,
'value' REAL  ,
'trim' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(dipoint_id) REFERENCES dipointtbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE draftsurveytbl (id INTEGER,plan_id INTEGER,initial TEXT,final TEXT,created_at INTEGER,updated_at INTEGER);
CREATE TABLE "gzdamagetbl" (
	"plan_id"	integer,
	"damagecase_id" integer,
	"gz"	TEXT,
	"sin"	TEXT,
	"ggsin"	TEXT,
	"gz2"	TEXT,
	"created_at"	integer,
	"updated_at"	integer,
	"type"	TEXT
);
CREATE TABLE "gztbl" (
	"id"	INTEGER,
	"plan_id"	integer NOT NULL UNIQUE,
	"angle"	TEXT,
	"sinT"	TEXT,
	"base"	TEXT,
	"param"	TEXT,
	"value"	TEXT,
	"created_at"	integer,
	"updated_at"	integer,
	"type"	TEXT,
	PRIMARY KEY("id")
);
CREATE TABLE 'i_gztbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'displ' REAL  ,
'data1' REAL  ,
'data2' REAL  ,
'data3' REAL  ,
'data4' REAL  ,
'data5' REAL  ,
'data6' REAL  ,
'data7' REAL  ,
'data8' REAL  ,
'data9' REAL  ,
'trim' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'i_tanktbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'tank_id' integer  ,
'sounding' REAL  ,
'volume' REAL  ,
'lcg' REAL  ,
'tcg' REAL  ,
'ullage' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'area' REAL  ,
'vcg' REAL  ,
'inertia' REAL  ,
'global_id' INTEGER, trim REAL, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "imodamagetbl" (
	"id"	INTEGER,
	"plan_id"	integer,
	"damagecase_id"	integer,
	"imo1"	TEXT,
	"imo2"	TEXT,
	"imo3"	TEXT,
	"imo4"	TEXT,
	"imo5"	TEXT,
	"imo6"	TEXT,
	"imo7"	TEXT,
	"imo8"	TEXT,
	"imo9"	TEXT,
	"created_at"	integer,
	"updated_at"	integer,
	"type"	TEXT,
	PRIMARY KEY("id")
);
CREATE TABLE "imotbl" (
	"id"	INTEGER,
	"plan_id"	integer NOT NULL UNIQUE,
	"l30"	REAL,
	"l40"	REAL,
	"l3040"	REAL,
	"igm"	REAL,
	"maxgz"	REAL,
	"maxgzangle"	REAL,
	"maxinangle"	REAL,
	"weather"	REAL,
	"visibility"	REAL,
	"type"	REAL,
	"lw1"	REAL,
	"lw2"	REAL,
	"a"	REAL,
	"z"	REAL,
	"t0"	REAL,
	"t1"	REAL,
	"t1t0"	REAL,
	"df"	REAL,
	"area_a"	REAL,
	"area_b"	REAL,
	"di"	REAL,
	"created_at"	integer,
	"updated_at"	integer,
	PRIMARY KEY("id")
);
CREATE TABLE 'inflowtbl' (
 'id' INTEGER NOT NULL ,
'plan_id' INTEGER  ,
'damagecase_id' INTEGER  ,
'tank_id' INTEGER  ,
'prosen' INTEGER  ,
'maxcap' INTEGER  ,
'weight' INTEGER  ,
'lcg' INTEGER  ,
'vcg' INTEGER  ,
'tcg' INTEGER  ,
'inertia' INTEGER  ,
'density' INTEGER  ,
'created_at' INTEGER  ,
'ullage' INTEGER  ,
'updated_at' INTEGER  ,
'type' TEXT  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(damagecase_id) REFERENCES damagecasetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'infotbl' (
 'id' INTEGER NOT NULL ,
'param' TEXT  ,
'val' TEXT  ,
'ship_id' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER,
'created_at' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'intacttbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'draft' REAL  ,
'displ' REAL  ,
'midb' REAL  ,
'midf' REAL  ,
'mtc' REAL  ,
'tpc' REAL  ,
'kb' REAL  ,
'tkm' REAL  ,
'lkm' REAL  ,
'wpa' REAL  ,
'mida' REAL  ,
'wsa' REAL  ,
'cb' REAL  ,
'cp' REAL  ,
'cw' REAL  ,
'cm' REAL  ,
'trim' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'tcb' REAL  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'iso_containertbl' (
 'id' INTEGER NOT NULL ,
'iso' TEXT  ,
'size' TEXT  ,
'type' TEXT  ,
'length' INTEGER  ,
'height' INTEGER  ,
'width' INTEGER  ,
'description' TEXT  ,
'containertype_id' INTEGER  ,
'containersize_id' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(containertype_id) REFERENCES containertypetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(containersize_id) REFERENCES containersizetbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "kendaraanareatbl" (
	"id"	INTEGER NOT NULL,
	"deck_id"	INTEGER,
	"coordinate"	TEXT,
	"kendaraantypes"	TEXT,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	FOREIGN KEY("deck_id") REFERENCES "decktbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE kendaraanmovetbl (id INTEGER,kendaraanplan_id INTEGER,x REAL,y REAL,undo_at INTEGER);
CREATE TABLE 'kendaraanplantbl' (
 'id' INTEGER NOT NULL ,
'plan_id' integer  ,
'kendaraan_id' integer  ,
'deck_id' integer  ,
'x' REAL  DEFAULT 0.00 ,
'y' REAL  DEFAULT 0.00 ,
'lcg' REAL  DEFAULT 0.00 ,
'vcg' REAL  DEFAULT 0.00 ,
'tcg' REAL  DEFAULT 0.00 ,
'global_id' integer  ,
'status' INTEGER  ,
'rotate' REAL  ,
'created_at' integer  ,
'updated_at' integer  , 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(kendaraan_id) REFERENCES kendaraantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(deck_id) REFERENCES decktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "kendaraantbl" (
	"id"	INTEGER NOT NULL,
	"voyage_id"	integer,
	"kendaraantype_id"	integer,
	"nopol"	TEXT,
	"addharga"	integer,
	"panjang"	REAL DEFAULT 0.00,
	"lebar"	REAL DEFAULT 0.00,
	"tinggi"	REAL DEFAULT 0.00,
	"berat"	REAL DEFAULT 0.00,
	"muatan"	REAL DEFAULT 0.00,
	"lcg"	REAL DEFAULT 0.00,
	"vcg"	REAL DEFAULT 0.00,
	"tcg"	REAL DEFAULT 0.00,
	"created_at"	integer,
	"updated_at"	integer,
	"global_id"	integer,
	"status"	INTEGER,
	"loadport_id"	integer,
	"dischport_id"	integer,
	"shiploadtype_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("kendaraantype_id") REFERENCES "kendaraantypetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("loadport_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("dischport_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("voyage_id") REFERENCES "voyagetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE 'kendaraantypetbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'nama' TEXT  ,
'image' TEXT  ,
'harga' integer  ,
'defpanjang' REAL  DEFAULT 0.00 ,
'deflebar' REAL  DEFAULT 0.00 ,
'deftinggi' REAL  DEFAULT 0.00 ,
'defberat' REAL  DEFAULT 0.00 ,
'deflcg' REAL  DEFAULT 0.00 ,
'defvcg' REAL  DEFAULT 0.00 ,
'deftcg' REAL  DEFAULT 0.00 ,
'model3d' TEXT  ,
'stackable' INTEGER  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, ev INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'limitingtbl' (
 'id' INTEGER NOT NULL ,
'plan_id' INTEGER  ,
'damagecase_id' INTEGER  ,
'draft' REAL  ,
'value' REAL  ,
'value_actual' REAL  ,
'volume' REAL  ,
'weight' REAL  ,
'wfr' REAL  ,
'sg' REAL  ,
'graph' TEXT  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(damagecase_id) REFERENCES damagecasetbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'logintbl' (
 'id' INTEGER NOT NULL ,
'username' TEXT  ,
'password' TEXT  ,
'ship_id' integer  ,
'usertype' integer  ,
'status' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "longstrtbl" (
	"id"	INTEGER UNIQUE,
	"plan_id"	integer UNIQUE,
	"frame"	TEXT,
	"x"	TEXT,
	"station"	TEXT,
	"sf"	TEXT,
	"bm"	TEXT,
	"maxsf"	TEXT,
	"minsf"	TEXT,
	"maxbm"	TEXT,
	"minbm"	TEXT,
	"buoyancy"	TEXT,
	"mass"	TEXT,
	"type"	INTEGER,
	"created_at"	integer,
	"updated_at"	integer,
	PRIMARY KEY("id")
);
CREATE TABLE 'lwttbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'lever' REAL  ,
'value' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "muatantbl" (
	"id"	INTEGER NOT NULL,
	"muatantype_id"	INTEGER,
	"name"	TEXT,
	"voyage_id"	TEXT,
	"length"	INTEGER,
	"width"	INTEGER,
	"height"	INTEGER,
	"weight"	INTEGER,
	"lcg"	INTEGER,
	"tcg"	INTEGER,
	"vcg"	INTEGER,
	"loadport_id"	INTEGER,
	"dischport_id"	INTEGER,
	"comodity"	TEXT,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"status"	INTEGER,
	"global_id"	INTEGER,
	FOREIGN KEY("voyage_id") REFERENCES "voyagetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("muatantype_id") REFERENCES "muatantypetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "muatantypetbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	integer,
	"name"	INTEGER,
	"image"	TEXT,
	"model3d"	TEXT,
	"length"	REAL DEFAULT 0.00,
	"width"	REAL DEFAULT 0.00,
	"height"	REAL DEFAULT 0.00,
	"lcg"	REAL DEFAULT 0.00,
	"vcg"	REAL DEFAULT 0.00,
	"tcg"	REAL DEFAULT 0.00,
	"stackable"	INTEGER,
	"created_at"	integer,
	"updated_at"	integer,
	"global_id"	INTEGER,
	"status"	INTEGER DEFAULT 1,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE 'offsettbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'lever' REAL  ,
'wl' REAL  ,
'value' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'operatortbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT NOT NULL  ,
'pathlogo' TEXT  ,
'info' TEXT  ,
'code' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE 'outflowtbl' (
 'id' INTEGER NOT NULL ,
'plan_id' INTEGER  ,
'damagecase_id' INTEGER  ,
'tank_id' INTEGER  ,
'prosen' INTEGER  ,
'maxcap' INTEGER  ,
'weight' INTEGER  ,
'lcg' INTEGER  ,
'vcg' INTEGER  ,
'tcg' INTEGER  ,
'inertia' INTEGER  ,
'density' INTEGER  ,
'created_at' INTEGER  ,
'ullage' INTEGER  ,
'updated_at' INTEGER  ,
'type' TEXT  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(damagecase_id) REFERENCES damagecasetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'ownertbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT NOT NULL  ,
'pathlogo' TEXT  ,
'info' TEXT  ,
'status' integer  ,
'code' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE "penumpangclasstbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	integer,
	"name"	TEXT,
	"capacity"	integer,
	"lcg"	REAL,
	"vcg"	REAL,
	"tcg"	REAL,
	"created_at"	integer,
	"updated_at"	integer,
	"global_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE "penumpangtbl" (
	"id"	INTEGER NOT NULL,
	"count"	integer DEFAULT 1,
	"penumpangtype_id"	integer,
	"penumpangclass_id"	INTEGER,
	"voyage_id"	integer,
	"loadport_id"	integer,
	"dischport_id"	integer,
	"status"	INTEGER DEFAULT 1,
	"global_id"	integer,
	"created_at"	integer,
	"updated_at"	integer,
	FOREIGN KEY("loadport_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("dischport_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("voyage_id") REFERENCES "voyagetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("penumpangtype_id") REFERENCES "penumpangtypetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("penumpangclass_id") REFERENCES "penumpangclasstbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "penumpangtypetbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	integer,
	"name"	TEXT,
	"weight"	REAL DEFAULT 0.00,
	"created_at"	integer,
	"updated_at"	integer,
	"global_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE "plancargotbl" (
	"id"	INTEGER,
	"cargotype_id"	INTEGER,
	"tankplan_id"	INTEGER,
	"temp"	REAL,
	"vcf"	REAL,
	"gsv"	REAL,
	"barrels"	REAL,
	"longton"	REAL,
	"mton"	REAL,
	"created_at"	integer DEFAULT (strftime('%s','now')),
	"updated_at"	integer DEFAULT (strftime('%s','now')),
	FOREIGN KEY("cargotype_id") REFERENCES "cargotypetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("tankplan_id") REFERENCES "tankplantbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE plancontaineroogtbl (id INTEGER,plan_container_id INTEGER,plan_id INTEGER,is_portside INTEGER,is_starboard INTEGER,is_fore INTEGER,is_aft INTEGER,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE 'plancontainertbl' (
 'id' INTEGER NOT NULL ,
'container_id' INTEGER  ,
'plan_id' INTEGER  ,
'bay_id' INTEGER  ,
'tier_id' INTEGER  ,
'row_id' INTEGER  ,
'lcg' INTEGER  ,
'vcg' INTEGER  ,
'tcg' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'status' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(container_id) REFERENCES containertbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "planmuatantbl" (
	"id"	INTEGER NOT NULL,
	"muatan_id"	INTEGER,
	"plan_id"	INTEGER,
	"deck_id"	INTEGER,
	"x"	REAL,
	"y"	REAL,
	"z"	REAL,
	"lcg"	REAL,
	"vcg"	REAL,
	"tcg"	REAL,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"status"	INTEGER,
	"global_id"	INTEGER,
	"rotate"	REAL DEFAULT 0.0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("deck_id") REFERENCES "decktbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("plan_id") REFERENCES "plantbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("muatan_id") REFERENCES "muatantbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE "plantbl" (
	"id"	INTEGER NOT NULL,
	"voyage_id"	integer,
	"port_id"	integer,
	"urutan"	integer,
	"status"	integer,
	"template_id"	integer,
	"created_at"	integer,
	"updated_at"	integer,
	"global_id"	integer,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("voyage_id") REFERENCES "voyagetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("port_id") REFERENCES "voyageporttbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE 'plantemptbl' (
 'id' INTEGER NOT NULL ,
'template_id' integer  ,
'urutan' integer  ,
'status' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' integer  , 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(template_id) REFERENCES templatetbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "porttbl" (
	"id"	INTEGER NOT NULL,
	"name"	TEXT,
	"shortname"	TEXT,
	"created_at"	integer,
	"updated_at"	integer,
	"status"	INTEGER,
	"isocode"	TEXT,
	"country_id"	TEXT,
	"global_id"	INTEGER,
	FOREIGN KEY("country_id") REFERENCES "countrytbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE 'rowstbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'name' TEXT  ,
'basetcg' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'ruangplantbl' (
 'id' INTEGER NOT NULL ,
'plan_id' integer  ,
'ruang_id' integer  ,
'jumlah' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' integer  , 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(ruang_id) REFERENCES ruangtbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'ruangtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'nama' TEXT  ,
'kapasitas' integer  ,
'deflcg' REAL  DEFAULT 0.00 ,
'defvcg' REAL  DEFAULT 0.00 ,
'deftcg' REAL  DEFAULT 0.00 ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE scenariocontainerplantbl (id INTEGER,ship_id INTEGER,plan_id INTEGER,name TEXT,data TEXT,created_at INTEGER,updated_at INTEGER,output TEXT,global_id INTEGER);
CREATE TABLE scenariomuatanplantbl (id INTEGER,ship_id INTEGER,plan_id INTEGER,name TEXT,data TEXT,output TEXT,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE 'segregation_typetbl' (
	'id' INTEGER NOT NULL ,
	'name' TEXT  ,
	'details' TEXT  ,
	'created_at' integer  ,
	'updated_at' integer  ,
	'global_id' INTEGER, 
	PRIMARY KEY(id AUTOINCREMENT) 
 );
CREATE TABLE "segregationtbl" (
	"id"	INTEGER NOT NULL,
	"dg_division_id1"	INTEGER,
	"dg_division_id2"	INTEGER,
	"type"	INTEGER,
	"created_at"	integer,
	"updated_at"	integer,
	"global_id"	INTEGER,
	FOREIGN KEY("type") REFERENCES "segregation_typetbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("dg_division_id2") REFERENCES "dg_divisiontbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("dg_division_id1") REFERENCES "dg_divisiontbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "sequencetbl" (
	"id"	INTEGER,
	"plan_id"	INTEGER,
	"label"	TEXT,
	"active"	INTEGER DEFAULT 1,
	"data"	TEXT,
	"global_id"	INTEGER,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	FOREIGN KEY("plan_id") REFERENCES "plantbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE sheartbl (id INTEGER,ship_id INTEGER,lever REAL,value REAL,created_at INTEGER,updated_at INTEGER,global_id INTEGER);
CREATE TABLE "ship3dtbl" (
	"id"	INTEGER,
	"ship_id"	INTEGER,
	"length"	REAL,
	"width"	REAL,
	"height"	REAL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE 'shiploadtypetbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'name' TEXT  ,
'image' TEXT  ,
'stackable' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "shipparamtbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	integer NOT NULL UNIQUE,
	"lwt"	REAL,
	"lcg"	REAL,
	"vcg"	REAL,
	"tcg"	REAL,
	"loa"	REAL,
	"lpp"	REAL,
	"b"	REAL,
	"h"	REAL,
	"height_overall"	REAL,
	"assume_kg"	REAL,
	"lp"	REAL,
	"dp"	REAL,
	"hp"	REAL,
	"lwl"	REAL,
	"ptc"	REAL,
	"trim"	TEXT,
	"trim_kn"	TEXT,
	"lwt_2"	REAL,
	"lcg_2"	REAL,
	"kg_2"	REAL,
	"bl_figure"	REAL,
	"cargotype_id"	TEXT,
	"offset"	REAL,
	"dapt"	NUMERIC,
	"haft"	REAL,
	"hfore"	REAL,
	"dnav"	REAL,
	"created_at"	integer,
	"updated_at"	integer,
	"knms"	TEXT,
	"calc"	TEXT,
	"report"	TEXT,
	"loads"	TEXT,
	"angle_gz"	TEXT,
	"bilgekeel"	REAL,
	"height"	REAL,
	"global_id"	INTEGER,
	"rho"	REAL DEFAULT 1.025,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE 'shiptbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT  ,
'origname' TEXT  ,
'imonumber' TEXT  ,
'class_id' integer  ,
'owner_id' integer  ,
'operator_id' integer  ,
'shiptype_id' integer  ,
'pathconfig' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'status' INTEGER  DEFAULT 1 ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(class_id) REFERENCES classtbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(owner_id) REFERENCES ownertbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(operator_id) REFERENCES operatortbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(shiptype_id) REFERENCES shiptypetbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'shiptypetbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT NOT NULL  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE "slottbl" (
	"id"	INTEGER NOT NULL,
	"ship_id"	INTEGER,
	"bay_id"	INTEGER,
	"row_id"	INTEGER,
	"tier_id"	INTEGER,
	"o_blcg"	REAL,
	"o_bvcg"	REAL,
	"o_btcg"	REAL,
	"rotated"	INTEGER,
	"created_at"	INTEGER,
	"updated_at"	INTEGER,
	"global_id"	INTEGER,
	"status"	INTEGER,
	"reefer_plug"	INTEGER,
	"oog"	INTEGER,
	FOREIGN KEY("tier_id") REFERENCES "tierstbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("ship_id") REFERENCES "shiptbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("bay_id") REFERENCES "baystbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("row_id") REFERENCES "rowstbl"("id") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE 'soundingcorrtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'tank_id' INTEGER  ,
'sounding' REAL  ,
'ullage' REAL  ,
'volume' REAL  ,
'diff' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, trim REAL, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'specialslottbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'bay_id' INTEGER  ,
'row_id' INTEGER  ,
'tier_id' INTEGER  ,
'specialslottype_id' INTEGER  ,
'isreefer' INTEGER  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(specialslottype_id) REFERENCES specialslottypetbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'specialslottypetbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'name' TEXT  ,
'size_container' TEXT  ,
'type_container' TEXT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE "stabdamagetbl" (
	"plan_id"	integer,
	"damagecase_id" integer,
	"displ"	REAL,
	"draft"	REAL,
	"fore"	REAL,
	"aft"	REAL,
	"mean"	REAL,
	"trim"	REAL,
	"lcg"	REAL,
	"lcb"	REAL,
	"bg"	REAL,
	"lcf"	REAL,
	"mtc"	REAL,
	"ld"	REAL,
	"tkm"	REAL,
	"kg"	REAL,
	"gm"	REAL,
	"ggo"	REAL,
	"gom"	REAL,
	"kgo"	REAL,
	"rp"	REAL,
	"tpc"	REAL,
	"type"	TEXT,
	"created_at"	integer,
	"updated_at"	integer
, heel REAL, tcg REAL);
CREATE TABLE "stabtbl" (
	"id"	INTEGER,
	"plan_id"	INTEGER NOT NULL UNIQUE,
	"displ"	REAL,
	"draft"	REAL,
	"fore"	REAL,
	"aft"	REAL,
	"mean"	REAL,
	"trim"	REAL,
	"lcg"	REAL,
	"lcb"	REAL,
	"bg"	REAL,
	"lcf"	REAL,
	"mtc"	REAL,
	"ld"	REAL,
	"tkm"	REAL,
	"kg"	REAL,
	"gm"	REAL,
	"ggo"	REAL,
	"gom"	REAL,
	"kgo"	REAL,
	"rp"	REAL,
	"tpc"	REAL,
	"type"	TEXT,
	"created_at"	integer,
	"updated_at"	integer,
	"tcg"	REAL,
	"heel"	REAL,
	"kb"	REAL,
	"gml"	REAL,
	"tcb"	REAL,
	"fore_m"	REAL,
	"aft_m"	REAL,
	"mean_m"	REAL,
	PRIMARY KEY("id")
);
CREATE TABLE 'swtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'bay_id' INTEGER  ,
'max20' REAL  ,
'max40' REAL  ,
'inhold' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tank2dtbl' (
 'id' INTEGER NOT NULL ,
'cargoview_id' INTEGER  ,
'tank_id' INTEGER  ,
'coordinate' TEXT  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(cargoview_id) REFERENCES cargoview(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tank3dtbl' (
 'id' INTEGER NOT NULL ,
'filename' TEXT  ,
'x' REAL  ,
'y' REAL  ,
'z' REAL  ,
'height' REAL  ,
'tank_id' INTEGER  ,
'coordinate' INTEGER  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tankplancargotypetbl' (
 'id' INTEGER NOT NULL ,
'cargotype_id' INTEGER  ,
'tankplan_id' INTEGER  ,
'temp' REAL  ,
'vcf' REAL  ,
'gsv' REAL  ,
'barrels' REAL  ,
'longton' REAL  ,
'mton' REAL  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'global_id' INTEGER, plan_id INTEGER, tank_id INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(tankplan_id) REFERENCES tankplantbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tankplantbl' (
 'id' INTEGER NOT NULL ,
'plan_id' INTEGER  ,
'tank_id' INTEGER  ,
'maxcap' REAL  ,
'weight' REAL  ,
'lcg' REAL  ,
'vcg' REAL  ,
'tcg' REAL  ,
'inertia' REAL  ,
'density' REAL  ,
'created_at' INTEGER  ,
'ullage' REAL  ,
'updated_at' INTEGER  ,
'type' TEXT  ,
'percent' REAL  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(plan_id) REFERENCES plantbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tanktbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT  ,
'tanktype' integer  ,
'ship_id' integer  ,
'editable' integer  ,
'maxcap' REAL  ,
'defdensity' REAL  ,
'panjang' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'hdb' REAL  ,
'maxullage' REAL  ,
'perm' REAL  ,
'x1' REAL  ,
'x2' REAL  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tanktemptbl' (
 'id' INTEGER NOT NULL ,
'template_id' integer  ,
'tank_id' integer  ,
'percent' REAL  ,
'maxcap' REAL  ,
'weight' REAL  ,
'lcg' REAL  ,
'vcg' REAL  ,
'tcg' REAL  ,
'inertia' REAL  ,
'density' REAL  ,
'fsm' REAL  ,
'ullage' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' integer  ,
'type' TEXT  , 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(template_id) REFERENCES templatetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tank_id) REFERENCES tanktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tanktypetbl' (
 'id' INTEGER NOT NULL ,
'name' TEXT  ,
'urutan' integer  ,
'urutlaporan' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
  );
CREATE TABLE 'templatetbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'name' TEXT  ,
'status' INT  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'tierstbl' (
 'id' INTEGER NOT NULL ,
'ship_id' INTEGER  ,
'name' TEXT  ,
'inhold' TEXT  ,
'basevcg' INTEGER  ,
'maxhigh' INTEGER  ,
'path' TEXT  ,
'breakbulk' INTEGER  ,
'specialdeck' INTEGER  ,
'overwrite' TEXT  ,
'created_at' INTEGER  ,
'updated_at' INTEGER  ,
'p' REAL  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'troopstbl' (
 'id' INTEGER NOT NULL ,
'voyage_id' INTEGER  ,
'amount' INTEGER  ,
'status' INTEGER  ,
'loadport_id' integer  ,
'dischport_id' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'deck_id' INTEGER  ,
'weight' REAL  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(voyage_id) REFERENCES voyagetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(deck_id) REFERENCES decktbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'voyageporttbl' (
 'id' INTEGER NOT NULL ,
'voyage_id' integer  ,
'port_from_id' integer  ,
'eta' integer  ,
'etd' integer  ,
'port_dest_id' INTEGER  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' integer  ,
'status' INTEGER  , 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(voyage_id) REFERENCES voyagetbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(port_from_id) REFERENCES porttbl(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(port_dest_id) REFERENCES porttbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE 'voyagetbl' (
 'id' INTEGER NOT NULL ,
'nomor' TEXT  ,
'ship_id' integer  ,
'etd' integer  ,
'created_at' integer  ,
'updated_at' integer  ,
'global_id' integer  ,
'status' INTEGER  , 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
CREATE TABLE wcftbl (id INTEGER,density REAL,value REAL,astm_id INTEGER,created_at INTEGER,updated_at INTEGER);
CREATE TABLE 'windtbl' (
 'id' INTEGER NOT NULL ,
'ship_id' integer  ,
'wl' REAL  ,
'underwl' REAL  ,
'windpres' REAL  ,
'dist' REAL  ,
'created_at' integer  ,
'updated_at' integer  ,
'tier_id' INTEGER  ,
'global_id' INTEGER, 
 PRIMARY KEY(id AUTOINCREMENT) 
 ,FOREIGN KEY(ship_id) REFERENCES shiptbl(id) ON UPDATE CASCADE ON DELETE CASCADE );
