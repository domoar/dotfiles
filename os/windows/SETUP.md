# `setup.ps1` — Windows Setup Script Summary

Bootstraps a fresh Windows machine: creates a tooling directory structure, sets
user environment variables, installs CLI tools and fonts via `winget`, and
symlinks dotfiles configs into place. Must run elevated (self-elevates if not
already Administrator).

## Base paths

| Variable    | Value                        |
|-------------|------------------------------|
| `$userPath` | `%USERPROFILE%`              |
| `$rootPath` | `%USERPROFILE%\.cfg`         |
| `$cfgPath`  | `%USERPROFILE%\.cfg` (same as `$rootPath`) |
| `$toolsPath`| `%USERPROFILE%\.cfg\tools`   |

## Step 1 — Directories created

- `%USERPROFILE%\.cfg`
- `%USERPROFILE%\.cfg\tools`
- `%USERPROFILE%\.cfg\tools\7zip`
- `%USERPROFILE%\.cfg\tools\bruno`
- `%USERPROFILE%\.cfg\misc\backgrounds`
- `%USERPROFILE%\.cfg\pwsh\modules`
- `%USERPROFILE%\.cfg\pwsh\latest`

## Step 2 — Tools installed

- Latest PowerShell (downloaded from GitHub releases, `win-x64.zip`) →
  extracted to `%USERPROFILE%\.cfg\pwsh\latest`
- Via `winget`:
  - Node.js LTS (`OpenJS.NodeJS.LTS`)
  - Windows Terminal Preview (`Microsoft.WindowsTerminal.Preview`)
  - PowerToys (`Microsoft.PowerToys`)
  - fastfetch
  - Starship (`Starship.Starship`)
  - GitHub CLI (`GitHub.cli`)
  - Git (`Git.Git`)
  - Visual Studio Code (`Microsoft.VisualStudioCode`)
  - Azure CLI (`Microsoft.AzureCLI`)
  - Azure Functions Core Tools (`Microsoft.Azure.FunctionsCoreTools`)

Requires `winget` to be available; exits with an error if not found.

## Step 3 — Post-install tasks

**Fonts** (Nerd Fonts, installed system-wide into `%WINDIR%\Fonts` +
registered in `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts`):
- IBM Plex Mono
- JetBrains Mono

**Environment variables** — all set at **User** scope via
`Set-UserEnvVariable` (which also live-updates the current process and
optionally appends to the user `PATH`):

| Name                | Value                              | Added to PATH |
|---------------------|-------------------------------------|:---:|
| `TOOLS_DIR`         | `%USERPROFILE%\.cfg\tools`          | ❌ |
| `BRUNO_HOME`        | `%TOOLS_DIR%/bruno`                 | ❌ |
| `PWSH_HOME`         | `%TOOLS_DIR%/pwsh/latest`           | ✅ |
| `PSModulePath`      | `%TOOLS_DIR%/pwsh/modules`          | ❌ |
| `GOROOT`            | `%TOOLS_DIR%/go`                    | ✅ |
| `GOHOME`            | `%TOOLS_DIR%/go`                    | ✅ |
| `GIT_HOME`          | `%TOOLS_DIR%/git`                   | ✅ |
| `GIT_BIN`           | `%GIT_HOME%/bin`                    | ✅ |
| `GIT_CMD`           | `%GIT_HOME%/cmd`                    | ✅ |
| `GH_CLI_HOME`       | `%TOOLS_DIR%/github`                | ✅ |
| `JAVA_HOME`         | `%TOOLS_DIR%/java`                  | ✅ |
| `JDK_HOME`          | `%JAVA_HOME%`                       | ✅ |
| `JRE_HOME`          | `%JAVA_HOME%/jre`                   | ✅ |
| `NPM_CONFIG_PREFIX` | `%TOOLS_DIR%/npm`                   | ✅ |
| `NODE_JS_HOME`      | `%TOOLS_DIR%/nodejs`                | ✅ |
| `AZURE_CLI_HOME`    | `%TOOLS_DIR%/azure`                 | ✅ |
| `DOTNET_HOME`       | `%TOOLS_DIR%/dotnet`                | ✅ |
| `DOTNET_TOOLS`      | `%DOTNET_HOME%/tools`               | ✅ |
| `SQLITE3_HOME`      | `%TOOLS_DIR%/sqlite3`               | ✅ |
| `TEXLIVE_HOME`      | `%TOOLS_DIR%/texlive`               | ✅ |
| `PYTHON_HOME`       | `%TOOLS_DIR%/python`                | ✅ |
| `FONTS_DIR`         | `%USERPROFILE%\.cfg\fonts`          | ❌ |
| `7Z_HOME`           | `%TOOLS_DIR%/7zip`                  | ❌ |

> Note: only entries marked `AddToPath = $true` are actually processed by
> `Invoke-SetEnvVariables` (the `foreach` loop only calls `Set-UserEnvVariable`
> for those); non-PATH entries above are defined but not applied by the
> current loop logic.

**Secrets / extra vars** — loaded from a local `.env` file next to the script
(`os/windows/.env`, not committed) via `Import-DotEnv`, then persisted to
User scope:
- `OPENROUTER_API_KEY`
- `COGNIGY_API_KEY`
- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `PROJECTS_HOME` → `%USERPROFILE%\projects`

**Project folders created:**
- `%USERPROFILE%\projects`
- `%USERPROFILE%\projects\python`
- `%USERPROFILE%\projects\csharp`
- `%USERPROFILE%\projects\web`
- `%USERPROFILE%\projects\go`
- `%USERPROFILE%\projects\rust`

## Step 4 — Config symlinks

| Link (target path)                              | Points to                                             |
|--------------------------------------------------|--------------------------------------------------------|
| `%HOME%\.config\starship.toml`                    | `%HOME%\projects\dotfiles\starship\starship.toml`       |
| `%LOCALAPPDATA%\fastfetch\config.jsonc`           | `%HOME%\projects\dotfiles\fastfetch\config.jsonc`       |

> Assumes this `dotfiles` repo is checked out at `%HOME%\projects\dotfiles`.

## Helper functions defined in the script

- `Write-Log` — timestamped, color-coded console logging (TRC/DBG/INF/WRN/ERR/CRI)
- `Set-UserEnvVariable` — sets a User env var, optionally appends to user PATH
- `Invoke-SetEnvVariables` — applies the table of tool env vars above
- `Install-NerdFont` — downloads/extracts/installs a Nerd Font ZIP, registers in HKLM
- `New-CfgDirectory` — creates a directory (idempotent, `-Force`)
- `Install-LatestPowerShellZip` — fetches latest PowerShell release from GitHub, extracts it
- `Import-DotEnv` — parses a `.env` file into process-scoped env vars
