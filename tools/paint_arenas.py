"""Arenas pintadas (2026-11-03, pedido del usuario: arenas "MUY EPICAS" hechas con Qwen). Por cada arena de
data/arenas/pinturas.json:
  - la pintura (art_src/arenas/<id>.png, de Qwen-Image 2.1 Turbo con el `prompt` y la `seed` del JSON, 1600x1200) va a
    sprites/arenas/<id>.png sin achicar (×2,5 la resolución del juego en una arena de 40x30);
  - el plano de colisión: con `auto` = las celdas claras (pasto, tierra, piso) unidas al centro son piso y lo oscuro
    (árboles, paredes) choca; después se abren los rectángulos `open` y se cierran los `solid`. Va a
    data/arenas/planos/<id>.txt ("." piso, "#" choca), que lee tools/build_arenas.gd para armar la escena.
Después: godot --headless --path . --quit-after 20000 --script res://tools/build_arenas.gd -- --only <id>
y revisar con --autotest-room-walk --zone <id> (la imagen de la colisión sobre la pintura).

Uso: python -I -B tools/paint_arenas.py . [<id>]
"""
import json
import os
import shutil
import sys
from collections import deque

from PIL import Image


def auto_plan(img, w, h, threshold):
    small = img.convert("RGB").resize((w * 8, h * 8), Image.BOX)
    px = small.load()
    bright = set()
    for y in range(h):
        for x in range(w):
            s = sum(0.299 * r + 0.587 * g + 0.114 * b
                    for r, g, b in (px[x * 8 + i, y * 8 + j] for j in range(8) for i in range(8)))
            if s / 64 > threshold:
                bright.add((x, y))
    start = (w // 2, h // 2)
    seen = {start} if start in bright else set()
    queue = deque(seen)
    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n in bright and n not in seen:
                seen.add(n)
                queue.append(n)
    return seen


def build(root, arena_id, cfg):
    w, h = cfg["size"]
    src = os.path.join(root, "art_src/arenas/%s.png" % arena_id)
    img = Image.open(src)
    floor = auto_plan(img, w, h, cfg["auto"]) if cfg.get("auto") is not None else set()
    for x0, y0, rw, rh in cfg.get("open", []):
        floor |= {(x, y) for x in range(x0, x0 + rw) for y in range(y0, y0 + rh)}
    for x0, y0, rw, rh in cfg.get("solid", []):
        floor -= {(x, y) for x in range(x0, x0 + rw) for y in range(y0, y0 + rh)}
    os.makedirs(os.path.join(root, "data/arenas/planos"), exist_ok=True)
    os.makedirs(os.path.join(root, "sprites/arenas"), exist_ok=True)
    with open(os.path.join(root, "data/arenas/planos/%s.txt" % arena_id), "w", encoding="utf8", newline="\n") as f:
        for y in range(h):
            f.write("".join("." if (x, y) in floor else "#" for x in range(w)) + "\n")
    shutil.copyfile(src, os.path.join(root, "sprites/arenas/%s.png" % arena_id))
    print("%-26s %dx%d, %d celdas de piso" % (arena_id, w, h, len(floor)))


def main(root, only=None):
    cfgs = json.load(open(os.path.join(root, "data/arenas/pinturas.json"), encoding="utf8"))
    for arena_id, cfg in cfgs.items():
        if not arena_id.startswith("_") and (only is None or only == arena_id):
            build(root, arena_id, cfg)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
