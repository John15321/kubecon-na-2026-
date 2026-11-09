#!/usr/bin/env bash
#
# 05 - Boot a SEPARATE g4dn.xlarge EC2 instance (not folder 04's) on the
# latest Flatcar alpha build, 4865.0.0, explicitly pinned to driver branch
# 570-open via Ignition. The demo then swaps it to 580-open IN PLACE, on
# this same OS build, by editing /etc/flatcar/enabled-sysext.conf and
# rebooting -- no update_engine OS version bump involved.
#
# A separate instance keeps folder 04's Kubernetes and GPU Operator state
# out of the swap. This instance has only Flatcar and the driver.
#
# This creates REAL BILLED AWS INFRASTRUCTURE, a second g4dn.xlarge on top
# of folder 04's (about $0.53/hr). Run this folder's own ./teardown.sh when
# done. It is independent of folder 04's teardown.
#
# Re-running is safe: if ssh/aws-state.json points at a running instance,
# this reuses it instead of launching a second one.
#
# Options:
#   SPOT=1             request a cheaper Spot instance (rehearsal only)
#   AWS_PROFILE=<name> pick an AWS CLI profile
#   AWS_SKIP_CONFIRM=1 skip the launch confirmation prompt

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

REGION="${AWS_REGION:-us-east-1}"
AMI_ID="ami-0d621daa0dadf89f4"   # Flatcar-alpha-4865.0.0-hvm, us-east-1 -- confirmed via describe-images
INSTANCE_TYPE="g4dn.xlarge"       # NVIDIA T4 (Turing) -- same as folder 04
SSH_KEY_DIR="ssh"
SSH_KEY="${SSH_KEY_DIR}/demo_ed25519"
BUTANE_TEMPLATE="config.bu"
IGNITION_CONFIG="config.ign"
STATE_FILE="${SSH_KEY_DIR}/aws-state.json"
NAME_TAG="flatcar-nvidia-upgrade-demo"

if [[ "$AMI_ID" != ami-0d621daa0dadf89f4 && "$REGION" != "us-east-1" ]]; then
    echo "WARNING: AMI_ID above is specific to us-east-1. If you change AWS_REGION," >&2
    echo "re-resolve the correct AMI id for build 4865.0.0 in that region first:" >&2
    echo "  curl -sL https://alpha.release.flatcar-linux.net/amd64-usr/4865.0.0/flatcar_production_ami_hvm_<region>.txt" >&2
fi

command -v aws >/dev/null || { echo "aws CLI not found"; exit 1; }
command -v docker >/dev/null || { echo "docker not found (needed for butane)"; exit 1; }
command -v ssh-keygen >/dev/null || { echo "ssh-keygen not found"; exit 1; }

# --- 0. Which AWS identity is this about to bill? ---------------------------
echo "==> AWS identity check (profile: ${AWS_PROFILE:-default})"
if PROFILES="$(aws configure list-profiles 2>/dev/null)"; then
    echo "    Configured profiles: $(echo "$PROFILES" | paste -sd, -)"
fi
CALLER_IDENTITY="$(aws sts get-caller-identity --output json)" || {
    echo "Could not call 'aws sts get-caller-identity' -- check your credentials/profile" >&2
    echo "(set AWS_PROFILE=<name> to pick a specific one, e.g. AWS_PROFILE=kubecon-demo ./run.sh)" >&2
    exit 1
}
ACCOUNT_ID="$(python3 -c "import json,sys;print(json.load(sys.stdin)['Account'])" <<< "$CALLER_IDENTITY")"
CALLER_ARN="$(python3 -c "import json,sys;print(json.load(sys.stdin)['Arn'])" <<< "$CALLER_IDENTITY")"
echo "    Account:  ${ACCOUNT_ID}"
echo "    Identity: ${CALLER_ARN}"
echo "    Region:   ${REGION}"

# --- Resume if already provisioned -----------------------------------------
if [[ -f "$STATE_FILE" ]]; then
    INSTANCE_ID="$(python3 -c "import json;print(json.load(open('$STATE_FILE'))['instance_id'])")"
    STATE="$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")"
    if [[ "$STATE" == "running" || "$STATE" == "pending" ]]; then
        PUBLIC_IP="$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"
        echo "==> Instance ${INSTANCE_ID} already exists (state: ${STATE})."
        echo "    Public IP: ${PUBLIC_IP}"
        echo "    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${PUBLIC_IP}"
        exit 0
    else
        echo "==> Stale state file (instance ${INSTANCE_ID} is '${STATE}'); provisioning fresh."
        rm -f "$STATE_FILE"
    fi
fi

# --- 1. Throwaway SSH keypair -----------------------------------------------
if [[ ! -f "$SSH_KEY" ]]; then
    echo "==> Generating a throwaway SSH keypair for this demo"
    mkdir -p "$SSH_KEY_DIR"
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "flatcar-nvidia-upgrade-demo" -q
fi
SSH_PUBLIC_KEY="$(cat "${SSH_KEY}.pub")"

# --- 2. Render Butane -> Ignition --------------------------------------------
echo "==> Transpiling config.bu to Ignition JSON"
sed "s#__SSH_PUBLIC_KEY__#${SSH_PUBLIC_KEY}#" "$BUTANE_TEMPLATE" \
    | docker run --rm -i quay.io/coreos/butane:latest --pretty --strict \
    > "$IGNITION_CONFIG"

# --- 3. Import the keypair into AWS -----------------------------------------
KEY_NAME="flatcar-nvidia-upgrade-demo-$(whoami)"
if ! aws ec2 describe-key-pairs --region "$REGION" --key-names "$KEY_NAME" >/dev/null 2>&1; then
    echo "==> Importing SSH key into EC2 as '${KEY_NAME}'"
    aws ec2 import-key-pair --region "$REGION" --key-name "$KEY_NAME" \
        --public-key-material "fileb://${SSH_KEY}.pub" >/dev/null
fi

# --- 4. Security group: SSH from this machine's IP only --------------------
MY_IP="$(curl -s https://checkip.amazonaws.com)/32"
SG_NAME="flatcar-nvidia-upgrade-demo-sg"
SG_ID="$(aws ec2 describe-security-groups --region "$REGION" \
    --filters "Name=group-name,Values=${SG_NAME}" \
    --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)"
if [[ -z "$SG_ID" || "$SG_ID" == "None" ]]; then
    VPC_ID="$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=isDefault,Values=true" \
        --query 'Vpcs[0].VpcId' --output text)"
    echo "==> Creating security group '${SG_NAME}' (SSH from ${MY_IP} only)"
    SG_ID="$(aws ec2 create-security-group --region "$REGION" --group-name "$SG_NAME" \
        --description "flatcar-nvidia-upgrade-demo: SSH only" --vpc-id "$VPC_ID" --query 'GroupId' --output text)"
    aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG_ID" \
        --protocol tcp --port 22 --cidr "$MY_IP" >/dev/null
fi

# --- 5. Launch ---------------------------------------------------------------
SPOT_ARGS=()
if [[ "${SPOT:-0}" == "1" ]]; then
    echo "==> SPOT=1: requesting a Spot instance (cheaper, can be reclaimed -- rehearsal/testing only)"
    SPOT_ARGS=(--instance-market-options 'MarketType=spot')
fi

echo "==> About to launch ${INSTANCE_TYPE} (${AMI_ID}, Flatcar alpha 4865.0.0) in ${REGION}"
echo "    under account ${ACCOUNT_ID} (${CALLER_ARN}), profile '${AWS_PROFILE:-default}'."
echo "    This is a SECOND instance, separate from folder 04's. Billing starts on"
echo "    confirmation (~\$0.53/hr on-demand for g4dn.xlarge). Run ./teardown.sh when done."
if [[ "${AWS_SKIP_CONFIRM:-0}" != "1" ]]; then
    read -r -p "    Proceed? [y/N] " REPLY
    [[ "$REPLY" =~ ^[Yy]$ ]] || { echo "Aborted -- nothing launched."; exit 1; }
fi
INSTANCE_ID="$(aws ec2 run-instances --region "$REGION" \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --user-data "file://${IGNITION_CONFIG}" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME_TAG}}]" \
    "${SPOT_ARGS[@]}" \
    --query 'Instances[0].InstanceId' --output text)"

python3 -c "
import json
json.dump({'instance_id': '$INSTANCE_ID', 'security_group_id': '$SG_ID', 'key_name': '$KEY_NAME', 'region': '$REGION'}, open('$STATE_FILE', 'w'))
"

echo "==> Waiting for ${INSTANCE_ID} to reach 'running'..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

PUBLIC_IP="$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"

echo "==> Instance running: ${INSTANCE_ID} (${PUBLIC_IP})"
echo "    Ignition sets nvidia-drivers-570-open and merges it via systemd-sysext on first boot."
echo "    Once SSH is reachable (see wait-for-ssh.sh / demo-tmux.sh):"
echo "      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${PUBLIC_IP}"
echo "    See README.md for the in-place sysext swap to 580-open walkthrough."
