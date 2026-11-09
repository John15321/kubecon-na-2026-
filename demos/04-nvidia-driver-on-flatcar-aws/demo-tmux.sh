#!/usr/bin/env bash
#
# tmux session split top/bottom, so one asciinema recording shows both
# panes. Unlike folders 01-03 (QEMU serial console), EC2 has no live boot
# log, so the top pane shows only run.sh's launch output.
#
# Top pane:    run.sh (launches the instance, prints its public IP)
# Bottom pane: waits for sshd, then gives you a prompt to type ssh and the
#              follow-up commands live.
#
# Record with:
#   asciinema rec demo.cast -c ./demo-tmux.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SESSION="flatcar-nvidia-demo"

tmux kill-session -t "$SESSION" 2>/dev/null || true

# -e passes AWS_PROFILE/AWS_REGION into the new panes explicitly: if a tmux
# server was already running from before this shell set them, panes would
# otherwise inherit the server's original (stale) environment instead.
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
