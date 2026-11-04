#!/usr/bin/env bash
#
# 02 - Single-node kubeadm cluster on Flatcar, with kubeadm, kubelet, and
# kubectl installed via systemd-sysext.
#
# Steps:
#   1. Download Flatcar's QEMU wrapper and disk image (cached after the
#      first run).
#   2. Generate a throwaway SSH keypair for this demo.
#   3. Render config.bu to Ignition JSON with the key baked in.
#   4. Boot with 4GB RAM and 2 vCPUs (kubeadm requires both). Ignition then
#      merges the Kubernetes sysext and runs kubeadm init once.
#
# After boot, SSH in. kubectl works immediately. The node is NotReady until
# you apply a CNI (see README.md).
#
# Re-running is safe. The VM disk persists across runs, so a second run
# resumes the cluster. Run reset.sh first for a fresh cluster; it restores
# the disk from a local cache instead of re-downloading.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

CHANNEL="stable"
BASE_URL="https://${CHANNEL}.release.flatcar-linux.net/amd64-usr/current"
WRAPPER="flatcar_production_qemu.sh"
IMAGE="flatcar_production_qemu_image.img"
IMAGE_ORIG="${IMAGE}.orig"
SSH_KEY_DIR="ssh"
SSH_KEY="${SSH_KEY_DIR}/demo_ed25519"
BUTANE_TEMPLATE="config.bu"
IGNITION_CONFIG="config.ign"

# --- 1. Fetch Flatcar's wrapper script + pristine disk image --------------
# Download the disk image once as IMAGE_ORIG and never touch it again.
# IMAGE is the working copy that boots and keeps cluster state. reset.sh
# deletes only IMAGE, so a fresh run restores from IMAGE_ORIG with a local
# copy instead of re-downloading.
if [[ ! -f "$WRAPPER" ]]; then
    echo "==> Downloading ${WRAPPER} (this is the only slow step, and only on first run)"
    curl -fL -o "$WRAPPER" "${BASE_URL}/${WRAPPER}"
fi
chmod +x "$WRAPPER"

if [[ ! -f "$IMAGE_ORIG" ]]; then
    echo "==> Downloading ${IMAGE} (this is the only slow step, and only on first run)"
    curl -fL -o "$IMAGE_ORIG" "${BASE_URL}/${IMAGE}"
fi

if [[ ! -f "$IMAGE" ]]; then
    echo "==> Restoring working disk image from the cached original (no re-download needed)"
    cp "$IMAGE_ORIG" "$IMAGE"
fi

# Optional GPG verification. Off by default. Set VERIFY_GPG=1 to enable.
# It verifies the pristine copy; the working copy is a local cp of it.
if [[ "${VERIFY_GPG:-0}" == "1" ]]; then
    echo "==> Verifying signatures"
    [[ -f "${WRAPPER}.sig" ]] || curl -fL -o "${WRAPPER}.sig" "${BASE_URL}/${WRAPPER}.sig"
    [[ -f "${IMAGE}.sig" ]] || curl -fL -o "${IMAGE}.sig" "${BASE_URL}/${IMAGE}.sig"
    gpg --keyserver keyserver.ubuntu.com --recv-keys 50E0885593D2DCB4
    gpg --verify "${WRAPPER}.sig" "$WRAPPER"
    gpg --verify "${IMAGE}.sig" "$IMAGE_ORIG"
fi

# --- 2. Throwaway SSH keypair for this demo --------------------------------
if [[ ! -f "$SSH_KEY" ]]; then
    echo "==> Generating a throwaway SSH keypair for this demo"
    mkdir -p "$SSH_KEY_DIR"
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "flatcar-demo" -q
fi
SSH_PUBLIC_KEY="$(cat "${SSH_KEY}.pub")"

# --- 3. Render Butane -> Ignition ------------------------------------------
echo "==> Transpiling config.bu to Ignition JSON"
sed "s#__SSH_PUBLIC_KEY__#${SSH_PUBLIC_KEY}#" "$BUTANE_TEMPLATE" \
    | docker run --rm -i quay.io/coreos/butane:latest --pretty --strict \
    > "$IGNITION_CONFIG"

# --- 4. Boot ----------------------------------------------------------------
# -M 4096 and -smp 2: kubeadm's preflight checks require at least 2 vCPUs
# and enough RAM. Flatcar's Kubernetes doc recommends 4096MB.
echo "==> Booting Flatcar (Ctrl-A X to quit QEMU)"
echo "    kubeadm init runs automatically once Ignition + systemd-sysext finish."
echo "    Once you see a login prompt, SSH in from another terminal with:"
echo "      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost"
echo
./"$WRAPPER" -i "$IGNITION_CONFIG" -M 4096 -- -nographic -smp 2
