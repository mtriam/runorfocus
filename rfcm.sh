#!/usr/bin/env bash
set -euo pipefail

TAG="$1"
APPID="$2"
shift 2
CMD="$*"

[ -n "$TAG" ] && [ -n "$APPID" ] && [ -n "$CMD" ] || exit 1

clients_data=$(mmsg get all-clients)
mapfile -t rows < <(echo "$clients_data" |
  jq -r --arg appid "$APPID" '.clients[] | select(.appid==$appid) | [.appid, .id, (.tags[0]//""), (.is_focused|tostring)] | @tsv')

appids=(); ids=(); tags=(); is_focused=()
for r in "${rows[@]}"; do
  IFS=$'\t' read -r a i g f <<< "$r"
  appids+=("$a"); ids+=("$i"); tags+=("$g"); is_focused+=("$f")
done

appids_count=${#appids[@]}

# no appid
if [ "$appids_count" -eq 0 ]; then
  if [[ "$TAG" =~ ^[1-9]$ ]]; then
    mmsg dispatch tag,"$TAG" >/dev/null 2>&1
  fi
  eval "$CMD" &
  exit 0
fi

if [ "$appids_count" -eq 1 ]; then
  if [ "${is_focused[0]}" = "true" ]; then
    mmsg dispatch focuslast
    exit 0
  else
    mmsg dispatch tag, "${tags[0]}"
    mmsg dispatch focusid client, "${ids[0]}"
    exit 0
  fi
fi

# more than one window, cycle
if [ "$appids_count" -gt 1 ]; then
  focus_idx=-1
  for i in "${!is_focused[@]}"; do
    if [ "${is_focused[$i]}" = "true" ]; then
      focus_idx=$i
      break
    fi
  done
  if [ "$focus_idx" -ge 0 ]; then
    next_idx=$(( (focus_idx + 1) % appids_count ))
  else
    next_idx=0
  fi
  mmsg dispatch tag, "${tags[$next_idx]}"
  mmsg dispatch focusid client, "${ids[$next_idx]}"
  exit 0
fi

