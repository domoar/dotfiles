# --- Symlink PowerShell Modules ---
Write-Host "Creating symlinks for PowerShell modules..."

# The base path to your dotfiles
$dotfilesRoot = $PSScriptRoot

$psModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules"

# Ensure the base modules directory exists
if (-not (Test-Path $psModulePath)) {
    New-Item -Path $psModulePath -ItemType Directory -Force
}

# --- utils module ---
$moduleName = "utils"
$moduleDir = Join-Path $psModulePath $moduleName
$sourceFile = Join-Path $dotfilesRoot "pwsh\modules\utils.psm1"
$destFile = Join-Path $moduleDir "utils.psm1"

# Create the module directory if it doesn't exist
if (-not (Test-Path $moduleDir)) {
    New-Item -Path $moduleDir -ItemType Directory -Force
}

# Create the symlink for the module file
if (-not (Test-Path $destFile)) {
    New-Item -ItemType SymbolicLink -Path $destFile -Target $sourceFile
    Write-Host "  - Symlinked $moduleName module."
} else {
    Write-Host "  - Symlink for $moduleName module already exists."
}

Write-Host "PowerShell module symlinking complete."
