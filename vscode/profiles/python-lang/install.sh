#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_NAME="python-lang"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.json"

if [[ ! -f "$EXTENSIONS_FILE" ]]; then
  echo "[ERROR:] Extensions file not found: $EXTENSIONS_FILE"
  exit 1
fi

echo "[INFO:] Reading extensions from $EXTENSIONS_FILE"

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR:] jq is required but was not found in PATH"
  exit 1
fi

mapfile -t pkglist < <(
  jq -r '.[].identifier.id' "$EXTENSIONS_FILE"
)

if [[ ${#pkglist[@]} -eq 0 ]]; then
  echo "[ERROR:] No extension ids were found in $EXTENSIONS_FILE"
  exit 1
fi

echo "[INFO:] Creating VS Code profile: $PROFILE_NAME"
if ! command -v code >/dev/null 2>&1; then
  echo "[ERROR:] VS Code CLI 'code' was not found in PATH"
  exit 1
fi

code --profile "$PROFILE_NAME"

for extension_id in "${pkglist[@]}"; do
  [[ -z "$extension_id" ]] && continue
  echo "[INFO:] Installing extension into profile '$PROFILE_NAME': $extension_id"
  code --profile "$PROFILE_NAME" --install-extension "$extension_id"
done

echo "[INFO:] Finished installing extensions for profile '$PROFILE_NAME'"