#!/usr/bin/env bash
set -euo pipefail


TAG="$1"
APPID="$2"
shift 2
CMD="$*"

[ -z "$TAG" ] && exit 1
[ -z "$APPID" ] && exit 1
[ -z "$CMD" ] && exit 1

appids=()
titles=()
while IFS= read -r line; do
  if [[ "$line" == *": "* ]]; then
    current_appid="${line%%: *}"
    current_title="${line#*: }"
    if [[ "$current_appid" == "$APPID" ]]; then
      appids+=("$current_appid")
      titles+=("$current_title")
    fi
  fi
done < <(wlrctl window list)


# no appid
if [ "${#appids[@]}" -eq 0 ]; then
  if [[ "$TAG" =~ ^[1-9]$ ]]; then
    echo $TAG
    mmsg -s -t "$TAG" >/dev/null 2>&1
  fi
  eval "$CMD" &
  exit 0
fi

# only one appid,focus it
if [ "${#appids[@]}" -eq 1 ]; then
  wlrctl window focus "app_id:$APPID"
  exit 0
fi

# more than one window, cycle
active_title="$(mmsg -g -c 2>/dev/null | tr -d '\r' | awk '/title/ { sub(/.*title[: ]+/, ""); print; exit }' || true)"
active_title="${active_title:-}"

current=-1
for i in "${!titles[@]}"; do
  if [ "$active_title" = "${titles[$i]}" ]; then
    current=$i
    break
  fi
done

# no active window or active window's title doesn't match any, focus the first one
if [ "$current" -eq -1 ]; then
  wlrctl window focus "title:${titles[0]}" "app_id:$APPID"
  exit 0
fi


# current_title is duplicate: advance focus until matching appid is found
# or advance to next tag with windows and repeat.
CURRENT_TAG="$(mmsg -g -t | awk '$2 == "tag" && $6 > 0 {print $3; exit}')"
TAGS_WITH_WINDOWS=($(mmsg -g -t | awk '$2 == "tag" && $5 > 0 {print $3}'))

# helper to try finding appid on the current tag by cycling windows
try_find_on_tag() {
  local tag="$1"
  local windows_on_tag
  windows_on_tag=$(mmsg -g -t | awk -v tag="$tag" '$2 == "tag" && $3 == tag {print $5; exit}')
  if [[ -z "$windows_on_tag" || "$windows_on_tag" -le 0 ]]; then
    return 1
  fi
  local steps=$((windows_on_tag - 1))

  local i
  local current_appid
  for ((i = 1; i <= steps; i++)); do
    mmsg -d focusstack, next >/dev/null 2>&1
    current_appid=$(mmsg -g -c | grep -o 'appid [^ ]*' | cut -d' ' -f2 || true)
    if [[ "$current_appid" == "$APPID" ]]; then
      return 0
    fi
  done
  return 1
}

# Start searching from CURRENT_TAG and then subsequent tags in TAGS_WITH_WINDOWS
found=1
start_idx=0
for idx in "${!TAGS_WITH_WINDOWS[@]}"; do
  if [[ "${TAGS_WITH_WINDOWS[$idx]}" == "$CURRENT_TAG" ]]; then
    start_idx=$idx
    break
  fi
done

total_tags=${#TAGS_WITH_WINDOWS[@]}
for ((offset = 0; offset < total_tags; offset++)); do
  idx=$(( (start_idx + offset) % total_tags ))
  tag=${TAGS_WITH_WINDOWS[$idx]}
  mmsg -s -t "$tag" >/dev/null 2>&1
  if try_find_on_tag "$tag"; then
    found=0
    break
  fi
done

if [ "$found" -eq 0 ]; then
  exit 0
fi

# restore original tag if nothing found
mmsg -s -t "$CURRENT_TAG" >/dev/null 2>&1
