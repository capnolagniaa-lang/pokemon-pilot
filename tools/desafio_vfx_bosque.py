"""Hojas de efecto de los kits del Bosque (las arma tools/make_desafio_vfx.py): generadores genéricos por forma y paleta.

SHEETS: nombre de la hoja (sin "sprites/fx/moves/" ni ".png") -> (generador, paleta). Los ataques que no están acá usan
la hoja del ataque oficial del mismo nombre (Pin Misil, Ácido, Impactrueno, Hoja Afilada, Trueno) o se dibujan por código
(látigos).
"""
import math
import os
import random

from PIL import Image, ImageDraw

BUG = [(40, 60, 10), (96, 130, 20), (150, 190, 40), (206, 230, 90), (244, 252, 190)]
POISON = [(50, 16, 70), (110, 40, 150), (160, 80, 200), (210, 150, 240), (245, 225, 255)]
FLY = [(60, 80, 110), (120, 150, 190), (170, 200, 230), (215, 232, 248), (250, 252, 255)]
NORMAL = [(80, 70, 56), (150, 136, 112), (206, 194, 170), (236, 228, 210), (255, 252, 244)]
ELEC = [(110, 80, 0), (200, 150, 10), (250, 210, 40), (255, 240, 130), (255, 255, 230)]
PSY = [(90, 20, 70), (180, 50, 130), (240, 100, 170), (255, 170, 210), (255, 235, 245)]
FIGHT = [(80, 24, 14), (160, 52, 30), (214, 96, 50), (244, 160, 100), (255, 232, 200)]
GROUND = [(70, 50, 24), (140, 104, 50), (196, 160, 90), (230, 206, 150), (250, 240, 210)]
DARK = [(16, 14, 24), (50, 44, 66), (90, 82, 110), (150, 140, 170), (220, 214, 235)]
LEAF = [(26, 70, 30), (50, 120, 44), (96, 176, 60), (170, 224, 100), (236, 250, 190)]


def _sheet(n, side, draw):
    """draw(d, i, im) pinta el cuadro i."""
    sheet = Image.new("RGBA", (n * side, side), (0, 0, 0, 0))
    for i in range(n):
        im = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        draw(ImageDraw.Draw(im), i, im)
        sheet.alpha_composite(im, (i * side, 0))
    return sheet


def _ball(d, x, y, r, pal):
    d.ellipse([x - r - 1, y - r - 1, x + r + 1, y + r + 1], fill=pal[0])
    d.ellipse([x - r, y - r, x + r, y + r], fill=pal[2])
    if r >= 2.5:
        d.ellipse([x - r * 0.6, y - r * 0.7, x + r * 0.3, y + r * 0.2], fill=pal[3])
    if r >= 4:
        d.ellipse([x - r * 0.45, y - r * 0.55, x - r * 0.05, y - r * 0.15], fill=pal[4])


def _fade(im, k):
    im.putalpha(im.getchannel("A").point(lambda v: int(v * max(0.0, min(1.0, k)))))


def orb(pal):
    """Proyectil: bola con estela, 16 px, 4 cuadros, hacia la derecha."""
    def draw(d, i, im):
        for k in range(3):
            _ball(d, 3 + k * 2.5 - (i % 2), 8 + math.sin(i * 1.6 + k) * 1.2, 1.2 + k * 0.5, pal)
        _ball(d, 11, 8, 3.2 + (i % 2) * 0.5, pal)
    return _sheet(4, 16, draw)


def gust(pal):
    """Proyectil: remolino de viento, 24 px."""
    def draw(d, i, im):
        for k in range(3):
            a = i * 60 + k * 120
            d.arc([4 + k, 4 + k, 20 - k, 20 - k], a, a + 150, fill=pal[2 + k % 2], width=2)
        d.arc([8, 8, 16, 16], -i * 90, -i * 90 + 200, fill=pal[4], width=1)
    return _sheet(4, 24, draw)


def egg(pal):
    """Proyectil: un huevo que gira, 16 px."""
    def draw(d, i, im):
        tilt = [0, 2, 0, -2][i]
        d.ellipse([3, 3 + tilt * 0.3, 13, 14], fill=pal[0])
        d.ellipse([4, 4, 12, 13], fill=(250, 240, 220))
        d.ellipse([5, 5, 9, 9], fill=(255, 252, 244))
        d.point([(7 + tilt, 10), (10 - tilt, 8), (8, 12)], fill=(214, 150, 150))
    return _sheet(4, 16, draw)


def slash(pal, side=32):
    """Corte cuerpo a cuerpo: una media luna que barre, hacia la derecha."""
    def draw(d, i, im):
        cx, cy = side * 0.35, side / 2
        r = side * 0.42
        sweep = [(-70, -20), (-60, 30), (-40, 65), (10, 75), (50, 80)][i]
        for k, w in enumerate([5, 3, 1]):
            d.arc([cx - r, cy - r, cx + r, cy + r], sweep[0], sweep[1], fill=pal[1 + k * 1 if k < 2 else 4], width=w)
        if i >= 3:
            _fade(im, 1.0 - (i - 2) * 0.3)
    return _sheet(5, side, draw)


def xslash(pal, side=48):
    """Dos cortes en cruz (Tajo Cruzado, Tijera X)."""
    def draw(d, i, im):
        c = side / 2
        ln = [8, 16, 21, 21, 21][i]
        for sx in (1, -1):
            if sx == -1 and i < 1:
                continue
            for k, w in enumerate([7, 4, 2]):
                d.line([(c - ln, c - ln * sx), (c + ln, c + ln * sx)], fill=pal[1 + k if k < 2 else 4], width=w)
        if i >= 3:
            _fade(im, 1.0 - (i - 2) * 0.33)
    return _sheet(5, side, draw)


def bite(pal, side=40):
    """Mordida: colmillos que se cierran y un destello."""
    gap = [8, 5, 2, 0, 0]

    def draw(d, i, im):
        cx, cy = side / 2, side / 2
        g = gap[i]
        if i >= 3:
            r = [10, 14][i - 3]
            for a in range(8):
                ang = a * math.tau / 8 + i * 0.4
                _ball(d, cx + math.cos(ang) * r, cy + math.sin(ang) * r * 0.8, 2.5 - (i - 3), pal)
        for k in range(4):
            x = cx - 12 + k * 8
            big = 9 if k in (0, 3) else 6
            d.polygon([(x - 3, cy - g - big - 2), (x + 3, cy - g - big - 2), (x, cy - g)], fill=pal[1])
            d.polygon([(x - 2, cy - g - big - 2), (x + 2, cy - g - big - 2), (x, cy - g - 2)], fill=(250, 246, 236))
            d.polygon([(x - 3, cy + g + big + 2), (x + 3, cy + g + big + 2), (x, cy + g)], fill=pal[1])
            d.polygon([(x - 2, cy + g + big + 2), (x + 2, cy + g + big + 2), (x, cy + g + 2)], fill=(250, 246, 236))
        if i == 4:
            _fade(im, 0.6)
    return _sheet(5, side, draw)


def web(pal, side=48):
    """Zona: telaraña en el piso (bucle con un brillo que la recorre)."""
    def draw(d, i, im):
        c = side / 2
        for k in range(8):
            a = k * math.tau / 8
            d.line([(c, c), (c + math.cos(a) * 22, c + math.sin(a) * 16)], fill=pal[3], width=1)
        for r in (7, 13, 20):
            pts = [(c + math.cos(k * math.tau / 8) * r, c + math.sin(k * math.tau / 8) * r * 0.73) for k in range(9)]
            d.line(pts, fill=pal[4] if r == 13 else pal[3], width=1)
        a = i / 6 * math.tau
        _ball(d, c + math.cos(a) * 13, c + math.sin(a) * 9.5, 1.5, pal)
        _fade(im, 0.9)
    return _sheet(6, side, draw)


def spikes(pal, side=48):
    """Zona: púas clavadas en el piso que gotean."""
    rnd = random.Random(3)
    spots = [(rnd.uniform(-17, 17), rnd.uniform(-11, 11)) for _ in range(9)]

    def draw(d, i, im):
        c = side / 2
        d.ellipse([c - 20, c - 14, c + 20, c + 14], outline=pal[1])
        for k, (sx, sy) in enumerate(spots):
            x, y = c + sx, c + sy
            h = 6 + (k % 3)
            d.polygon([(x - 2, y), (x + 2, y), (x, y - h)], fill=pal[2], outline=pal[0])
            d.point((x, y - h + 1), fill=pal[4])
            if (i + k) % 6 < 2:
                d.ellipse([x + 2, y - 1, x + 4, y + 1], fill=pal[3])
    return _sheet(6, side, draw)


def cloud(pal, side=64, alpha=0.75):
    """Zona: nube de polvo o esporas (bucle)."""
    rnd = random.Random(11)
    puffs = [(k * math.tau / 10 + rnd.uniform(-0.2, 0.2), 19 if k < 10 else 7, rnd.uniform(6, 10)) for k in range(14)]

    def draw(d, i, im):
        t = i / 8 * math.tau
        for ang, dist, r in sorted(puffs, key=lambda p: math.sin(p[0]) * p[1]):
            a = ang + math.sin(t + ang) * 0.25
            x = side / 2 + math.cos(a) * dist
            y = side / 2 + math.sin(a) * dist * 0.7 + math.sin(t + ang * 3) * 1.5
            rr = r + math.sin(t + ang * 2) * 1.5
            d.ellipse([x - rr - 1, y - rr - 1, x + rr + 1, y + rr + 1], fill=pal[1])
            d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=pal[2])
            d.ellipse([x - rr * 0.6, y - rr * 0.7, x + rr * 0.2, y + rr * 0.1], fill=pal[3])
        for k in range(6):  # motas que flotan
            a = k * 1.1 + t
            d.point((side / 2 + math.cos(a) * 22, side / 2 + math.sin(a * 1.3) * 15), fill=pal[4])
        _fade(im, alpha)
    return _sheet(8, side, draw)


def ring(pal, side=96):
    """Área: onda que se abre desde el centro."""
    def draw(d, i, im):
        c = side / 2
        r = 8 + 38 * (i / 7) ** 0.7
        for k, w in enumerate([5, 3, 1]):
            d.ellipse([c - r, c - r * 0.8, c + r, c + r * 0.8], outline=pal[1 + k if k < 2 else 4], width=w)
        for k in range(14):
            a = k * math.tau / 14 + i * 0.2
            _ball(d, c + math.cos(a) * (r + 3), c + math.sin(a) * (r + 3) * 0.8, 2.0, pal)
        if i < 2:
            _ball(d, c, c, [12, 7][i], pal)
        if i >= 5:
            _fade(im, 1.0 - (i - 4) / 4.0)
    return _sheet(8, side, draw)


def spin(pal, side=32):
    """Pegado al cuerpo: giro (embestida girando, taladro)."""
    def draw(d, i, im):
        c = side / 2
        rot = i * 45
        for k in range(3):
            s = rot + k * 120
            d.arc([c - 13, c - 13, c + 13, c + 13], s, s + 70, fill=pal[2], width=3)
            d.arc([c - 10, c - 10, c + 10, c + 10], s + 20, s + 80, fill=pal[4], width=2)
    return _sheet(4, side, draw)


def streak(pal, side=32):
    """Pegado al cuerpo: líneas de velocidad que quedan atrás (el movimiento va hacia la derecha)."""
    def draw(d, i, im):
        c = side / 2
        for k in range(5):
            y = c - 9 + k * 4.5 + ((i + k) % 2)
            x0 = 2 + ((i * 5 + k * 7) % 9)
            d.line([(x0, y), (x0 + 12 + (k % 2) * 4, y)], fill=pal[2 + k % 3], width=1 + (k == 2))
        d.arc([14, c - 11, 30, c + 11], -65, 65, fill=pal[4], width=2)
        d.arc([12, c - 12, 30, c + 12], -55, 55, fill=pal[2], width=1)
    return _sheet(4, side, draw)


def aura(pal, side=32):
    """Pegado al cuerpo: energía que sube (mejoras propias)."""
    def draw(d, i, im):
        c = side / 2
        for k in range(7):
            x = c - 12 + k * 4
            rise = ((i * 4 + k * 5) % 22)
            y = side - 5 - rise
            d.line([(x, y), (x, y - 4)], fill=pal[2 + (k % 3)], width=1)
            d.point((x, y - 5), fill=pal[4])
        d.arc([c - 13, side - 13, c + 13, side - 3], 0, 360, fill=pal[2], width=1)
        _fade(im, 0.9)
    return _sheet(6, side, draw)


def egg_drop(pal, side=48):
    """Golpe del cielo: el huevo cae, revienta y salpica."""
    def draw(d, i, im):
        c = side / 2
        if i < 2:
            y = c - 14 + i * 12
            d.ellipse([c - 6, y - 8, c + 6, y + 7], fill=(250, 240, 220), outline=pal[0])
            d.line([(c - 3, y - 14), (c - 3, y - 20)], fill=pal[4])
            d.line([(c + 3, y - 12), (c + 3, y - 19)], fill=pal[4])
        else:
            r = [9, 15, 19, 21][i - 2]
            for k in range(9):
                a = k * math.tau / 9 + 0.3
                x, y = c + math.cos(a) * r, c + math.sin(a) * r * 0.8
                d.polygon([(x - 2, y - 2), (x + 3, y), (x - 1, y + 2)], fill=(250, 240, 220), outline=pal[0])
            d.ellipse([c - r * 0.5, c - r * 0.35, c + r * 0.5, c + r * 0.35], fill=(255, 214, 90))
            d.ellipse([c - r * 0.25, c - r * 0.18, c + r * 0.25, c + r * 0.18], fill=(255, 244, 190))
            if i >= 4:
                _fade(im, 1.0 - (i - 3) * 0.3)
    return _sheet(6, side, draw)


def recolor(path, pal):
    """Otra hoja pasada a esta paleta, por brillo (chorros y rayos)."""
    src = Image.open(path).convert("RGBA")
    out = Image.new("RGBA", src.size)
    px, po = src.load(), out.load()
    for y in range(src.height):
        for x in range(src.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            k = min(3.999, max(r, g, b) / 255.0 * 0.6 * 4.6 + (r + g + b) / 765.0 * 0.4 * 4.6)
            lo, hi = pal[int(k)], pal[min(4, int(k) + 1)]
            f = k - int(k)
            po[x, y] = tuple(int(lo[c] + (hi[c] - lo[c]) * f) for c in range(3)) + (a,)
    return out


SHEETS = {
    # Caterpie
    "d_disparo_demora": (orb, NORMAL), "d_picadura": (bite, BUG), "d_telarana_zona": (web, NORMAL),
    "d_red_pegajosa": (ring, NORMAL), "d_hilo_cuerpo": (streak, NORMAL),
    # Weedle
    "d_picotazo_veneno": (slash, POISON), "d_puas_toxicas_zona": (spikes, POISON),
    "d_doble_ataque_cuerpo": (streak, BUG), "d_arremetida_cuerpo": (streak, BUG),
    # Pidgey
    "d_tornado": (gust, FLY), "d_ataque_ala_cuerpo": (streak, FLY), "d_ataque_arena": (orb, GROUND),
    "d_vuelo_corto_cuerpo": (streak, FLY),
    # Rattata
    "d_mordisco": (bite, NORMAL), "d_ataque_rapido_cuerpo": (streak, NORMAL), "d_foco_energia_cuerpo": (aura, FIGHT),
    "d_hipercolmillo_cuerpo": (streak, NORMAL), "d_escurrirse_cuerpo": (streak, NORMAL),
    # Oddish
    "d_absorber": (orb, LEAF), "d_polvo_veneno_zona": (cloud, POISON), "d_saltito_cuerpo": (streak, LEAF),
    # Bellsprout
    "d_resorte_cuerpo": (streak, LEAF),
    # Paras
    "d_aranazo": (slash, NORMAL), "d_chupavidas": (bite, BUG), "d_paralizador_zona": (cloud, ELEC),
    "d_espora": (ring, LEAF), "d_bajo_tierra_cuerpo": (streak, GROUND),
    # Venonat
    "d_psicorrayo": (orb, PSY), "d_chupavidas_venonat": (bite, BUG), "d_supersonico": (ring, NORMAL),
    "d_revoloteo_cuerpo": (streak, BUG),
    # Spearow
    "d_picotazo": (slash, FLY), "d_ataque_furia": (slash, NORMAL), "d_malicioso": (orb, DARK),
    "d_pico_taladro_cuerpo": (spin, FLY), "d_persecucion_cuerpo": (streak, DARK),
    # Pikachu
    "d_chispa_cuerpo": (spin, ELEC), "d_onda_trueno": (orb, ELEC), "d_ataque_rapido_pika_cuerpo": (streak, ELEC),
    # Exeggcute
    "d_bombardeo": (egg, NORMAL), "d_bomba_huevo_caida": (egg_drop, NORMAL), "d_hipnosis": (orb, PSY),
    "d_lluvia_huevos_caida": (egg_drop, NORMAL), "d_rodar_cuerpo": (spin, NORMAL),
    # Nidoran
    "d_aranazo_nido": (slash, NORMAL), "d_doble_patada": (slash, FIGHT), "d_grunido": (ring, NORMAL),
    "d_mordisco_toxico_cuerpo": (streak, POISON), "d_embate_cuerpo": (streak, POISON),
    "d_picotazo_nido": (slash, POISON), "d_cornada_cuerpo": (streak, POISON), "d_foco_nido_cuerpo": (aura, FIGHT),
    "d_perforador_cuerpo": (spin, NORMAL), "d_brinco_cuerpo": (streak, NORMAL),
    # Mankey
    "d_golpe_karate": (slash, FIGHT), "d_patada_baja": (slash, GROUND), "d_furia_cuerpo": (aura, FIGHT),
    "d_tajo_cruzado": (xslash, FIGHT), "d_salto_mono_cuerpo": (streak, FIGHT),
    # Scyther
    "d_corte_furia": (slash, BUG), "d_ala_guadana_cuerpo": (streak, BUG), "d_danza_espada_cuerpo": (aura, FLY),
    "d_tijera_x_cuerpo": (xslash, BUG), "d_agilidad_cuerpo": (streak, PSY),
}

# Hojas que salen de otra, cambiándole los colores: nombre -> (hoja de origen, paleta; None = copia tal cual)
RECOLORS = {
    "d_vendaval_chorro": ("lanzallamas_chorro", FLY), "d_megaagotar_chorro": ("lanzallamas_chorro", LEAF),
    "d_onda_mental_carga": ("rayo_solar_carga", PSY), "d_onda_mental_rayo": ("rayo_solar_rayo", PSY),
    "d_onda_mental_impacto": ("rayo_solar_impacto", PSY), "d_tormenta_hojas": ("hoja_afilada", None),
}


def build(root):
    dest = os.path.join(root, "sprites/fx/moves")
    out = {name: fn(pal) for name, (fn, pal) in SHEETS.items()}
    for name, (src, pal) in RECOLORS.items():
        path = os.path.join(dest, src + ".png")
        out[name] = Image.open(path).convert("RGBA") if pal is None else recolor(path, pal)
    return out
