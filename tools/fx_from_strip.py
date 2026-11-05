"""Pasa una tira de efecto hecha de una vez con Qwen-Image 2.1 (N cuadros en fila, fondo blanco) a una hoja del juego:
una fila de cuadros cuadrados en pixel art, con transparencia dura y paleta común (formato de DB.vfx_sheet).

Uso:  python -I -B tools/fx_from_strip.py <tira.png> <salida.png> --frames 6 --size 96 [--colors 24] [--cut 205]

A diferencia de fx_from_frames.py (cuadros sueltos de Wan), no recorta: la tira ya tiene el efecto en el mismo lugar y a la
misma escala en todos los cuadros, y recortar por cuadro lo haría saltar. Cada píxel del juego promedia solo lo que no es
fondo, y queda opaco si más de la mitad de su bloque no era fondo.
"""
import argparse

from PIL import Image


def is_bg(p, cut):
    return min(p) >= cut and max(p) - min(p) <= 40


def shrink(cell, size, cut):
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px, dst = cell.load(), out.load()
    w, h = cell.size
    for y in range(size):
        for x in range(size):
            sr, sg, sb, n = 0, 0, 0, 0
            x0, x1 = x * w // size, max(x * w // size + 1, (x + 1) * w // size)
            y0, y1 = y * h // size, max(y * h // size + 1, (y + 1) * h // size)
            for j in range(y0, y1):
                for i in range(x0, x1):
                    p = px[i, j]
                    if not is_bg(p, cut):
                        sr, sg, sb, n = sr + p[0], sg + p[1], sb + p[2], n + 1
            if n * 2 > (x1 - x0) * (y1 - y0):
                dst[x, y] = (sr // n, sg // n, sb // n, 255)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("strip")
    ap.add_argument("out")
    ap.add_argument("--frames", type=int, required=True)
    ap.add_argument("--size", type=int, required=True)
    ap.add_argument("--colors", type=int, default=24)
    ap.add_argument("--trim", type=int, default=2, help="borde de cada cuadro que se descarta (algunas semillas dibujan una grilla)")
    ap.add_argument("--cut", type=int, default=205, help="lo más claro que esto y sin color es fondo")
    a = ap.parse_args()
    im = Image.open(a.strip).convert("RGB")
    cw = im.width // a.frames
    sheet = Image.new("RGBA", (a.size * a.frames, a.size), (0, 0, 0, 0))
    for f in range(a.frames):
        t = a.trim
        sheet.paste(shrink(im.crop((f * cw + t, t, (f + 1) * cw - t, im.height - t)), a.size, a.cut), (f * a.size, 0))
    alpha = sheet.getchannel("A")
    pal = sheet.convert("RGB").quantize(a.colors, dither=Image.Dither.NONE).convert("RGB")
    pal.putalpha(alpha)
    pal.save(a.out)
    print(a.out, pal.size)


if __name__ == "__main__":
    main()
