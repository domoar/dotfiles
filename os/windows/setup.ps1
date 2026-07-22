#region helpers
<#
.SYNOPSIS
Writes a timestamped, color-coded log message to the console.

.PARAMETER Message
The message text to write to the console.

.PARAMETER LogLevel
The severity level for the log entry. Valid values are TRC, DBG, INF, WRN, ERR, and CRI. Defaults to INF.

.USAGE
Write-Log -Message "Starting setup" -LogLevel INF
Write-Log -Message "Something failed" -LogLevel ERR
#>
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
        'TRC' { 'DarkGray' }
        'DBG' { 'Gray' }
        'INF' { 'Green' }
        'WRN' { 'Yellow' }
        'ERR' { 'Red' }
        'CRI' { 'Magenta' }
    }

    Write-Host $logEntry -ForegroundColor $foregroundColor
}
<#
.SYNOPSIS
Sets a user-scoped environment variable and optionally appends its value to the user PATH.

.PARAMETER Name
The name of the environment variable to set.

.PARAMETER Value
The value to assign to the environment variable.

.PARAMETER AddToPath
Adds the value to the user PATH when specified.

.USAGE
Set-UserEnvVariable -Name "TOOLS_DIR" -Value "$env:USERPROFILE\.cfg\tools"
Set-UserEnvVariable -Name "PWSH_HOME" -Value "%TOOLS_DIR%/pwsh/latest" -AddToPath
#>
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
            }
            else {
                "$currentUserPath;$Value"
            }

            [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
            $env:Path = "$env:Path;$Value"
            Write-Log -Message "Added $Value to user PATH." -LogLevel INF
        }
    }
    Write-Log -Message "Note: other already-open terminals won't see these changes until restarted." -LogLevel DBG
}

<#
.SYNOPSIS
Configures the standard user environment variables used by the Windows tool setup.

.USAGE
Invoke-SetEnvVariables
#>
function Invoke-SetEnvVariables {
    $envVars = @(
        [PSCustomObject]@{ Name = "TOOLS_DIR"; Value = Join-Path $userPath "tools"; AddToPath = $false },
        [PSCustomObject]@{ Name = "BRUNO_HOME"; Value = "%TOOLS_DIR%/bruno"; AddToPath = $false },
        [PSCustomObject]@{ Name = "PWSH_HOME"; Value = "%TOOLS_DIR%/pwsh/latest"; AddToPath = $true },
        [PSCustomObject]@{ Name = "PSModulePath"; Value = "%TOOLS_DIR%/pwsh/modules"; AddToPath = $false },
        [PSCustomObject]@{ Name = "GOROOT"; Value = "%TOOLS_DIR%/go"; AddToPath = $true },
        [PSCustomObject]@{ Name = "GOHOME"; Value = "%TOOLS_DIR%/go"; AddToPath = $true },
        [PSCustomObject]@{ Name = "GIT_HOME"; Value = "%TOOLS_DIR%/git"; AddToPath = $true },
        [PSCustomObject]@{ Name = "GIT_BIN"; Value = "%GIT_HOME%/bin"; AddToPath = $true },
        [PSCustomObject]@{ Name = "GIT_CMD"; Value = "%GIT_HOME%/cmd"; AddToPath = $true },
        [PSCustomObject]@{ Name = "GH_CLI_HOME"; Value = "%TOOLS_DIR%/github"; AddToPath = $true },
        [PSCustomObject]@{ Name = "JAVA_HOME"; Value = "%TOOLS_DIR%/java"; AddToPath = $true },
        [PSCustomObject]@{ Name = "JDK_HOME"; Value = "%JAVA_HOME%"; AddToPath = $true },
        [PSCustomObject]@{ Name = "JRE_HOME"; Value = "%JAVA_HOME%/jre"; AddToPath = $true },   
        [PSCustomObject]@{ Name = "NPM_CONFIG_PREFIX"; Value = "%TOOLS_DIR%/npm"; AddToPath = $true },
        [PSCustomObject]@{ Name = "NODE_JS_HOME"; Value = "%TOOLS_DIR%/nodejs"; AddToPath = $true },
        [PSCustomObject]@{ Name = "AZURE_CLI_HOME"; Value = "%TOOLS_DIR%/azure"; AddToPath = $true },
        [PSCustomObject]@{ Name = "DOTNET_HOME"; Value = "%TOOLS_DIR%/dotnet"; AddToPath = $true },
        [PSCustomObject]@{ Name = "DOTNET_TOOLS"; Value = "%DOTNET_HOME%/tools"; AddToPath = $true },
        [PSCustomObject]@{ Name = "SQLITE3_HOME"; Value = "%TOOLS_DIR%/sqlite3"; AddToPath = $true },
        [PSCustomObject]@{ Name = "TEXLIVE_HOME"; Value = "%TOOLS_DIR%/texlive"; AddToPath = $true },
        [PSCustomObject]@{ Name = "PYTHON_HOME"; Value = "%TOOLS_DIR%/python"; AddToPath = $true },
        [PSCustomObject]@{ Name = "FONTS_DIR"; Value = Join-Path $rootPath "fonts"; AddToPath = $false },
        [PSCustomObject]@{ Name = "7Z_HOME"; Value = Join-Path "%TOOLS_DIR%/7zip"; AddToPath = $false }
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

<#
.SYNOPSIS
Downloads and installs a Nerd Font package on Windows.

.DESCRIPTION
Downloads a ZIP archive from the specified URL, extracts all TrueType font
files, copies them to the Windows Fonts directory, and registers them under
the system-wide Windows Fonts registry key.

The function requires administrative privileges because it writes to the
Windows Fonts directory and the HKEY_LOCAL_MACHINE registry hive.

Temporary download and extraction files are removed after installation.

.PARAMETER Url
Specifies the URL of the Nerd Font ZIP archive to download.

.PARAMETER FontName
Specifies the font package name. This value is used to create temporary file
and extraction directory names.

.EXAMPLE
Install-NerdFont `
    -Url 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/IBMPlexMono.zip' `
    -FontName 'IBMPlexMono'

Downloads and installs the IBM Plex Mono Nerd Font package.

.NOTES
Requires Windows and an elevated PowerShell session.
#>
function Install-NerdFont {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [string]$FontName
    )

    $zip = Join-Path $env:TEMP "$FontName.zip"
    $extract = Join-Path $env:TEMP "$FontName"

    try {
        Invoke-WebRequest `
            -Uri $Url `
            -OutFile $zip

        Expand-Archive `
            -Path $zip `
            -DestinationPath $extract `
            -Force

        $fontsFolder = Join-Path $env:WINDIR 'Fonts'
        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

        Get-ChildItem $extract -Filter '*.ttf' | ForEach-Object {
            $fontFile = $_.Name
            $source = $_.FullName
            $destination = Join-Path $fontsFolder $fontFile

            Copy-Item $source $destination -Force

            $fontCollection = [System.Drawing.Text.PrivateFontCollection]::new()
            $fontCollection.AddFontFile($destination)
            $family = $fontCollection.Families[0].Name

            New-ItemProperty `
                -Path $regPath `
                -Name "$family (TrueType)" `
                -Value $fontFile `
                -PropertyType String `
                -Force | Out-Null

            Write-Log -Message "Installed: $family" -LogLevel INF
        }
    }
    finally {
        if (Test-Path $zip) {
            Remove-Item $zip -Force
        }

        if (Test-Path $extract) {
            Remove-Item $extract -Recurse -Force
        }
    }
}
<#
.SYNOPSIS
Creates a configuration directory under the current user's profile directory.

.DESCRIPTION
Creates a directory with the specified folder name inside the user's profile path.
If the directory already exists, it will be preserved due to the use of the Force parameter.

.PARAMETER FolderName
The name of the directory to create under the user's profile directory.

.EXAMPLE
New-CfgDirectory -FolderName ".cfg"

Creates the directory C:\Users\<User>\.cfg.
#>
function New-CfgDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FolderName
    )

    $rootPath = Join-Path $env:USERPROFILE $FolderName

    New-Item -ItemType Directory -Force -Path $rootPath | Out-Null

    Write-Log -Message "Created root path at $rootPath" -LogLevel INF

    return $rootPath
}

function Install-LatestPowerShellZip {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DestinationPath
    )

    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"

    $asset = $release.assets |
    Where-Object { $_.name -like "*win-x64.zip" } |
    Select-Object -First 1

    if (-not $asset) {
        Write-Log -Message "Unable to locate the latest PowerShell win-x64 ZIP asset." -LogLevel ERR
        exit 1
    }

    $zipPath = Join-Path $env:TEMP $asset.name

    Invoke-WebRequest `
        -Uri $asset.browser_download_url `
        -OutFile $zipPath

    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null

    Expand-Archive `
        -Path $zipPath `
        -DestinationPath $DestinationPath `
        -Force

    Remove-Item $zipPath -Force

    Write-Log -Message "Installed PowerShell $($release.tag_name) to '$DestinationPath'" -LogLevel INF
}
<#
.SYNOPSIS
Imports environment variables from a .env file into the current PowerShell process.

.DESCRIPTION
Reads a .env file containing KEY=VALUE pairs, ignores blank lines and comments,
removes surrounding single or double quotes from values, and sets each variable
as a process-level environment variable.

.PARAMETER Path
The path to the .env file. Defaults to ".env".

.EXAMPLE
Import-DotEnv

Imports environment variables from the .env file in the current directory.

.EXAMPLE
Import-DotEnv -Path "C:\Projects\MyApp\.env"

Imports environment variables from the specified .env file.

.NOTES
Environment variables are set for the current PowerShell process only and are
available to child processes started from the current session.
#>
function Import-DotEnv {
    param(
        [string]$Path = ".env"
    )

    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }

        $key, $value = $_ -split '=', 2
        $key = $key.Trim()
        $value = $value.Trim().Trim('"').Trim("'")

        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}
#endregion helpers

Write-Log -Message "Starting Windows setup ..." -LogLevel INF
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log -Message "This script must be run as Administrator. Restarting with elevated privileges..." -LogLevel WRN
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Write-Log -Message "Elevation request sent. Exiting current process." -LogLevel INF
    Break
}
Write-Log -Message "Running with elevated privileges." -LogLevel INF

#####################################################################

$rootPath = Join-Path $env:USERPROFILE ".cfg"
$userPath = $env:USERPROFILE

#region directories
Write-Log -Message "(1/4) Starting directory setup ..." -LogLevel INF

$cfgPath = New-CfgDirectory -FolderName $rootPath
$toolsPath = New-CfgDirectory -FolderName (Join-Path $cfgPath "tools")
New-CfgDirectory -FolderName (Join-Path $toolsPath "7zip")
New-CfgDirectory -FolderName (Join-Path $toolsPath "bruno")
New-CfgDirectory -FolderName (Join-Path $cfgPath "misc/backgrounds")
New-CfgDirectory -FolderName (Join-Path $cfgPath "pwsh/modules")
New-CfgDirectory -FolderName (Join-Path $cfgPath "pwsh/latest")

#endregion directories

#####################################################################

#region tools
Write-Log -Message "(2/4) Starting tool setup ..." -LogLevel INF
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Log -Message "'winget' CLI is not available." -LogLevel CRI
    exit 1
}

Install-LatestPowerShellZip -DestinationPath (Join-Path $cfgPath "pwsh/latest")

winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id Microsoft.WindowsTerminal.Preview
winget install -e --id Microsoft.PowerToys
winget install fastfetch
winget install -e --id Starship.Starship
winget install -e --id GitHub.cli
winget install -e --id Git.Git
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.AzureCLI
winget install -e --id Microsoft.Azure.FunctionsCoreTools
#endregion tools

#####################################################################

#region post-install
Write-Log -Message "(3/4) Starting post-installation tasks ..." -LogLevel INF

Write-Log -Message "Installing fonts ..." -LogLevel INF
Install-NerdFont `
    -Url 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IBMPlexMono.zip' `
    -FontName 'IBMPlexMono'

Install-NerdFont `
    -Url 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip' `
    -FontName 'JetBrainsMono'

Write-Log -Message "Setting env variables ..." -LogLevel INF
Invoke-SetEnvVariables

Import-DotEnv -Path (Join-Path $PSScriptRoot ".env")

[Environment]::SetEnvironmentVariable("OPENROUTER_API_KEY", $env:OPENROUTER_API_KEY, "User")
[Environment]::SetEnvironmentVariable("COGNIGY_API_KEY", $env:COGNIGY_API_KEY, "User")
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $env:ANTHROPIC_API_KEY, "User")
[Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $env:OPENAI_API_KEY, "User")
[Environment]::SetEnvironmentVariable("PROJECTS_HOME", "$env:USERPROFILE\projects", "User")

mkdir "$env:USERPROFILE\projects" -Force | Out-Null
mkdir "$env:USERPROFILE\projects\python" -Force | Out-Null
mkdir "$env:USERPROFILE\projects\csharp" -Force | Out-Null
mkdir "$env:USERPROFILE\projects\web" -Force | Out-Null
mkdir "$env:USERPROFILE\projects\go" -Force | Out-Null
mkdir "$env:USERPROFILE\projects\rust" -Force | Out-Null
#endregion post-install

#####################################################################

#region cfgs
Write-Log -Message "(4/4) Starting configuration ..." -LogLevel INF

Write-Log -Message "Creating symlinks ..." -LogLevel INF
New-Item -ItemType SymbolicLink `
    -Path "$HOME\.config\starship.toml" `
    -Target "$HOME\projects\dotfiles\starship\starship.toml"

New-Item -ItemType SymbolicLink `
    -Path "$LOCALAPPDATA\fastfetch\config.jsonc" `
    -Target "$HOME\projects\dotfiles\fastfetch\config.jsonc"
#endregion cfgs

#####################################################################
