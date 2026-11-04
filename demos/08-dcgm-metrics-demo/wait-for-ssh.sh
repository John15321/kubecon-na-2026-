#!/usr/bin/env bash
#
# Folders 07, 08, and 09 have no instance of their own. They run on folder
# 03's instance. This reuses folder 05's SSH key and state
# (ssh/aws-state.json), waits for sshd, then gives you a prompt to type ssh
# and this folder's kubectl commands live.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

REF05="../05-nvidia-driver-on-flatcar-aws"
SSH_KEY="${REF05}/ssh/demo_ed25519"
STATE_FILE="${REF05}/ssh/aws-state.json"
REGION="${AWS_REGION:-us-east-1}"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "No ${STATE_FILE} found -- bring up folder 05 first (./run.sh there)." >&2
    exit 1
fi

INSTANCE_ID="$(python3 -c "import json;print(json.load(open('$STATE_FILE'))['instance_id'])")"
PUBLIC_IP="$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"

echo "Targeting folder 05's instance (${INSTANCE_ID}, ${PUBLIC_IP})."
echo "Waiting for sshd on :22..."
until (exec 3<>"/dev/tcp/${PUBLIC_IP}/22") 2>/dev/null; do
    sleep 2
done
exec 3>&- 3<&- 2>/dev/null || true

# Small buffer: the port can accept TCP a moment before sshd authenticates.
sleep 2

echo
echo "Ready. SSH in with:"
echo "  ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${PUBLIC_IP}"
echo
echo "This folder assumes folder 05's cluster is already Ready with the GPU"
echo "Operator installed. See this folder's README.md for the exact commands."
echo
exec "${SHELL:-bash}"
