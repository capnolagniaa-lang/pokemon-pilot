"""Arenas pintadas (2026-11-03, pedido del usuario: arenas "MUY EPICAS" hechas con Qwen). Por cada arena de
data/arenas/pinturas.json:
  - la pintura (art_src/arenas/<id>.png, de Qwen-Image 2.1 Turbo con el `prompt` y la `seed` del JSON, 1600x1200; con
    `sketch` se le pasó ese boceto como imagen para que respete dónde va el agua) va a sprites/arenas/<id>.png sin achicar;
  - el plano, resuelto, a data/arenas/planos/<id>.json, que lee tools/build_arenas.gd para armar la escena:
    `rows` ("." piso, "#" choca, "~" agua de verdad: moja, frena y conduce), floor/wall (metatiles), rocks, cells, field,
    water (rectángulos de pileta). Con `auto` = las celdas claras (pasto, tierra, piso) unidas al centro son piso y lo
    oscuro choca; después se abren los rectángulos `open`, se cierran los `solid` y se ponen los `water`.
  - `brillo` (opcional) aclara la pintura al copiarla (1,35 = un 35 % más clara);
  - `scale` agranda la arena: todas las celdas y rectángulos del JSON (que se marcan sobre la grilla de `size`) se
    multiplican y la arena queda de size × scale celdas, con la misma pintura dibujada más grande.
Después: godot --headless --path . --quit-after 20000 --script res://tools/build_arenas.gd -- --only <id>
y revisar con --autotest-room-walk --arena <id> (la imagen de la colisión sobre la pintura).

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


def cells_of(rects, k):
    out = set()
    for x0, y0, rw, rh in rects:
        x1, y1 = round(x0 * k), round(y0 * k)
        out |= {(x, y) for x in range(x1, round((x0 + rw) * k)) for y in range(y1, round((y0 + rh) * k))}
    return out


def build(root, arena_id, cfg):
    k = float(cfg.get("scale", 1.0))
    w, h = round(cfg["size"][0] * k), round(cfg["size"][1] * k)
    src = os.path.join(root, "art_src/arenas/%s.png" % arena_id)
    img = Image.open(src)
    floor = auto_plan(img, w, h, cfg["auto"]) if cfg.get("auto") is not None else set()
    floor |= cells_of(cfg.get("open", []), k)
    floor -= cells_of(cfg.get("solid", []), k)
    water = cells_of(cfg.get("water", []), k)
    rows = ["".join("~" if (x, y) in water else "." if (x, y) in floor else "#" for x in range(w)) for y in range(h)]
    pt = lambda p: [round(p[0] * k), round(p[1] * k)]
    rect = lambda r: [round(r[0] * k), round(r[1] * k), round((r[0] + r[2]) * k) - round(r[0] * k),
                      round((r[1] + r[3]) * k) - round(r[1] * k)]
    plan = {
        "name": cfg.get("name", ""),
        "rows": rows,
        "floor": cfg["floor"],
        "wall": cfg["wall"],
        "rocks": [pt(p) for p in cfg.get("rocks", [])],
        "cells": {name: pt(p) for name, p in cfg["cells"].items()},
        "field": rect(cfg["field"]),
        "water": [rect(r) for r in cfg.get("water", [])],
    }
    os.makedirs(os.path.join(root, "data/arenas/planos"), exist_ok=True)
    os.makedirs(os.path.join(root, "sprites/arenas"), exist_ok=True)
    with open(os.path.join(root, "data/arenas/planos/%s.json" % arena_id), "w", encoding="utf8", newline="\n") as f:
        json.dump(plan, f, ensure_ascii=False, indent=1)
    old = os.path.join(root, "data/arenas/planos/%s.txt" % arena_id)  # (formato viejo)
    if os.path.exists(old):
        os.remove(old)
    dst = os.path.join(root, "sprites/arenas/%s.png" % arena_id)
    if cfg.get("brillo", 1.0) != 1.0:  # las muy oscuras (Surge, el Escondite): en plena pelea no se veía el piso
        from PIL import ImageEnhance
        ImageEnhance.Brightness(img.convert("RGB")).enhance(float(cfg["brillo"])).save(dst)
    else:
        shutil.copyfile(src, dst)
    print("%-26s %dx%d, %d de piso, %d de agua" % (arena_id, w, h, sum(r.count(".") for r in rows), len(water)))


def main(root, only=None):
    cfgs = json.load(open(os.path.join(root, "data/arenas/pinturas.json"), encoding="utf8"))
    for arena_id, cfg in cfgs.items():
        if not arena_id.startswith("_") and (only is None or only == arena_id):
            build(root, arena_id, cfg)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
