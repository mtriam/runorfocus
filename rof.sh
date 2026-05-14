#!/usr/bin/env bash

FALLBACK="$1"
APPID="$2"
PROCESS_NAME="$3"
shift 3
CMD="$*"


CURRENT_TAG="$(mmsg -g -t | awk '$2 == "tag" && $6 > 0 {print $3; exit}')"
TAGS_WITH_WINDOWS=($(mmsg -g -t | awk '$2 == "tag" && $5 > 0 {print $3}'))
# resolve fallback
if [[ "$FALLBACK" == "c" ]]; then
    FALLBACK_TAG="$CURRENT_TAG"
else
    FALLBACK_TAG="$FALLBACK"
fi

is_process_running() {
    local pattern="$1"
    local pid

    if pgrep -x -- "$pattern" >/dev/null 2>&1; then
        return 0
    fi

    while read -r pid; do
        [[ -z "$pid" ]] && continue
        [[ "$pid" == "$$" || "$pid" == "$PPID" ]] && continue
        return 0
    done < <(pgrep -f -- "$pattern" 2>/dev/null)

    return 1
}

if [[ -n "$PROCESS_NAME" ]] && ! is_process_running "$PROCESS_NAME"; then
    mmsg -s -t "$FALLBACK_TAG" >/dev/null 2>&1
    exec bash -c "$CMD"
    exit 1
fi

has_appid_on_current_tag() {
    local include_current="${1:-0}"
    local initial_output
    initial_output=$(mmsg -g -c)
    local initial_appid
    initial_appid=$(echo "$initial_output" | grep -o 'appid [^ ]*' | cut -d' ' -f2)
    local active_tag
    active_tag=$(mmsg -g -t | awk '$2 == "tag" && $6 > 0 {print $3; exit}')
    local windows_on_tag
    windows_on_tag=$(mmsg -g -t | awk -v tag="$active_tag" '$2 == "tag" && $3 == tag {print $5; exit}')
    local steps
    steps=$((windows_on_tag - 1))

    if [[ "$include_current" == "1" && "$initial_appid" == "$APPID" ]]; then
        return 0
    fi

    if (( steps <= 0 )); then
        return 1
    fi

    local i
    local current_output
    local current_appid
    for ((i = 1; i <= steps; i++)); do
        mmsg -d focusstack, next >/dev/null 2>&1
                current_output=$(mmsg -g -c)
        current_appid=$(echo "$current_output" | grep -o 'appid [^ ]*' | cut -d' ' -f2)
        if [[ "$current_appid" == "$APPID" ]]; then
            return 0
        fi
    done
    return 1
}

ACTIVE_WINDOW_INFO="$(mmsg -g -c)"
if echo "$ACTIVE_WINDOW_INFO" | grep -qi "appid $APPID"; then
    FOUND_NEXT=0
    if has_appid_on_current_tag 0; then
        FOUND_NEXT=1
    fi
    if [[ "$FOUND_NEXT" -eq 0 && "$FALLBACK_TAG" != "$CURRENT_TAG" && " ${TAGS_WITH_WINDOWS[*]} " == *" $FALLBACK_TAG "* ]]; then
        mmsg -s -t "$FALLBACK_TAG" >/dev/null 2>&1
                if has_appid_on_current_tag 1; then
            FOUND_NEXT=1
        fi
    fi
    if [[ "$FOUND_NEXT" -eq 0 ]]; then
        for TAG in "${TAGS_WITH_WINDOWS[@]}"; do
            if (( TAG > CURRENT_TAG )); then
                mmsg -s -t "$TAG" >/dev/null 2>&1
                                if has_appid_on_current_tag 1; then
                    FOUND_NEXT=1
                    break
                fi
            fi
        done
        if [[ "$FOUND_NEXT" -eq 0 ]]; then
            for TAG in "${TAGS_WITH_WINDOWS[@]}"; do
                if (( TAG < CURRENT_TAG )); then
                    mmsg -s -t "$TAG" >/dev/null 2>&1
                                        if has_appid_on_current_tag 1; then
                        FOUND_NEXT=1
                        break
                    fi
                fi
            done
        fi
    fi
    if [[ "$FOUND_NEXT" -eq 0 ]]; then
        mmsg -s -t "$CURRENT_TAG" >/dev/null 2>&1
    fi
    exit 0
else
    FOUND=0
    if [[ " ${TAGS_WITH_WINDOWS[*]} " == *" $FALLBACK_TAG "* ]]; then
        mmsg -s -t "$FALLBACK_TAG" >/dev/null 2>&1
                if has_appid_on_current_tag 1; then
            exit 0
        fi
    fi
    for TAG in "${TAGS_WITH_WINDOWS[@]}"; do
        if [[ "$TAG" == "$FALLBACK_TAG" ]]; then
            continue
        fi
        mmsg -s -t "$TAG" >/dev/null 2>&1
                if has_appid_on_current_tag 1; then
            FOUND=1
            break
        fi
    done
    if [[ "$FOUND" -eq 1 ]]; then
        exit 0
    fi
    mmsg -s -t "$FALLBACK_TAG" >/dev/null 2>&1
    bash -c "$CMD" &
fi
