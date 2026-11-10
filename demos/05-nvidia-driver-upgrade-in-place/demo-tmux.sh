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

# Set each pane's environment inside its own shell command rather than via
# tmux's -e/global-environment mechanism: a tmux SERVER can persist across
# invocations of this script (or self-restart mid-script, since it exits
# whenever it has zero sessions), so -e/global-environment state is not
# reliable to build on. This is deterministic regardless of tmux server
# state. AWS_PROFILE is explicitly unset rather than exported empty: the
# aws CLI treats an empty-but-present AWS_PROFILE as "use profile named
# ''" (not "unset"), which fails with "The config profile () could not be
# found" instead of falling back to the default profile.
if [[ -n "${AWS_PROFILE:-}" ]]; then
    AWS_PROFILE_ENV="export AWS_PROFILE=$(printf '%q' "${AWS_PROFILE}"); "
else
    AWS_PROFILE_ENV="unset AWS_PROFILE; "
fi
COMMON_ENV="${AWS_PROFILE_ENV}export AWS_REGION=$(printf '%q' "${AWS_REGION:-}") PRESENTATION_MODE=$(printf '%q' "${PRESENTATION_MODE:-}"); "
RUN_ENV="${COMMON_ENV}export AWS_SKIP_CONFIRM=$(printf '%q' "${AWS_SKIP_CONFIRM:-}"); "
SSH_ENV="${COMMON_ENV}export AUTO_SSH=$(printf '%q' "${AUTO_SSH:-}"); "

tmux new-session -d -s "$SESSION" -x 220 -y 50 "${RUN_ENV}exec ./run.sh"
tmux select-pane -t "${SESSION}:0.0" -T "Instance launch (run.sh)" 2>/dev/null || true

# "failed": a pane that exits non-zero stays visible with its error instead
# of the pane (and then, if both die quickly, the whole session) vanishing
# the instant it exits -- otherwise a fast failure looks like the
# recording just closed, with no error ever shown. A pane that exits
# cleanly (e.g. run.sh reusing an already-running instance) still closes
# as normal; plain `remain-on-exit on` would freeze that case too.
#
# Scoped to this SESSION's window (no -g), so it can't leak into and
# affect a *different* invocation of this script sharing the same
# persistent tmux server.
tmux set-option -t "$SESSION" remain-on-exit failed

tmux split-window -v -t "$SESSION" "${SSH_ENV}exec ./wait-for-ssh.sh"
tmux select-pane -t "${SESSION}:0.1" -T "SSH session" 2>/dev/null || true
# Each pane above is titled immediately after it's created, not batched at
# the end: with remain-on-exit above, a pane that finishes fast (run.sh
# reusing an already-running instance) is destroyed and tmux renumbers the
# survivor down to fill the gap (pane 1 becomes pane 0). A later, batched
# `select-pane -t :0.1` would then fail with "can't find pane: 1" -- and
# because this script has `set -e`, that single failure used to kill the
# whole script before it ever reached `attach-session`, even though a
# perfectly good (renumbered) session existed to attach to.

tmux set-option -t "$SESSION" -g pane-border-status top
tmux set-option -t "$SESSION" -g pane-border-format "#{pane_title}"

# Best-effort: pane 0 may no longer exist by this point for the same
# renumbering reason, and which pane has initial focus is cosmetic only.
tmux select-pane -t "${SESSION}:0.0" 2>/dev/null || true
tmux attach-session -t "$SESSION"
