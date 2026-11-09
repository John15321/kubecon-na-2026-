#!/usr/bin/env bash
#
# Folder 07 is inherently a two-pane demo: fire vLLM requests in one pane
# and watch GPU utilization react in the other. Both panes SSH into folder
# 04's instance (no infra of its own). Each waits for sshd, then drops you
# at a prompt so you type the commands live -- see README.md:
#   Pane A: a curl loop against vLLM (folder 06 must be running)
#   Pane B: watch -n1 the dcgm-exporter /metrics for DCGM_FI_DEV_GPU_UTIL
#
# Precondition: folder 04 is up, GPU Operator installed, and folder 06's
# vLLM Deployment is already Running. Record with:
#   asciinema rec demo.cast -c ./demo-tmux.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SESSION="flatcar-dcgm-demo"
tmux kill-session -t "$SESSION" 2>/dev/null || true

tmux new-session -d -s "$SESSION" -x 220 -y 50 \
    -e "AWS_PROFILE=${AWS_PROFILE:-}" -e "AWS_REGION=${AWS_REGION:-}" \
    './wait-for-ssh.sh'
tmux split-window -v -t "$SESSION" \
    -e "AWS_PROFILE=${AWS_PROFILE:-}" -e "AWS_REGION=${AWS_REGION:-}" \
    './wait-for-ssh.sh'

tmux set-option -t "$SESSION" -g pane-border-status top
tmux set-option -t "$SESSION" -g pane-border-format "#{pane_title}"
tmux select-pane -t "${SESSION}:0.0" -T "Pane A: vLLM request loop"
tmux select-pane -t "${SESSION}:0.1" -T "Pane B: DCGM GPU utilization"

tmux select-pane -t "${SESSION}:0.0"
tmux attach-session -t "$SESSION"
