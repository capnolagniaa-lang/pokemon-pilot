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

Uso: python -I -B tools/build_piece_rooms.py . [--preview <carpeta>] [<id> ...]
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

# Escena -> ancla + miembros [pieza, dx, dy, azar px, opcional]. En las de "orilla", +x es hacia el agua.
SCENES = {
    "naufragio": {"anchor": "orilla", "members": [
        ["naufragio", 0, 0, 0], ["ancla", 78, 34, 6], ["mastil", -96, 30, 8], ["barril", 64, -34, 5], ["barril", 84, -22, 5],
        ["cajas", -84, -30, 6], ["tablas", 30, 52, 8], ["tablas", -46, 58, 8], ["madera", 108, 52, 8], ["barril", -116, 4, 6, True]]},
    "campamento": {"anchor": "orilla", "members": [
        ["bote", 0, 0, 0], ["remo", 14, 26, 4], ["red_pesca", -78, -34, 6], ["fogata", -50, 30, 5], ["canasta", -92, 16, 5],
        ["cajas", -124, -16, 6], ["madera", -30, 44, 5], ["tronco", -70, 62, 8, True]]},
    "palmeral": {"anchor": "borde", "members": [
        ["palmera", 0, 0, 5], ["palmera_inclinada", 44, 22, 8], ["palmera_baja", -38, 26, 8], ["palmera", 86, -4, 8, True],
        ["cocos", 16, 34, 6], ["cocos", -22, 44, 6, True], ["pasto_duna", 30, 8, 8], ["pasto_duna", -14, 14, 8],
        ["pasto_duna", 62, 30, 8], ["pasto_duna", -50, 6, 8]]},
    "poza_a": {"anchor": "arena", "members": [
        ["poza_a", 0, 0, 0], ["roca_percebes", -70, -8, 6], ["roca_chica", 58, -30, 6], ["coral", 44, 40, 6], ["estrella", -30, 40, 5],
        ["concha", 62, 12, 5], ["cangrejo", -52, 28, 6], ["piedritas", 20, -44, 6]]},
    "poza_b": {"anchor": "arena", "members": [
        ["poza_b", 0, 0, 0], ["roca_percebes", 74, -10, 6], ["roca_chica", -64, 26, 6], ["coral", -50, -34, 6], ["estrella", 40, 44, 5],
        ["concha", -20, 48, 5], ["cangrejo", 60, 34, 6], ["piedritas", -70, -6, 6]]},
    "laguna": {"anchor": "arena", "members": [
        ["laguna", 0, 0, 0], ["roca_chica", 76, 16, 6], ["coral", -66, 22, 6], ["roca_chica", -58, -34, 6], ["estrella", 30, 52, 5],
        ["concha", -30, 54, 5], ["piedritas", 64, -36, 6]]},
    "rocas": {"anchor": "borde", "members": [
        ["roca_grande", 0, 0, 0], ["roca_percebes", 54, 26, 6], ["roca_chica", -44, 22, 6], ["roca_chica", 22, 46, 6, True],
        ["piedritas", -20, 44, 6], ["piedritas", 80, 46, 6], ["algas", 40, 52, 6]]},
    "rocas_orilla": {"anchor": "orilla", "members": [
        ["roca_percebes", 0, 0, 0], ["roca_chica", 48, 20, 6], ["roca_chica", -40, 18, 6], ["coral", 30, -24, 6, True],
        ["piedritas", 10, 34, 6], ["algas", 60, 40, 6]]},
    "charco": {"anchor": "arena", "members": [
        ["charco", 0, 0, 0], ["roca_chica", 40, -14, 5], ["concha", -36, 20, 5], ["estrella", 26, 30, 5]]},
}

# Sala -> (nombre, marco, semilla, escenas en orden de importancia: la primera es la protagonista)
ROOMS = {
    "sala_costa_p1": ("La caleta del pescador", "marco_costa_mar_der", 11,
                      ["campamento", "palmeral", "palmeral", "rocas_orilla", "rocas", "charco"]),
    "sala_costa_p2": ("El naufragio", "marco_costa_mar_izq", 23,
                      ["naufragio", "rocas_orilla", "palmeral", "rocas", "charco", "palmeral"]),
    "sala_costa_p3": ("Las pozas de marea", "marco_costa_ensenada", 37,
                      ["poza_a", "poza_b", "laguna", "rocas_orilla", "palmeral", "rocas"]),
}
BIOME = "costa"
# El plano del marco (mismo criterio que la entrada de la sala en pinturas.json).
FRAME_COLOR = {"hue": [30, 65], "min_s": 0.2, "min_v": 120, "part": 0.6, "water": True, "foam": True}
OPEN = [(30, 0, 4, 10), (30, 40, 4, 8)]


def frame_plan(root, frame):
    img = Image.open(os.path.join(root, "art_src/arenas/%s.png" % frame))
    floor, water = paint_arenas.color_plan(img, W, H, FRAME_COLOR)
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


def base_cells(d, x, y, grow=0.0):
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


def build(root, rid, attempt=0):
    name, frame, seed, scenes = ROOMS[rid]
    rng = random.Random(seed * 1000 + attempt)
    catalog = json.load(open(os.path.join(root, "data/rogue/piezas/%s.json" % BIOME), encoding="utf8"))
    floor, sea = frame_plan(root, frame)
    walls = {(x, y) for x in range(W) for y in range(H)} - floor - sea
    d_sea = distance(list(sea), floor | sea)
    d_wall = distance(list(walls), floor | walls)
    # Donde no va nada sólido: los pasos de entrada y salida (con margen), el frente de las puertas de recompensa y el centro.
    keep = {(x, y) for x in range(26, 38) for y in list(range(0, 14)) + list(range(36, H))}
    keep |= {(x, y) for x in range(22, 42) for y in range(11, 16)}
    centre = {(x, y) for x in range(W) for y in range(H) if ((x - 32) / 10.0) ** 2 + ((y - 25) / 6.5) ** 2 <= 1.0}
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
            if any(abs(cx - ax) + abs(cy - ay) < 13 for ax, ay in anchors):
                continue  # (las escenas, separadas entre sí)
            ax, ay = (cx + 0.5) * T, (cy + 0.5) * T
            # "+x" de la escena = hacia el agua (orilla) o hacia el centro de la sala (borde): se espeja si hace falta.
            mirror = (sea_side if scene["anchor"] == "orilla" else (1 if cx < W / 2 else -1)) < 0
            placed, s_cells, w_cells, ok = [], set(), set(), True
            for k, m in enumerate(scene["members"]):
                pid, dx, dy, jit = m[0], m[1], m[2], m[3]
                optional = k > 0  # (solo la primera, la protagonista de la escena, es obligatoria)
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

    missing = [sid for sid in scenes if not try_scene(sid)]
    if scenes[0] in missing:
        return None  # sin la protagonista no hay sala
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
            pieces.append([pid, round((c[0] + rng.random()) * T), round((c[1] + rng.random()) * T), rng.random() < 0.5])
            pool = [(w2, c2) for w2, c2 in pool if abs(c2[0] - c[0]) + abs(c2[1] - c[1]) > 3]

    calm = lambda c: 0.15 if c in centre else 1.0
    scatter("linea_marea", 7, lambda c: 1.0 if d_sea.get(c, 99) == 2 else 0.0)
    scatter("concha", 12, lambda c: calm(c) * (3.0 if d_sea.get(c, 99) <= 4 else 0.4))
    scatter("estrella", 6, lambda c: calm(c) * (3.0 if d_sea.get(c, 99) <= 3 else 0.2))
    scatter("algas", 7, lambda c: calm(c) * (3.0 if d_sea.get(c, 99) <= 3 else 0.3))
    scatter("cangrejo", 4, lambda c: calm(c) * (2.0 if d_sea.get(c, 99) <= 5 else 0.3))
    scatter("pasto_duna", 14, lambda c: 3.0 if d_wall.get(c, 99) <= 2 and d_sea.get(c, 99) > 5 and c not in keep else 0.0)
    scatter("piedritas", 8, lambda c: calm(c) * (2.0 if d_wall.get(c, 99) <= 3 else 0.3))
    scatter("madera", 4, lambda c: calm(c) * (2.0 if d_sea.get(c, 99) <= 4 else 0.2))
    return {"name": name, "frame": frame, "seed": seed * 1000 + attempt, "scenes": [s for s in scenes if s not in missing],
            "missing": missing, "pieces": pieces}


def preview(root, rid, room, out_dir):
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


def main(root, args):
    out_dir = args[args.index("--preview") + 1] if "--preview" in args else ""
    only = [a for a in args if a in ROOMS]
    for rid in ROOMS:
        if only and rid not in only:
            continue
        room = None
        for attempt in range(40):
            room = build(root, rid, attempt)
            if room is not None and not room["missing"]:
                break
        if room is None:
            sys.exit("%s: no se pudo armar" % rid)
        path = os.path.join(root, "data/rogue/salas/%s.json" % rid)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf8", newline="\n") as f:
            f.write('{\n  "biome": "%s",\n  "name": %s,\n  "frame": "%s",\n  "seed": %d,\n  "scenes": %s,\n  "pieces": [\n'
                    % (BIOME, json.dumps(room["name"], ensure_ascii=False), room["frame"], room["seed"], json.dumps(room["scenes"]))
                    + ",\n".join("    " + json.dumps(p) for p in room["pieces"]) + "\n  ]\n}\n")
        print("%-16s %-24s %d piezas, escenas: %s%s" % (rid, room["name"], len(room["pieces"]), ", ".join(room["scenes"]),
              "  (faltó: %s)" % ", ".join(room["missing"]) if room["missing"] else ""))
        if out_dir:
            preview(root, rid, room, out_dir)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
