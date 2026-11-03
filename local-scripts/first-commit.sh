#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
git add -A
git commit -s -S -m "Init"
# git remote add origin git@github.com:John15321/kubecon-na-2026.git
# git push -u origin main
