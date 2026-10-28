"""Arma un paquete de tiles hechos con IA (docs/COMFYUI.md) a partir de lo que generó ComfyUI.

Uso (necesita Pillow):
  python -I -B tools/tile_pack.py arbol <imagen grande del árbol sobre blanco> [--pack hgss]
  python -I -B tools/tile_pack.py pasto_alto <imagen al tamaño del juego> <celda x,y> [--pack hgss]

- arbol: el árbol del workflow mejorar_sprite_pokemon (salida "grande", fondo blanco) → 32×48 con transparencia (el
  árbol de FireRed ocupa 2×3 celdas: copa, cuerpo y base), de 32 de ancho y apoyado abajo; lo blanco del fondo pasa a
  transparente, paleta de 24 colores, transparencia en 0/1 → art/tile_packs/<pack>/arbol.png.
- pasto_alto: una celda de 16×16 de una escena redibujada al tamaño del juego (salida "juego") →
  art/tile_packs/<pack>/pasto_alto.png.
El juego los usa con TilePack (scripts/world/tile_pack.gd) si el ajuste "tile_pack" está prendido.
"""
import os
import sys

try:
    from PIL import Image, ImageChops
except ImportError:
    sys.exit("Falta Pillow: pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def pack_dir(argv):
    name = argv[argv.index("--pack") + 1] if "--pack" in argv else "hgss"
    d = os.path.join(ROOT, "art", "tile_packs", name)
    os.makedirs(d, exist_ok=True)
    return d


def tree(src, out, width=32, height=48, colors=24, cut=110):
    im = Image.open(src).convert("RGB")
    inv = ImageChops.invert(im)  # fondo blanco → negro: la "fuerza" es la diferencia con el blanco
    r, g, b = inv.split()
    strength = ImageChops.lighter(ImageChops.lighter(r, g), b)
    alpha = strength.point(lambda v: 0 if v <= 18 else 255 if v >= 70 else int((v - 18) * 255 / 52))
    rgba = im.copy()
    rgba.putalpha(alpha)
    box = alpha.point(lambda v: 255 if v > 60 else 0).getbbox()
    # Escalado a `width` de ancho conservando la forma, apoyado abajo (el tronco toca el borde de abajo).
    w = box[2] - box[0]
    h = min(height, round((box[3] - box[1]) * width / w))
    tree_img = rgba.crop(box).convert("RGBa").resize((width, h), Image.BOX).convert("RGBA")
    small = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    small.paste(tree_img, (0, height - h))
    mask = small.getchannel("A").point(lambda v: 255 if v >= cut else 0)
    rgb = Image.new("RGB", small.size, (60, 120, 60))
    rgb.paste(small.convert("RGB"), (0, 0), mask)
    pal = rgb.quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGBA")
    pal.putalpha(mask)
    pal.save(out)
    print("ok", out)


def tall_grass(src, cell, out):
    x, y = (int(v) for v in cell.split(","))
    Image.open(src).convert("RGBA").crop((x * 16, y * 16, x * 16 + 16, y * 16 + 16)).save(out)
    print("ok", out)


def main(argv):
    if len(argv) < 2:
        sys.exit(__doc__)
    d = pack_dir(argv)
    if argv[0] == "arbol":
        tree(argv[1], os.path.join(d, "arbol.png"))
    elif argv[0] == "pasto_alto":
        tall_grass(argv[1], argv[2], os.path.join(d, "pasto_alto.png"))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
