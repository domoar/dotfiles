#!/usr/bin/env bash

set -euo pipefail

# storage.json finden – Windows (Git-Bash) nutzt %APPDATA%, sonst ~/.config
if [ -n "${APPDATA:-}" ]; then
  STORAGE="$APPDATA/Code/User/globalStorage/storage.json"
else
  STORAGE="$HOME/.config/Code/User/globalStorage/storage.json"
fi

python3 -c "
import json, sys
data = json.load(open(r'$STORAGE'))
for p in data.get('userDataProfiles', []):
    print(f\"{p['name']} -> {p['location']}\")
"