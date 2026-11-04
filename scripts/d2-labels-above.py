#!/usr/bin/env python3
"""Move D2 connection labels above their arrows.

D2 centres a label on its connection and masks the line behind it, so the text
cuts through the arrow. This drops the mask and lifts the label by a fixed
offset so it sits above the line.
"""
import re
import sys

LIFT = 26

CONN = re.compile(
    r'(<path [^>]*class="connection"[^>]*?)\s+mask="url\(#[^"]+\)"([^>]*/>)'
    r'(<text x="[^"]+" y=")([0-9.]+)(" [^>]*class="text-[a-z]+"[^>]*>)(.*?)(</text>)'
)


def fix(path):
    svg = open(path, encoding="utf-8").read()

    def repl(m):
        lines = max(1, m.group(6).count("<tspan"))
        dys = [float(d) for d in re.findall(r'dy="([0-9.]+)"', m.group(6))]
        y = float(m.group(4)) - LIFT - sum(dys)
        return (f"{m.group(1)}{m.group(2)}{m.group(3)}{y:.6f}"
                f"{m.group(5)}{m.group(6)}{m.group(7)}")

    out = CONN.sub(repl, svg)
    if out != svg:
        open(path, "w", encoding="utf-8").write(out)


for p in sys.argv[1:]:
    fix(p)
