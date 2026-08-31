#!/bin/bash
# Start a new tmux session and split it into 4 panes for R1, R2, R3, R4
tmux new-session -d -s lab001 'ssh admin@r1'
tmux split-window -v 'ssh admin@r2'
tmux attach-session -t lab001
