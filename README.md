```bash
code --list-extensions | xargs -L 1 echo code --install-extension
```

```pwsh
code --list-extensions | ForEach-Object { "code --install-extension $_" }
```

```pwsh
code --profile "profile-name" --list-extensions
```

TODO Make env


Modules technically require manifests """New-ModuleManifest -Path "$HOME\Documents\PowerShell\Modules\MyTools\MyTools.psd1" `
-RootModule "MyTools.psm1" `
    -FunctionsToExport "OpenFileExplorer" `
-AliasesToExport "fe" `
    -ModuleVersion "1.0.0""""


TODO starhip porject recognizer
