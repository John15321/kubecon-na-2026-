# KubeCon NA 2026

Your GPU Nodes Deserve Better: Flatcar Container Linux for AI Workloads.
KubeCon + CloudNativeCon North America 2026, Maintainer Track (Incubating
Project), by Jan Bronicki and Sayan Chowdhury.

The deck lives in [`slides.md`](slides.md) and is still Flatcar-101 heavy in
the middle: trim it to a short intro, then fill in the NVIDIA sysext and local
LLM demo sections. `make build` writes the PDF to `build/slides.pdf`.

## Build

The recommended path is Podman + `make`. Everything runs inside a small container image so the host only needs `podman` and `make`.

```sh
make setup        # first-time: build the slides-builder container image
make build        # -> build/slides.pdf
make clean        # remove build artifacts
make shell        # interactive shell inside the container
```

Native (no container) — requires Node.js on the host:

```sh
npm ci            # or npm install
make native-build # -> build/slides.pdf
```

Author-time preview with live reload:

```sh
make watch        # rebuilds on save
make preview      # live browser preview
```

See `make help` for the full target list.

## Layout

```
slides.md                  # slide content (Markdown)
themes/
  flatcar.css              # theme entry point
  flatcar/{base,dark,sidebar}.css   # partials
assets/
  backgrounds/             # theme backgrounds (staircase, etc.)
  diagrams/                # D2 sources + generated .svg diagrams
  logos/                   # brand + third-party logos
  photo/                   # individual + group photos
  qr-code.png              # closing-slide QR
scripts/                   # build / clean / gather-artifacts
Containerfile              # Podman image (Marp CLI + bash + make)
compose.yaml               # slides-builder service definition
Makefile                   # top-level workflow
.github/workflows/         # CI: builds PDF on push, releases on tag
```

## Slide layouts & utility classes

See [MANUAL.md](MANUAL.md) for the full authoring reference — slide
layouts (`cover`, `sidebar`, `agenda`, etc.), utility classes
(`img-*`, `pin-*`, `pane-*`, `row`, `cols-*`, `callout`, …) and both
the HTML-class and markdown-alt-text ways to apply them.

## Diagrams

[D2](https://d2lang.com) is the default diagramming tool. Put sources
in `assets/diagrams/*.d2` and reference the generated `.svg` from your
slides — `make build` re-renders them when `d2` is on `PATH` and falls
back to the committed SVGs otherwise. Other tools (Mermaid, Excalidraw,
draw.io, plain PNGs / screenshots) work too: just drop the exported
image under `assets/` and `<img>` it in. See [MANUAL.md](MANUAL.md#diagrams-d2)
for details.

## PowerPoint

`make build` (and `make pptx`) also produce `build/slides-native.pptx`, generated
from `slides.md` with nothing to keep in sync by hand. `scripts/build-pptx.py`
renders each slide in headless Chrome and builds the PowerPoint from a picture
of the slide plus native, editable text boxes on top. Wording, fonts and colours
stay editable; cards, bands and diagrams are part of the picture. Needs
[uv](https://docs.astral.sh/uv/) (or python-pptx and playwright) and Chrome or
Chromium. The file refers to the Overpass font by name, so install Overpass to
see it as designed.

`make build` also produces `build/slides.pptx`, a picture-only deck where every
slide is a PNG rendered by Marp. It matches the PDF exactly and needs no fonts
installed, but its text cannot be edited. Use `slides-native.pptx` when you
need to edit.

## Releases

Pushing a tag `v*` triggers the CI workflow to attach `slides.pdf`, `slides.pptx` and `slides-native.pptx` to a GitHub Release.

---

Generated from [cookiecutter-marp-flatcar](https://github.com/John15321/cookiecutter-marp-flatcar) by **Jan Bronicki**.
