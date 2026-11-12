"""Hojas de efecto de los kits del Modo Desafío (tools/build_desafio_kits.py), en pixel art hecho por código (Pillow).

    python -I -B tools/make_desafio_vfx.py . [--sheet <png de contacto>]

Escribe sprites/fx/moves/d_<ataque>[_<parte>].png: una fila de cuadros cuadrados, apuntando a la derecha (DB.vfx_sheet).
Partes: sin sufijo = cuerpo del ataque (corte, onda de área, proyectil); `_zona` = dibujo de una zona en el piso
(GroundZone); `_cuerpo` = pegado al Pokémon mientras dura (Creature._body_vfx); `_chorro` = canalizado (ChannelCone).
Los que no están acá usan la hoja del ataque oficial del mismo nombre (Ascuas, Pistola Agua, Hoja Afilada, Rayo Solar).
Pisa lo que genera: si una hoja se rehace con IA (docs/COMFYUI.md), sacarla de SHEETS.
"""
import math
import os
import random
import sys

from PIL import Image, ImageDraw

FIRE = [(120, 28, 12), (214, 64, 20), (250, 130, 30), (255, 200, 70), (255, 244, 190)]
WATER = [(24, 60, 130), (40, 110, 200), (90, 170, 240), (170, 220, 255), (240, 250, 255)]
LEAF = [(26, 70, 30), (50, 120, 44), (96, 176, 60), (170, 224, 100), (236, 250, 190)]
SMOKE = [(48, 48, 56), (84, 84, 94), (126, 126, 138), (172, 172, 182), (214, 214, 222)]


def new(n, side):
    return Image.new("RGBA", (n * side, side), (0, 0, 0, 0))


def frame(sheet, i, side):
    im = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def put(sheet, im, i, side):
    sheet.alpha_composite(im, (i * side, 0))


def blob(d, x, y, r, pal, light=(-0.3, -0.35)):
    """Bola con contorno oscuro, cuerpo y brillo: el ladrillo de humo, fuego y agua."""
    d.ellipse([x - r - 1, y - r - 1, x + r + 1, y + r + 1], fill=pal[0])
    d.ellipse([x - r, y - r, x + r, y + r], fill=pal[1])
    if r >= 3:
        d.ellipse([x - r + 1, y - r + 1, x + r - 2, y + r - 2], fill=pal[2])
    if r >= 5:
        hx, hy = x + light[0] * r, y + light[1] * r
        d.ellipse([hx - r * 0.35, hy - r * 0.3, hx + r * 0.35, hy + r * 0.3], fill=pal[3])


def flame(d, x, y, h, w, pal, lean=0.0):
    """Lengua de fuego parada en (x, y), de alto h."""
    for k, shrink in enumerate([1.0, 0.72, 0.45, 0.22]):
        hh, ww = h * shrink, w * shrink
        d.polygon([(x - ww, y), (x + ww, y), (x + ww * 0.5 + lean * hh, y - hh * 0.55), (x + lean * hh, y - hh),
                   (x - ww * 0.6 + lean * hh * 0.5, y - hh * 0.5)], fill=pal[min(k + 1, 4)])
    d.line([(x - w, y), (x + w, y)], fill=pal[0])


def colmillo_igneo():
    side, n = 40, 6
    sheet = new(n, side)
    gap = [8, 5, 2, 0, 0, 0]
    for i in range(n):
        im, d = frame(sheet, i, side)
        cx, cy = side / 2, side / 2
        if i >= 3:  # el mordisco estalla en fuego
            r = [9, 13, 16][i - 3]
            for a in range(10):
                ang = a * math.tau / 10 + i * 0.4
                px, py = cx + math.cos(ang) * r, cy + math.sin(ang) * r * 0.8
                blob(d, px, py, [4, 3, 2][i - 3], FIRE[1:] + [FIRE[4]])
            if i == 3:
                blob(d, cx, cy, 8, FIRE[2:] + [FIRE[4], FIRE[4]])
        if i <= 4:
            g = gap[i]
            fang = (250, 246, 236) if i < 4 else (255, 214, 150)
            edge = FIRE[1]
            for k in range(4):  # colmillos de arriba y de abajo
                x = cx - 12 + k * 8
                big = 9 if k in (0, 3) else 6
                d.polygon([(x - 3, cy - g - big - 2), (x + 3, cy - g - big - 2), (x, cy - g)], fill=edge)
                d.polygon([(x - 2, cy - g - big - 2), (x + 2, cy - g - big - 2), (x, cy - g - 2)], fill=fang)
                d.polygon([(x - 3, cy + g + big + 2), (x + 3, cy + g + big + 2), (x, cy + g)], fill=edge)
                d.polygon([(x - 2, cy + g + big + 2), (x + 2, cy + g + big + 2), (x, cy + g + 2)], fill=fang)
            for k in range(5):  # llamas en las encías
                x = cx - 14 + k * 7
                flame(d, x, cy - g - 9, 6 + (k + i) % 3 * 2, 3, FIRE)
        put(sheet, im, i, side)
    return sheet


def pantalla_humo():
    side, n = 64, 8
    sheet = new(n, side)
    rnd = random.Random(7)
    puffs = [(k * math.tau / 11 + rnd.uniform(-0.2, 0.2), 20 if k < 11 else 7, rnd.uniform(7, 11), 1.0) for k in range(15)]
    for i in range(n):
        im, d = frame(sheet, i, side)
        t = i / n * math.tau
        order = sorted(puffs, key=lambda p: math.sin(p[0]) * p[1])
        for ang, dist, r, sp in order:
            a = ang + math.sin(t + ang) * 0.25
            x = side / 2 + math.cos(a) * dist
            y = side / 2 + math.sin(a) * dist * 0.7 + math.sin(t * 1 + ang * 3) * 1.5
            rr = r + math.sin(t + ang * 2) * 1.5
            blob(d, x, y, rr, SMOKE)
        put(sheet, im, i, side)
    # humo: semitransparente, para que se vea quién está adentro
    a = sheet.getchannel("A").point(lambda v: int(v * 0.78))
    sheet.putalpha(a)
    return sheet


def salto_cola():
    side, n = 32, 4
    sheet = new(n, side)
    for i in range(n):
        im, d = frame(sheet, i, side)
        cy = side / 2
        for k in range(6):  # estela de fuego hacia atrás (izquierda), el salto va a la derecha
            x = 24 - k * 4.5 - i * 0.8
            y = cy + math.sin(k * 1.3 + i * 1.6) * (2 + k * 0.6)
            blob(d, x, y, max(1.5, 5.5 - k * 0.8), FIRE[1:] + [FIRE[4]])
        d.arc([10, cy - 11, 30, cy + 11], -70 + i * 12, 70 + i * 12, fill=FIRE[4], width=2)
        put(sheet, im, i, side)
    return sheet


def infierno():
    side, n = 96, 8
    sheet = new(n, side)
    for i in range(n):
        im, d = frame(sheet, i, side)
        cx, cy = side / 2, side / 2
        r = 8 + (46 - 8) * (i / (n - 1)) ** 0.7
        tongues = 22
        fade = 1.0 if i < 5 else 1.0 - (i - 4) / 4.0
        for k in range(tongues):
            ang = k * math.tau / tongues + i * 0.13
            x, y = cx + math.cos(ang) * r, cy + math.sin(ang) * r * 0.8
            h = (11 + (k * 7 + i * 3) % 6) * (0.6 + 0.4 * fade)
            flame(d, x, y + 3, h, 4.5 * (0.5 + 0.5 * fade), FIRE, lean=math.cos(ang) * 0.25)
        if i < 3:  # el estallido del centro
            blob(d, cx, cy, [15, 11, 6][i], FIRE[2:] + [FIRE[4], FIRE[4]])
        if fade < 1.0:
            a = im.getchannel("A").point(lambda v, f=fade: int(v * max(f, 0.0)))
            im.putalpha(a)
        put(sheet, im, i, side)
    return sheet


def refugio():
    side, n = 32, 6
    sheet = new(n, side)
    for i in range(n):
        im, d = frame(sheet, i, side)
        cx, cy = side / 2, side / 2 + 1
        pulse = math.sin(i / n * math.tau)
        r = 12 + pulse * 0.8
        d.ellipse([cx - r - 1, cy - r, cx + r + 1, cy + r - 2], outline=WATER[0], width=1)
        d.ellipse([cx - r, cy - r + 1, cx + r, cy + r - 3], outline=WATER[2], width=2)
        # placas del caparazón
        for k in range(3):
            x = cx - 7 + k * 7
            d.polygon([(x, cy - 7), (x + 4, cy - 4), (x + 4, cy + 1), (x, cy + 4), (x - 4, cy + 1), (x - 4, cy - 4)],
                      outline=WATER[3])
        hx = cx - r + 3 + (i * (2 * r - 4) / n)  # brillo que recorre el domo
        d.line([(hx, cy - r + 4), (hx + 3, cy - r + 9)], fill=WATER[4], width=2)
        a = im.getchannel("A").point(lambda v: int(v * 0.85))
        im.putalpha(a)
        put(sheet, im, i, side)
    return sheet


def giro_rapido():
    side, n = 32, 4
    sheet = new(n, side)
    for i in range(n):
        im, d = frame(sheet, i, side)
        cx, cy = side / 2, side / 2
        rot = i * 90 / 2
        for k in range(3):
            start = rot + k * 120
            d.arc([cx - 13, cy - 13, cx + 13, cy + 13], start, start + 70, fill=WATER[2], width=3)
            d.arc([cx - 10, cy - 10, cx + 10, cy + 10], start + 20, start + 80, fill=WATER[4], width=2)
        for k in range(4):  # gotas que salen despedidas
            ang = math.radians(rot * 2 + k * 90)
            blob(d, cx + math.cos(ang) * 14, cy + math.sin(ang) * 14, 1.5, WATER[1:] + [WATER[4]])
        put(sheet, im, i, side)
    return sheet


def drenadoras():
    side, n = 48, 6
    sheet = new(n, side)
    seeds = [(-11, -6), (10, -8), (0, 2), (-8, 9), (12, 7)]
    for i in range(n):
        im, d = frame(sheet, i, side)
        cx, cy = side / 2, side / 2
        pulse = math.sin(i / n * math.tau)
        d.ellipse([cx - 19, cy - 14, cx + 19, cy + 14], outline=LEAF[1])
        for k in range(8):  # zarcillos entre las semillas
            ang = k * math.tau / 8 + pulse * 0.1
            d.line([(cx + math.cos(ang) * 6, cy + math.sin(ang) * 4), (cx + math.cos(ang + 0.5) * 17, cy + math.sin(ang + 0.5) * 12)],
                   fill=LEAF[1])
        for k, (sx, sy) in enumerate(seeds):
            x, y = cx + sx, cy + sy
            grow = 2 + ((i + k * 2) % n) / n * 3
            d.ellipse([x - 3, y - 2, x + 3, y + 3], fill=(92, 58, 30), outline=(52, 30, 14))
            d.line([(x, y - 1), (x, y - 2 - grow)], fill=LEAF[2], width=1)
            d.polygon([(x, y - 2 - grow), (x - 3, y - 4 - grow), (x - 1, y - 1 - grow)], fill=LEAF[3])
            d.polygon([(x, y - 2 - grow), (x + 3, y - 4 - grow), (x + 1, y - 1 - grow)], fill=LEAF[2])
        gx = cx + math.cos(i / n * math.tau) * 15  # chispa de energía que da la vuelta
        gy = cy + math.sin(i / n * math.tau) * 10
        blob(d, gx, gy, 1.5, LEAF[2:] + [LEAF[4], LEAF[4]])
        put(sheet, im, i, side)
    return sheet


def liana():
    side, n = 48, 3
    sheet = new(n, side)
    for i in range(n):
        im, d = frame(sheet, i, side)
        cy = side / 2
        pts = [(x, cy + math.sin(x * 0.35 + i * 1.4) * 3) for x in range(0, 30, 2)]
        d.line(pts, fill=LEAF[0], width=4)
        d.line(pts, fill=LEAF[2], width=2)
        for k in range(4):  # hojitas a lo largo
            x, y = pts[2 + k * 3]
            up = -1 if k % 2 == 0 else 1
            d.polygon([(x, y), (x - 4, y + up * 5), (x + 2, y + up * 3)], fill=LEAF[3], outline=LEAF[0])
        d.polygon([(30, cy - 3), (38, cy), (30, cy + 3)], fill=LEAF[4], outline=LEAF[1])  # la punta que engancha
        put(sheet, im, i, side)
    return sheet


def hidrobomba_chorro(root):
    """El chorro de Lanzallamas pasado a agua (mismo dibujo, colores cambiados)."""
    src = Image.open(os.path.join(root, "sprites/fx/moves/lanzallamas_chorro.png")).convert("RGBA")
    out = Image.new("RGBA", src.size)
    px, po = src.load(), out.load()
    for y in range(src.height):
        for x in range(src.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            light = (r * 0.5 + g * 0.4 + b * 0.1) / 255.0
            k = min(4.0, light * 4.6)
            lo, hi = WATER[int(k)], WATER[min(4, int(k) + 1)]
            f = k - int(k)
            po[x, y] = (int(lo[0] + (hi[0] - lo[0]) * f), int(lo[1] + (hi[1] - lo[1]) * f), int(lo[2] + (hi[2] - lo[2]) * f), a)
    return out


def main(root, contact=""):
    dest = os.path.join(root, "sprites/fx/moves")
    sheets = {
        "d_colmillo_igneo": colmillo_igneo(), "d_pantalla_humo_zona": pantalla_humo(),
        "d_salto_cola_cuerpo": salto_cola(), "d_infierno": infierno(), "d_refugio_cuerpo": refugio(),
        "d_giro_rapido_cuerpo": giro_rapido(), "d_drenadoras_zona": drenadoras(), "d_liana_cuerpo": liana(),
        "d_hidrobomba_chorro": hidrobomba_chorro(root),
        "d_burbujas": Image.open(os.path.join(dest, "burbuja.png")).convert("RGBA"),
    }
    for name, im in sheets.items():
        im.save(os.path.join(dest, name + ".png"))
        print(name, im.size)
    if contact:
        zoom = 3
        w = max(im.width for im in sheets.values()) * zoom
        h = sum(im.height * zoom + 6 for im in sheets.values())
        board = Image.new("RGBA", (w, h), (58, 92, 60, 255))
        y = 0
        for im in sheets.values():
            big = im.resize((im.width * zoom, im.height * zoom), Image.NEAREST)
            board.alpha_composite(big, (0, y))
            y += big.height + 6
        board.save(contact)


if __name__ == "__main__":
    args = sys.argv[1:]
    sheet = args[args.index("--sheet") + 1] if "--sheet" in args else ""
    main(args[0] if args and not args[0].startswith("--") else ".", sheet)
