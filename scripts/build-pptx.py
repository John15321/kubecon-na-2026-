#!/usr/bin/env python3
"""Convert the Marp deck into a PowerPoint with real, editable text.

Run with: make pptx
Output:   build/slides-native.pptx

Marp renders slides.md to HTML. This script opens that HTML in headless
Chrome and, per slide, (1) reads every text block with its position, font and
colour, and (2) screenshots the slide with the text hidden. Each PowerPoint
slide is that picture with the text put back as native text boxes, so the
design matches the PDF exactly and the wording stays editable. It follows
slides.md automatically, there is nothing to keep in sync by hand.

Cards, bands and diagrams are part of the background picture. For a deck made
only of native shapes, replace this file with a hand-built script.

Needs python-pptx, playwright and a Chrome or Chromium. The PowerPoint file
refers to fonts by name, so install Overpass to see it as designed.
"""
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.util import Emu, Pt

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
OUT = BUILD / "slides-native.pptx"
HTML = BUILD / "pptx-source.html"
IMG_DIR = BUILD / "pptx-assets"
SCALE = 2  # background picture resolution relative to the 96 dpi layout
EMU_PER_PX = 9525

# Read once in the browser: every visible text block of every slide.
EXTRACT_JS = r"""
() => {
  const SKIP = new Set(['SCRIPT', 'STYLE', 'SVG', 'IMG', 'CANVAS', 'VIDEO', 'NOSCRIPT']);
  const px = v => parseFloat(v) || 0;

  // Keep generated content (page numbers, ::before/::after) and list markers
  // visible in the background picture once the text colour is made transparent.
  document.querySelectorAll('svg[data-marpit-svg] *').forEach(el => {
    for (const p of ['::before', '::after']) {
      const cs = getComputedStyle(el, p);
      if (cs.content !== 'none' && cs.content !== 'normal') {
        el.style.setProperty('--kc' + p.replace('::', '-'), cs.color);
      }
    }
    if (el.tagName === 'LI') el.style.setProperty('--kc-marker', getComputedStyle(el, '::marker').color);
  });

  const style = el => {
    const cs = getComputedStyle(el);
    const fam = (cs.fontFamily.split(',')[0] || '').replace(/["']/g, '').trim();
    return {
      size: px(cs.fontSize),
      bold: parseInt(cs.fontWeight, 10) >= 600,
      italic: cs.fontStyle === 'italic',
      underline: cs.textDecorationLine.includes('underline'),
      color: cs.color,
      font: fam,
      upper: cs.textTransform,
      pre: cs.whiteSpace.startsWith('pre'),
    };
  };

  const slides = [];
  document.querySelectorAll('svg[data-marpit-svg] > foreignObject > section').forEach(sec => {
    const sr = sec.getBoundingClientRect();
    const boxes = [];

    const collect = (el, runs, nodes, blocks) => {
      for (const ch of el.childNodes) {
        if (ch.nodeType === 3) {
          if (!ch.textContent) continue;
          runs.push(Object.assign({text: ch.textContent}, style(el)));
          nodes.push(ch);
        } else if (ch.nodeType === 1) {
          const tag = ch.tagName.toUpperCase();
          if (tag === 'BR') { runs.push({br: true}); continue; }
          if (SKIP.has(tag)) continue;
          const cs = getComputedStyle(ch);
          if (cs.display === 'none' || cs.visibility === 'hidden') continue;
          if (cs.display === 'inline') collect(ch, runs, nodes, blocks);
          else blocks.push(ch);
        }
      }
    };

    const walk = el => {
      const runs = [], nodes = [], blocks = [];
      collect(el, runs, nodes, blocks);
      if (nodes.some(n => n.textContent.trim())) {
        let l = Infinity, t = Infinity, r = -Infinity, b = -Infinity;
        for (const n of nodes) {
          const range = document.createRange();
          range.selectNodeContents(n);
          for (const q of range.getClientRects()) {
            if (!q.width || !q.height) continue;
            l = Math.min(l, q.left); t = Math.min(t, q.top);
            r = Math.max(r, q.right); b = Math.max(b, q.bottom);
          }
        }
        if (isFinite(l)) {
          const cs = getComputedStyle(el);
          const cr = el.getBoundingClientRect();
          const cl = cr.left + px(cs.paddingLeft) + px(cs.borderLeftWidth);
          const cw = cr.width - px(cs.paddingLeft) - px(cs.paddingRight)
                     - px(cs.borderLeftWidth) - px(cs.borderRightWidth);
          let lh = px(cs.lineHeight);
          if (!lh) lh = px(cs.fontSize) * 1.2;
          boxes.push({
            left: cl - sr.left, width: Math.max(cw, r - l),
            top: t - sr.top, height: b - t,
            align: cs.textAlign, lineHeight: lh, runs,
          });
        }
      }
      blocks.forEach(walk);
    };
    walk(sec);
    slides.push({width: sr.width, height: sr.height, boxes});
  });
  return slides;
}
"""

# Hide text but keep every other pixel of the slide.
HIDE_CSS = """
svg[data-marpit-svg] * { color: transparent !important; text-shadow: none !important;
  text-decoration-color: transparent !important; caret-color: transparent !important; }
svg[data-marpit-svg] *::before { color: var(--kc-before, transparent) !important; }
svg[data-marpit-svg] *::after { color: var(--kc-after, transparent) !important; }
svg[data-marpit-svg] li::marker { color: var(--kc-marker, transparent) !important; }
body { margin: 0 !important; }
"""


def marp_command():
    env = os.environ.get("MARP_CMD")
    if env:
        return shlex.split(env)
    if shutil.which("marp"):
        return ["marp"]
    local = ROOT / "node_modules/.bin/marp"
    if local.exists():
        return [str(local)]
    return ["npx", "--yes", "@marp-team/marp-cli@4.1.2"]


def render_html():
    BUILD.mkdir(exist_ok=True)
    cmd = marp_command() + [
        "--html", "--allow-local-files", "--no-stdin", "--template", "bare",
        "slides.md", "-o", str(HTML), "--theme-set", "themes",
    ]
    subprocess.run(cmd, cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    # Local assets are relative to the project root, the HTML lives in build/.
    text = HTML.read_text(encoding="utf-8")
    HTML.write_text(
        text.replace("<head>", f'<head><base href="{ROOT.as_uri()}/">', 1),
        encoding="utf-8",
    )


def chrome_path():
    for var in ("CHROME_PATH", "PUPPETEER_EXECUTABLE_PATH"):
        if os.environ.get(var):
            return os.environ[var]
    for name in ("google-chrome", "google-chrome-stable", "chromium", "chromium-browser", "chrome"):
        found = shutil.which(name)
        if found:
            return found
    sys.exit("No Chrome or Chromium found. Set CHROME_PATH.")


def parse_color(css):
    m = re.match(r"rgba?\(([^)]*)\)", css)
    if not m:
        return None
    parts = [p.strip() for p in re.split(r"[,/ ]+", m.group(1)) if p.strip()]
    if len(parts) > 3 and float(parts[3]) == 0:
        return None
    return RGBColor(*(round(float(p)) for p in parts[:3]))


def transform(text, mode):
    if mode == "uppercase":
        return text.upper()
    if mode == "lowercase":
        return text.lower()
    if mode == "capitalize":
        return text.title()
    return text


def tidy(runs):
    """Collapse whitespace like CSS does, outside preformatted text."""
    out, prev_space = [], True
    for run in runs:
        if run.get("br"):
            out.append(run)
            prev_space = True
            continue
        text = run["text"]
        if not run["pre"]:
            text = re.sub(r"\s+", " ", text)
            if prev_space and text.startswith(" "):
                text = text[1:]
        if text:
            prev_space = text.endswith(" ")
            out.append(dict(run, text=text))
    while out and not out[-1].get("br") and not out[-1]["pre"] and out[-1]["text"].endswith(" "):
        stripped = out[-1]["text"].rstrip(" ")
        if stripped:
            out[-1] = dict(out[-1], text=stripped)
            break
        out.pop()
    return out


ALIGN = {"center": PP_ALIGN.CENTER, "right": PP_ALIGN.RIGHT, "end": PP_ALIGN.RIGHT}


def emu(px):
    return Emu(round(px * EMU_PER_PX))


def add_text(slide, box):
    runs = tidy(box["runs"])
    if not any(not r.get("br") and r["text"].strip() for r in runs):
        return
    size = max(r["size"] for r in runs if not r.get("br"))
    has_break = any(r.get("br") for r in runs)
    single = box["height"] / box["lineHeight"] < 1.5 and not has_break
    pre = any(r.get("pre") for r in runs if not r.get("br"))

    # Slack so a slightly wider fallback font does not wrap an extra line.
    slack = 0 if single else size * 0.6
    tb = slide.shapes.add_textbox(
        emu(box["left"]), emu(box["top"]), emu(box["width"] + slack), emu(box["height"])
    )
    tf = tb.text_frame
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    tf.word_wrap = not (single or pre)
    tf.vertical_anchor = MSO_ANCHOR.TOP
    para = tf.paragraphs[0]
    para.alignment = ALIGN.get(box["align"], PP_ALIGN.LEFT)
    para.line_spacing = Pt(box["lineHeight"] * 0.75)

    for run in runs:
        if run.get("br"):
            para.add_line_break()
            continue
        r = para.add_run()
        r.text = transform(run["text"], run["upper"])
        f = r.font
        f.size = Pt(run["size"] * 0.75)
        f.bold = run["bold"]
        f.italic = run["italic"]
        f.underline = run["underline"]
        if run["font"]:
            f.name = run["font"]
        color = parse_color(run["color"])
        if color is not None:
            f.color.rgb = color


def main():
    render_html()
    if IMG_DIR.exists():
        shutil.rmtree(IMG_DIR)
    IMG_DIR.mkdir(parents=True)

    with sync_playwright() as pw:
        browser = pw.chromium.launch(
            executable_path=chrome_path(), args=["--no-sandbox", "--allow-file-access-from-files"]
        )
        page = browser.new_page(viewport={"width": 1280, "height": 720}, device_scale_factor=SCALE)
        page.goto(HTML.as_uri())
        page.evaluate("document.fonts.ready")
        slides = page.evaluate(EXTRACT_JS)
        if not slides:
            sys.exit("No slides found in the rendered HTML.")

        w_px, h_px = slides[0]["width"], slides[0]["height"]
        page.set_viewport_size({"width": round(w_px), "height": round(h_px)})
        page.add_style_tag(content=HIDE_CSS)
        page.wait_for_timeout(300)

        prs = Presentation()
        prs.slide_width, prs.slide_height = emu(w_px), emu(h_px)
        blank = prs.slide_layouts[6]
        sections = page.locator("svg[data-marpit-svg] > foreignObject > section")

        for i, data in enumerate(slides):
            png = IMG_DIR / f"slide-{i + 1:03d}.png"
            sections.nth(i).screenshot(path=str(png))
            slide = prs.slides.add_slide(blank)
            pic = slide.shapes.add_picture(str(png), 0, 0, prs.slide_width, prs.slide_height)
            pic.name = "Background"
            for box in data["boxes"]:
                add_text(slide, box)
        browser.close()

    prs.save(OUT)
    HTML.unlink(missing_ok=True)
    shutil.rmtree(IMG_DIR, ignore_errors=True)
    print(f"✅ Built {OUT.relative_to(ROOT)} ({len(slides)} slides)")


if __name__ == "__main__":
    main()
