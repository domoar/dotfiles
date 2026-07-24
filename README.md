# README

TODO Make env

Modules technically require manifests """New-ModuleManifest -Path "$HOME\Documents\PowerShell\Modules\MyTools\MyTools.psd1" `
-RootModule "MyTools.psm1" `
    -FunctionsToExport "OpenFileExplorer" `
-AliasesToExport "fe" `
    -ModuleVersion "1.0.0""""

TODO starhip porject recognizer

```powershell
mstsc.exe -v "<servername>"
```

```powershell
start-process msedge -ArgumentList '--inprivate https://example.com'
in 'PS C:\Program Files\BraveSoftware\Brave-Browser\Application>' .\brave --incognito "www.google.de" or add to PATH
in 'PS C:\Program Files\Google\Chrome\Application>' .\chrome --incognito "www.google.de" or add to PATH
```

## Browser Extensions

- SAML rcFed Tracer
- Dark Reader
- Session Buddy
- Go Full Page

## GitConfig

[REF](https://linux101.dev/git-commands/git-config/)

1. Copy the example config:
   cp .gitconfig.example .gitconfig
2. Fill in your personal values in .gitconfig:
   - user.name, user.email
   - user.signingkey (path to your SSH signing key)
3. Symlink it into your home directory:
    - Windows (PowerShell): ```powershell New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.gitconfig -Target <path-to-gitconfig>```
    - Linux/macOS: ```bash ln -s <path-to-gitconfig> ~/.gitconfig```

Note: .gitconfig is gitignored — only .gitconfig.example is tracked.

## OS-Setup

Currently supported OS are Windows | Linux. Check the referenced installers for details.

```bash

```

### Windows

In dotfiles root

```powershell

```

### Linux

## TODO

justcli
justfile
justextension

terraform
protobuf https://buf.build/product/cli

https://www.tinytooltown.com/tools/splitpanefix/
https://codingfreaks.de/terminal-progress/
https://learn.microsoft.com/de-de/windows/terminal/tutorials/shell-integration

https://github.com/tealdeer-rs/tealdeer