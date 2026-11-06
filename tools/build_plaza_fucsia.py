"""Plaza con fuente y estadio de fútbol de Ciudad Fucsia (pedido del usuario 2026-11-06: el campo de abajo estaba vacío).
Todo como agregados de `ExtraContent`, sin tocar la zona importada:
  - sprites/props/fucsia_{piso,fuente,banco,estadio}.png (fuente, banco y estadio de Qwen 2.1, en art_src/fucsia/; el piso,
    con el mismo color de la calle)
  - data/world/extra/buildings/fucsia_*.tres, data/world/extra/pens/fucsia_estadio.tres (los Pokémon chicos que pasean) y
    data/world/extra/pitches/fucsia_estadio.tres (los Hitmonlee que juegan al fútbol: SoccerMatch)
  - data/story/npcs/fucsia_plaza_*.tres (la gente que camina por la plaza, NpcData.wander_rect)
Correrlo de nuevo pisa esos archivos.

Uso: python -I -B tools/build_plaza_fucsia.py .
Necesita Pillow. Después: godot --headless --path . --import
"""
import os
import subprocess
import sys

from PIL import Image

ZONE = "ciudad_fucsia"
PLAZA = (31, 35, 18, 16)  # x, y, ancho, alto, en celdas locales (con el puesto de panchos adentro)
# Caminos: de la calle a la plaza, y de la plaza a la entrada del estadio.
PATHS = [(43, 23, 4, 12), (45, 51, 3, 13), (45, 62, 23, 2)]
FOUNTAIN = (38, 44, 4, 3)
BENCHES = [(33, 42), (45, 37), (45, 42), (33, 48), (45, 48), (38, 49)]
STADIUM = (50, 40, 31, 22)
# Dónde están las líneas de la cancha y el arco, como parte del dibujo (de art_src/fucsia/estadio.png).
LINES = (0.149, 0.219, 0.848, 0.823)
GOAL_HALF = 0.075
# Los Pokémon chicos pasean en el pasto de abajo de la plaza.
FIELD = (32, 52, 12, 9)
PETS = ["pichu", "togepi", "igglybuff", "cleffa", "azurill", "skitty", "marill", "eevee", "teddiursa", "pikachu"]
# Color de la calle de Fucsia y del pasto de al lado (de la captura del juego).
ROAD = (238, 226, 135)
EDGE = (172, 215, 150)
WALKERS = [
    ("nene", "Nene", "boy", (35, 42), ["¡Dicen que si tirás una moneda en la fuente te sale un shiny!", "Yo ya tiré tres. Nada todavía."]),
    ("nena", "Nena", "little_girl", (43, 46), ["¿Viste los Pokémon chiquitos en el pasto? ¡Yo quiero un Togepi!"]),
    ("chica", "Chica", "lass", (36, 48), ["Antes esto era puro campo. Ahora da gusto venir a sentarse un rato."]),
    ("pibe", "Pibe", "youngster", (43, 42), ["¡Yo hincho por los de celeste y blanco! Los Hitmonlee juegan todo el día, no se cansan nunca."]),
    ("senor", "Señor", "gentleman", (37, 42), ["La Zona Safari queda ahí arriba, pero yo prefiero la plaza: acá nadie te corre."]),
]
GUIDE = ("guia", "Boletera", "woman_1", (62, 63), ["¡Bienvenido al estadio de Fucsia! Hoy juegan Celeste contra Azul.", "Se juega todo el día. ¡Los Hitmonlee patean tan fuerte que no dejan entrar a nadie a la cancha!"])

BUILDING = """[gd_resource type="Resource" script_class="ExtraBuilding" format=3]

[ext_resource type="Script" path="res://scripts/resources/extra_building.gd" id="1_b"]
{tex_line}
[resource]
script = ExtResource("1_b")
id = "{id}"
zone_id = "%s"
cell = Vector2i({x}, {y})
size = Vector2i({w}, {h})
{tex}{walk}""" % ZONE

PEN = """[gd_resource type="Resource" script_class="ExtraPen" format=3]

[ext_resource type="Script" path="res://scripts/resources/extra_pen.gd" id="1_p"]

[resource]
script = ExtResource("1_p")
id = "fucsia_estadio"
zone_id = "%s"
area = Rect2i(%d, %d, %d, %d)
species = PackedStringArray(%s)
"""

PITCH = """[gd_resource type="Resource" script_class="ExtraPitch" format=3]

[ext_resource type="Script" path="res://scripts/resources/extra_pitch.gd" id="1_p"]

[resource]
script = ExtResource("1_p")
id = "fucsia_estadio"
zone_id = "%s"
species_id = "hitmonlee"
players_per_team = 4
field = Rect2(%.1f, %.1f, %.1f, %.1f)
goal_half = %.1f
"""

PERSON = """[gd_resource type="Resource" script_class="NpcData" format=3]

[ext_resource type="Script" path="res://scripts/resources/npc_data.gd" id="1_n"]
[ext_resource type="Script" path="res://scripts/resources/npc_talk.gd" id="2_t"]

[sub_resource type="Resource" id="Talk_0"]
script = ExtResource("2_t")
lines = PackedStringArray({lines})

[resource]
script = ExtResource("1_n")
id = "fucsia_plaza_{id}"
display_name = "{name}"
zone_id = "%s"
cell = Vector2i({x}, {y})
gfx = "{gfx}"
facing = Vector2i(0, 1)
look_around = {look}
{wander}talks = Array[ExtResource("2_t")]([SubResource("Talk_0")])
""" % ZONE


def write(root, path, text):
    full = os.path.join(root, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf8", newline="\n") as f:
        f.write(text)


def building(root, name, cell, size, tex=None, walkable=False):
    bid = "fucsia_" + name
    tex_line = '[ext_resource type="Texture2D" path="res://sprites/props/%s.png" id="2_t"]\n' % tex if tex else ""
    write(root, "data/world/extra/buildings/%s.tres" % bid, BUILDING.format(
        tex_line=tex_line, id=bid, x=cell[0], y=cell[1], w=size[0], h=size[1],
        tex='texture = ExtResource("2_t")\n' if tex else "", walk="walkable = true\n" if walkable else ""))


def floor(root):
    rects = [PLAZA] + PATHS
    x0 = min(r[0] for r in rects)
    y0 = min(r[1] for r in rects)
    x1 = max(r[0] + r[2] for r in rects)
    y1 = max(r[1] + r[3] for r in rects)
    w, h = (x1 - x0) * 16, (y1 - y0) * 16
    mask = [[False] * w for _ in range(h)]
    for r in rects:
        for y in range((r[1] - y0) * 16, (r[1] + r[3] - y0) * 16):
            for x in range((r[0] - x0) * 16, (r[0] + r[2] - x0) * 16):
                mask[y][x] = True
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            if not mask[y][x]:
                continue
            border = any(not (0 <= y + dy < h and 0 <= x + dx < w and mask[y + dy][x + dx]) for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)))
            px[x, y] = EDGE + (255,) if border else ROAD + (255,)
    img.save(os.path.join(root, "sprites/props/fucsia_piso.png"))
    return (x0, y0), (x1 - x0, y1 - y0)


def prop(root, src, out, height, colors=32):
    subprocess.run([sys.executable, "-I", "-B", os.path.join(root, "tools/prop_from_image.py"), os.path.join(root, "art_src/fucsia", src),
                    os.path.join(root, "sprites/props", out), "--height", str(height), "--colors", str(colors), "--outer-bg"], check=True)


def pad_width(root, name, width):
    """El edificio se dibuja desde su esquina: lo centra en el ancho de sus celdas."""
    path = os.path.join(root, "sprites/props", name)
    im = Image.open(path).convert("RGBA")
    if im.width > width:
        im = im.resize((width, im.height * width // im.width), Image.NEAREST)
    out = Image.new("RGBA", (width, im.height), (0, 0, 0, 0))
    out.alpha_composite(im, ((width - im.width) // 2, 0))
    out.save(path)


def quote(lines):
    return ", ".join('"%s"' % line for line in lines)


def main(root):
    prop(root, "fuente.png", "fucsia_fuente.png", 58)
    pad_width(root, "fucsia_fuente.png", FOUNTAIN[2] * 16)
    prop(root, "banco.png", "fucsia_banco.png", 26, 12)
    pad_width(root, "fucsia_banco.png", 32)
    prop(root, "estadio.png", "fucsia_estadio.png", 341, 64)
    cell, size = floor(root)
    building(root, "piso", cell, size, "fucsia_piso", True)
    building(root, "fuente", FOUNTAIN[:2], FOUNTAIN[2:], "fucsia_fuente")
    for i, b in enumerate(BENCHES):
        building(root, "banco_%d" % i, b, (2, 1), "fucsia_banco")
    building(root, "estadio_dibujo", STADIUM[:2], STADIUM[2:], "fucsia_estadio", True)
    building(root, "estadio", STADIUM[:2], STADIUM[2:])  # sin dibujo: no se entra
    write(root, "data/world/extra/pens/fucsia_estadio.tres", PEN % (ZONE, FIELD[0], FIELD[1], FIELD[2], FIELD[3], quote(PETS)))
    # La cancha: las líneas del dibujo, ya centrado en sus celdas (como lo pone ExtraContent).
    drawn = Image.open(os.path.join(root, "sprites/props/fucsia_estadio.png")).size
    x0 = STADIUM[0] * 16 + (STADIUM[2] * 16 - drawn[0]) // 2
    y0 = STADIUM[1] * 16 + (STADIUM[3] * 16 - drawn[1]) // 2
    left, top, right, bottom = LINES
    write(root, "data/world/extra/pitches/fucsia_estadio.tres", PITCH % (
        ZONE, x0 + left * drawn[0], y0 + top * drawn[1], (right - left) * drawn[0], (bottom - top) * drawn[1], GOAL_HALF * drawn[1]))
    rect = "wander_rect = Rect2i(%d, %d, %d, %d)\n" % PLAZA
    for pid, name, gfx, at, lines in WALKERS:
        write(root, "data/story/npcs/fucsia_plaza_%s.tres" % pid, PERSON.format(
            id=pid, name=name, gfx=gfx, x=at[0], y=at[1], look="false", wander=rect, lines=quote(lines)))
    pid, name, gfx, at, lines = GUIDE
    write(root, "data/story/npcs/fucsia_plaza_%s.tres" % pid, PERSON.format(
        id=pid, name=name, gfx=gfx, x=at[0], y=at[1], look="true", wander="", lines=quote(lines)))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else ".")
