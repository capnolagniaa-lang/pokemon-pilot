"""Un globo aerostático con su piloto en cada ciudad (pedido del usuario 2026-10-29; BalloonTravel,
scripts/world/balloon_travel.gd). Arma, como agregados de `ExtraContent` (sin tocar las zonas importadas):
  - data/world/extra/buildings/globo_<ciudad>.tres  (el globo: 3x2 celdas sólidas, sin puerta; sprites/props/globo.png)
  - data/story/npcs/globo_<ciudad>_piloto.tres      (el piloto, a la izquierda de la canasta; acción "globo")
Bajás del globo en la celda de abajo al medio. Correrlo de nuevo pisa esos archivos.

Uso: python -I -B tools/build_balloons.py .            (arma todo)
     python -I -B tools/build_balloons.py . --buscar   (solo lista lugares libres)
El lugar sale de free_spots (tools/build_online_centers.py) contando también al piloto y dejando libre el Centro de
Combate Online y su entrada; la celda de cada ciudad quedó fija en BALLOONS después de mirarla en pantalla.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_online_centers as centers  # noqa: E402

# ciudad -> celda (local) de arriba a la izquierda del globo (3x2).
BALLOONS = {
    "ciudad_verde": (52, 45),
    "ciudad_plateada": (40, 42),
    "ciudad_celeste": (21, 35),
    "ciudad_carmin": (47, 21),
    "pueblo_lavanda": (6, 6),
    "ciudad_azulona": (80, 22),
    "ciudad_azafran": (48, 70),
    "ciudad_fucsia": (38, 30),
    "isla_canela": (21, 15),
}
SIZE = (3, 2)
PILOT_GFX = "gentleman"

BUILDING = """[gd_resource type="Resource" script_class="ExtraBuilding" format=3]

[ext_resource type="Script" path="res://scripts/resources/extra_building.gd" id="1_b"]
[ext_resource type="Texture2D" path="res://sprites/props/globo.png" id="2_t"]

[resource]
script = ExtResource("1_b")
id = "globo_{c}"
zone_id = "{c}"
cell = Vector2i({x}, {y})
size = Vector2i({w}, {h})
texture = ExtResource("2_t")
"""

PILOT = """[gd_resource type="Resource" script_class="NpcData" format=3]

[ext_resource type="Script" path="res://scripts/resources/npc_data.gd" id="1_n"]
[ext_resource type="Script" path="res://scripts/resources/npc_talk.gd" id="2_t"]

[sub_resource type="Resource" id="Talk_0"]
script = ExtResource("2_t")
lines = PackedStringArray("¡Buenas! Con mi globo te llevo volando a cualquier ciudad que ya conozcas.")
action = "globo"

[resource]
script = ExtResource("1_n")
id = "globo_{c}_piloto"
display_name = "Piloto"
zone_id = "{c}"
cell = Vector2i({px}, {py})
gfx = "{gfx}"
facing = Vector2i(0, 1)
look_around = false
talks = Array[ExtResource("2_t")]([SubResource("Talk_0")])
"""


def online_center_cells(root, city):
    """Las celdas del Centro de Combate Online de la ciudad, con un borde de 1 y 3 filas libres frente a la puerta."""
    path = os.path.join(root, "data/world/extra/buildings")
    out = set()
    for f in os.listdir(path):
        s = open(os.path.join(path, f), encoding="utf8").read()
        if not f.startswith("centro_online") or 'zone_id = "%s"' % city not in s:
            continue
        cx, cy = map(int, re.search(r"\ncell = Vector2i\((\d+), (\d+)\)", s).groups())
        w, h = map(int, re.search(r"\nsize = Vector2i\((\d+), (\d+)\)", s).groups())
        dx, dy = map(int, re.search(r"\ndoor = Vector2i\((\d+), (\d+)\)", s).groups())
        out |= {(cx + i, cy + j) for i in range(-1, w + 1) for j in range(-1, h + 1)}
        out |= {(dx + i, dy + j) for i in (-1, 0, 1) for j in (1, 2, 3)}
    return out


def spots(root, city):
    # Se busca con un ancho de 4 (la columna de la izquierda es la del piloto) para que él también quede libre.
    found = centers.free_spots(root, city, (SIZE[0] + 1, SIZE[1]), online_center_cells(root, city))
    return [(score, (x + 1, y)) for score, (x, y) in found]


def build(root):
    for city, cell in BALLOONS.items():
        if cell is None:
            found = spots(root, city)
            cell = found[0][1]
        x, y = cell
        pilot = (x - 1, y + SIZE[1] - 1)
        files = {
            "data/world/extra/buildings/globo_%s.tres" % city: BUILDING.format(c=city, x=x, y=y, w=SIZE[0], h=SIZE[1]),
            "data/story/npcs/globo_%s_piloto.tres" % city: PILOT.format(c=city, px=pilot[0], py=pilot[1], gfx=PILOT_GFX),
        }
        for p, text in files.items():
            with open(os.path.join(root, p), "w", encoding="utf8", newline="\n") as f:
                f.write(text)
        print("%-16s globo %s, piloto %s, bajás en %s" % (city, cell, pilot, (x + SIZE[0] // 2, y + SIZE[1])))


def search(root):
    for city in BALLOONS:
        found = spots(root, city)
        print("%-16s %d lugares; los mejores %s" % (city, len(found), [c for _, c in found[:6]]))


if __name__ == "__main__":
    (search if "--buscar" in sys.argv else build)(sys.argv[1])
