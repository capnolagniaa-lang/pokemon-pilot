"""Arte de las bendiciones del Modo Desafío (R-2): pasa las pinturas de Qwen-Image 2.1 de art_src/bendiciones/ al juego.
  - banner_<dador>.png (1536x640) -> sprites/ui/bendiciones/<dador>.png (1280 de ancho);
  - <bendición>.png (768x768, un emblema sobre negro) -> sprites/ui/bendiciones/iconos/<bendición>.png: recortado al
    dibujo, con el negro vuelto transparente, a 96x96.
Los prompts y semillas de cada una están en art_src/bendiciones/<nombre>.json.

Uso: python -I -B tools/make_boon_art.py .   (necesita Pillow; después: godot --headless --path . --import)
"""
import os
import sys

from PIL import Image

SIZE = 96


def icon(src, dst):
    im = Image.open(src).convert("RGB")
    px = im.load()
    w, h = im.size
    out = Image.new("RGBA", (w, h))
    po = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            m = max(r, g, b)
            a = 0 if m < 30 else min(255, (m - 30) * 255 // 60)
            po[x, y] = (r, g, b, a)
    box = out.getbbox()
    side = max(box[2] - box[0], box[3] - box[1]) + 16
    cx, cy = (box[0] + box[2]) // 2, (box[1] + box[3]) // 2
    sq = Image.new("RGBA", (side, side))
    sq.paste(out.crop(box), (side // 2 - (cx - box[0]), side // 2 - (cy - box[1])))
    sq.resize((SIZE, SIZE), Image.LANCZOS).save(dst)


def main(root):
    src = os.path.join(root, "art_src/bendiciones")
    dst = os.path.join(root, "sprites/ui/bendiciones")
    os.makedirs(os.path.join(dst, "iconos"), exist_ok=True)
    n = 0
    for f in sorted(os.listdir(src)):
        if not f.endswith(".png"):
            continue
        name = f[:-4]
        if name.startswith("banner_"):
            im = Image.open(os.path.join(src, f)).convert("RGB")
            im.resize((1280, round(1280 * im.size[1] / im.size[0])), Image.LANCZOS).save(os.path.join(dst, name[7:] + ".png"))
        else:
            icon(os.path.join(src, f), os.path.join(dst, "iconos", name + ".png"))
        n += 1
    print("%d imágenes" % n)


if __name__ == "__main__":
    main(sys.argv[1])
