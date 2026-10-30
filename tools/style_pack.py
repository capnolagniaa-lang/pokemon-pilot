"""Paquetes de estilo del terreno propio (docs/PLAN_TERRENO_PROPIO.md): pasa las imágenes de Qwen (ComfyUI) a piezas del
juego en art/estilos/<paquete>/.

Uso:  python -I -B tools/style_pack.py <carpeta output/terreno de ComfyUI> <proyecto> [--sheet <png>]

- Objetos (fondo blanco): saca el fondo blanco desde los bordes (no toca el blanco de adentro: paredes encaladas),
  se queda con la pieza más grande (y lo que esté pegado), recorta, achica al ancho de OBJ_WIDTH y pasa a paleta.
- Materiales (suelos): recorte del centro, achicado a MAT_SIZE y "cerrado" para que se repita sin costura (mezcla con
  la misma imagen corrida media vuelta, pesada hacia los bordes).
--sheet arma una hoja de contacto de todos los paquetes (para revisar).
"""
import os
import sys
from collections import deque

from PIL import Image, ImageDraw

## Paquete -> pieza -> nombre de la imagen de ComfyUI (sin el _00001_.png).
PACKS = {
    "campo": {
        "casa": "v8_campo_sin_casa", "tienda": "v8_campo_sin_tienda", "fuente": "v8_campo_sin_fuente",
        "arbol": "v8_campo_sin_arbol", "arbol_bosque": "v10_campo_arbol_bosque", "cerca": "v8_campo_sin_cerca",
        "pasto_alto": "v10_campo_pasto_alto", "cueva": "v8_campo_sin_cueva", "roca": "v8_campo_sin_roca",
        "mat_pasto": "v11_campo_mat_pasto", "mat_tierra": "v11_campo_mat_tierra",
        "mat_empedrado": "v11_campo_mat_empedrado", "mat_cueva_piso": "v11_campo_mat_cueva_piso",
        "mat_agua": "v13_campo_mat_agua", "mat_roca": "v13_campo_mat_roca", "mat_pasto_alto": "v14_campo_mat_pasto_alto",
    },
    "cuento": {
        "casa": "v8_cuento_sin_casa", "tienda": "v8_cuento_sin_tienda", "fuente": "v8_cuento_sin_fuente",
        "arbol": "v8_cuento_sin_arbol", "arbol_bosque": "v10_cuento_arbol_bosque", "cerca": "v8_cuento_sin_cerca",
        "pasto_alto": "v10_cuento_pasto_alto", "cueva": "v8_cuento_sin_cueva", "roca": "v8_cuento_sin_roca",
        "mat_pasto": "v11_cuento_mat_pasto", "mat_tierra": "v11_cuento_mat_tierra",
        "mat_empedrado": "v11_cuento_mat_empedrado", "mat_cueva_piso": "v11_cuento_mat_cueva_piso",
        "mat_agua": "v13_cuento_mat_agua", "mat_roca": "v13_cuento_mat_roca", "mat_pasto_alto": "v14_cuento_mat_pasto_alto",
    },
    "siniestro": {
        "casa": "v10_siniestro_casa", "tienda": "v10_siniestro_tienda", "fuente": "v10_siniestro_fuente",
        "arbol": "v10_siniestro_arbol", "arbol_bosque": "v10_siniestro_arbol_bosque", "cerca": "v10_siniestro_cerca",
        "pasto_alto": "v10_siniestro_pasto_alto", "cueva": "v10_siniestro_cueva", "roca": "v10_siniestro_roca",
        "mat_pasto": "v13_siniestro_mat_pasto", "mat_tierra": "v13_siniestro_mat_tierra",
        "mat_empedrado": "v13_siniestro_mat_empedrado", "mat_cueva_piso": "v13_siniestro_mat_cueva_piso",
        "mat_agua": "v13_siniestro_mat_agua", "mat_roca": "v13_siniestro_mat_roca",
        "mat_pasto_alto": "v14_siniestro_mat_pasto_alto",
    },
}
## Ancho en el juego (px; una celda = 16). La casa ocupa el sello de 5×5 de FireRed.
OBJ_WIDTH = {"casa": 80, "tienda": 80, "fuente": 40, "arbol": 40, "arbol_bosque": 44, "cerca": 48, "pasto_alto": 16,
             "cueva": 72, "roca": 28}
MAT_SIZE = 128
COLORS = 32
## Curva de brillo por paquete (gamma < 1 aclara las sombras): el siniestro sale casi negro de Qwen y en el juego no se
## leía contra el suelo.
GAMMA = {"siniestro": 0.7}
## Versión HD de cada paquete (art/estilos/<paquete>_hd/): HD veces más píxeles por celda y sin pasar a paleta, para ver
## el detalle de Qwen en el juego (StyleOverlay la dibuja a 1/HD de escala). Pedido del usuario 2026-10-30: "no se ven
## en HD".
HD = 4


def remove_white(im):
    """Fondo blanco -> transparente, solo lo conectado con el borde."""
    im = im.convert("RGBA")
    w, h = im.size
    px = im.load()
    seen = bytearray(w * h)
    q = deque((x, y) for x in range(w) for y in (0, h - 1))
    q.extend((x, y) for y in range(h) for x in (0, w - 1))
    while q:
        x, y = q.popleft()
        if not (0 <= x < w and 0 <= y < h) or seen[y * w + x]:
            continue
        seen[y * w + x] = 1
        r, g, b, _ = px[x, y]
        if min(r, g, b) < 225 or max(r, g, b) - min(r, g, b) > 30:
            continue
        px[x, y] = (0, 0, 0, 0)
        q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    # Fondo encerrado (entre las ramas de un árbol, debajo de un aljibe): manchas grandes de blanco casi puro. Las
    # paredes encaladas tienen sombra o tono y no llegan a este blanco.
    for y in range(h):
        for x in range(w):
            if seen[y * w + x] or min(px[x, y][:3]) < 246:
                continue
            region = []
            q = deque([(x, y)])
            seen[y * w + x] = 1
            while q:
                cx, cy = q.popleft()
                region.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx] and min(px[nx, ny][:3]) >= 246:
                        seen[ny * w + nx] = 1
                        q.append((nx, ny))
            if len(region) > 120:
                for p in region:
                    px[p] = (0, 0, 0, 0)
    return im


def keep_main(im):
    """Se queda con la mancha más grande (y las que tengan al menos 3% de su tamaño): saca bichitos y motas sueltas."""
    w, h = im.size
    a = im.getchannel("A").load()
    comp = [0] * (w * h)
    sizes = [0]
    for y in range(h):
        for x in range(w):
            if a[x, y] < 128 or comp[y * w + x]:
                continue
            n = len(sizes)
            sizes.append(0)
            q = deque([(x, y)])
            comp[y * w + x] = n
            while q:
                cx, cy = q.popleft()
                sizes[n] += 1
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and not comp[ny * w + nx] and a[nx, ny] >= 128:
                        comp[ny * w + nx] = n
                        q.append((nx, ny))
    big = max(sizes)
    keep = {i for i, s in enumerate(sizes) if i and s >= big * 0.03}
    px = im.load()
    for y in range(h):
        for x in range(w):
            if comp[y * w + x] not in keep:
                px[x, y] = (0, 0, 0, 0)
    return im


def to_palette(im, colors=COLORS):
    alpha = im.getchannel("A").point(lambda v: 255 if v >= 128 else 0)
    rgb = im.convert("RGB").quantize(colors, dither=Image.Dither.NONE).convert("RGB")
    out = rgb.convert("RGBA")
    out.putalpha(alpha)
    return out


def make_object(src, width, hd=False):
    im = keep_main(remove_white(Image.open(src)))
    im = im.crop(im.getbbox())
    if hd:
        width *= HD
    h = max(1, round(im.height * width / im.width))
    im = im.resize((width, h), Image.LANCZOS if hd else Image.BOX)
    if hd:
        im.putalpha(im.getchannel("A").point(lambda v: 255 if v >= 128 else 0))
        return im
    return to_palette(im)


def make_material(src, size=MAT_SIZE, hd=False):
    if hd:
        size *= HD
    im = Image.open(src).convert("RGB")
    m = im.width // 8
    im = im.crop((m, m, im.width - m, im.height - m)).resize((size, size), Image.BOX)
    rolled = Image.new("RGB", (size, size))
    half = size // 2
    rolled.paste(im.crop((half, half, size, size)), (0, 0))
    rolled.paste(im.crop((0, half, half, size)), (half, 0))
    rolled.paste(im.crop((half, 0, size, half)), (0, half))
    rolled.paste(im.crop((0, 0, half, half)), (half, half))
    mask = Image.new("L", (size, size))
    mp = mask.load()
    for y in range(size):
        for x in range(size):
            d = min(x, y, size - 1 - x, size - 1 - y) / half  # 0 en el borde, 1 en el centro
            mp[x, y] = int(255 * min(1.0, d * 2.2))
    out = Image.composite(im, rolled, mask)
    if hd:
        return out.convert("RGBA")
    return out.quantize(COLORS, dither=Image.Dither.NONE).convert("RGBA")


def main():
    src_dir, root = sys.argv[1], sys.argv[2]
    sheet = sys.argv[sys.argv.index("--sheet") + 1] if "--sheet" in sys.argv else None
    done = {}
    for pack, pieces in [(k, v) for k, v in PACKS.items()] + [(k + "_hd", v) for k, v in PACKS.items()]:
        hd = pack.endswith("_hd")
        base = pack.removesuffix("_hd")
        out_dir = os.path.join(root, "art", "estilos", pack)
        os.makedirs(out_dir, exist_ok=True)
        for piece, name in pieces.items():
            src = os.path.join(src_dir, name + "_00001_.png")
            if not os.path.exists(src):
                print("falta", pack, piece, name)
                continue
            im = make_material(src, hd=hd) if piece.startswith("mat_") else make_object(src, OBJ_WIDTH[piece], hd)
            if base in GAMMA and not piece.startswith("mat_"):
                g = GAMMA[base]
                rgb = im.convert("RGB").point(lambda v: round(255 * (v / 255) ** g))
                rgb.putalpha(im.getchannel("A"))
                im = rgb
            im.save(os.path.join(out_dir, piece + ".png"))
            done.setdefault(pack, []).append((piece, im))
        print(pack, len(done.get(pack, [])), "piezas")
    done = {k: v for k, v in done.items() if not k.endswith("_hd")}
    if sheet:
        cell = 140
        cols = max(len(v) for v in done.values())
        im = Image.new("RGBA", (cols * cell, len(done) * cell), (90, 110, 90, 255))
        d = ImageDraw.Draw(im)
        for r, (pack, items) in enumerate(done.items()):
            for c, (piece, p) in enumerate(items):
                k = max(1, min(2, (cell - 20) // max(p.size)))
                big = p.resize((p.width * k, p.height * k), Image.NEAREST)
                im.alpha_composite(big, (c * cell + 4, r * cell + 16))
                d.text((c * cell + 4, r * cell + 2), "%s/%s" % (pack, piece), fill="white")
        im.save(sheet)


if __name__ == "__main__":
    main()
