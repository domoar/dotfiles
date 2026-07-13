#!/usr/bin/env bash
set -euo pipefail

BASE="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/profiles"

if [ ! -d "$BASE" ]; then
  echo "[ERR:] No VS Code profiles directory found: $BASE"
  exit 1
fi

echo "[INF:] VS Code profile IDs:"
for dir in "$BASE"/*; do
  [ -d "$dir" ] || continue
  id="$(basename "$dir")"
  echo
  echo "[INF:] ID:   $id"
  echo "[INF:] Path: $dir"

  [ -f "$dir/settings.json" ] && echo "[INF:] Settings: $dir/settings.json"
  [ -f "$dir/extensions.json" ] && echo "[INF:] Extensions: $dir/extensions.json"
done