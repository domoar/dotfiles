function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Message,

        [ValidateSet('TRC', 'DBG', 'INF', 'WRN', 'ERR', 'CRI')]
        [string]$LogLevel = 'INF'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffK'
    $computerName = $env:COMPUTERNAME
    $processId = $PID

    $logEntry = '[{0}] [{1}] [{2}] [PID:{3}] {4}' -f `
        $timestamp,
        $LogLevel.ToUpperInvariant(),
        $computerName,
        $processId,
        $Message

    $foregroundColor = switch ($LogLevel) {
        'TRC'    { 'DarkGray' }
        'DBG'    { 'Gray' }
        'INF'    { 'Green' }
        'WRN'    { 'Yellow' }
        'ERR'    { 'Red' }
        'CRI'    { 'Magenta' }
    }

    Write-Host $logEntry -ForegroundColor $foregroundColor
}

function Set-UserEnvVariable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Value,
        [switch]$AddToPath
    )

    [Environment]::SetEnvironmentVariable($Name, $Value, "User")
    Write-Log -Message "Set user env variable $Name = $Value" -LogLevel INF
    Set-Item -Path "Env:$Name" -Value $Value

    if ($AddToPath) {
        if (-not (Test-Path -LiteralPath $Value -PathType Container)) {
            Write-Log -Message "$Value does not exist or is not a directory. Adding to PATH anyway." -LogLevel WRN
        }

        $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $pathEntries = $currentUserPath -split ';' | Where-Object { $_ -ne "" }

        if ($pathEntries -contains $Value) {
            Write-Log -Message "$Value is already in the user PATH." -LogLevel WRN
        }
        else {
            $newUserPath = if ([string]::IsNullOrEmpty($currentUserPath)) {
                $Value
            } else {
                "$currentUserPath;$Value"
            }

            [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
            $env:Path = "$env:Path;$Value"
            Write-Log -Message "Added $Value to user PATH." -LogLevel INF
        }
    }
    Write-Log -Message "Note: other already-open terminals won't see these changes until restarted." -LogLevel DBG
}

function Invoke-SetEnvVariables {
    $envVars = @(
        [PSCustomObject]@{ Name = "PWSH_HOME";    Value = Join-Path $userPath "pwsh/latest";   AddToPath = $true }
        [PSCustomObject]@{ Name = "SOFTWARE_DIR"; Value = Join-Path $userPath "software";      AddToPath = $false }
        [PSCustomObject]@{ Name = "TOOLS_DIR"; Value = Join-Path $userPath "tools";      AddToPath = $false }
    )

    foreach ($entry in $envVars) {
        Write-Host "$($entry.Name) = $($entry.Value) | AddToPath: $($entry.AddToPath)"

        if ($entry.AddToPath) {
            Set-UserEnvVariable -Name $entry.Name -Value $entry.Value -AddToPath
        }
        else {
            Set-UserEnvVariable -Name $entry.Name -Value $entry.Value
        }
    }
}

$userPath = $env:USERPROFILE


Write-Log -Message "(1/x) Starting script execution ..." -LogLevel INF


$rootPath = Join-Path $env:USERPROFILE ".cfg"
New-Item -ItemType Directory -Force -Path $rootPath
Write-Log -Message "Created root path at $rootPath" -LogLevel INF

$pwshPath = Join-Path $rootPath "pwsh/latest"
New-Item -ItemType Directory -Force -Path $pwshPath
Write-Log -Message "Created pwsh path at $pwshPath" -LogLevel INF

$pwshModulesPath = Join-Path $rootPath "pwsh/cus-modules"
New-Item -ItemType Directory -Force -Path $pwshModulesPath
Write-Log -Message "Created modules path at $pwshModulesPath" -LogLevel INF

$softwarePath = Join-Path $rootPath "software"
New-Item -ItemType Directory -Force -Path $softwarePath
Write-Log -Message "Created software path at $softwarePath" -LogLevel INF

$miscPath = Join-Path $rootPath "misc/backgrounds"
New-Item -ItemType Directory -Force -Path $miscPath
Write-Log -Message "Created misc path at $miscPath" -LogLevel INF

$toolspath = Join-Path $rootPath "tools"
New-Item -ItemType Directory -Force -Path $toolspath
Write-Log -Message "Created tools path at $toolspath" -LogLevel INF


# Set-UserEnvVariable -Name "MY_VAR" -Value "some_value"

# Set-UserEnvVariable -Name "MY_VAR_IN_PATH" -Value "D:\temp\beispiele-test3" -AddToPath

Write-Log -Message "(2/x) Starting installer..." -LogLevel INF
winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id Microsoft.WindowsTerminal.Preview


Write-Log -Message "(3/x) Starting post-installation tasks ..." -LogLevel INF
Invoke-SetEnvVariables