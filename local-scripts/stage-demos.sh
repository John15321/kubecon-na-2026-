#!/usr/bin/env bash
# Stage the demo renumbering so git shows renames instead of delete + untracked.
set -euo pipefail
cd "$(dirname "$0")/.."
git add -A demos
git status --short demos
