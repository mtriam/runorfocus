#!/usr/bin/env bash
set -euo pipefail

TAG=""
APPID=""
WINDOW_TITLE=""
IGNORE_TITLE=""
COMMAND=""
CMD=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    -t|--tag)
      [ "$#" -ge 2 ] || exit 1
      TAG="$2"
      shift 2
      ;;
    -T|--title)
      [ "$#" -ge 2 ] || exit 1
      WINDOW_TITLE="$2"
      shift 2
      ;;
    -a|--appid)
      [ "$#" -ge 2 ] || exit 1
      APPID="$2"
      shift 2
      ;;
    -i|--ignore)
      [ "$#" -ge 2 ] || exit 1
      IGNORE_TITLE="$2"
      shift 2
      ;;
    -c|--command)
      [ "$#" -ge 2 ] || exit 1
      COMMAND="$2"
      shift 2
      ;;
    --)
      shift
      CMD=("$@")
      break
      ;;
    *)
      exit 1
      ;;
  esac
 done

wait_for_window() {
  local max_checks=15
  local check=0

  while [ "$check" -lt "$max_checks" ]; do
    local opened_count
    opened_count=$(mmsg get all-clients | jq -r --arg appid "$APPID" --arg window_title "$WINDOW_TITLE" --arg ignore_title "$IGNORE_TITLE" '
      [.clients[] |
        select(
          ($appid == "" or .appid == $appid)
          and
          ($window_title == "" or ((.title // "" | ascii_downcase) | contains($window_title | ascii_downcase)))
          and
          ($ignore_title == "" or ((.title // "" | ascii_downcase) | contains($ignore_title | ascii_downcase) | not))
        )
      ] | length')

    if [ "$opened_count" -gt 0 ]; then
      return 0
    fi

    sleep 0.2
    check=$((check + 1))
  done

  return 1
}

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
  [ "${#CMD[@]}" -gt 0 ] || exit 1
  if [[ "$TAG" =~ ^[1-9]$ ]]; then
    mmsg dispatch view,"$TAG" >/dev/null 2>&1
  fi
    env "${CMD[@]}" &
  if [ -n "$COMMAND" ] && wait_for_window; then
    mmsg dispatch "$COMMAND" >/dev/null 2>&1
  fi
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
