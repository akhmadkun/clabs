#!/usr/bin/env bash

SESSION="routers"

# Attach existing session
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach-session -t "$SESSION"
    exit 0
fi

# ============================================================
# Create 2 columns
# ============================================================

tmux new-session -d -s "$SESSION" -n lab

LEFT=$(tmux display-message -p -t "$SESSION:0.0" '#{pane_id}')

RIGHT=$(tmux split-window \
    -h \
    -p 50 \
    -t "$LEFT" \
    -P \
    -F '#{pane_id}')

# ============================================================
# Create 3 rows on LEFT
# ============================================================

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

# ============================================================
# Create 3 rows on RIGHT
# ============================================================

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

# ============================================================
# Find panes by their VISUAL position
#
# Sort:
#   1. top
#   2. left
#
# Result:
#   R1 R2
#   R3 R4
#   R5 R6
# ============================================================

mapfile -t PANES < <(
    tmux list-panes \
        -t "$SESSION:0" \
        -F '#{pane_id} #{pane_top} #{pane_left}' |
    sort -k2,2n -k3,3n |
    awk '{print $1}'
)

# Safety check
if [ "${#PANES[@]}" -ne 6 ]; then
    echo "ERROR: Expected 6 panes, found ${#PANES[@]}"
    tmux list-panes -t "$SESSION:0"
    exit 1
fi

# ============================================================
# Start SSH
# ============================================================

tmux send-keys -t "${PANES[0]}" 'ssh admin@R1' C-m
tmux send-keys -t "${PANES[1]}" 'ssh admin@R2' C-m
tmux send-keys -t "${PANES[2]}" 'ssh admin@R3' C-m
tmux send-keys -t "${PANES[3]}" 'ssh admin@R4' C-m
tmux send-keys -t "${PANES[4]}" 'ssh admin@R5' C-m
tmux send-keys -t "${PANES[5]}" 'ssh admin@R6' C-m

# Focus R1
tmux select-pane -t "${PANES[0]}"

# Attach
tmux attach-session -t "$SESSION"
