"""Interior del Centro de Combate Online (rediseño del 2026-11-03, pedido del usuario: la idea 4 de Qwen = pantalla grande,
mostrador con el vendedor, la enfermera y la recepcionista, filas de máquinas de link a los costados y un escenario
holográfico en el medio; "más lindo y con identidad propia, no tan FireRed"). El cuarto es una pintura
(sprites/props/centro_online_sala.png); este script reescribe las capas Ground y Overhead de
scenes/world/extra/centro_online.tscn con la colisión de esa pintura (`PLAN`) y deja el resto de la escena igual. Después: tools/build_online_centers.py (copia el interior a las demás ciudades y pone encima el
cuarto pintado con Qwen, `DECOR`). Los tiles no se ven (la pintura los tapa): quedan para la colisión, así que la capa
Overhead queda vacía.

Cómo se pintó: Qwen-Image 2.1 Turbo (tools/comfy/qwen21_run.py, semilla 44, 1152x768) con una captura del interior
viejo como imagen y el prompt de art_src/centro_online/prompt.txt → art_src/centro_online/idea4_qwen.png; se borró la
enfermera pintada (y dos figuritas) copiando el panel de atrás, se dejó negro lo de afuera, sin achicarla (1152x768 = las
24x16 celdas del cuarto a ×3 la resolución del juego; ExtraBuilding la dibuja escalada y suave). Antes el cuarto era de
15x10 y la pintura quedaba chica; se agrandó a pedido del usuario (2026-11-03).: `--pintura` en este script.

Uso: python -I -B tools/build_online_interior.py .              (la colisión)
     python -I -B tools/build_online_interior.py . --pintura    (vuelve a armar el sprite desde art_src)
"""
import base64
import re
import struct
import sys

W, H = 24, 16
PC_BELOW, PC_ABOVE, BUILDING_BELOW, BUILDING_ABOVE = 108, 110, 9, 11  # fuentes del TileSet

# Plano de colisión del cuarto pintado (idea 4 de Qwen, la que eligió el usuario): "#" = sólido (un tile de pared),
# "." = piso, "-" = se deja lo que había (la fila de abajo, con la alfombra de salida). Los tiles no se ven.
PLAN = [
    # 0         1         2
    # 012345678901234567890123
    "########################",  # 0 pared de pantallas
    "########################",  # 1
    "########################",  # 2
    "########################",  # 3
    "##.....##########...####",  # 4 maceta, mostrador, quiosco de la derecha
    "##.....##......##...####",  # 5 vendedor (10, 5), enfermera (12, 5) y recepcionista (14, 5) detrás del mostrador
    "###....##########...####",  # 6
    "###....................#",  # 7
    "##..###...........###..#",  # 8 máquinas de link (4-6 y 18-20); el escenario (10-14, 8-12) se pisa
    "###.###...........###..#",  # 9
    "###.###...........###..#",  # 10
    "##..###...........###..#",  # 11
    "##..###...........######",  # 12
    "########........########",  # 13 sillones y plantas; la salida es la alfombra (11-12, 13)
    "########################",  # 14
    "########################",  # 15
]
SOLID, FLOOR = "40", "10"
PAINT_SCALE = 3  # píxeles de la pintura por píxel del juego
GROUND = [[{"#": SOLID, ".": FLOOR}.get(ch, "-") for ch in row] for row in PLAN]
# Overhead (si no estuviera la pintura): cada celda nueva de GROUND con la parte de arriba de su metatile.
PAINTED = True  # con el cuarto pintado encima no va nada arriba
OVERHEAD_CLEAR = [(10, 1), (1, 0), (0, 5), (1, 5)]


def decode(data):
    b = base64.b64decode(data)
    cells = {}
    for i in range(2, len(b), 12):
        x, y, s, ax, ay, al = struct.unpack("<hhHHHH", b[i:i + 12])
        cells[(x, y)] = (s, ax, ay, al)
    return cells


def encode(cells):
    out = bytearray(b"\x00\x00")
    for (x, y), (s, ax, ay, al) in sorted(cells.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        out += struct.pack("<hhHHHH", x, y, s, ax, ay, al)
    return base64.b64encode(bytes(out)).decode()


def tile(code, below):
    src = (BUILDING_BELOW if below else BUILDING_ABOVE) if code.startswith("b:") else (PC_BELOW if below else PC_ABOVE)
    code = code[2:] if code.startswith("b:") else code
    return (src, int(code[0], 16), int(code[1], 16), 0)


def apply(cells, layout, below):
    for y, row in enumerate(layout):
        assert len(row) == W, (y, len(row))
        for x, code in enumerate(row):
            if code == "-":
                continue
            if code == "":
                cells.pop((x, y), None)
            else:
                cells[(x, y)] = tile(code, below)
    return cells


def overhead_from(ground_cells, cells, root):
    if PAINTED:
        return {}
    from PIL import Image  # (solo para saber qué partes de arriba están vacías)
    above = Image.open(root + "/art/pret/tiles/pokemon_center_above.png").convert("RGBA")
    for c in OVERHEAD_CLEAR:
        cells.pop(c, None)
    for y, row in enumerate(GROUND):
        for x, code in enumerate(row):
            if code == "-" or code.startswith("b:"):
                continue
            ax, ay = int(code[0], 16), int(code[1], 16)
            if above.crop((ax * 16, ay * 16, ax * 16 + 16, ay * 16 + 16)).getextrema()[3][1] > 0:
                cells[(x, y)] = (PC_ABOVE, ax, ay, 0)
            else:
                cells.pop((x, y), None)
    return cells


def main(root):
    path = root + "/scenes/world/extra/centro_online.tscn"
    text = open(path, encoding="utf8").read()
    for layer in ("Ground", "Overhead"):
        pat = re.compile(r'(\[node name="%s" type="TileMapLayer"[^\n]*\n(?:[^\[][^\n]*\n)*?tile_map_data = PackedByteArray\(")([^"]*)("\))' % layer)
        m = pat.search(text)
        assert m, layer
        cells = decode(m.group(2))
        cells = apply(cells, GROUND, True) if layer == "Ground" else overhead_from(GROUND, cells, root)
        text = text[:m.start(2)] + encode(cells) + text[m.end(2):]
    with open(path, "w", encoding="utf8", newline="\n") as f:
        f.write(text)
    print("listo:", path)


def paint(root):
    from PIL import Image
    im = Image.open(root + "/art_src/centro_online/idea4_qwen.png").convert("RGB")
    strip = im.crop((600, 178, 660, 264))  # panel limpio detrás del mostrador
    for x in range(438, 716, 60):  # borra la enfermera pintada y las dos figuritas (ahí se paran los de verdad)
        im.paste(strip.crop((0, 0, min(60, 716 - x), 86)), (x, 178))
    black = Image.new("RGB", (1152, 768))
    im.paste(black.crop((0, 0, 1152, 60)), (0, 715))  # afuera del cuarto
    im.paste(black.crop((0, 0, 505, 20)), (0, 700))
    im.paste(black.crop((0, 0, 512, 20)), (640, 700))
    # ×3 la resolución del juego: con el zoom de la cámara (2-3) se ve casi a la resolución de la pantalla. A ×1 (un
    # píxel por píxel del juego) quedaba muy pixelado (queja del usuario 2026-11-03).
    out = im.resize((W * 16 * PAINT_SCALE, H * 16 * PAINT_SCALE), Image.LANCZOS)
    out.convert("RGBA").save(root + "/sprites/props/centro_online_sala.png")
    print("listo: sprites/props/centro_online_sala.png")


if __name__ == "__main__":
    (paint if "--pintura" in sys.argv else main)(sys.argv[1])
