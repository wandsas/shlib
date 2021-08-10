. ~/lib/stdout-log.sh

# Get current tmux session.
tmux-current-session () {
    if [ "$TMUX" ]; then
        tmux display-message -pF '#{client_session}'
    fi
}

# Do we have a running system?
tmux-has-session () {
    tmux has-session -t "$1" 2>/dev/null
}

tmux-check-session-var () {
    if [ -z "$tmux_session" ]; then
        echo >&2 "caller must define \$session"
        exit 1
    fi
}

# Create new tmux session, or return existing session if it exists.
tmux-new-session () {
    if [ -z "$tmux_session" ]; then
        tmux_session="$1"
    fi

    tmux-check-session-var

    if tmux-has-session "$tmux_session"; then
        echo "$tmux_session session already exists!  Attaching ..."
        tmux-attach
        exit
    fi

    if [ -n "$TMUX" ]; then
        echo "Detach from the tmux server before running this."
        exit 1
    fi

    # The -d is necessary to allow the script to proceed
    tmux new-session -d -s "$tmux_session"
}

# Create new tmux window.
tmux-new-window () {
    tmux-check-session-var
    tmux new-window -t "$tmux_session" "$@"
}

# Attach tmux session.
tmux-attach () {
    tmux attach-session -t "$tmux_session"
}

tmux-detach () {
    tmux detach-client
}

# Kill current tmux session.
tmux-kill-session () {
    if [ -n "$TMUX" ]; then
        tmux kill-session -t $(tmux display-message -pF '#{client_session}')
    fi
}

# Find all tmux sessions and kill them.
tmux-kill-all-sessions () {
    tmux list-sessions | awk -F: '{print $1}' | xargs -n 1 tmux kill-session -t
}
