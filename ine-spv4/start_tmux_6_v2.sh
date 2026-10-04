#!/usr/bin/env bash

SESSION="routers"

# Attach existing session
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach-session -t "$SESSION"
    exit 0
fi

# ============================================================
# WINDOW 0: 6 router panes
#
# Result:
#   R1 R2
#   R3 R4
#   R5 R6
# ============================================================

tmux new-session -d -s "$SESSION" -n lab

LEFT=$(tmux display-message -p -t "$SESSION:0.0" '#{pane_id}')

RIGHT=$(tmux split-window \
    -h \
    -p 50 \
    -t "$LEFT" \
    -P \
    -F '#{pane_id}')

# Create 3 rows on LEFT
LEFT_BOTTOM=$(tmux split-window \
    -v \
    -p 66 \
    -t "$LEFT" \
    -P \
    -F '#{pane_id}')

tmux split-window \
    -v \
    -p 50 \
    -t "$LEFT_BOTTOM" \
    -P \
    -F '#{pane_id}' >/dev/null

# Create 3 rows on RIGHT
RIGHT_BOTTOM=$(tmux split-window \
    -v \
    -p 66 \
    -t "$RIGHT" \
    -P \
    -F '#{pane_id}')

tmux split-window \
    -v \
    -p 50 \
    -t "$RIGHT_BOTTOM" \
    -P \
    -F '#{pane_id}' >/dev/null

# Find panes by visual position so the mapping stays:
#   R1 R2
#   R3 R4
#   R5 R6
mapfile -t PANES < <(
    tmux list-panes \
        -t "$SESSION:0" \
        -F '#{pane_id} #{pane_top} #{pane_left}' |
    sort -k2,2n -k3,3n |
    awk '{print $1}'
)

# Safety check
if [ "${#PANES[@]}" -ne 6 ]; then
    echo "ERROR: Expected 6 panes in window 0, found ${#PANES[@]}"
    tmux list-panes -t "$SESSION:0"
    exit 1
fi

# Start SSH in window 0
tmux send-keys -t "${PANES[0]}" 'ssh admin@R1' C-m
tmux send-keys -t "${PANES[1]}" 'ssh admin@R2' C-m
tmux send-keys -t "${PANES[2]}" 'ssh admin@R3' C-m
tmux send-keys -t "${PANES[3]}" 'ssh admin@R4' C-m
tmux send-keys -t "${PANES[4]}" 'ssh admin@R5' C-m
tmux send-keys -t "${PANES[5]}" 'ssh admin@R6' C-m

# ============================================================
# WINDOW 1: 2 XR panes
#
# Result:
#   XR1
#   XR2
# ============================================================

tmux new-window -t "$SESSION:1" -n xr

XR1=$(tmux display-message -p -t "$SESSION:1.0" '#{pane_id}')

XR2=$(tmux split-window \
    -v \
    -p 50 \
    -t "$XR1" \
    -P \
    -F '#{pane_id}')

# Start SSH in window 1
tmux send-keys -t "$XR1" 'ssh clab@XR1' C-m
tmux send-keys -t "$XR2" 'ssh clab@XR2' C-m

# Focus R1 in window 0 before attaching
# This also keeps the original first window as the default view.
tmux select-window -t "$SESSION:0"
tmux select-pane -t "${PANES[0]}"

# Attach
tmux attach-session -t "$SESSION"
