#!/usr/bin/env bash

set -euo pipefail

index=1

mmsg get all-clients | jq -r '.clients[].appid' | sort -u | while read -r appid; do
    [ -n "$appid" ] || continue

    desktop_file=$(grep -RIl --exclude-dir=icons --exclude='icon-theme.cache' \
        -- "$appid" /usr/share/applications ~/.local/share/applications 2>/dev/null | head -n1 || true)

    exec_cmd=""
    if [ -n "$desktop_file" ]; then
        exec_cmd=$(grep -m1 "^Exec=" "$desktop_file" 2>/dev/null | sed -E 's/^Exec=//; s/[[:space:]]%[a-zA-Z]//g')
    fi

    if [ -z "$exec_cmd" ]; then
        echo "# skipped $appid (missing Exec in desktop file)"
        continue
    fi

    echo "bind = SUPER,$index,spawn, ~/.local/bin/rf c $appid \"\" \"\" $exec_cmd"
    ((index++))
done
