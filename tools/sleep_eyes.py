"""Ojos cerrados para los Pokémon que en su hoja Sleep de PMD duermen con los ojos abiertos (pedido del usuario 2026-10-30).

Uso:  python -I -B tools/sleep_eyes.py <proyecto> <n.º>:<imagen editada.png> [<n.º>:<imagen>...] [--preview <png>]

La imagen editada es el cuadro 0 de Sleep pasado por Qwen Image Edit ("cerrá los ojos, no cambies nada más", salida
"_juego" del workflow de docs/COMFYUI.md: mismo tamaño que el cuadro). De ahí se toman solo los píxeles que cambiaron de
verdad (los ojos), llevados a la paleta original del sprite, y se pegan en todos los cuadros de la animación buscando
dónde quedó la cabeza en cada uno (±4 px). Pisa sprites/pokemon/<n.º>/Sleep-Anim.png (el original queda en git; si
la hoja es CopyOf de otra animación, no hace nada). --preview arma una hoja antes/después para revisar.
"""
import os
import re
import sys

from PIL import Image


def sleep_sheet(root, d):
    p = os.path.join(root, 'sprites/pokemon/%s/' % d)
    x = open(p + 'AnimData.xml', encoding='utf8').read()
    m = re.search(r'<Name>Sleep</Name>(.*?)</Anim>', x, re.S).group(1)
    if '<CopyOf>' in m:
        return None, 0, 0
    fw = int(re.search(r'<FrameWidth>(\d+)', m).group(1))
    fh = int(re.search(r'<FrameHeight>(\d+)', m).group(1))
    return p + 'Sleep-Anim.png', fw, fh


def palette(im):
    return list({p[:3] for p in im.get_flattened_data() if p[3] > 0})


def near(c, pal):
    return min(pal, key=lambda q: (q[0] - c[0]) ** 2 * 3 + (q[1] - c[1]) ** 2 * 4 + (q[2] - c[2]) ** 2 * 2)


def patch(orig0, edit0):
    """Píxeles que cambiaron fuerte (ojos), en la paleta original; sin los sueltos (ruido del redibujo)."""
    pal = palette(orig0)
    a, b = orig0.load(), edit0.convert('RGBA').resize(orig0.size, Image.NEAREST).load()
    w, h = orig0.size
    ch = {}
    for y in range(h):
        for x in range(w):
            if a[x, y][3] == 0:
                continue
            n = near(b[x, y][:3], pal)
            if sum(a[x, y][:3]) < 150 and sum(n) > 600:
                continue  # un contorno oscuro que se vuelve blanco no es un ojo (las antenas de Butterfree)
            if sum(abs(n[i] - a[x, y][i]) for i in range(3)) > 90:
                ch[(x, y)] = n
    return {p: c for p, c in ch.items()
            if sum((p[0] + dx, p[1] + dy) in ch for dx in (-1, 0, 1) for dy in (-1, 0, 1)) >= 3}


def apply(orig0, fk, ch):
    if not ch:
        return fk
    xs = [p[0] for p in ch]
    ys = [p[1] for p in ch]
    x0, x1, y0, y1 = min(xs) - 2, max(xs) + 2, min(ys) - 2, max(ys) + 2
    a, k = orig0.load(), fk.load()
    best = None
    for dy in range(-4, 5):
        for dx in range(-4, 5):
            e = 0
            for y in range(y0, y1 + 1):
                for x in range(x0, x1 + 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= x < orig0.size[0] and 0 <= y < orig0.size[1] and 0 <= xx < fk.size[0] and 0 <= yy < fk.size[1]:
                        e += sum(abs(a[x, y][i] - k[xx, yy][i]) for i in range(4))
                    else:
                        e += 400
            if best is None or e < best[0]:
                best = (e, dx, dy)
    out = fk.copy()
    o = out.load()
    for (x, y), c in ch.items():
        xx, yy = x + best[1], y + best[2]
        if 0 <= xx < fk.size[0] and 0 <= yy < fk.size[1] and o[xx, yy][3]:
            o[xx, yy] = c + (255,)
    return out


def main():
    root = sys.argv[1]
    preview = sys.argv[sys.argv.index('--preview') + 1] if '--preview' in sys.argv else None
    rows = []
    for item in sys.argv[2:]:
        if ':' not in item or item == preview:
            continue
        n, edit = item.split(':', 1)
        d = '%04d' % int(n)
        path, fw, fh = sleep_sheet(root, d)
        if path is None:
            print(d, 'Sleep es copia de otra animación: no se toca')
            continue
        sheet = Image.open(path).convert('RGBA')
        frames = [sheet.crop((i * fw, 0, (i + 1) * fw, fh)) for i in range(sheet.size[0] // fw)]
        ch = patch(frames[0], Image.open(edit))
        new = [apply(frames[0], f, ch) for f in frames]
        out = Image.new('RGBA', sheet.size)
        for i, f in enumerate(new):
            out.alpha_composite(f, (i * fw, 0))
        out.save(path)
        print(d, 'píxeles cambiados:', len(ch))
        rows.append((d, frames[0], new[0]))
    if preview and rows:
        cell = max(max(r[1].size) for r in rows) * 4 + 8
        im = Image.new('RGBA', (cell * 2, cell * len(rows)), (120, 170, 120, 255))
        for i, (d, a, b) in enumerate(rows):
            for j, f in enumerate((a, b)):
                im.alpha_composite(f.resize((f.size[0] * 4, f.size[1] * 4), Image.NEAREST), (j * cell + 4, i * cell + 4))
        im.save(preview)


if __name__ == '__main__':
    main()
