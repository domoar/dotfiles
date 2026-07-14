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
        'TRC'    { 'DarkGray' }
        'DBG'    { 'Gray' }
        'INF'    { 'Green' }
        'WRN'    { 'Yellow' }
        'ERR'    { 'Red' }
        'CRI'    { 'Magenta' }
    }

    Write-Host $logEntry -ForegroundColor $foregroundColor
}
Export-ModuleMember -Function Write-Log

#####################################################################
