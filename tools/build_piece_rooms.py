"""Generador de las "Salas por piezas" del Modo Desafío (sección 10 de docs/PROPUESTA_ROGUELIKE.md, P-1).
Arma cada sala de ROOMS colocando **escenas** (grupos de piezas con lógica), no piezas sueltas (pedido del usuario
2026-11-11: "debería tener algo de sentido el mapa dibujado y no dejar cosas por dejar"): el naufragio va con su ancla,
su mástil y sus barriles pegado a la orilla; el campamento del pescador, con el bote junto al agua; las palmeras, en
palmerales contra el acantilado; las pozas, con rocas y corales en el borde.

Cómo: lee el plano del marco de la sala (piso / mar / pared, con tools/paint_arenas.py::color_plan sobre
art_src/arenas/<marco>.png) y, con la semilla de la sala:
  1. coloca las escenas de su tema, cada una en un **ancla** según su regla: "orilla" (piso a 2-4 celdas del mar),
     "borde" (contra la pared, lejos del mar) o "arena" (piso abierto); los miembros van en su lugar relativo, con un
     poco de azar y espejados si el mar queda del otro lado (`hacia el agua` = +x en las escenas de orilla);
  2. no pone nada sólido en los pasos de entrada y salida, ni en el centro (el espacio de pelea), ni pegado a otra escena;
  3. reparte el decorado sin colisión con criterio: líneas de marea y conchas junto al agua, pasto de duna contra la
     pared, piedritas junto a las rocas, y casi nada en el centro;
  4. valida que todo el piso quede conectado de la entrada a la salida (si no, prueba otra semilla).
Escribe data/rogue/salas/<id>.json (lo lee RoomPieces) y una vista previa en --preview <carpeta>.

Uso: python -I -B tools/build_piece_rooms.py . [--preview <carpeta>] <bioma o id de sala> ...   (datos: tools/piece_room_data.py)
Después: paint_arenas.py . <id> → godot --import → build_arenas.gd -- --only <id>
"""
import json
import math
import os
import random
import sys
from collections import deque

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import paint_arenas  # noqa: E402

T = 16
W, H = 64, 48
# Celdas de piso de una sala "amplia" (se llena del todo) y cuánto del decorado suelto de la tabla se pone.
FULL_FLOOR = 1900
DECOR_K = 0.7

from piece_room_data import BIOMES  # noqa: E402

# Todas las salas: id -> (nombre, marco, semilla, escenas, bioma)
ROOMS = {rid: tuple(room) + (biome,) for biome, d in BIOMES.items() for rid, room in d["rooms"].items()}
OPEN = [(30, 0, 4, 10), (30, 40, 4, 8)]


def lava_cells(img):
    """Las celdas de lava de un marco de volcán (naranja muy saturado y brillante): no se pisan, pero son "la orilla"."""
    import colorsys
    small = img.convert("RGB").resize((W * 4, H * 4), Image.BOX)
    px = small.load()
    out = set()
    for y in range(H):
        for x in range(W):
            n = 0
            for j in range(4):
                for i in range(4):
                    r, g, b = px[x * 4 + i, y * 4 + j]
                    hh, ss, vv = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
                    if (hh * 360.0 < 42.0 or hh * 360.0 > 345.0) and ss > 0.78 and vv > 0.6:
                        n += 1
            if n >= 8:
                out.add((x, y))
    return out


def frame_plan(root, frame, cfg):
    """(piso, líquido) del marco: el líquido es el agua (se pisa la de la orilla) o, en el volcán, la lava (no se pisa)."""
    img = Image.open(os.path.join(root, "art_src/arenas/%s.png" % frame))
    floor, water = paint_arenas.color_plan(img, W, H, cfg["color"])
    if cfg.get("lava"):
        water = lava_cells(img)
        floor -= water
    # El líquido que cuenta para ubicar las escenas es la masa más grande (un borde celeste de la pared no es "la orilla").
    best, left = set(), set(water)
    while left:
        part = {left.pop()}
        queue = deque(part)
        while queue:
            x, y = queue.popleft()
            for n in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if n in left:
                    left.discard(n)
                    part.add(n)
                    queue.append(n)
        if len(part) > len(best):
            best = part
    water = best if len(best) >= 40 else set()
    rim = {(x, y) for x in range(W) for y in range(H) if x < 1 or y < 1 or x >= W - 1 or y >= H - 1}
    floor -= rim
    water -= rim
    for x0, y0, w, h in OPEN:
        cells = {(x, y) for x in range(x0, x0 + w) for y in range(y0, y0 + h)}
        floor |= cells
        water -= cells
    return floor, water


def distance(sources, allowed):
    """Distancia en celdas (8 vecinos) desde `sources`, caminando por `allowed`."""
    out = {c: 0 for c in sources}
    queue = deque(sources)
    while queue:
        x, y = queue.popleft()
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                n = (x + dx, y + dy)
                if n in allowed and n not in out:
                    out[n] = out[(x, y)] + 1
                    queue.append(n)
    return out


CELL_GROW = 7.0  # (igual que RoomPieces.CELL_GROW: se marca toda celda que la base toca)


def base_cells(d, x, y, grow=0.0):
    grow += CELL_GROW if d["kind"] == "solida" else 0.0
    rx, ry = max(d["base"][0] / 2.0, 1.0) + grow, max(d["base"][1] / 2.0, 1.0) + grow
    out = set()
    for cy in range(int((y - ry) // T), int((y + ry) // T) + 1):
        for cx in range(int((x - rx) // T), int((x + rx) // T) + 1):
            px, py = (cx + 0.5) * T - x, (cy + 0.5) * T - y
            if (px * px) / (rx * rx) + (py * py) / (ry * ry) <= 1.0:
                out.add((cx, cy))
    return out or {(int(x // T), int(y // T))}


def connected(floor, blocked):
    free = floor - blocked
    start = (32, H - 2)
    if start not in free or (32, 1) not in free:
        return False, 0.0
    seen = {start}
    queue = deque(seen)
    while queue:
        x, y = queue.popleft()
        for n in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if n in free and n not in seen:
                seen.add(n)
                queue.append(n)
    return (32, 1) in seen, len(seen) / float(len(free))


def build(root, rid, attempt=0, rotate=0):
    name, frame, seed, scenes, biome = ROOMS[rid]
    scenes = list(scenes[rotate:]) + list(scenes[:rotate])  # (si la protagonista no entra, prueba con la siguiente)
    cfg = BIOMES[biome]
    SCENES = cfg["scenes"]
    rng = random.Random(seed * 1000 + attempt)
    catalog = json.load(open(os.path.join(root, "data/rogue/piezas/%s.json" % biome), encoding="utf8"))
    floor, sea = frame_plan(root, frame, cfg)
    walls = {(x, y) for x in range(W) for y in range(H)} - floor - sea
    d_sea = distance(list(sea), floor | sea)
    d_wall = distance(list(walls), floor | walls)
    # Donde no va nada sólido: los pasos de entrada y salida (con margen), el frente de las puertas de recompensa y el centro.
    keep = {(x, y) for x in range(26, 38) for y in list(range(0, 14)) + list(range(36, H))}
    keep |= {(x, y) for x in range(22, 42) for y in range(11, 16)}
    if cfg.get("trail"):  # el sendero pintado del marco, de la entrada a la salida
        keep |= {(x, y) for x in range(29, 35) for y in range(H)}
    # Cuánto se llena la sala depende de su piso (pedido del usuario 2026-11-11: "algunas salas se sienten MUY cargadas"):
    # con mar, lago o lava grande queda menos lugar, así que van menos escenas y menos decorado. `room_k` = 1 con
    # FULL_FLOOR celdas de piso o más; el centro (el espacio de pelea) queda siempre libre de sólidos.
    room_k = max(0.45, min(1.0, len(floor) / float(FULL_FLOOR)))
    centre = {(x, y) for x in range(W) for y in range(H) if ((x - 32) / 12.0) ** 2 + ((y - 25) / 8.0) ** 2 <= 1.0}
    sea_side = 1 if sum(x for x, _ in sea) / max(1, len(sea)) > W / 2 else -1
    solid, wet, used = set(), set(), set()  # celdas sólidas, de agua de piezas y "ocupadas" (con margen entre escenas)
    pieces, anchors = [], []

    def spots(rule):
        out = []
        for c in floor:
            if c in keep or c in centre or c in used:
                continue
            ds, dw = d_sea.get(c, 99), d_wall.get(c, 99)
            if rule == "orilla" and 4 <= ds <= 8 and dw >= 4:
                out.append(c)
            elif rule == "borde" and 3 <= dw <= 4 and ds >= 9:
                out.append(c)
            elif rule == "arena" and dw >= 6 and ds >= 7:
                out.append(c)
        return out

    def try_scene(sid):
        scene = SCENES[sid]
        options = spots(scene["anchor"])
        rng.shuffle(options)
        for cx, cy in options[:120]:
            if any(abs(cx - ax) + abs(cy - ay) < 15 for ax, ay in anchors):
                continue  # (las escenas, separadas entre sí)
            ax, ay = (cx + 0.5) * T, (cy + 0.5) * T
            # "+x" de la escena = hacia el agua (orilla) o hacia el centro de la sala (borde): se espeja si hace falta.
            mirror = (sea_side if scene["anchor"] == "orilla" else (1 if cx < W / 2 else -1)) < 0
            placed, s_cells, w_cells, ok = [], set(), set(), True
            for k, m in enumerate(scene["members"]):
                pid, dx, dy, jit = m[0], m[1], m[2], m[3]
                optional = k > 0  # (solo la primera, la protagonista de la escena, es obligatoria)
                if pid not in catalog:
                    continue
                d = catalog[pid]
                x = round(ax + (-dx if mirror else dx) + rng.uniform(-jit, jit))
                y = round(ay + dy + rng.uniform(-jit, jit))
                if d["kind"] == "decorado":
                    c = (int(x // T), int(y // T))
                    if c in floor and c not in s_cells:
                        placed.append([pid, x, y, mirror])
                    continue
                cells = base_cells(d, x, y)
                margin = base_cells(d, x, y, 10.0)
                bad = not cells <= floor or cells & (keep | centre | solid | wet | s_cells | w_cells) or margin & used
                if d["kind"] == "zona":
                    bad = bad or not margin <= floor
                if bad:
                    if optional:
                        continue
                    ok = False
                    break
                placed.append([pid, x, y, mirror])
                (w_cells if d["kind"] == "zona" else s_cells).update(cells)
            if not ok or len(placed) < max(2, len(scene["members"]) * 2 // 3):
                continue  # (una escena a la que le falta la mitad no cuenta la historia)
            good, part = connected(floor, solid | s_cells | wet | w_cells)
            if not good or part < 0.97:
                continue
            pieces.extend(placed)
            solid.update(s_cells)
            wet.update(w_cells)
            for c in s_cells | w_cells:
                for dx in range(-2, 3):
                    for dy in range(-2, 3):
                        used.add((c[0] + dx, c[1] + dy))
            anchors.append((cx, cy))
            return True
        return False

    scenes = scenes[:max(3, round(len(scenes) * room_k))]
    missing = [sid for sid in scenes if not try_scene(sid)]
    if (scenes[0] in missing and attempt < 40) or len(scenes) - len(missing) < 2:
        return None  # sin la protagonista no hay sala (pasados 40 intentos, se acepta la que tenga 2 escenas o más)
    # Decorado suelto, con criterio.
    free = [c for c in floor if c not in solid and c not in wet]

    def scatter(pid, count, weight):
        pool = [(weight(c), c) for c in free]
        pool = [(w, c) for w, c in pool if w > 0.0]
        for _ in range(count):
            if not pool:
                return
            total = sum(w for w, _ in pool)
            pick = rng.uniform(0, total)
            for w, c in pool:
                pick -= w
                if pick <= 0:
                    break
            pieces.append([pid, c[0] * T + rng.randrange(1, T - 1), c[1] * T + rng.randrange(1, T - 1), rng.random() < 0.5])  # (adentro de su celda)
            pool = [(w2, c2) for w2, c2 in pool if abs(c2[0] - c[0]) + abs(c2[1] - c[1]) > 3]

    calm = lambda c: 0.15 if c in centre else 1.0
    rules = {
        "linea": lambda c: 1.0 if d_sea.get(c, 99) == 2 else 0.0,
        "liquido": lambda c: calm(c) * (3.0 if d_sea.get(c, 99) <= 4 else 0.3),
        "pared": lambda c: 3.0 if d_wall.get(c, 99) <= 2 and d_sea.get(c, 99) > 5 and c not in keep else 0.0,
        "roca": lambda c: calm(c) * (2.0 if d_wall.get(c, 99) <= 3 else 0.3),
        "suelto": lambda c: calm(c),
    }
    for pid, count, rule in cfg.get("decor", []):
        if pid in catalog and catalog[pid]["kind"] == "decorado":  # (suelto va solo lo que no choca)
            scatter(pid, max(1, round(count * room_k * DECOR_K)), rules[rule])
    # El decorado que quedó debajo de la base de una pieza sólida (puesta después) no se ve: se saca.
    pieces = [p for p in pieces if catalog[p[0]]["kind"] != "decorado" or (int(p[1] // T), int(p[2] // T)) not in solid]
    return {"name": name, "frame": frame, "biome": biome, "seed": seed * 1000 + attempt, "scenes": [s for s in scenes if s not in missing],
            "missing": missing, "pieces": pieces}


def preview(root, rid, room, out_dir):
    BIOME = room["biome"]
    catalog = json.load(open(os.path.join(root, "data/rogue/piezas/%s.json" % BIOME), encoding="utf8"))
    bg = Image.open(os.path.join(root, "art_src/arenas/%s.png" % room["frame"])).convert("RGB").resize((W * T, H * T), Image.BOX).convert("RGBA")
    order = sorted(room["pieces"], key=lambda p: ({"zona": 0, "decorado": 1, "solida": 2}[catalog[p[0]]["kind"]], p[2]))
    for p in order:
        d = catalog[p[0]]
        im = Image.open(os.path.join(root, "sprites/rogue/piezas/%s/%s.png" % (BIOME, p[0]))).convert("RGBA")
        foot = d.get("foot", 0)
        if len(p) > 3 and p[3]:
            im = im.transpose(Image.FLIP_LEFT_RIGHT)
            foot = -foot
        if d["kind"] == "solida":
            pos = (p[1] - im.width // 2 - foot, p[2] - im.height + d["base"][1] // 2 + d["sink"])
        else:
            pos = (p[1] - im.width // 2, p[2] - im.height // 2)
        bg.alpha_composite(im, (int(pos[0]), int(pos[1])))
    os.makedirs(out_dir, exist_ok=True)
    bg.convert("RGB").save(os.path.join(out_dir, rid + ".png"))


def ensure_entry(root, rid, room):
    """La entrada de la sala en data/arenas/pinturas.json (la crea si falta, antes de la del castillo; si ya está, no la
    toca): su marco como `src`, pixel art 1 a 1 y el `auto_color` de su bioma."""
    path = os.path.join(root, "data/arenas/pinturas.json")
    raw = open(path, encoding="utf8", newline="").read()
    if '"%s": {' % rid in raw:
        return
    cfg = BIOMES[room["biome"]]
    meta_path = os.path.join(root, "art_src/arenas/%s.json" % room["frame"])
    meta = json.load(open(meta_path, encoding="utf8")) if os.path.exists(meta_path) else {}
    entry = {
        "_modo": "Sala POR PIEZAS del Modo Desafío (tools/build_piece_rooms.py, datos en tools/piece_room_data.py): fondo = el marco `src` en pixel art 1 a 1 (`pixel`), obstáculos = data/rogue/salas/<id>.json (RoomPieces).",
        "name": room["name"], "src": room["frame"], "pixel": [W * T, H * T, 128], "size": [W, H], "auto": None,
        "auto_color": cfg["color"], "border": 1, "open": [list(r) for r in OPEN], "solid": [], "floor": 1, "wall": 35008,
        "rocks": [], "cells": {"foe_trainer": [32, 5], "foe_mon": [32, 18], "player_mon": [32, 40], "player": [32, 43]},
        "field": [10, 10, 44, 30], "prompt": meta.get("prompt", ""), "seed": meta.get("seed", 0), "px": [2048, 1536]}
    if cfg.get("deep"):
        entry["deep"] = cfg["deep"]
    body = json.dumps({rid: entry}, ensure_ascii=False, indent=2)[1:-1].rstrip("\n").lstrip("\n")
    i = raw.index('  "castillo_mew": {')
    raw = raw[:i] + body + ",\n" + raw[i:]
    json.loads(raw)
    open(path, "w", encoding="utf8", newline="").write(raw)


def main(root, args):
    out_dir = args[args.index("--preview") + 1] if "--preview" in args else ""
    only = [a for a in args if a in ROOMS] + [rid for rid, r in ROOMS.items() if r[4] in args]
    if not only:
        sys.exit("decí qué salas o qué bioma armar (p. ej. volcan, o sala_costa_p1): no se rearma todo sin pedirlo")
    for rid in ROOMS:
        if only and rid not in only:
            continue
        room = None
        best = None
        for attempt in range(60):
            room = build(root, rid, attempt)
            if room is not None and (best is None or len(room["missing"]) < len(best["missing"])):
                best = room
            if room is not None and not room["missing"]:
                break
            if attempt >= 39 and best is not None and best["scenes"][0] == ROOMS[rid][3][0]:
                break
        rotate = 1
        while best is None and rotate < len(ROOMS[rid][3]):
            for attempt in range(20):
                best = build(root, rid, attempt, rotate)
                if best is not None:
                    break
            rotate += 1
        room = best
        if room is None:
            print("%s: NO se pudo armar (queda como estaba)" % rid)
            continue
        path = os.path.join(root, "data/rogue/salas/%s.json" % rid)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf8", newline="\n") as f:
            f.write('{\n  "biome": "%s",\n  "name": %s,\n  "frame": "%s",\n  "seed": %d,\n  "scenes": %s,\n  "pieces": [\n'
                    % (room["biome"], json.dumps(room["name"], ensure_ascii=False), room["frame"], room["seed"], json.dumps(room["scenes"]))
                    + ",\n".join("    " + json.dumps(p) for p in room["pieces"]) + "\n  ]\n}\n")
        print("%-16s %-24s %d piezas, escenas: %s%s" % (rid, room["name"], len(room["pieces"]), ", ".join(room["scenes"]),
              "  (faltó: %s)" % ", ".join(room["missing"]) if room["missing"] else ""))
        ensure_entry(root, rid, room)
        if out_dir:
            preview(root, rid, room, out_dir)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
