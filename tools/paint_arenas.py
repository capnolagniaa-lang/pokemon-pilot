"""Arenas pintadas (2026-11-03, pedido del usuario: arenas "MUY EPICAS" hechas con Qwen). Por cada arena de
data/arenas/pinturas.json:
  - la pintura (art_src/arenas/<id>.png, de Qwen-Image 2.1 Turbo con el `prompt` y la `seed` del JSON, 1600x1200; con
    `sketch` se le pasó ese boceto como imagen para que respete dónde va el agua) va a sprites/arenas/<id>.png sin achicar;
  - el plano, resuelto, a data/arenas/planos/<id>.json, que lee tools/build_arenas.gd para armar la escena:
    `rows` ("." piso, "#" choca, "~" agua de verdad: moja, frena y conduce), floor/wall (metatiles), rocks, cells, field,
    water (rectángulos de pileta). Con `auto` = las celdas claras (pasto, tierra, piso) unidas al centro son piso y lo
    oscuro choca; después se abren los rectángulos `open`, se cierran los `solid` y se ponen los `water`. Con
    `auto_color` (salas del Modo Desafío, con obstáculos pintados) el plano sale por color: ver color_plan.
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


def color_plan(img, w, h, cfg):
    """Plano por color (salas con obstaculos pintados; `auto_color` del JSON): piso = celdas claras y de color (pasto,
    musgo, tierra), unidas al centro; lo gris (rocas, ruinas), lo marron oscuro (troncos, raices) y lo oscuro (arboles)
    choca; con `water` true, lo celeste es agua de verdad. Cada celda se decide por mayoria de sus 64 muestras.
    Claves: min_v (brillo minimo 0-255), min_s (saturacion minima 0-1), part (parte de la celda que tiene que ser piso),
    water (bool)."""
    import colorsys
    small = img.convert("RGB").resize((w * 8, h * 8), Image.BOX)
    px = small.load()
    min_v, min_s, part = cfg.get("min_v", 95), cfg.get("min_s", 0.3), cfg.get("part", 0.6)
    ok, wet = set(), set()
    for y in range(h):
        for x in range(w):
            floor_n = water_n = 0
            for j in range(8):
                for i in range(8):
                    r, g, b = px[x * 8 + i, y * 8 + j]
                    hh, ss, vv = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
                    hue = hh * 360.0
                    if vv * 255.0 < min_v:
                        continue
                    if 165.0 <= hue <= 250.0 and ss >= 0.25:
                        water_n += 1
                    elif 25.0 <= hue <= 150.0 and ss >= min_s:
                        floor_n += 1
            if cfg.get("water") and water_n >= 64 * part:
                wet.add((x, y))
            elif floor_n >= 64 * part:
                ok.add((x, y))
    start = (w // 2, h // 2)
    if start not in ok:  # (un obstaculo justo en el medio: la celda de piso mas cercana)
        start = min(ok, key=lambda c: abs(c[0] - start[0]) + abs(c[1] - start[1]))
    seen = {start}
    queue = deque(seen)
    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n in ok and n not in seen:
                seen.add(n)
                queue.append(n)
    wet = {c for c in wet if any((c[0] + dx, c[1] + dy) in seen or (c[0] + dx, c[1] + dy) in wet
                                 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}
    return seen, wet


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
    water = set()
    if cfg.get("auto_color") is not None:
        floor, water = color_plan(img, w, h, cfg["auto_color"])
    floor |= cells_of(cfg.get("open", []), k)
    floor -= cells_of(cfg.get("solid", []), k)
    water |= cells_of(cfg.get("water", []), k)
    floor -= water
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
        "water_cells": sorted([x, y] for x, y in water - cells_of(cfg.get("water", []), k)),  # (las del plano por color)
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
