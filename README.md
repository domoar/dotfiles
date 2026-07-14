```bash
code --list-extensions | xargs -L 1 echo code --install-extension
```

```pwsh
code --list-extensions | ForEach-Object { "code --install-extension $_" }
```

```pwsh
code --profile "profile-name" --list-extensions
```

Make env

# In your $PROFILE, BEFORE any Import-Module lines

$env:PSModulePath = "F:\path\to\dotfiles\PowerShell\Modules;" + $env:PSModulePath

Import-Module MyTools

Modules technically require manifests """New-ModuleManifest -Path "$HOME\Documents\PowerShell\Modules\MyTools\MyTools.psd1" `
-RootModule "MyTools.psm1" `
    -FunctionsToExport "OpenFileExplorer" `
-AliasesToExport "fe" `
    -ModuleVersion "1.0.0""""

New Command """Start-Process wt.exe -Verb RunAs -ArgumentList "-p `"PowerShell`""""" Set alias elevate
