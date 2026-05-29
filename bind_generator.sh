#!/usr/bin/env bash

i=1

mmsg get all-clients | jq -r '.clients[].appid' | uniq | while read -r appid; do
    desktop_file=$(grep -Rl --exclude-dir={icons,icon-theme.cache} \
        "$appid" /usr/share/applications ~/.local/share/applications 2>/dev/null | head -n1)

    exec_cmd=$(grep "^Exec=" "$desktop_file" 2>/dev/null | head -n1 | sed 's/^Exec=//;s/ %.*//' )

    echo "bind = SUPER,$i,spawn, ~/.local/bin/rfcm c $appid $exec_cmd"

    ((i++))
done
