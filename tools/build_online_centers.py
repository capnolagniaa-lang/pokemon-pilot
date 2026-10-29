"""Un Centro de Combate Online en cada ciudad (pedido del usuario 2026-10-29; docs/PLAN_ONLINE.md). El de Ciudad Verde
(`centro_online`, O-1) es el original y no se toca: este script arma los demás copiándolo, como agregados de
`ExtraContent` (sin tocar las zonas importadas ni kanto.tres):
  - data/world/extra/buildings/centro_online_<ciudad>.tres  (el edificio, en la celda de CENTERS)
  - data/world/extra/zones/centro_online_<ciudad>.tres      (el interior, debajo de todo el mundo, uno al lado del otro)
  - scenes/world/extra/centro_online_<ciudad>.tscn          (copia del interior de Ciudad Verde)
  - data/story/npcs/centro_online_<ciudad>_{nurse,clerk,recepcionista}.tres (copias de las de Ciudad Verde)
Correrlo de nuevo pisa esos archivos (no los de Ciudad Verde).

Uso: python -I -B tools/build_online_centers.py .            (arma todo)
     python -I -B tools/build_online_centers.py . --buscar   (solo lista lugares libres en cada ciudad)
La celda de cada ciudad salió de --buscar: 5x4 celdas caminables (y un borde de 1 alrededor), sin pasto alto, sin
personas ni objetos, lejos de las puertas, con la puerta del edificio alcanzable y sin cortar ningún camino; con la
fila de abajo cerca de la del Centro Pokémon. Después se miró cada una en pantalla.
"""
import collections
import glob
import json
import os
import re
import sys

# ciudad -> celda (local) de arriba a la izquierda del edificio (5x4; la puerta queda en celda + (2, 3)).
CENTERS = {
    "ciudad_plateada": (21, 40),
    "ciudad_celeste": (26, 32),
    "ciudad_carmin": (39, 19),
    "pueblo_lavanda": (16, 1),
    "ciudad_azulona": (72, 20),
    "ciudad_azafran": (40, 68),
    "ciudad_fucsia": (30, 28),
    "isla_canela": (31, 9),
}
SIZE = (5, 4)
INTERIOR_SIZE = (15, 10)
# Los interiores van en fila al lado del de Ciudad Verde (origen 0, 3300), cada uno a 20 celdas.
INTERIOR_Y = 3300
INTERIOR_STEP = 20

BUILDING = """[gd_resource type="Resource" script_class="ExtraBuilding" format=3]

[ext_resource type="Script" path="res://scripts/resources/extra_building.gd" id="1_b"]
[ext_resource type="Texture2D" path="res://sprites/props/centro_online.png" id="2_t"]

[resource]
script = ExtResource("1_b")
id = "centro_online_{c}"
zone_id = "{c}"
cell = Vector2i({x}, {y})
size = Vector2i({w}, {h})
texture = ExtResource("2_t")
door = Vector2i({dx}, {dy})
to_zone = "centro_online_{c}"
to_cell = Vector2i(7, 8)
"""

ZONE = """[gd_resource type="Resource" script_class="ZoneEntry" format=3]

[ext_resource type="Script" path="res://scripts/resources/zone_entry.gd" id="1_z"]

[resource]
script = ExtResource("1_z")
id = "centro_online_{c}"
display_name = "Centro de Combate Online"
scene_path = "res://scenes/world/extra/centro_online_{c}.tscn"
origin = Vector2i({ox}, {oy})
size = Vector2i({w}, {h})
biome = "interior"
hub = Vector2i(7, 5)
warps = {{
{warps}
}}
interior = true
"""

WARP = """Vector2i({x}, 8): {{
"cell": Vector2i({dx}, {dy}),
"to": "{c}"
}}"""


def door_of(cell):
    return (cell[0] + 2, cell[1] + SIZE[1] - 1)


def build(root):
    scene = open(os.path.join(root, "scenes/world/extra/centro_online.tscn"), encoding="utf8").read()
    scene = re.sub(r' uid="[^"]*"', "", scene, count=1)  # (la copia no puede tener el mismo uid)
    npcs = {n: open(os.path.join(root, "data/story/npcs/centro_online_%s.tres" % n), encoding="utf8").read()
            for n in ("nurse", "clerk", "recepcionista")}
    for k, (city, cell) in enumerate(CENTERS.items(), start=1):
        dx, dy = door_of(cell)
        warps = ",\n".join(WARP.format(x=x, dx=dx, dy=dy, c=city) for x in (6, 7, 8))
        out = {
            "data/world/extra/buildings/centro_online_%s.tres" % city:
                BUILDING.format(c=city, x=cell[0], y=cell[1], w=SIZE[0], h=SIZE[1], dx=dx, dy=dy),
            "data/world/extra/zones/centro_online_%s.tres" % city:
                ZONE.format(c=city, ox=k * INTERIOR_STEP, oy=INTERIOR_Y, w=INTERIOR_SIZE[0], h=INTERIOR_SIZE[1],
                            warps=warps),
            "scenes/world/extra/centro_online_%s.tscn" % city:
                scene.replace('zone_id = "centro_online"', 'zone_id = "centro_online_%s"' % city),
        }
        for n, text in npcs.items():
            t = text.replace('id = "centro_online_%s"' % n, 'id = "centro_online_%s_%s"' % (city, n))
            t = t.replace('zone_id = "centro_online"', 'zone_id = "centro_online_%s"' % city)
            out["data/story/npcs/centro_online_%s_%s.tres" % (city, n)] = t
        for path, text in out.items():
            with open(os.path.join(root, path), "w", encoding="utf8", newline="\n") as f:
                f.write(text)
        print("%-16s edificio %s, puerta %s, interior en %s" % (city, cell, (dx, dy), (k * INTERIOR_STEP, INTERIOR_Y)))


def free_spots(root, city, size, extra_blocked=frozenset()):
    """Lugares libres para algo de `size` celdas en una ciudad, los mejores primero: [(puntaje, (x, y))]. Todo caminable
    (y un borde de 1 alrededor), sin pasto alto, sin personas, objetos ni `extra_blocked`, lejos de las puertas, con el
    frente (abajo al medio) alcanzable y sin cortar ningún camino; cuanto más cerca de la fila del Centro Pokémon, mejor.
    (También lo usa tools/build_balloons.py.)"""
    d = json.load(open(os.path.join(root, "data/world/frlg_maps.json"), encoding="utf8"))
    cat = json.load(open(os.path.join(root, "art/pret/tiles/catalog.json"), encoding="utf8"))
    water = {int(k) for k, v in cat["physics"].items() if v == 1}
    tags = cat.get("tags", {})
    z = next(z for z in d["zones"] if z["id"] == city)
    people = set()
    for f in glob.glob(os.path.join(root, "data/story/npcs/*.tres")):
        s = open(f, encoding="utf8").read()
        m = re.search(r'zone_id = "([^"]+)"', s)
        c = re.search(r'\ncell = Vector2i\((-?\d+), (-?\d+)\)', s)
        if m and c and m.group(1) == city:
            people.add((int(c.group(1)), int(c.group(2))))
    W, H = size
    w, h = z["size"]
    warps = [tuple(x["cell"]) for x in z["warps"]]
    blocked = set(warps) | {tuple(o["cell"]) for o in z["objects"]} | people | {tuple(n["cell"]) for n in z["npcs"]}         | set(extra_blocked)

    def walk(c):
        if not (0 <= c[0] < w and 0 <= c[1] < h) or c in extra_blocked:
            return False
        i = c[1] * w + c[0]
        return z["col"][i] == 0 and z["cells"][i] >= 0 and z["cells"][i] not in water

    def reach(extra=frozenset()):
        st = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)] + warps
        seen = {s for s in st if walk(s) and s not in extra}
        q = collections.deque(seen)
        while q:
            cx, cy = q.popleft()
            for ddx, ddy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (cx + ddx, cy + ddy)
                if n not in seen and n not in extra and walk(n):
                    seen.add(n)
                    q.append(n)
        return seen
    base = reach()
    cen = next((tuple(x["cell"]) for x in z["warps"] if x["to"].endswith("_centro")), (w // 2, h // 2))
    found = []
    for y in range(1, h - H - 1):
        for x in range(1, w - W - 1):
            rect = {(x + i, y + j) for i in range(W) for j in range(H)}
            ring = {(x + i, y + j) for i in range(-1, W + 1) for j in range(-1, H + 2)}
            if not all(walk(c) and c not in blocked for c in ring):
                continue
            if any("pasto_alto" in tags.get(str(z["cells"][c[1] * w + c[0]]), []) for c in rect):
                continue
            if any(x - 3 <= wx <= x + W + 2 and y - 3 <= wy <= y + H + 3 for wx, wy in warps):
                continue
            if (x + W // 2, y + H) not in base or len(reach(frozenset(rect))) != len(base) - len(rect & base):
                continue
            found.append((abs(y + H - 1 - cen[1]) * 3 + abs(x + W // 2 - cen[0]), (x, y)))
    found.sort()
    return found


def search(root):
    for city in CENTERS:
        found = free_spots(root, city, SIZE)
        print("%-16s %d lugares; los mejores %s" % (city, len(found), [c for _, c in found[:5]]))


if __name__ == "__main__":
    (search if "--buscar" in sys.argv else build)(sys.argv[1])
