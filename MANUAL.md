# Flatcar theme: authoring manual

Reference for the utility classes and markdown conventions provided by
the Flatcar Marp theme. For build/setup, see [README.md](README.md).

## Contents

- [Flatcar theme: authoring manual](#flatcar-theme-authoring-manual)
  - [Contents](#contents)
  - [Slide layouts](#slide-layouts)
  - [Utility classes](#utility-classes)
    - [Text](#text)
    - [Badges](#badges)
    - [Image sizing](#image-sizing)
    - [Block alignment](#block-alignment)
    - [Slide-wide pins (`pin-*`)](#slide-wide-pins-pin-)
    - [Pane pins (`pane-*`, sidebar/agenda only)](#pane-pins-pane--sidebaragenda-only)
    - [Layout containers](#layout-containers)
    - [Logo walls](#logo-walls)
    - [Callouts](#callouts)
  - [Diagrams (D2)](#diagrams-d2)
  - [Font sizes \& overrides](#font-sizes--overrides)
  - [How the two syntaxes work](#how-the-two-syntaxes-work)
    - [The `<p>` wrapper](#the-p-wrapper)
  - [Extending the pattern](#extending-the-pattern)

## Slide layouts

Set via `<!-- _class: NAME -->` on the target slide:

| Class            | Use case                                |
| ---------------- | --------------------------------------- |
| *(none)*         | White slide with navy title bar         |
| `cover`          | Navy title slide with Flatcar icon      |
| `lead`           | Full-bleed navy for big statements      |
| `section`        | Section divider                         |
| `closing`        | Thank-you slide + QR code + Discord CTA |
| `agenda`         | Left rail + bullet list                 |
| `sidebar`        | Left rail + free-form right pane        |
| `sidebar whoami` | Bio variant of sidebar                  |
| `quote`          | Blockquote slide                        |

Rules live in [themes/flatcar/dark.css](themes/flatcar/dark.css) (dark
layouts) and [themes/flatcar/sidebar.css](themes/flatcar/sidebar.css)
(rail layouts).

## Utility classes

The theme ships a small set of Tailwind-style utilities so you can place
and size elements without writing custom CSS per slide. Utilities live in
[themes/flatcar/base.css](themes/flatcar/base.css) (global) and
[themes/flatcar/sidebar.css](themes/flatcar/sidebar.css) (sidebar/agenda
pane pins only).

Two equivalent ways to apply them:

```markdown
<!-- HTML class syntax, works on any element -->
<img class="img-md pin-br" src="assets/logo.png">

<!-- Markdown alt-text syntax, works on <img> only -->
![img-md pin-br](assets/logo.png)
```

Token order does not matter; combine as many as you like.

### Text

| Class          | Effect                             |
| -------------- | ---------------------------------- |
| `text-left`    | Left-align text                    |
| `text-center`  | Center-align text                  |
| `text-right`   | Right-align text                   |
| `muted`        | Grey (`--muted`), for footnotes    |
| `small`        | 0.8× font size                     |
| `big`          | 1.4× font size                     |
| `upper`        | Uppercase + letter-spacing         |

### Badges

```markdown
<span class="badge">CNCF Incubating</span>
<span class="badge badge-cyan">v4.1</span>
<span class="badge badge-muted">draft</span>
```

Variants: default grey, `badge-cyan`, `badge-navy`, `badge-muted`.

### Image sizing

Three families of size tokens. All work as classes or alt-text.

**Widths**: set width, height auto-scales.

| Token       | Width  |
| ----------- | ------ |
| `img-2xs`   | 48px   |
| `img-xs`    | 80px   |
| `img-sm`    | 160px  |
| `img-md`    | 320px  |
| `img-lg`    | 560px  |
| `img-xl`    | 720px  |
| `img-full`  | 100%   |

**Heights**: set height, width auto-scales. Useful when a row of
differently-shaped logos should share one visual height.

| Token       | Height |
| ----------- | ------ |
| `img-h-xs`  | 60px   |
| `img-h-sm`  | 120px  |
| `img-h-md`  | 200px  |
| `img-h-lg`  | 320px  |

**Squares**: set both dimensions equal, with `object-fit: cover` so
portraits and avatars crop cleanly instead of stretching.

| Token        | Size      |
| ------------ | --------- |
| `img-sq-sm`  | 120×120px |
| `img-sq-md`  | 220×220px |
| `img-sq-lg`  | 300×300px |
| `img-sq-xl`  | 400×400px |

```markdown
![img-sq-lg pin-mr](assets/photo/individual_photos/jan-bronicki.jpg)
```

For rounded corners on a square, add an inline style:

```markdown
<img class="img-sq-md" style="border-radius: 6px" src="…">
```

### Block alignment

| Class    | Effect                    |
| -------- | ------------------------- |
| `center` | Block-centered            |
| `left`   | Flush left (block)        |
| `right`  | Flush right (block)       |

Combine with a size class:

```markdown
![img-md center](assets/logos/external/cncf-banner.png)
```

### Slide-wide pins (`pin-*`)

Absolute-position an element to a slide edge, corner, or intermediate
row. Works on any slide layout.

|                   | left      | center    | right     |
| ----------------- | --------- | --------- | --------- |
| **top** (60px)    | `pin-tl`  | `pin-tc`  | `pin-tr`  |
| **middle-top** (25%) | `pin-mtl` | `pin-mtc` | `pin-mtr` |
| **middle** (50%)  | `pin-ml`  | `pin-mc`  | `pin-mr`  |
| **middle-bottom** (75%) | `pin-mbl` | `pin-mbc` | `pin-mbr` |
| **bottom** (60px) | `pin-bl`  | `pin-bc`  | `pin-br`  |

```markdown
![pin-br img-sm](assets/logos/flatcar-logotype/icon/color/flatcar-icon-color.png)
```

Caveat: on default (unclassed) slides the top edge is covered by the navy
title bar, prefer `pin-tr` / `pin-tl` on dark layouts (`cover`, `lead`,
`section`, `closing`) instead.

### Pane pins (`pane-*`, sidebar/agenda only)

Same 5×3 grid, but anchored to the white right pane so it skips the navy
rail. Uses a `--rail-width` custom property (33% for `sidebar`, 25% for
`agenda`) so one rule set serves both.

|                   | left       | center     | right      |
| ----------------- | ---------- | ---------- | ---------- |
| **top** (60px)    | `pane-tl`  | `pane-tc`  | `pane-tr`  |
| **middle-top** (25%) | `pane-mtl` | `pane-mtc` | `pane-mtr` |
| **middle** (50%)  | `pane-ml`  | `pane-mc`  | `pane-mr`  |
| **middle-bottom** (75%) | `pane-mbl` | `pane-mbc` | `pane-mbr` |
| **bottom** (60px) | `pane-bl`  | `pane-bc`  | `pane-br`  |

- **Corner / row variants** (`-l` and `-r`) keep the element at its
  intrinsic size, combine with `img-sm`/`img-md` for logos.
- **Center variants** (`-c`) span the full pane width and auto-fit
  images (max-height 220px). Leave off `img-*` sizing.

```markdown
<!-- _class: sidebar -->

# Backed by CNCF

- Incubating since 2024
- Vendor-neutral governance

![pane-bc](assets/logos/external/cncf-banner.png)
```

### Layout containers

| Class          | Effect                                       |
| -------------- | -------------------------------------------- |
| `row`          | Horizontal flex, `gap: 24px`, wraps          |
| `row-center`   | Combine with `row` to center horizontally    |
| `row-between`  | Combine with `row` to push items to edges    |
| `col`          | Vertical flex stack, `gap: 16px`             |
| `cols-2`       | Equal-width 2-column grid                    |
| `cols-3`       | Equal-width 3-column grid                    |
| `cols-4`       | Equal-width 4-column grid                    |

```markdown
<div class="cols-3">
  <img src="assets/logos/external/clouds/aws.png">
  <img src="assets/logos/external/clouds/azure.png">
  <img src="assets/logos/external/clouds/gcp.png">
</div>
```

### Logo walls

Uniform grid for logo groups. Each cell centers its image, caps the
height, and applies a subtle drop-shadow so mixed light/dark logos read
consistently against the white slide.

| Class          | Cell max-height |
| -------------- | --------------- |
| `logo-wall`    | 140px           |
| `logo-wall-lg` | 210px           |
| `logo-wall-sm` | 60px            |

Column count is not baked in, set it inline (or via a `<style scoped>`
block) so the same rules serve 2/3/4-up walls:

```markdown
<div class="logo-wall logo-wall-lg" style="grid-template-columns: repeat(4, 1fr)">
  <img src="assets/logos/external/clouds/aws.png">
  <img src="assets/logos/external/clouds/azure.svg">
  <img src="assets/logos/external/clouds/gcp.png">
  <img src="assets/logos/external/clouds/openstack.svg">
</div>
```

### Callouts

```markdown
<div class="callout">

**Note:** Flatcar is immutable, no `apt install`.

</div>
```

Variants: default cyan, `callout-warn` (amber), `callout-ok` (green).
Blank lines around the inner content let Marp still parse `**bold**` and
inline code inside.

## Diagrams (D2)

[D2](https://d2lang.com) is the **default, first-class way** to author
diagrams in this template. Sources live in `assets/diagrams/*.d2` and
compile to `.svg` next to them. The build pipeline (`scripts/build.sh`)
re-renders every `.d2` before running Marp when the `d2` CLI is on
`PATH`; if it isn't, the committed `.svg` files are used as-is, so CI
and fresh checkouts still work without `d2` installed.

Dropping a diagram onto a slide is just an `<img>` pointing at the
generated SVG, Marp doesn't need to know it came from D2:

```markdown
<img src="assets/diagrams/flatcar-workflow.svg" alt="Flatcar workflow">
```

Authoring workflow:

1. Edit or create `assets/diagrams/my-diagram.d2`.
2. Run `make build` (or `d2 assets/diagrams/my-diagram.d2 assets/diagrams/my-diagram.svg` on the host) to regenerate the SVG.
3. Reference the `.svg` from `slides.md`.
4. Commit **both** the `.d2` source and the generated `.svg` so the deck
   still builds on machines without `d2`.

Install `d2` locally with `brew install d2`, `go install oss.terrastruct.com/d2@latest`,
or the one-liner from [d2lang.com](https://d2lang.com/tour/install).

The shipped diagrams (`flatcar-ux-flow.d2`, `ab-updates.d2`) use the
Flatcar palette (`#12172B` navy, `#09BAC8` cyan) via a shared
`classes:` block near the top of each file, copy that pattern for
new diagrams to stay on-brand.

**Other diagram tools are fine but unsupported here.** If you prefer
Mermaid, Excalidraw, draw.io, PlantUML, tldraw, or plain Inkscape, just
export your diagram to a PNG or SVG, drop it under `assets/diagrams/`
(or anywhere else in `assets/`), and reference it from a slide the same
way. The `scripts/build.sh` auto-compile step only touches `.d2` files;
any pre-rendered image is used as-is. The template doesn't include
helpers for those tools, but pasting a screenshot of a diagram works
out of the box:

```markdown
![My architecture diagram](assets/diagrams/my-architecture.png)
```

## Font sizes & overrides

The theme uses a **32px body default**, with each special layout setting
its own hero/title sizes. Sizes are hard-coded per rule (no CSS
variable) so bumping the default in `base.css` only affects layouts that
inherit, layouts with their own explicit rules stay put.

Where the sizes live:

| Element                         | Size | File                                         |
| ------------------------------- | ---- | -------------------------------------------- |
| Slide body (default + sidebar)  | 32px | `base.css`: `section`                       |
| `h1` navy title bar             | 40px | `base.css`: `section h1`                    |
| `h2` subheading                 | 32px | `base.css`: `section h2`                    |
| `code` inline pill              | 0.9em | `base.css`: `code`                         |
| Slide number `::after`          | 14px | `base.css`                                   |
| Sidebar `h1` cyan title         | 44px | `sidebar.css`: `section.sidebar h1`         |
| Sidebar `h2`                    | 28px | `sidebar.css`                                |
| Sidebar table th/td             | 24px | `sidebar.css`                                |
| Agenda `h1` "Agenda"            | 56px | `sidebar.css`                                |
| Agenda list                     | 32px | `sidebar.css`                                |
| Whoami `h1` "whoami"            | 56px | `sidebar.css`                                |
| Whoami `h2` name                | 52px | `sidebar.css`                                |
| Whoami body / list              | 32px | `sidebar.css`                                |
| Cover / lead / quote            | (varies) | `dark.css`                                |

Three ways to override sizing from Markdown:

**1. `<style scoped>`: one whole slide**

Marp lets you drop a `<style scoped>` block inside a slide; the CSS
applies only to that slide.

```markdown
---

<!-- _class: sidebar -->

<style scoped>
  section li { font-size: 40px; font-weight: 600; }
  section h2 { font-size: 44px; }
</style>

# Big-Font Slide

- Bigger bullet
- Another bigger bullet
```

**2. Inline `style=""` on an element: one piece of text**

```markdown
- <span style="font-size: 44px; font-weight: 600">This bullet pops</span>
- Normal bullet

<p style="font-size: 44px">Whole paragraph in a bigger size.</p>
```

Inline styles beat almost any theme rule on specificity, so this is the
"just make it work" escape hatch.

**3. The `.small` and `.big` utility classes: relative bumps**

```markdown
- <span class="big">1.4× the surrounding size</span>
- <span class="small">0.8× the surrounding size</span>
```

Because they use `em` units, they scale relative to whatever context
they're in (a whoami slide's 52px h2 versus a content slide's 32px body).

**When to promote to a real utility:** if you keep repeating the same
`<style scoped>` block across slides, move it into `base.css` as a proper
class (e.g. `.hero-list { font-size: 40px; font-weight: 500 }`) so you
can just write `<ul class="hero-list">`.

## How the two syntaxes work

Marp emits `![alt text](url)` as `<img alt="alt text" src="url">`. CSS
has an attribute selector `[alt~="word"]` that matches any whitespace-
separated word inside the `alt` attribute. Every utility is written as:

```css
.center, img[alt~="center"] { display: block; margin: 0 auto; }
```

So both of these render identically:

```markdown
<img class="center" src="…">
![center](…)
```

Because `[alt~="…"]` is a word match, extra tokens become real,
accessible alt text, the best of both worlds:

```markdown
![pane-bc CNCF Incubating banner](assets/logos/external/cncf-banner.png)
```

`pane-bc` triggers the utility; the rest is visible to screen readers.

### The `<p>` wrapper

Marp wraps `![…](…)` in a paragraph:

```html
<p><img alt="pin-br" src="…"></p>
```

For absolutely-positioned pins that would leave an invisible flow-space
gap where the paragraph used to be. [themes/flatcar/base.css](themes/flatcar/base.css)
has a `display: contents` rule that hides the `<p>` from the layout tree
whenever its child image carries a `pin-` or `pane-` alt token.

## Extending the pattern

Any class rule `foo` can be exposed to markdown alt-text syntax by adding
an `img[alt~="foo"]` selector to the rule:

```css
.my-thing, img[alt~="my-thing"] { … }
```

That's the entire trick, no build step, no plugin, just CSS.

If you invent a new positional token (e.g. `.pin-corner-tr`), remember to
also add it to the `[class*="pin-"], img[alt*="pin-"]` "hide the wrapping
`<p>`" rule in [themes/flatcar/base.css](themes/flatcar/base.css) if you
want the markdown-syntax version to work in normal flow slides.
