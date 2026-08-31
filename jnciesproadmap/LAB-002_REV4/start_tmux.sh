#!/bin/bash
# Start a new tmux session and split it into 4 panes for r1, r2, r3, r4
tmux new-session -d -s lab002 'ssh admin@r1'
tmux split-window -h 'ssh admin@r2'
tmux split-window -v 'ssh admin@r3'
tmux attach-session -t lab002

