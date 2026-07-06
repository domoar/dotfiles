Get-Content "$env:APPDATA\Code\User\globalStorage\storage.json" -Raw |
    ConvertFrom-Json |
    Select-Object -ExpandProperty userDataProfiles |
    ForEach-Object { "$($_.name) -> $($_.location)" }