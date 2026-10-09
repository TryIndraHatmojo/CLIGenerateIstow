param(
    [Parameter(Mandatory=$true)][string]$QtRoot,
    [Parameter(Mandatory=$true)][string]$CompilerBin,
    [string]$BuildDirectory = 'build-cli',
    [string]$Destination = 'dist/windows'
)
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath "$PSScriptRoot\..").Path
$binary = (Resolve-Path -LiteralPath (Join-Path $BuildDirectory 'istow-cli.exe')).Path
$target = [IO.Path]::GetFullPath((Join-Path $taskRoot $Destination))
if (-not $target.StartsWith($taskRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Package destination must stay inside this workspace.' }
if (Test-Path -LiteralPath $target) { throw 'Package destination already exists; choose a new empty destination.' }
New-Item -ItemType Directory -Path "$target\sqldrivers" -Force | Out-Null
Copy-Item -LiteralPath $binary -Destination $target
foreach ($dll in @('Qt6Core.dll', 'Qt6Sql.dll')) {
    Copy-Item -LiteralPath (Join-Path $QtRoot "bin\$dll") -Destination $target
}
Copy-Item -LiteralPath (Join-Path $QtRoot 'plugins\sqldrivers\qsqlite.dll') -Destination "$target\sqldrivers"
foreach ($dll in @('libgcc_s_seh-1.dll', 'libstdc++-6.dll', 'libwinpthread-1.dll')) {
    Copy-Item -LiteralPath (Join-Path $CompilerBin $dll) -Destination $target
}
[IO.File]::WriteAllText("$target\qt.conf", "[Paths]`nPlugins=.`n", [Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath (Join-Path $taskRoot 'docs\third-party-notices.md') -Destination $target
$version = & "$target\istow-cli.exe" --version | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Packaged executable failed version smoke test.' }
$hash = (Get-FileHash -LiteralPath "$target\istow-cli.exe" -Algorithm SHA256).Hash.ToLowerInvariant()
$version | Add-Member -NotePropertyName binary_sha256 -NotePropertyValue $hash
$version | Add-Member -NotePropertyName platform -NotePropertyValue 'windows-x86_64-mingw'
$version | ConvertTo-Json | Set-Content -LiteralPath "$target\release.json" -Encoding UTF8
Write-Output "Package ready: $target"
