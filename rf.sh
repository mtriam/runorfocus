#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 5 ]; then
  exit 1
fi

TAG="$1"
APPID="$2"
WINDOW_TITLE="$3"
IGNORE_TITLE="$4"
shift 4
CMD="$*"

[ -n "$TAG" ] && [ -n "$CMD" ] && { [ -n "$APPID" ] || [ -n "$WINDOW_TITLE" ]; } || exit 1

clients_data=$(mmsg get all-clients)
mapfile -t rows < <(echo "$clients_data" |
  jq -r --arg appid "$APPID" --arg window_title "$WINDOW_TITLE" --arg ignore_title "$IGNORE_TITLE" '
    .clients[] |
    select(
      ($appid == "" or .appid == $appid)
      and
      ($window_title == "" or ((.title // "" | ascii_downcase) | contains($window_title | ascii_downcase)))
      and
      ($ignore_title == "" or ((.title // "" | ascii_downcase) | contains($ignore_title | ascii_downcase) | not))
    )
    | [.appid, .title, .id, (.tags[0]//""), (.is_focused|tostring)] | @tsv')

appids=(); window_title=(); ids=(); tags=(); is_focused=()
for r in "${rows[@]}"; do
  IFS=$'\t' read -r a t i g f <<< "$r"
  appids+=("$a"); window_title+=("$t"); ids+=("$i"); tags+=("$g"); is_focused+=("$f")
 done
matching_count=${#appids[@]}

# no matches
if [ "$matching_count" -eq 0 ]; then
  if [[ "$TAG" =~ ^[1-9]$ ]]; then
    mmsg dispatch view,"$TAG" >/dev/null 2>&1
  fi
  eval "$CMD" &
  exit 0
fi

if [ "$matching_count" -eq 1 ]; then
  if [ "${is_focused[0]}" = "true" ]; then
    mmsg dispatch focuslast
    exit 0
  else
    mmsg dispatch view, "${tags[0]}"
    mmsg dispatch focusid client, "${ids[0]}"
    exit 0
  fi
fi

# more than one window, cycle
if [ "$matching_count" -gt 1 ]; then
  focus_idx=-1
  for i in "${!is_focused[@]}"; do
    if [ "${is_focused[$i]}" = "true" ]; then
      focus_idx=$i
      break
    fi
  done
  if [ "$focus_idx" -ge 0 ]; then
    next_idx=$(( (focus_idx + 1) % matching_count ))
  else
    next_idx=0
  fi
  mmsg dispatch view, "${tags[$next_idx]}"
  mmsg dispatch focusid client, "${ids[$next_idx]}"
  exit 0
fi

