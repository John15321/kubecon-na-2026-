#!/bin/sh
# Build the Marp slides PDF.
# Works inside the container (marp on PATH), locally (npm-installed marp), or via npx fallback.

set -e

INPUT="${INPUT:-slides.md}"
OUTPUT="${OUTPUT:-build/slides.pdf}"

echo "📑 Building Marp slides from ${INPUT}..."
mkdir -p "$(dirname "${OUTPUT}")"

# Compile any D2 diagram sources alongside their .svg output.
# Skips silently when d2 is not on PATH (e.g. in the container build),
# in which case the committed .svg files are used as-is.
D2_CMD=""
if command -v d2 > /dev/null 2>&1; then
    D2_CMD="d2"
elif [ -x "$HOME/.local/bin/d2" ]; then
    D2_CMD="$HOME/.local/bin/d2"
fi
if [ -n "${D2_CMD}" ] && [ -d assets/diagrams ]; then
    for src in assets/diagrams/*.d2; do
        [ -f "$src" ] || continue
        out="${src%.d2}.svg"
        echo "🖼️  d2: ${src} → ${out}"
        "${D2_CMD}" --theme 0 "$src" "$out" > /dev/null
    done
fi

if command -v marp > /dev/null 2>&1; then
    MARP_CMD="marp"
elif [ -x ./node_modules/.bin/marp ]; then
    MARP_CMD="./node_modules/.bin/marp"
else
    # Last-resort fallback. Pinned to match devDependencies in package.json so
    # `npx` uses its local cache and skips the registry "@latest" version check.
    echo "ℹ️  marp not found locally, falling back to npx (pinned)"
    MARP_CMD="npx --yes @marp-team/marp-cli@4.1.2"
fi

echo "Using: ${MARP_CMD}"
# --theme-set is greedy; keep it LAST so it only consumes "themes"
# and not the input/output paths.
# --html allows raw HTML / inline SVG in the markdown (used for diagrams).
${MARP_CMD} --pdf --html --allow-local-files --no-stdin "${INPUT}" -o "${OUTPUT}" --theme-set themes

if [ -f "${OUTPUT}" ]; then
    echo "✅ Build complete: ${OUTPUT} ($(ls -lh "${OUTPUT}" | awk '{print $5}'))"
else
    echo "❌ Build failed: ${OUTPUT} not produced"
    exit 1
fi
