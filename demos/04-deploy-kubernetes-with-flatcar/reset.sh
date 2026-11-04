#!/usr/bin/env bash
#
# Removes the working VM disk copy, the generated Ignition config, and the
# demo SSH keypair, so the next run.sh starts a fresh cluster.
#
# The wrapper script and the pristine disk image original are kept, so the
# next run restores the working disk with a local copy instead of
# re-downloading. Delete the .orig file yourself to re-fetch the current
# release.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

rm -fv flatcar_production_qemu_image.img
rm -fv config.ign
rm -rfv ssh/

echo "Reset. The next ./run.sh restores the disk from the cache and re-inits the cluster."
