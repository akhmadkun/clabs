#!/usr/bin/env bash

SESSION="juniper-lab"

# Jangan buat session kalau sudah ada
tmux has-session -t "$SESSION" 2>/dev/null && tmux attach -t "$SESSION" && exit 0

# Pane 0 → R1
tmux new-session -d -s "$SESSION" "ssh admin@r1"

# Pane 1 → R2
tmux split-window -h "ssh admin@r3"

# Pane 2 → R3
tmux split-window -v "ssh admin@r4"

# Fokus ke R1
tmux select-pane -t "$SESSION:0.0"
# Pane 3 → R4
tmux split-window -v "ssh admin@r2"
# Fokus ke R1
tmux select-pane -t "$SESSION:0.0"


# Attach
tmux attach-session -t "$SESSION"
