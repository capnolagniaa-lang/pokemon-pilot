"""Arenas pintadas (2026-11-03, pedido del usuario: arenas "MUY EPICAS" hechas con Qwen). Por cada arena de
data/arenas/pinturas.json:
  - la pintura (art_src/arenas/<id>.png, de Qwen-Image 2.1 Turbo con el `prompt` y la `seed` del JSON, 1600x1200; con
    `sketch` se le pasó ese boceto como imagen para que respete dónde va el agua) va a sprites/arenas/<id>.png sin achicar;
  - el plano, resuelto, a data/arenas/planos/<id>.json, que lee tools/build_arenas.gd para armar la escena:
    `rows` ("." piso, "#" choca, "~" agua de verdad: moja, frena y conduce), floor/wall (metatiles), rocks, cells, field,
    water (rectángulos de pileta). Con `auto` = las celdas claras (pasto, tierra, piso) unidas al centro son piso y lo
    oscuro choca; después se abren los rectángulos `open`, se cierran los `solid` y se ponen los `water`. Con
    `auto_color` (salas del Modo Desafío, con obstáculos pintados) el plano sale por color: ver color_plan.
  - `hd` (salas del Modo Desafio y castillo de Mew) = la pintura del juego la hace tools/refine_arenas.py en alta
    resolucion (sprites/arenas/<id>.jpg) y este script solo arma el plano; `floor_tex` quedo sin uso (se veia granulada);
  - `floor_tex` (opcional) = textura de suelo que se mezcla sobre el piso (ver texture_floor), `floor_tone`, `floor_amount`;
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
    water (bool). Para los otros biomas (2026-11-11): hue = [desde, hasta] del color del piso (por defecto 25-150: pasto y
    tierra; arena 35-65, ceniza 25-60, pasto violeta 235-300), max_s (saturacion maxima: la lava no es piso) y any_hue
    (nieve: todo lo muy claro es piso, sea del color que sea)."""
    import colorsys
    small = img.convert("RGB").resize((w * 8, h * 8), Image.BOX)
    px = small.load()
    min_v, min_s, part = cfg.get("min_v", 95), cfg.get("min_s", 0.3), cfg.get("part", 0.6)
    hue_lo, hue_hi = cfg.get("hue", [25.0, 150.0])
    max_s, any_hue, has_water = cfg.get("max_s", 1.0), cfg.get("any_hue", False), cfg.get("water", False)
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
                    if has_water and 165.0 <= hue <= 250.0 and ss >= 0.25:
                        water_n += 1
                    elif any_hue or (hue_lo <= hue <= hue_hi and min_s <= ss <= max_s):
                        floor_n += 1
            if has_water and water_n >= 64 * part:
                wet.add((x, y))
            elif floor_n >= 64 * part:
                ok.add((x, y))
    # El piso es el pedazo conectado mas grande (con una laguna o un arbol en el medio de la sala, el centro no sirve
    # de punto de partida: se quedaba con la islita).
    seen, left = set(), set(ok)
    while left:
        part = {left.pop()}
        queue = deque(part)
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (x + dx, y + dy)
                if n in left:
                    left.discard(n)
                    part.add(n)
                    queue.append(n)
        if len(part) > len(seen):
            seen = part
    wet = {c for c in wet if any((c[0] + dx, c[1] + dy) in seen or (c[0] + dx, c[1] + dy) in wet
                                 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}
    return seen, wet


def texture_floor(img, cfg, root):
    """Textura de piso (2026-11-11, pedido del usuario: en juego el piso de las salas se veia de un color liso, porque
    Qwen pinta el suelo casi plano y jugando se ve sobre todo suelo). `floor_tex` del JSON = una pintura de suelo visto
    desde arriba (art_src/arenas/texturas/<nombre>.png, del tamano de la sala) que se mezcla SOLO sobre los pixeles de
    piso (la misma regla de color de `auto_color`, pixel a pixel, con el borde suavizado): el piso pasa a ser
    pintura x textura / promedio de la textura (conserva la luz y el tono de la pintura y suma el detalle), corrido
    `floor_tone` (0-1) hacia el color propio de la textura. El plano de colision se saca siempre de la pintura original."""
    from PIL import ImageChops, ImageFilter, ImageStat
    ac = cfg.get("auto_color") or {}
    tex = Image.open(os.path.join(root, "art_src/arenas/texturas/%s.png" % cfg["floor_tex"])).convert("RGB").resize(img.size, Image.LANCZOS)
    if cfg.get("floor_boost", 1.6) != 1.0:  # (las texturas de Qwen salen suaves: se les sube el contraste)
        from PIL import ImageEnhance
        tex = ImageEnhance.Contrast(tex).enhance(float(cfg.get("floor_boost", 1.6)))
    base = img.convert("RGB")
    h, s, v = base.convert("HSV").split()
    lo, hi = [x * 255.0 / 360.0 for x in ac.get("hue", [25.0, 150.0])]
    min_s, max_s, min_v = ac.get("min_s", 0.3) * 255.0, ac.get("max_s", 1.0) * 255.0, ac.get("min_v", 95)
    mask = v.point(lambda x: 255 if x >= min_v else 0)
    if not ac.get("any_hue"):
        mask = ImageChops.multiply(mask, h.point(lambda x: 255 if lo <= x <= hi else 0))
        mask = ImageChops.multiply(mask, s.point(lambda x: 255 if min_s <= x <= max_s else 0))
    mask = mask.filter(ImageFilter.MinFilter(5)).filter(ImageFilter.GaussianBlur(2.5))  # (no pisa el borde de los objetos)
    mean = ImageStat.Stat(tex).mean
    detail = Image.merge("RGB", [ImageChops.multiply(bc, tc).point(lambda x, m=m: min(255, int(x * 255.0 / max(m, 1.0))))
                                 for bc, tc, m in zip(base.split(), tex.split(), mean)])
    detail = Image.blend(detail, tex, float(cfg.get("floor_tone", 0.25)))
    out = Image.composite(detail, base, mask)
    return Image.blend(base, out, float(cfg.get("floor_amount", 1.0)))


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
    edge = int(cfg.get("border", 0))  # (el borde de la sala choca siempre, pinte lo que pinte Qwen ahi)
    if edge > 0:
        rim = {(x, y) for x in range(w) for y in range(h) if x < edge or y < edge or x >= w - edge or y >= h - edge}
        floor -= rim
        water -= rim
    floor |= cells_of(cfg.get("open", []), k)
    if cfg.get("auto_color") is not None:
        water -= cells_of(cfg.get("open", []), k)  # (el paso abierto a mano es piso aunque la pintura ponga agua ahi)
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
    if cfg.get("hd"):
        # La pintura del juego es la de alta resolucion (sprites/arenas/<id>.jpg, de tools/refine_arenas.py): aca solo el plano.
        print("%-26s %dx%d, %d de piso, %d de agua (pintura HD aparte)" % (arena_id, w, h, sum(r.count(".") for r in rows), len(water)))
        return
    if cfg.get("floor_tex"):
        img = texture_floor(img, cfg, root)
        if cfg.get("brillo", 1.0) == 1.0:
            img.save(dst)
    if cfg.get("brillo", 1.0) != 1.0:  # las muy oscuras (Surge, el Escondite): en plena pelea no se veía el piso
        from PIL import ImageEnhance
        ImageEnhance.Brightness(img.convert("RGB")).enhance(float(cfg["brillo"])).save(dst)
    elif not cfg.get("floor_tex"):
        shutil.copyfile(src, dst)
    print("%-26s %dx%d, %d de piso, %d de agua" % (arena_id, w, h, sum(r.count(".") for r in rows), len(water)))


def main(root, only=None):
    cfgs = json.load(open(os.path.join(root, "data/arenas/pinturas.json"), encoding="utf8"))
    for arena_id, cfg in cfgs.items():
        if not arena_id.startswith("_") and (only is None or only == arena_id):
            build(root, arena_id, cfg)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
