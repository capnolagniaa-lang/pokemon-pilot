"""Pasa un objeto generado con ComfyUI (fondo blanco liso) a un sprite del juego (sprites/props/).

Uso:  python -I -B tools/prop_from_image.py <imagen.png> <salida.png> --height <px> [--colors 24] [--keep-glow]

Saca el fondo (lo casi blanco y el halo claro alrededor), se queda con la mancha principal (y las que la tocan: se
descartan las manchitas sueltas), recorta y achica a la altura pedida promediando cada bloque (el arte de Qwen viene
con "píxeles" de varios píxeles reales), con alfa duro y paleta chica. Escala de referencia: una celda = 16 px; un
entrenador mide ~24 px.
"""
import sys

from PIL import Image


def arg(name, default=None, cast=str):
    if name in sys.argv:
        return cast(sys.argv[sys.argv.index(name) + 1])
    return default


def is_bg(p, cut):
    r, g, b = p[0], p[1], p[2]
    return min(r, g, b) >= cut and max(r, g, b) - min(r, g, b) <= 40


def main():
    src, out = sys.argv[1], sys.argv[2]
    height = arg("--height", 32, int)
    colors = arg("--colors", 24, int)
    cut = arg("--bg-cut", 215, int)
    im = Image.open(src).convert("RGBA")
    w, h = im.size
    px = im.load()
    fg = bytearray(w * h)
    for y in range(h):
        for x in range(w):
            if not is_bg(px[x, y], cut):
                fg[y * w + x] = 1
    # Manchas (8 vecinos); se queda con la más grande y las que están a menos de `gap` de su recuadro.
    seen = bytearray(w * h)
    blobs = []
    for i in range(w * h):
        if not fg[i] or seen[i]:
            continue
        stack, pts = [i], []
        seen[i] = 1
        while stack:
            j = stack.pop()
            pts.append(j)
            x, y = j % w, j // w
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        k = ny * w + nx
                        if fg[k] and not seen[k]:
                            seen[k] = 1
                            stack.append(k)
        blobs.append(pts)
    blobs.sort(key=len, reverse=True)
    main_blob = blobs[0]
    xs = [j % w for j in main_blob]
    ys = [j // w for j in main_blob]
    box = [min(xs), min(ys), max(xs), max(ys)]
    gap = max(4, (box[3] - box[1]) // 40)
    keep = set(main_blob)
    for b in blobs[1:]:
        if len(b) < 0.002 * len(main_blob):
            continue
        bx = [j % w for j in b]
        by = [j // w for j in b]
        if (max(bx) - min(bx)) * (max(by) - min(by)) > (box[2] - box[0]) * (box[3] - box[1]):
            continue  # más grande que el objeto: un marco o el fondo, no una pieza suya
        if min(bx) <= box[2] + gap and max(bx) >= box[0] - gap and min(by) <= box[3] + gap and max(by) >= box[1] - gap:
            keep.update(b)
    clean = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cp = clean.load()
    for j in keep:
        x, y = j % w, j // w
        cp[x, y] = px[x, y][:3] + (255,)
    clean = clean.crop(clean.getbbox())
    cw, ch = clean.size
    tw = max(1, round(cw * height / ch))
    small = clean.resize((tw, height), Image.BOX)
    sp = small.load()
    for y in range(height):
        for x in range(tw):
            p = sp[x, y]
            sp[x, y] = (p[0], p[1], p[2], 255) if p[3] >= 110 else (0, 0, 0, 0)
    rgb = small.convert("RGB").quantize(colors, method=Image.Quantize.MEDIANCUT).convert("RGBA")
    rgb.putalpha(small.getchannel("A"))
    rgb.save(out)
    print(out, rgb.size)


if __name__ == "__main__":
    main()
