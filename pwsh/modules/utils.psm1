<#
.SYNOPSIS
Opens the current directory in Windows File Explorer.

.USAGE
fe
#>
function OpenFileExplorer {
    $currentPath = Get-Location
    Start-Process explorer.exe $currentPath
}
Set-Alias -Name fe -Value OpenFileExplorer

#####################################################################

Export-ModuleMember -Function OpenFileExplorer -Alias fe