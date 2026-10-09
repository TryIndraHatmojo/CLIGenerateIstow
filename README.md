# istow-cli

Console Qt C++17 exporter for the legacy iStow `.istow` format. The executable
uses Qt Core/SQL and zlib; it does not load QML, a GUI, or the desktop home folder.
Source references: `C:/Pranala/ship-configure/Core/Tools/tools.cpp`,
`Core/ship.cpp`, `Repository/localrepository.cpp`, and the schema-only baseline
from `res/db/container.db`.

## Build

Requirements: CMake 3.24+, Qt 6.8+ Core/SQL with QSQLITE, C++17 compiler,
Ninja, and zlib. Tests additionally use Qt Test and Python 3.12. Release baseline
tested locally: Windows x64, Qt **6.10.1**, MinGW **13.1**, zlib verifier **1.3.1**.
If system zlib is absent, CMake fetches the pinned source with a SHA-256 check.

```powershell
$env:PATH = 'C:\Qt2\Tools\mingw1310_64\bin;C:\Qt2\6.10.1\mingw_64\bin;C:\Qt2\Tools\CMake_64\bin;' + $env:PATH
cmake --preset release -DCMAKE_PREFIX_PATH=C:/Qt2/6.10.1/mingw_64 -DCMAKE_C_COMPILER=C:/Qt2/Tools/mingw1310_64/bin/gcc.exe -DCMAKE_CXX_COMPILER=C:/Qt2/Tools/mingw1310_64/bin/g++.exe
cmake --build --preset release
ctest --preset release
```

On Linux use the same presets with `-DCMAKE_PREFIX_PATH=/opt/Qt/6.10.1/gcc_64`.
Set the prefix to the actual SDK installation directory. No display variables
or `QT_QPA_PLATFORM` are needed. Qt Creator can open the root CMake project;
select the `istow-cli` run target and supply CLI arguments.

## Commands

```powershell
.\build-cli\istow-cli.exe --version
.\build-cli\istow-cli.exe export --manifest C:/staging/request.json --input-dir C:/staging/input --output C:/staging/output/ship.istow --format legacy-v1 --json
.\build-cli\istow-cli.exe verify --archive C:/staging/output/ship.istow --format legacy-v1 --json
```

Prepare an immutable SQLite snapshot with the canonical basename, and enumerate
all assets in the manifest. See [example manifest](examples/request.json) and
[archive contract](docs/archive-contract.md). Output parent must already exist,
must be outside input, and output must not exist. Export verifies every payload
hash before reporting success. Verify inspects the stream without extracting it.

Defaults are 256 MiB per entry, 1 GiB total payload, and 4,096 entries. Override
with `--max-file-bytes`, `--max-total-bytes`, `--max-entries` from worker
configuration. These are provisional development bounds, not a measured
production concurrency recommendation.

## Laravel example and status

The [Laravel 12 integration](docs/laravel-integration.md) includes a service,
queue job, tracking model/migration, policies, status/download routes, immutable
revision staging using SQLite Backup API, and retention cleanup.

```powershell
cd examples/laravel
composer install
$env:ISTOW_TEST_BINARY = 'C:\Pranala\CLIGenerateIstow\build-cli\istow-cli.exe'
composer test
```

The example Ship model and `istow_revision` field must be adapted to the target
application. SQLite construction from a web application's data is outside this
MVP; it requires that application's actual schema and data mapping.

See [compatibility and acceptance](docs/compatibility-matrix.md),
[deployment](docs/deployment.md), and [implementation status](docs/implementation-status.md).
Desktop import acceptance and clean Linux machine verification remain external
checks; automated tests establish stream/payload compatibility with the source
code pattern, not complete operational desktop acceptance.

Graphify outputs live in `graphify-out/`; `graphify update .` refreshes code
relationships after edits. Documentation changes require semantic extraction
through the Graphify skill.
