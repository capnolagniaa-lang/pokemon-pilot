"""Convierte los cuadros de un efecto animado con IA (ComfyUI: efecto_1_cuadro_clave → efecto_2_animar) en una hoja
de efecto del juego: una fila de cuadros cuadrados en pixel art, con transparencia (formato de DB.vfx_sheet).

Uso (necesita Pillow; Python del sistema o el de ComfyUI):
  python -I -B tools/fx_from_frames.py <cuadros> --out sprites/fx/types/fuego_impacto.png --size 32 --frames 7
  python -I -B tools/fx_from_frames.py <cuadros> --preview out/fuego.png        # solo mirar (hoja ×8)
  python -I -B tools/fx_from_frames.py <clave.png> --clean-key <ComfyUI>/input/efecto_clave.png  # antes de animar

<cuadros> = carpeta, o carpeta/prefijo (p. ej. .../output/efectos/cuadros/fuego). Si en la carpeta hay varias tandas
del mismo prefijo, toma la última (ComfyUI guarda los cuadros de una tanda juntos).

Qué hace: saca el fondo liso (negro, o blanco con --bg white) convirtiendo la diferencia con el fondo en
transparencia, elige los cuadros donde el efecto se ve (de --start al último con algo), recorta un cuadrado común a
todos, lo achica (promediando) al tamaño del juego, deja una paleta común (--colors) y la transparencia en 0/1.
--grow N agrega N cuadros al principio con el primero chiquito (los videos arrancan en el cuadro clave, ya grande).
Proyectiles: tienen que apuntar a la derecha (--flip o --rotate si no).
--clean-key: Qwen suele dibujar un piso o un fondo casi negro con sombra; pasa todo lo oscuro a negro puro, para que
Wan no anime el efecto "cayendo" sobre un piso.
"""
import argparse
import glob
import os
import sys

try:
    from PIL import Image, ImageChops, ImageStat
except ImportError:
    sys.exit("Falta Pillow: pip install pillow (o usá el python_embeded de ComfyUI)")


def load_frames(src):
    if os.path.isdir(src):
        files = glob.glob(os.path.join(src, "*.png"))
    else:
        files = glob.glob(src + "_*.png") or glob.glob(src + "*.png")
    files.sort()
    if not files:
        sys.exit("No hay cuadros en %s" % src)
    # La última tanda: ComfyUI escribe todos los cuadros de una corrida seguidos (sin pausas de más de 20 s).
    files.sort(key=os.path.getmtime)
    run = [files[-1]]
    for f in reversed(files[:-1]):
        if os.path.getmtime(run[0]) - os.path.getmtime(f) > 20:
            break
        run.insert(0, f)
    run.sort()
    return [Image.open(f).convert("RGB") for f in run]


def extract_alpha(frame, invert, lo, hi):
    """Imagen sobre fondo negro (o blanco invertido) → RGBA con el color sin premultiplicar."""
    if invert:
        frame = ImageChops.invert(frame)
    r, g, b = frame.split()
    strength = ImageChops.lighter(ImageChops.lighter(r, g), b)
    span = max(1, hi - lo)
    alpha = strength.point(lambda v: 0 if v <= lo else 255 if v >= hi else int((v - lo) * 255 / span))
    # Sobre negro, el píxel ya es el color premultiplicado por la opacidad: RGBa → RGBA lo desmultiplica.
    rgba = Image.merge("RGBa", (r, g, b, alpha)).convert("RGBA")
    if invert:
        cr, cg, cb, a = rgba.split()
        rgba = Image.merge("RGBA", (ImageChops.invert(cr), ImageChops.invert(cg), ImageChops.invert(cb), a))
    return rgba


def coverage(rgba):
    return ImageStat.Stat(rgba.getchannel("A")).sum[0] / 255.0


def solid_bbox(rgba, cut=80):
    return rgba.getchannel("A").point(lambda v: 255 if v >= cut else 0).getbbox()


def mass_bbox(rgba, keep=0.94):
    """Rectángulo que junta el `keep` de lo visible (descarta las chispas sueltas de los bordes)."""
    alpha = rgba.getchannel("A")
    w, h = alpha.size

    def span(values):
        total = sum(values) or 1
        lo_cut, hi_cut = total * (1 - keep) / 2, total * (1 + keep) / 2
        acc, lo, hi = 0, 0, len(values)
        for i, v in enumerate(values):
            acc += v
            if acc < lo_cut:
                lo = i + 1
            if acc <= hi_cut:
                hi = i + 1
        return lo, hi

    pixels = lambda im: list(im.get_flattened_data() if hasattr(im, "get_flattened_data") else im.getdata())
    x0, x1 = span(pixels(alpha.resize((w, 1), Image.BOX)))
    y0, y1 = span(pixels(alpha.resize((1, h), Image.BOX)))
    return (x0, y0, x1, y1) if x1 > x0 and y1 > y0 else None


def clean_key(src, dst, cut):
    im = Image.open(src).convert("RGB")
    r, g, b = im.split()
    keep = ImageChops.lighter(ImageChops.lighter(r, g), b).point(lambda v: 255 if v > cut else 0)
    out = Image.new("RGB", im.size, (0, 0, 0))
    out.paste(im, (0, 0), keep)
    out.save(dst)
    print("ok", dst)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("frames")
    ap.add_argument("--out", help="hoja para el juego (p. ej. sprites/fx/types/fuego_impacto.png)")
    ap.add_argument("--preview", help="PNG para mirar: la hoja agrandada ×8 sobre cuadros")
    ap.add_argument("--size", type=int, default=32, help="lado de cada cuadro (impacto 32, proyectil 16)")
    ap.add_argument("--frames-count", "--frames", dest="count", type=int, default=7)
    ap.add_argument("--start", type=int, default=0, help="saltear los primeros N cuadros del video")
    ap.add_argument("--end", type=int, default=0, help="usar hasta el cuadro N (0 = hasta que se desvanece)")
    ap.add_argument("--grow", type=int, default=0, help="cuadros de crecimiento a agregar al principio")
    ap.add_argument("--bg", choices=["auto", "black", "white"], default="auto")
    ap.add_argument("--colors", type=int, default=16)
    ap.add_argument("--alpha-cut", type=int, default=110, help="opacidad (0-255) desde la que un píxel queda")
    ap.add_argument("--margin", type=float, default=0.12, help="aire alrededor del efecto (fracción)")
    ap.add_argument("--flip", action="store_true", help="espejar horizontal (proyectiles que miran a la izquierda)")
    ap.add_argument("--rotate", type=float, default=0, help="rotar N grados (antihorario)")
    ap.add_argument("--floor", type=int, default=45, help="todo lo más oscuro que esto (0-255) cuenta como fondo")
    ap.add_argument("--clean-key", help="limpiar un cuadro clave (imagen suelta) y guardarlo acá")
    a = ap.parse_args(argv)
    if a.clean_key:
        clean_key(a.frames, a.clean_key, a.floor + 15)
        return
    if not a.out and not a.preview:
        ap.error("decí --out y/o --preview")

    frames = load_frames(a.frames)
    if a.bg == "auto":
        f0 = frames[0]
        w, h = f0.size
        corners = [f0.getpixel(p) for p in [(2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)]]
        a.bg = "white" if sum(sum(c) for c in corners) / 12 > 128 else "black"
    rgba = [extract_alpha(f, a.bg == "white", a.floor, a.floor + 110) for f in frames]
    if a.flip:
        rgba = [im.transpose(Image.FLIP_LEFT_RIGHT) for im in rgba]
    if a.rotate:
        rgba = [im.rotate(a.rotate, resample=Image.BICUBIC) for im in rgba]

    # Rango activo: desde --start hasta el último cuadro con algo visible.
    cov = [coverage(im) for im in rgba]
    peak = max(cov[a.start:]) or 1.0
    end = a.end or max(i for i, c in enumerate(cov) if c >= peak * 0.04) + 1
    active = list(range(a.start, max(a.start + 1, end)))
    n = min(a.count - a.grow, len(active))
    # Más cuadros al principio (el estallido) que al final (lo que se desvanece).
    pick = [active[round((k / max(1, n - 1)) ** 1.7 * (len(active) - 1))] for k in range(n)]
    chosen = [rgba[i] for i in pick]

    # Cuadrado común: lo visible del cuadro más lleno (las gotas o chispas que vuelan lejos quedan afuera).
    fullest = max(chosen, key=coverage)
    box = mass_bbox(fullest)
    if not box:
        sys.exit("No se ve nada en los cuadros (¿el fondo es otro? probá --bg)")
    x0, y0, x1, y1 = box
    side = int(max(x1 - x0, y1 - y0) * (1 + 2 * a.margin)) + 1
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    crop = (cx - side // 2, cy - side // 2, cx - side // 2 + side, cy - side // 2 + side)
    chosen = [im.crop(crop) for im in chosen]

    if a.grow:
        first = chosen[0]
        grown = []
        for k in range(a.grow):
            s = 0.3 + 0.55 * k / max(1, a.grow)
            small = first.convert("RGBa").resize((max(1, int(side * s)),) * 2, Image.BOX).convert("RGBA")
            canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
            canvas.alpha_composite(small, ((side - small.width) // 2, (side - small.height) // 2))
            grown.append(canvas)
        chosen = grown + chosen

    # Achicar promediando (premultiplicado, así los bordes no se ensucian con el fondo).
    small = [im.convert("RGBa").resize((a.size, a.size), Image.BOX).convert("RGBA") for im in chosen]
    sheet = Image.new("RGBA", (a.size * len(small), a.size), (0, 0, 0, 0))
    for i, im in enumerate(small):
        sheet.paste(im, (i * a.size, 0))

    # Paleta común y transparencia en 0/1 (pixel art).
    mask = sheet.getchannel("A").point(lambda v: 255 if v >= a.alpha_cut else 0)
    stat = ImageStat.Stat(sheet.convert("RGB"), mask)
    fill = tuple(int(v) for v in stat.mean) if mask.getbbox() else (0, 0, 0)
    rgb = Image.new("RGB", sheet.size, fill)
    rgb.paste(sheet.convert("RGB"), (0, 0), mask)
    pal = rgb.quantize(colors=a.colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    out = pal.convert("RGBA")
    out.putalpha(mask)

    print("cuadros del video: %d (fondo %s), elegidos %s%s, recorte %d px -> %d x %d px" % (
        len(frames), a.bg, pick, " + %d de crecimiento" % a.grow if a.grow else "", side, len(small), a.size))
    if a.out:
        os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
        out.save(a.out)
        print("ok", a.out)
    if a.preview:
        z = 8
        big = out.resize((out.width * z, out.height * z), Image.NEAREST)
        checker = Image.new("RGBA", big.size, (70, 70, 80, 255))
        tile = Image.new("RGBA", (z * 2, z * 2), (95, 95, 105, 255))
        for yy in range(0, big.height, z * 4):
            for xx in range(0, big.width, z * 4):
                checker.paste(tile, (xx, yy))
                checker.paste(tile, (xx + z * 2, yy + z * 2))
        checker.alpha_composite(big)
        os.makedirs(os.path.dirname(os.path.abspath(a.preview)), exist_ok=True)
        checker.save(a.preview)
        print("ok", a.preview)


if __name__ == "__main__":
    main(sys.argv[1:])
