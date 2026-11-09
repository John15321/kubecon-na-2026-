#!/usr/bin/env bash
#
# tmux split top/bottom, so one asciinema recording shows the launch output
# and the SSH session.
#
# Top pane:    run.sh (launches this folder's own instance, prints its IP)
# Bottom pane: waits for sshd, then gives you a prompt to type ssh and the
#              in-place sysext-swap walkthrough live.
#
# Record with:
#   asciinema rec demo.cast -c ./demo-tmux.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SESSION="flatcar-driver-upgrade-demo"

tmux kill-session -t "$SESSION" 2>/dev/null || true

tmux new-session -d -s "$SESSION" -x 220 -y 50 \
    -e "AWS_PROFILE=${AWS_PROFILE:-}" -e "AWS_REGION=${AWS_REGION:-}" -e "AWS_SKIP_CONFIRM=${AWS_SKIP_CONFIRM:-}" \
    './run.sh'
tmux split-window -v -t "$SESSION" \
    -e "AWS_PROFILE=${AWS_PROFILE:-}" -e "AWS_REGION=${AWS_REGION:-}" \
    './wait-for-ssh.sh'

tmux set-option -t "$SESSION" -g pane-border-status top
tmux set-option -t "$SESSION" -g pane-border-format "#{pane_title}"
tmux select-pane -t "${SESSION}:0.0" -T "Instance launch (run.sh)"
tmux select-pane -t "${SESSION}:0.1" -T "SSH session"

tmux select-pane -t "${SESSION}:0.0"
tmux attach-session -t "$SESSION"
