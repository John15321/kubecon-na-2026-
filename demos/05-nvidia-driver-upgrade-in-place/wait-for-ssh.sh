#!/usr/bin/env bash
#
# Waits for this folder's EC2 instance's SSH port, then gives you a prompt
# so you type the ssh command live.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SSH_KEY="ssh/demo_ed25519"
STATE_FILE="ssh/aws-state.json"
REGION="${AWS_REGION:-us-east-1}"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "No ${STATE_FILE} found -- run ./run.sh first." >&2
    exit 1
fi

INSTANCE_ID="$(python3 -c "import json;print(json.load(open('$STATE_FILE'))['instance_id'])")"
PUBLIC_IP="$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"

echo "Waiting for Flatcar (${INSTANCE_ID}, ${PUBLIC_IP}) to finish booting and sshd to come up on :22..."
until (exec 3<>"/dev/tcp/${PUBLIC_IP}/22") 2>/dev/null; do
    sleep 2
done
exec 3>&- 3<&- 2>/dev/null || true

sleep 2

echo
echo "Ready. SSH in with:"
echo "  ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${PUBLIC_IP}"
echo
echo "This instance booted on Flatcar alpha 4865.0.0 with nvidia-drivers-570-open (pinned at boot)."
echo "See README.md for the in-place sysext swap to nvidia-drivers-580-open, live, on this same build."
echo

# AUTO_SSH=1: skip typing the command above live and connect directly.
# Useful when re-recording a take against an instance that's already up.
if [[ "${AUTO_SSH:-0}" == "1" ]]; then
    exec ssh -i "${SSH_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "core@${PUBLIC_IP}"
fi

exec "${SHELL:-bash}"
