#!/usr/bin/env bash
set -euo pipefail

BASE="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/profiles"

if [ ! -d "$BASE" ]; then
  echo "No VS Code profiles directory found: $BASE"
  exit 1
fi

echo "VS Code profile IDs:"
for dir in "$BASE"/*; do
  [ -d "$dir" ] || continue
  id="$(basename "$dir")"
  echo
  echo "ID:   $id"
  echo "Path: $dir"

  [ -f "$dir/settings.json" ] && echo "Settings: $dir/settings.json"
  [ -f "$dir/extensions.json" ] && echo "Extensions: $dir/extensions.json"
done