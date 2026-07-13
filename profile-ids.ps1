$ProfilesBase = Join-Path $env:APPDATA "Code\User\profiles"
$Db = Join-Path $env:APPDATA "Code\User\globalStorage\state.vscdb"

if (!(Test-Path $ProfilesBase)) {
    Write-Host "[ERR:] No VS Code profiles directory found: $ProfilesBase"
    exit 1
}

if (!(Test-Path $Db)) {
    Write-Host "[ERR:] No VS Code state DB found: $Db"
    exit 1
}

Write-Host "[INF:] Reading VS Code profile metadata..."
Write-Host ""

$sql = @"
SELECT value
FROM ItemTable
WHERE key = 'userDataProfiles';
"@

$json = sqlite3 $Db $sql

if (!$json) {
    Write-Host "[ERR:] Nothing found with key 'userDataProfiles'"
    exit 1
}

$profiles = $json | ConvertFrom-Json

$profileDirs = Get-ChildItem $ProfilesBase -Directory

foreach ($dir in $profileDirs) {
    $match = $profiles | Where-Object { $_.id -eq $dir.Name }

    Write-Host ""
    Write-Host "[INF:] ID:   $($dir.Name)"
    Write-Host "[INF:] Name: $($match.name)"
    Write-Host "[INF:] Path: $($dir.FullName)"
}