"""Hoja de contacto de los sellos: recorte de la referencia | sello renderizado (abajo + arriba) | diferencia en
rojo, con el número de cada sello (para revisar a ojo). Uso:
python -I -B tools/dev/stamp_contact_sheet.py <proyecto> <salida.png> [grupo] [desde] [hasta]
"""
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import match_reference as M  # noqa: E402
import pret_import as P  # noqa: E402

root, out = sys.argv[1], sys.argv[2]
group = sys.argv[3] if len(sys.argv) > 3 else ""
lo = int(sys.argv[4]) if len(sys.argv) > 4 else 0
hi = int(sys.argv[5]) if len(sys.argv) > 5 else 9999
meta = M.Metatiles(root)
sheets = {k: M.load_sheet(os.path.join(root, v[0]), v[1], v[2]) for k, v in M.SHEETS.items()}
stamps = json.load(open(os.path.join(root, "data", "world", "stamps.json"), encoding="utf8"))["stamps"]
entries = [(i, s, v) for i, s in enumerate(stamps) for v in s["variants"] if (not group or s["group"] == group) and lo <= i < hi]

W = 1100
x = y = 0
rowh = 0
layout = []
for i, s, v in entries:
    w, h = s["size"]
    bw = w * 16 * 3 + 24
    if x + bw > W:
        x, y = 0, y + rowh + 10
        rowh = 0
    layout.append((x, y, i, s, v))
    x += bw + 10
    rowh = max(rowh, h * 16 + 14)
c = P.Canvas(W, y + rowh + 10)
for k in range(c.w * c.h):
    c.data[k * 4:k * 4 + 4] = b"\x28\x28\x30\xff"


def put(X, Y, p):
    c.set(X, Y, (p[0] * 8, p[1] * 8, p[2] * 8, 255))


for (X, Y, i, s, v) in layout:
    w, h = s["size"]
    rx, ry = v["ref"]["rect"][:2]
    cells = sheets[v["ref"]["sheet"]]
    for k, ch in enumerate(str(i)):
        bits = P.DIGITS[int(ch)]
        for yy in range(5):
            for xx in range(3):
                if bits[yy * 3 + xx] == "1":
                    for d in range(4):
                        c.set(X + k * 8 + xx * 2 + d % 2, Y + yy * 2 + d // 2, (255, 220, 60, 255))
    Y += 12
    for cy in range(h):
        for cx in range(w):
            ref = cells.get((rx + cx, ry + cy))
            g = v["cells"][cy * w + cx]
            img = meta.img.get(g) if g >= 0 else None
            for py in range(16):
                for px in range(16):
                    a = ref[py * 16 + px] if ref else None
                    b = img[py * 16 + px] if img else None
                    if a:
                        put(X + cx * 16 + px, Y + cy * 16 + py, a)
                    if b:
                        put(X + w * 16 + 4 + cx * 16 + px, Y + cy * 16 + py, b)
                    if a and b and a != b:
                        c.set(X + 2 * (w * 16 + 4) + cx * 16 + px, Y + cy * 16 + py, (255, 40, 40, 255))
                    elif b:
                        q = (b[0] * 3, b[1] * 3, b[2] * 3, 255)
                        c.set(X + 2 * (w * 16 + 4) + cx * 16 + px, Y + cy * 16 + py, q)
            if g < 0 and ref:  # celda de la hoja que quedó vacía en el sello: agujero
                for py in range(16):
                    for px in range(16):
                        if (px + py) % 4 == 0:
                            c.set(X + w * 16 + 4 + cx * 16 + px, Y + cy * 16 + py, (255, 0, 255, 255))
P.write_png(out, c)
for (X, Y, i, s, v) in layout:
    print(i, s["group"], s["name"], "|", v["name"], v["id"], "dif:", v["ref_diff"])
