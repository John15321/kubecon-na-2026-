#!/usr/bin/env bash
#
# Folder 07 runs against folder 05's instance (no infra of its own), so
# there is no launch pane -- just one SSH pane. It waits for sshd on folder
# 05's box, then drops you at a prompt to type `ssh` and the vLLM demo
# commands (kubectl apply -f vllm-demo.yaml, the curl, the scale beat) live.
#
# Precondition: folder 05 is up and its cluster is Ready with the GPU
# Operator installed. Record with:
#   asciinema rec demo.cast -c ./demo-tmux.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SESSION="flatcar-vllm-demo"
tmux kill-session -t "$SESSION" 2>/dev/null || true

tmux new-session -d -s "$SESSION" -x 220 -y 50 \
    -e "AWS_PROFILE=${AWS_PROFILE:-}" -e "AWS_REGION=${AWS_REGION:-}" \
    './wait-for-ssh.sh'

tmux set-option -t "$SESSION" -g pane-border-status top
tmux set-option -t "$SESSION" -g pane-border-format "#{pane_title}"
tmux select-pane -t "${SESSION}:0.0" -T "vLLM demo (folder 05 instance)"

tmux attach-session -t "$SESSION"
