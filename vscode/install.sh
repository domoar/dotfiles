#!/usr/bin/env bash

set -euo pipefail

install_extension() {
  local profile_name="$1"
  local package_name="$2"
  code --profile "$profile_name" --install-extension "$package_name"
}

# Einzelaufruf beispiel
# install_extension "python-1" "ms-vscode-remote.remote-ssh"

# Assoziatives Array: Schlüssel = Profilname, Wert = Beschreibung
declare -A profiles=(
  ["python-lang"]="Python language specs"
  ["csharp-lang"]="C# language specs"
  ["typescript-lang"]="TS language specs"
  ["c-lang"]="C language specs"
  ["go-lang"]="GO language specs"
  ["rust-lang"]="Rust language specs"
)

# Über alle Einträge iterieren
for name in "${!profiles[@]}"; do
  echo "$name -> ${profiles[$name]}"
done