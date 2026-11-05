"""Pasa una tira de efecto hecha de una vez con Qwen-Image 2.1 (N cuadros en fila, fondo blanco) a una hoja del juego:
una fila de cuadros cuadrados en pixel art, con transparencia dura y paleta común (formato de DB.vfx_sheet).

Uso:  python -I -B tools/fx_from_strip.py <tira.png> <salida.png> --frames 6 --size 96 [--colors 24] [--cut 205]
      --bg black: fondo negro (fuego, electricidad; lo más claro es efecto, así el centro blanco no queda hueco).
      --rows: los cuadros están apilados en filas (chorros horizontales). --band N: el dibujo ocupa N px del lado angosto del
      cuadro, centrado en el cuadro cuadrado del juego (si no, cada cuadro de la tira tiene que ser cuadrado).

A diferencia de fx_from_frames.py (cuadros sueltos de Wan), no recorta: la tira ya tiene el efecto en el mismo lugar y a la
misma escala en todos los cuadros, y recortar por cuadro lo haría saltar. Cada píxel del juego promedia solo lo que no es
fondo, y queda opaco si más de la mitad de su bloque no era fondo.
"""
import argparse

from PIL import Image


def is_bg(p, cut, black):
    if black:
        return max(p) < cut
    return min(p) >= cut and max(p) - min(p) <= 40


def shrink(cell, size_w, size_h, cut, black):
    out = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    px, dst = cell.load(), out.load()
    w, h = cell.size
    for y in range(size_h):
        for x in range(size_w):
            sr, sg, sb, n = 0, 0, 0, 0
            x0, x1 = x * w // size_w, max(x * w // size_w + 1, (x + 1) * w // size_w)
            y0, y1 = y * h // size_h, max(y * h // size_h + 1, (y + 1) * h // size_h)
            for j in range(y0, y1):
                for i in range(x0, x1):
                    p = px[i, j]
                    if not is_bg(p, cut, black):
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
    ap.add_argument("--cut", type=int, default=0, help="umbral del fondo (def.: 205 en blanco, 90 en negro)")
    ap.add_argument("--bg", choices=["white", "black"], default="white")
    ap.add_argument("--rows", action="store_true")
    ap.add_argument("--band", type=int, default=0)
    a = ap.parse_args()
    im = Image.open(a.strip).convert("RGB")
    black = a.bg == "black"
    cut = a.cut or (90 if black else 205)
    cw = im.height // a.frames if a.rows else im.width // a.frames
    band = a.band or a.size
    sheet = Image.new("RGBA", (a.size * a.frames, a.size), (0, 0, 0, 0))
    for f in range(a.frames):
        t = a.trim
        if a.rows:
            cell = shrink(im.crop((t, f * cw + t, im.width - t, (f + 1) * cw - t)), a.size, band, cut, black)
            sheet.paste(cell, (f * a.size, (a.size - band) // 2))
        else:
            cell = shrink(im.crop((f * cw + t, t, (f + 1) * cw - t, im.height - t)), band, a.size, cut, black)
            sheet.paste(cell, (f * a.size + (a.size - band) // 2, 0))
    alpha = sheet.getchannel("A")
    pal = sheet.convert("RGB").quantize(a.colors, dither=Image.Dither.NONE).convert("RGB")
    pal.putalpha(alpha)
    pal.save(a.out)
    print(a.out, pal.size)


if __name__ == "__main__":
    main()
