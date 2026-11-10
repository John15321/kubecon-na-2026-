#!/usr/bin/env bash
#
# Folder 08 runs against folder 04's instance (no infra of its own), so
# there is no launch pane -- just one SSH pane. It waits for sshd on folder
# 04's box, then drops you at a prompt to type `ssh` and the Triton demo
# commands live:
#   kubectl apply -f triton-demo.yaml   (staged on the node by folder 04's
#                                        Ignition -- server + in-cluster
#                                        client Job in one apply)
#   kubectl get pods -w
#   kubectl logs job/triton-classify
#
# Precondition: folder 04 is up and its cluster is Ready with the GPU
# Operator installed. Record with:
#   asciinema rec demo.cast -c ./demo-tmux.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SESSION="flatcar-triton-demo"
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Set the pane's environment inside its own shell command, and explicitly
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
# stays on screen instead of this pane -- the only pane in the only
# window -- vanishing the instant it exits, taking the whole session with
# it. Baked into the pane's own command rather than a separate
# `tmux set-option remain-on-exit` call after creation: this script's
# failure path is a pure local file check with no network call, so it can
# exit before a later, separate tmux command would even run. On success,
# wait-for-ssh.sh execs into a shell/ssh session and never returns, so
# this wrapper never runs.
ON_FAIL='rc=$?; if [ "$rc" -ne 0 ]; then echo; echo "[exited $rc] Press Enter to close this pane."; read -r _; fi; exit "$rc"'

tmux new-session -d -s "$SESSION" -x 220 -y 50 "${SSH_ENV}./wait-for-ssh.sh; ${ON_FAIL}"
tmux select-pane -t "${SESSION}:0.0" -T "Triton demo (folder 04 instance)" 2>/dev/null || true

tmux set-option -t "$SESSION" -g pane-border-status top
tmux set-option -t "$SESSION" -g pane-border-format "#{pane_title}"

tmux attach-session -t "$SESSION"
