Import-Module logger
Import-Module utils
Import-Module code-utils
Import-Module wsl-utils
Import-Module docker
Import-Module terminal-utils

Import-Module -Name Terminal-Icons

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)

    $sensitive = "password|asplaintext|token|key|secret"
    return ($line -notmatch $sensitive)
}

Set-PSReadLineOption -Colors @{
    "Command"                = 'Cyan'
    "Parameter"              = 'Gray'
    "String"                 = 'Green'
    "Operator"               = 'DarkGray'
    "Variable"               = 'Yellow'
    "Type"                   = 'Magenta'
    "Number"                 = 'DarkYellow'
    "Member"                 = 'White'
    "Comment"                = 'DarkGreen'
    "Keyword"                = 'Blue'
    "Error"                  = 'Red'
    "Emphasis"               = 'White'
    "InlinePrediction"       = 'DarkGray'
    "ListPrediction"         = 'DarkGray'
    "ListPredictionSelected" = 'Gray'
    "Default"                = 'White'
}

Invoke-Expression (&starship init powershell)
fastfetch
