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

# Set each pane's environment inside its own shell command, and explicitly
# unset AWS_PROFILE rather than exporting it empty: the aws CLI treats an
# empty-but-present AWS_PROFILE as "use profile named ''" (not "unset"),
# which fails with "The config profile () could not be found" instead of
# falling back to the default profile.
if [[ -n "${AWS_PROFILE:-}" ]]; then
    AWS_PROFILE_ENV="export AWS_PROFILE=$(printf '%q' "${AWS_PROFILE}"); "
else
    AWS_PROFILE_ENV="unset AWS_PROFILE; "
fi
SSH_ENV="${AWS_PROFILE_ENV}export AWS_REGION=$(printf '%q' "${AWS_REGION:-}") PRESENTATION_MODE=$(printf '%q' "${PRESENTATION_MODE:-}") AUTO_SSH=$(printf '%q' "${AUTO_SSH:-}"); "

# If wait-for-ssh.sh fails (e.g. folder 04 isn't up), pause so its error
# stays on screen instead of the pane -- and here, since BOTH panes run
# the identical command and would fail at the same instant -- the whole
# session vanishing with no error ever shown. Baked into each pane's own
# command rather than a separate `tmux set-option remain-on-exit` call
# after creation, since that command is a local file check with no
# network call and can race ahead of a later, separate tmux command. On
# success, wait-for-ssh.sh execs into a shell/ssh session and never
# returns, so this wrapper never runs.
ON_FAIL='rc=$?; if [ "$rc" -ne 0 ]; then echo; echo "[exited $rc] Press Enter to close this pane."; read -r _; fi; exit "$rc"'

tmux new-session -d -s "$SESSION" -x 220 -y 50 "${SSH_ENV}./wait-for-ssh.sh; ${ON_FAIL}"
tmux select-pane -t "${SESSION}:0.0" -T "Pane A: vLLM request loop" 2>/dev/null || true

tmux split-window -v -t "$SESSION" "${SSH_ENV}./wait-for-ssh.sh; ${ON_FAIL}"
tmux select-pane -t "${SESSION}:0.1" -T "Pane B: DCGM GPU utilization" 2>/dev/null || true

tmux set-option -t "$SESSION" -g pane-border-status top
tmux set-option -t "$SESSION" -g pane-border-format "#{pane_title}"

tmux select-pane -t "${SESSION}:0.0" 2>/dev/null || true
tmux attach-session -t "$SESSION"
