#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_NAME="python-lang"
TEXT_EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"
JSON_EXTENSIONS_FILE="$SCRIPT_DIR/extensions.json"

if [[ -s "$TEXT_EXTENSIONS_FILE" ]]; then
  EXTENSIONS_FILE="$TEXT_EXTENSIONS_FILE"
  EXTENSIONS_FORMAT="text"
elif [[ -f "$JSON_EXTENSIONS_FILE" ]]; then
  EXTENSIONS_FILE="$JSON_EXTENSIONS_FILE"
  EXTENSIONS_FORMAT="json"
else
  echo "[ERROR:] No extensions file found. Expected a non-empty $TEXT_EXTENSIONS_FILE or $JSON_EXTENSIONS_FILE"
  exit 1
fi

echo "[INFO:] Reading extensions from $EXTENSIONS_FILE"

if [[ "$EXTENSIONS_FORMAT" == "text" ]]; then
  mapfile -t pkglist < <(
    grep -vE '^[[:space:]]*$' "$EXTENSIONS_FILE"
  )

  printf '%s\n' '[]' > "$JSON_EXTENSIONS_FILE"
else
  if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR:] jq is required but was not found in PATH"
    exit 1
  fi

  mapfile -t pkglist < <(
    jq -r '.[].identifier.id' "$EXTENSIONS_FILE"
  )
fi

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