#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProfileName = "python-lang"

$TextExtensionsFile = Join-Path $ScriptDir "extensions.txt"
$JsonExtensionsFile = Join-Path $ScriptDir "extensions.json"

if ((Test-Path $TextExtensionsFile) -and ((Get-Item $TextExtensionsFile).Length -gt 0)) {
    $ExtensionsFile = $TextExtensionsFile
    $ExtensionsFormat = "text"
}
elseif (Test-Path $JsonExtensionsFile) {
    $ExtensionsFile = $JsonExtensionsFile
    $ExtensionsFormat = "json"
}
else {
    Write-Error "No extensions file found. Expected a non-empty '$TextExtensionsFile' or '$JsonExtensionsFile'."
    exit 1
}

Write-Host "[INFO:] Reading extensions from $ExtensionsFile"

if ($ExtensionsFormat -eq "text") {
    $PkgList = Get-Content $ExtensionsFile |
        Where-Object { $_.Trim() -ne "" }
        Set-Content $JsonExtensionsFile "[]"
}
else {
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Error "VS Code CLI 'code' was not found in PATH."
        exit 1
    }

    $PkgList = Get-Content $ExtensionsFile -Raw |
        ConvertFrom-Json |
        ForEach-Object { $_.identifier.id }
}

if (-not $PkgList -or $PkgList.Count -eq 0) {
    Write-Error "No extension IDs were found in '$ExtensionsFile'."
    exit 1
}

Write-Host "[INFO:] Creating VS Code profile: $ProfileName"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code CLI 'code' was not found in PATH."
    exit 1
}

code --profile $ProfileName

foreach ($ExtensionId in $PkgList) {
    if ([string]::IsNullOrWhiteSpace($ExtensionId)) {
        continue
    }

    Write-Host "[INFO:] Installing extension into profile '$ProfileName': $ExtensionId"
    code --profile $ProfileName --install-extension $ExtensionId
}

Write-Host "[INFO:] Finished installing extensions for profile '$ProfileName'"