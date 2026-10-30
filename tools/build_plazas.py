"""Plazas con un puesto de panchos y hamburguesas y una parrilla en las ciudades grandes (pedido del usuario 2026-10-29;
sprites hechos con Qwen: sprites/props/puesto_panchos.png y parrilla.png, y las personas art/pret/characters/parrillero.png
y puestero.png). También las sombrillas de la playa de Ciudad Celeste. Arma, como agregados de `ExtraContent` (sin tocar
las zonas importadas):
  - data/world/extra/buildings/plaza_<ciudad>_{puesto,parrilla}.tres  (objetos sólidos, sin puerta)
  - data/story/npcs/plaza_<ciudad>_{puestero,parrillero}.tres         (con sus charlas)
  - data/world/extra/buildings/playa_celeste_sombrilla_<n>.tres
Correrlo de nuevo pisa esos archivos.

Uso: python -I -B tools/build_plazas.py .            (arma todo)
     python -I -B tools/build_plazas.py . --buscar   (solo lista lugares libres)
Cada plaza ocupa 8x3 celdas: el puesto (3x2) a la izquierda con el puestero al lado, y la parrilla (2x1) a la derecha con
el parrillero atrás. El lugar sale de free_spots (tools/build_online_centers.py), dejando libres el Centro de Combate
Online, el globo y sus entradas; se eligió la más abierta
(sin nada sólido alrededor) y quedó fija en PLAZAS después de mirarla en pantalla.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_online_centers as centers  # noqa: E402
import build_balloons as balloons  # noqa: E402

# ciudad -> celda (local) de arriba a la izquierda de la plaza (8x3).
PLAZAS = {
    "ciudad_celeste": (14, 43),
    "ciudad_carmin": (54, 24),
    "ciudad_azulona": (30, 8),
    "ciudad_azafran": (45, 16),
    "ciudad_fucsia": (35, 38),
}
SIZE = (8, 3)
# Sombrillas de la playa de Ciudad Celeste (tools/import_frlg_maps.py, PAINTS): celdas de arriba a la izquierda (3x1).
UMBRELLAS = [(12, 14), (20, 16), (28, 13)]

OBJECT = """[gd_resource type="Resource" script_class="ExtraBuilding" format=3]

[ext_resource type="Script" path="res://scripts/resources/extra_building.gd" id="1_b"]
[ext_resource type="Texture2D" path="res://sprites/props/{tex}.png" id="2_t"]

[resource]
script = ExtResource("1_b")
id = "{id}"
zone_id = "{c}"
cell = Vector2i({x}, {y})
size = Vector2i({w}, {h})
texture = ExtResource("2_t")
"""

PERSON = """[gd_resource type="Resource" script_class="NpcData" format=3]

[ext_resource type="Script" path="res://scripts/resources/npc_data.gd" id="1_n"]
[ext_resource type="Script" path="res://scripts/resources/npc_talk.gd" id="2_t"]

[sub_resource type="Resource" id="Talk_0"]
script = ExtResource("2_t")
lines = PackedStringArray({lines})

[resource]
script = ExtResource("1_n")
id = "{id}"
display_name = "{name}"
zone_id = "{c}"
cell = Vector2i({x}, {y})
gfx = "{gfx}"
facing = Vector2i(0, 1)
look_around = false
talks = Array[ExtResource("2_t")]([SubResource("Talk_0")])
"""

PUESTERO = ["¡Panchos y hamburguesas! ¡Calentitos, recién hechos!",
            "Dicen que un Snorlax se comió todo el puesto de mi primo en la Ruta 12... ¡Ojo con los tuyos!"]
PARRILLERO = ["¡Vení, que está saliendo el asado! Chorizo, morcilla, vacío...",
              "El secreto es el fuego lento. Un Charmander apurado te quema todo, ¡ja!"]


def quote(lines):
    return ", ".join('"%s"' % line.replace('"', '\\"') for line in lines)


def taken(root, city):
    """Lo que ya ocupa la ciudad: el Centro de Combate Online, el globo y su piloto (con un borde)."""
    out = balloons.online_center_cells(root, city)
    b = balloons.BALLOONS.get(city)
    if b:
        x, y = b
        out |= {(x + i, y + j) for i in range(-2, balloons.SIZE[0] + 1) for j in range(-1, balloons.SIZE[1] + 3)}
    return out


def build(root):
    for city, cell in PLAZAS.items():
        if cell is None:
            cell = centers.free_spots(root, city, SIZE, taken(root, city))[0][1]
        x, y = cell
        files = {
            "data/world/extra/buildings/plaza_%s_puesto.tres" % city:
                OBJECT.format(id="plaza_%s_puesto" % city, c=city, x=x, y=y, w=3, h=2, tex="puesto_panchos"),
            "data/world/extra/buildings/plaza_%s_parrilla.tres" % city:
                OBJECT.format(id="plaza_%s_parrilla" % city, c=city, x=x + 5, y=y + 1, w=2, h=1, tex="parrilla"),
            "data/story/npcs/plaza_%s_puestero.tres" % city:
                PERSON.format(id="plaza_%s_puestero" % city, name="Puestero", c=city, x=x + 3, y=y + 1, gfx="puestero",
                              lines=quote(PUESTERO)),
            "data/story/npcs/plaza_%s_parrillero.tres" % city:
                PERSON.format(id="plaza_%s_parrillero" % city, name="Parrillero", c=city, x=x + 7, y=y + 1,
                              gfx="parrillero", lines=quote(PARRILLERO)),
        }
        for p, text in files.items():
            with open(os.path.join(root, p), "w", encoding="utf8", newline="\n") as f:
                f.write(text)
        print("%-16s plaza en %s" % (city, cell))
    for k, (x, y) in enumerate(UMBRELLAS):
        p = "data/world/extra/buildings/playa_celeste_sombrilla_%d.tres" % (k + 1)
        with open(os.path.join(root, p), "w", encoding="utf8", newline="\n") as f:
            f.write(OBJECT.format(id="playa_celeste_sombrilla_%d" % (k + 1), c="ciudad_celeste", x=x, y=y, w=3, h=1,
                                  tex="sombrilla"))


def search(root):
    for city in PLAZAS:
        found = centers.free_spots(root, city, SIZE, taken(root, city))
        print("%-16s %d lugares; los mejores %s" % (city, len(found), [c for _, c in found[:6]]))


if __name__ == "__main__":
    (search if "--buscar" in sys.argv else build)(sys.argv[1])
