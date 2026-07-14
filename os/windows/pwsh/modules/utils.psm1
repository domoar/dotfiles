<#
.SYNOPSIS
Opens File Explorer at the current PowerShell location.

.USAGE
OpenFileExplorer
fe
#>
function OpenFileExplorer {
    $currentPath = Get-Location
    Start-Process explorer.exe $currentPath
}
Export-ModuleMember -Function OpenFileExplorer -Alias fe

#####################################################################

<#
.SYNOPSIS
Moves up one or more parent directories from the current location.

.PARAMETER -Levels
The number of directory levels to move up. Defaults to 1.

.USAGE
GoUpNDirectories -Levels 2
up 2
#>
function GoUpNDirectories {
    param(
        [Parameter(Position = 0)]
        [int]$Levels = 1
    )

    if ($Levels -lt 1) {
        Write-Log -Message "Levels must be >= 1" -LogLevel ERR
        return
    }
    $path = (1..$Levels | ForEach-Object { ".." }) -join [IO.Path]::DirectorySeparatorChar
    Set-Location $path
}
Export-ModuleMember -Function GoUpNDirectories -Alias up

#####################################################################

<#
.SYNOPSIS
Copies a file path to the clipboard after verifying that it exists.

.PARAMETER -Path
The file or folder path to copy to the clipboard.

.USAGE
scop .\README.md
Get-Item .\README.md | ForEach-Object { scop $_.FullName }
#>
function scop {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$Path
    )
    if (Test-Path $Path) {
        Set-Clipboard -Path $Path
        Write-Log -Message "File '$Path' copied to clipboard" -LogLevel INF
    } else {
        Write-Log -Message "File '$Path' does not exist" -LogLevel ERR
    }
}
Export-ModuleMember -Function scop

#####################################################################

<#
.SYNOPSIS
Starts the Windows SlideToShutDown experience and exits the current session.

.USAGE
SlideToShutDown
conexit
#>
function SlideToShutDown {
    Write-Log -Message "Init shutdown ..." -LogLevel ERR
    Start-Process "C:\Windows\System32\SlideToShutDown.exe"
    exit
}
Export-ModuleMember -Function SlideToShutDown -Alias conexit

#####################################################################

<#
.SYNOPSIS
Opens the PowerShell command history file in Visual Studio Code.

.USAGE
OpenPsHistory
history
#>
function OpenPsHistory {
    code (Get-PSReadlineOption).HistorySavePath
}
Export-ModuleMember -Function OpenPsHistory -Alias history

#####################################################################

<#
.SYNOPSIS
Extracts a zip archive with 7-Zip into a target directory.

.PARAMETER -ArchivePath
The path to the zip archive to extract.

.PARAMETER -DestinationPath
The output directory. Defaults to a folder named after the archive in the current location.

.USAGE
UnpackFileWith7Zip -ArchivePath .\archive.zip
unpack .\archive.zip .\output
#>
function UnpackFileWith7Zip {
    param (
        [Parameter(Mandatory)]
        [string]$ArchivePath,

        [Parameter(ValueFromPipeline)]
        [string]$DestinationPath
    )

    $zipPath = "C:\Program Files\7-Zip\7z.exe"
    
    if (!(Test-Path $ArchivePath)) {
        Write-Log -Message "File '$ArchivePath' not found." -LogLevel WRN
        return
    }

    if (!($ArchivePath -match '\.zip$')) {
        Write-Log -Message "File '$ArchivePath' is not a valid zip file." -LogLevel WRN
        return
    }

    if (-not $DestinationPath) {
        $DestinationPath = Get-Location
        $folderName = [System.IO.Path]::GetFileNameWithoutExtension($ArchivePath)
        $fullDestinationPath = Join-Path $DestinationPath $folderName
    }
    else {
        $fullDestinationPath = $DestinationPath
    }
    
    if (-not (Test-Path $fullDestinationPath)) {
        New-Item -Path $fullDestinationPath -ItemType Directory
    }

    & $zipPath x "$ArchivePath" -o"$fullDestinationPath" -aoa -r
    Write-Log -Message "File '$ArchivePath' unpacked to '$fullDestinationPath'." -LogLevel INF
}
Export-ModuleMember -Function UnpackFileWith7Zip -Alias unpack

#####################################################################

<#
.SYNOPSIS
Creates a zip archive from a file or folder with 7-Zip.

.PARAMETER -SourcePath
The file or folder to add to the zip archive.

.PARAMETER -DestinationPath
The destination zip path. Defaults to a zip file in the current location.

.USAGE
PackFileWith7Zip -SourcePath .\logs
pack .\logs .\logs.zip
#>
function PackFileWith7Zip {
    param (
        [Parameter(Mandatory)]
        [string]$SourcePath,

        [string]$DestinationPath
    )

    if (-not $DestinationPath) {
        $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)
        $DestinationPath = Join-Path (Get-Location) -ChildPath "$fileNameWithoutExtension.zip"
    }

    $zipPath = "C:\Program Files\7-Zip\7z.exe"
    if (!(Test-Path $SourcePath)) {
        Write-Warning "Source path '$SourcePath' not found."
        return
    }

    & $zipPath a "$DestinationPath" "$SourcePath" -tzip

    Write-Log -Message "File '$SourcePath' packed to '$DestinationPath'." -LogLevel INF
}
Export-ModuleMember -Function PackFileWith7Zip -Alias pack

#####################################################################

<#
.SYNOPSIS
Changes the current location to the user's Visual Studio repositories folder.

.USAGE
GoToVisualStudioRepos
repos
vsrepos
#>
function GoToVisualStudioRepos {
    $username = $env:USERNAME
    $path = "C:\Users\$username\source\repos"
    
    if (Test-Path $path) {
        Set-Location $path
        Write-Log -Message "Opening VisualStudio repositories @ $path" -LogLevel INF
    }
    else {
        Write-Log -Message "VisualStudio repositories @ $path not found!" -LogLevel WRN
    }
}
Export-ModuleMember -Function GoToVisualStudioRepos -Alias repos, vsrepos

#####################################################################

<#
.SYNOPSIS
Shows a decorated git commit graph for all branches.

.USAGE
GetGitLog
ggl
#>
function GetGitLog {
    git log --graph --all --decorate --pretty=format:"%C(yellow)%h%Creset - %Cgreen%ad%Creset %C(auto)%d%Creset %s" --date=short
}
Export-ModuleMember -Function GetGitLog -Alias ggl

#####################################################################

<#
.SYNOPSIS
Prints a tree view of the current directory.

.PARAMETER -f
Includes files in the tree output.

.PARAMETER -s
Shows file sizes when files are included.

.PARAMETER -d
Sets the maximum tree depth. Defaults to 5.

.USAGE
Show-Tree
tr -f -s -d 3
#>
function Show-Tree {
    [CmdletBinding()]
    param (
        [switch]$f,
        [switch]$s,
        [int]$d = 5
    )

    <#
    .SYNOPSIS
    Recursively writes a tree view for a directory path.

    .PARAMETER -Path
    The directory path to render.

    .PARAMETER -ParentLastFlags
    The branch-state flags used to render indentation for parent nodes.

    .PARAMETER -Depth
    The current recursion depth.

    .PARAMETER -MaxDepth
    The maximum recursion depth to render.

    .USAGE
    Show-TreeInternal -Path $cwd.Path -ParentLastFlags @() -Depth 0 -MaxDepth $d
    #>
    function Show-TreeInternal {
        param (
            [string]$Path,
            [bool[]]$ParentLastFlags = @(),
            [int]$Depth = 0,
            [int]$MaxDepth
        )

        if ($Depth -gt $MaxDepth) {
            return
        }

        $folderColor = "`e[34m"  # Blue
        $resetColor  = "`e[0m"

        $name = Split-Path $Path -Leaf
        $prefix = ""
        for ($i = 0; $i -lt $ParentLastFlags.Count - 1; $i++) {
            $prefix += $ParentLastFlags[$i] ? "    " : "│   "
        }

        if ($Depth -eq 0) {
            Write-Output "$folderColor$name/$resetColor"
        } else {
            $isLast = $ParentLastFlags[-1]
            $branch = $isLast ? "└── " : "├── "
            Write-Output "$prefix$branch$folderColor$name/$resetColor"
        }

        if ($Depth -eq $MaxDepth) {
            return
        }

        $children = Get-ChildItem -LiteralPath $Path -Force | Where-Object { -not $_.Attributes.ToString().Contains("Hidden") }
        if (-not $f) {
            $children = $children | Where-Object { $_.PSIsContainer }
        }

        $count = $children.Count
        for ($i = 0; $i -lt $count; $i++) {
            $child = $children[$i]
            $isLast = ($i -eq $count - 1)
            $newFlags = $ParentLastFlags + $isLast

            $filePrefix = ""
            for ($j = 0; $j -lt $newFlags.Count - 1; $j++) {
                $filePrefix += $newFlags[$j] ? "    " : "│   "
            }
            $fileBranch = $newFlags[-1] ? "└── " : "├── "

            if ($child.PSIsContainer) {
                Show-TreeInternal -Path $child.FullName -ParentLastFlags $newFlags -Depth ($Depth + 1) -MaxDepth $MaxDepth
            } elseif ($f) {
                if ($s) {
                    $size = "{0,9:N0} B" -f $child.Length
                    Write-Output "$filePrefix$fileBranch$($child.Name) $size"
                } else {
                    Write-Output "$filePrefix$fileBranch$($child.Name)"
                }
            }
        }
    }

    $cwd = Get-Location
    Show-TreeInternal -Path $cwd.Path -ParentLastFlags @() -Depth 0 -MaxDepth $d
}
Export-ModuleMember -Function Show-Tree -Alias tr

#####################################################################

<#
.SYNOPSIS
Lists running WSL instances and optionally shuts them all down.

.USAGE
Stop-RunningWSL
exvirt
#>
function Stop-RunningWSL {
    $running = wsl --list --running 2>$null | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne "" }

    if (-not $running) {
        Write-Log -Message "No running WSL instances found." -LogLevel INF
        return
    }
    
    Write-Log -Message "Running WSL instances:" -LogLevel INF
    $running | ForEach-Object { Write-Log -Message " - $($_.Trim())" -LogLevel INF }

    $confirm = Read-Host "Shutdown all running WSL instances? (Y/N)"

    if ($confirm -match '^[Yy]$') {
        Write-Log -Message "Shutting down WSL ..." -LogLevel INF
        wsl --shutdown
    } else {
        Write-Log -Message "Aborted." -LogLevel WRN
    }
}
Export-ModuleMember -Function Stop-RunningWSL -Alias exvirt

#####################################################################

<#
.SYNOPSIS
Starts a new elevated Windows Terminal PowerShell session.

.USAGE
Elevate-Terminal
elevate
#>
function Elevate-Terminal {
    Start-Process wt.exe -Verb RunAs -ArgumentList "-p `"PowerShell`""
}
Export-ModuleMember -Function Elevate-Terminal -Alias elevate
