#!/usr/bin/env bash
# One LOCAL tmux session per host; inside it: SSH -> attach/create REMOTE tmux session "kevin".
# Safe for shared servers (no file edits).

set -euo pipefail

REMOTE_SESSION_NAME="kevin"           # fixed remote name
LOCAL_PREFIX="${LOCAL_PREFIX:-}"      # optional local prefix, e.g., "my-"
SSH_OPTS="${SSH_OPTS:--tt}"           # force a TTY for tmux
ISOLATE_REMOTE="${ISOLATE_REMOTE:-1}" # 1 = private tmux server on remote (-L)

if (($# < 1)); then
    echo "Usage: $0 host1[#LocalName] host2[#LocalName] ..."
    exit 1
fi

tmux start-server
created=()

for SPEC in "$@"; do
    if [[ "$SPEC" == *#* ]]; then
        HOST="${SPEC%%#*}"
        LNAME="${SPEC#*#}" # explicit local name
    else
        HOST="$SPEC"
        LNAME="${LOCAL_PREFIX}${HOST//[^A-Za-z0-9_.-]/_}" # auto local name from host
    fi

    if tmux has-session -t "$LNAME" 2>/dev/null; then
        echo "Local session '$LNAME' exists. Attach: tmux attach -t $LNAME"
        continue
    fi

    if [[ "$ISOLATE_REMOTE" == "1" ]]; then
        # Private remote tmux server per client-IP so you never collide with others
        REMOTE_CMD='set -- $SSH_CONNECTION; SOCK="kevin-$1"; COLORTERM=truecolor exec tmux -L "$SOCK" -u -2 new -As '"$REMOTE_SESSION_NAME"
    else
        REMOTE_CMD='COLORTERM=truecolor exec tmux -u -2 new -As '"$REMOTE_SESSION_NAME"
    fi

    tmux new-session -d -s "$LNAME" -n "$HOST" "ssh ${SSH_OPTS} ${HOST} '${REMOTE_CMD}'"
    created+=("$LNAME")
done

# Auto-attach/switch into the first created local session (which is running remote 'kevin')
if ((${#created[@]} > 0)); then
    target="${created[0]}"
    if [[ -n "${TMUX-}" ]]; then
        tmux switch-client -t "$target"
    else
        tmux attach -t "$target"
    fi
fi
