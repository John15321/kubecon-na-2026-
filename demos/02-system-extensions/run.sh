#!/usr/bin/env bash
#
# 02 - Add software to Flatcar with a systemd-sysext.
#
# Flatcar's /usr is read-only and there is no package manager. A system
# extension (sysext) is a squashfs image that systemd merges over /usr at
# boot. Here Ignition fetches the official Kubernetes sysext and drops it in
# /etc/extensions; systemd-sysext merges it, and kubeadm, kubelet, and
# kubectl appear without touching the base OS.
#
# This folder stops at "the binaries are now present." Folder 03 takes the
# same sysext further and bootstraps an actual cluster.
#
# Steps:
#   1. Download Flatcar's QEMU wrapper script and disk image (cached after
#      the first run).
#   2. Generate a throwaway SSH keypair for this demo.
#   3. Render config.bu (Butane) to Ignition JSON with the key baked in.
#   4. Boot Flatcar, serial console on this terminal. Ignition downloads the
#      sysext during boot, so this boot needs network access.
#
# Re-running is safe: anything already downloaded or generated is reused.

set -euo pipefail

# Always operate relative to this folder, no matter where it's invoked from.
cd "$(dirname "${BASH_SOURCE[0]}")"

CHANNEL="stable"
BASE_URL="https://${CHANNEL}.release.flatcar-linux.net/amd64-usr/current"
WRAPPER="flatcar_production_qemu.sh"
IMAGE="flatcar_production_qemu_image.img"
SSH_KEY_DIR="ssh"
SSH_KEY="${SSH_KEY_DIR}/demo_ed25519"
BUTANE_TEMPLATE="config.bu"
IGNITION_CONFIG="config.ign"

# --- 1. Fetch Flatcar's wrapper script + disk image -----------------------
# The image is already qcow2 despite the .img extension. No decompression
# step is needed.
for f in "$WRAPPER" "$IMAGE"; do
    if [[ ! -f "$f" ]]; then
        echo "==> Downloading ${f} (this is the only slow step, and only on first run)"
        curl -fL -o "$f" "${BASE_URL}/${f}"
    fi
done
chmod +x "$WRAPPER"

# Optional GPG verification. Off by default. Set VERIFY_GPG=1 to turn it
# on.
if [[ "${VERIFY_GPG:-0}" == "1" ]]; then
    echo "==> Verifying signatures"
    for f in "$WRAPPER" "$IMAGE"; do
        [[ -f "${f}.sig" ]] || curl -fL -o "${f}.sig" "${BASE_URL}/${f}.sig"
    done
    gpg --keyserver keyserver.ubuntu.com --recv-keys 50E0885593D2DCB4
    gpg --verify "${WRAPPER}.sig" "$WRAPPER"
    gpg --verify "${IMAGE}.sig" "$IMAGE"
fi

# --- 2. Throwaway SSH keypair for this demo --------------------------------
# Keep personal keys out of the committed Ignition config. This keypair
# lives under ssh/ (gitignored); only its public half is substituted in.
if [[ ! -f "$SSH_KEY" ]]; then
    echo "==> Generating a throwaway SSH keypair for this demo"
    mkdir -p "$SSH_KEY_DIR"
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "flatcar-demo" -q
fi
SSH_PUBLIC_KEY="$(cat "${SSH_KEY}.pub")"

# --- 3. Render Butane -> Ignition ------------------------------------------
# config.bu holds a placeholder instead of a real key. Use `#` as the sed
# delimiter because the key can contain `/`.
echo "==> Transpiling config.bu to Ignition JSON"
sed "s#__SSH_PUBLIC_KEY__#${SSH_PUBLIC_KEY}#" "$BUTANE_TEMPLATE" \
    | docker run --rm -i quay.io/coreos/butane:latest --pretty --strict \
    > "$IGNITION_CONFIG"

# --- 4. Boot ----------------------------------------------------------------
# -nographic keeps boot output on this terminal. -snapshot discards disk
# writes on exit, so every run is a clean first boot and Ignition re-fetches
# and re-merges the sysext. Ctrl-A X quits QEMU.
echo "==> Booting Flatcar (Ctrl-A X to quit QEMU)"
echo "    Ignition downloads the Kubernetes sysext during boot (needs network)."
echo "    Once you see a login prompt, SSH in from another terminal with:"
echo "      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost"
echo
./"$WRAPPER" -i "$IGNITION_CONFIG" -- -nographic -snapshot
