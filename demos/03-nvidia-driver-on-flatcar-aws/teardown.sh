#!/usr/bin/env bash
#
# Terminates the EC2 instance run.sh created and deletes its security
# group. This is the only teardown for folders 03-07, which share this
# instance. Run it after the session to stop billing.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

REGION="${AWS_REGION:-us-east-1}"
STATE_FILE="ssh/aws-state.json"

echo "==> Using AWS profile '${AWS_PROFILE:-default}', region ${REGION}"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "No ${STATE_FILE} found -- nothing to tear down."
    exit 0
fi

INSTANCE_ID="$(python3 -c "import json;print(json.load(open('$STATE_FILE'))['instance_id'])")"
SG_ID="$(python3 -c "import json;print(json.load(open('$STATE_FILE'))['security_group_id'])")"

echo "==> Terminating instance ${INSTANCE_ID}"
aws ec2 terminate-instances --region "$REGION" --instance-ids "$INSTANCE_ID" >/dev/null
aws ec2 wait instance-terminated --region "$REGION" --instance-ids "$INSTANCE_ID"

echo "==> Deleting security group ${SG_ID}"
aws ec2 delete-security-group --region "$REGION" --group-id "$SG_ID" || \
    echo "    (left in place -- may still be referenced; delete manually if needed)"

rm -f "$STATE_FILE"
echo "==> Done. Billing for this instance has stopped."
echo "    (The EC2 key pair 'flatcar-gpu-demo-$(whoami)' is left registered in AWS --"
echo "     it's free to keep, delete it yourself with 'aws ec2 delete-key-pair' if you want it gone.)"
