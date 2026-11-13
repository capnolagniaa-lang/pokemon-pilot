"""Hojas de efecto de los kits del Volcán, la Costa, la Cueva, el Hielo y el Cementerio (tools/desafio_kits_resto.py).

A diferencia de las del Bosque no hay una tabla a mano: la hoja de cada ataque sale de **su forma y su tipo** (un disparo
= bola con estela del color del tipo, un golpe = media luna, una embestida = líneas de velocidad pegadas al cuerpo, una
zona = nube, algo que cae del cielo = `drop`, etc.), salvo que el kit pida otra con `look`. Lo llama make_desafio_vfx.py.
"""
import math
import os

from PIL import Image

import desafio_vfx_bosque as B
from desafio_kits_resto import KITS_RESTO, LOOKS

FIRE = [(90, 20, 0), (190, 60, 10), (245, 130, 30), (255, 205, 90), (255, 245, 200)]
WATER = [(14, 50, 110), (40, 110, 200), (90, 170, 240), (170, 220, 255), (236, 250, 255)]
ICE = [(40, 90, 130), (110, 180, 220), (170, 225, 245), (220, 244, 252), (255, 255, 255)]
ROCK = [(56, 46, 36), (120, 100, 78), (170, 150, 120), (210, 196, 170), (240, 232, 214)]
GHOST = [(30, 16, 60), (80, 50, 140), (130, 90, 200), (190, 160, 240), (236, 226, 255)]
DRAGON = [(30, 30, 110), (70, 70, 200), (120, 130, 245), (180, 200, 255), (236, 240, 255)]
FAIRY = [(120, 50, 90), (220, 110, 160), (250, 160, 200), (255, 210, 230), (255, 244, 250)]

PALETTES = {"fuego": FIRE, "agua": WATER, "hielo": ICE, "roca": ROCK, "fantasma": GHOST, "dragon": DRAGON, "hada": FAIRY,
            "veneno": B.POISON, "normal": B.NORMAL, "volador": B.FLY, "tierra": B.GROUND, "psiquico": B.PSY,
            "lucha": B.FIGHT, "bicho": B.BUG, "electrico": B.ELEC, "planta": B.LEAF, "siniestro": B.DARK}


def drop(pal, side=48):
    """Golpe del cielo: algo cae (roca, témpano, luz), revienta y deja esquirlas."""
    def draw(d, i, im):
        c = side / 2
        if i < 2:
            y = c - 16 + i * 14
            d.polygon([(c - 7, y - 6), (c + 2, y - 10), (c + 8, y - 2), (c + 4, y + 7), (c - 6, y + 5)], fill=pal[2],
                      outline=pal[0])
            d.polygon([(c - 4, y - 4), (c + 1, y - 7), (c + 3, y - 2), (c - 2, y)], fill=pal[3])
            d.line([(c - 3, y - 14), (c - 3, y - 22)], fill=pal[4])
            d.line([(c + 4, y - 13), (c + 4, y - 20)], fill=pal[3])
        else:
            r = [9, 15, 19, 21][i - 2]
            for k in range(9):
                a = k * math.tau / 9 + 0.3
                x, y = c + math.cos(a) * r, c + math.sin(a) * r * 0.8
                d.polygon([(x - 2, y - 3), (x + 3, y), (x - 1, y + 2)], fill=pal[2], outline=pal[0])
            d.ellipse([c - r * 0.6, c - r * 0.42, c + r * 0.6, c + r * 0.42], fill=pal[3])
            d.ellipse([c - r * 0.3, c - r * 0.2, c + r * 0.3, c + r * 0.2], fill=pal[4])
            if i >= 4:
                B._fade(im, 1.0 - (i - 3) * 0.3)
    return B._sheet(6, side, draw)


def puddle(pal, side=64):
    """Zona: charco espeso en el piso con burbujas (bucle)."""
    def draw(d, i, im):
        c = side / 2
        t = i / 6 * math.tau
        for k, (rx, ry) in enumerate([(26, 17), (22, 14), (15, 9)]):
            w = math.sin(t + k) * 1.2
            d.ellipse([c - rx - w, c - ry + w, c + rx + w, c + ry - w], fill=pal[k])
        for k in range(5):
            a = k * 1.3 + 0.4
            x, y = c + math.cos(a) * 14, c + math.sin(a) * 8
            rr = 1.0 + ((i + k * 2) % 6) * 0.5
            if (i + k * 2) % 6 < 5:
                d.ellipse([x - rr, y - rr, x + rr, y + rr], outline=pal[4])
        B._fade(im, 0.85)
    return B._sheet(6, side, draw)


GENS = {"orb": B.orb, "gust": B.gust, "egg": B.egg, "slash": B.slash, "xslash": B.xslash, "bite": B.bite, "web": B.web,
        "spikes": B.spikes, "cloud": B.cloud, "ring": B.ring, "spin": B.spin, "streak": B.streak, "aura": B.aura,
        "drop": drop, "puddle": puddle}


def plan(m):
    """[(nombre de la hoja, generador o None, hoja de origen a recolorear)] de un ataque."""
    mid, kind, look = m["id"], m["kind"], LOOKS.get(m["id"], "")
    if kind == "PROJECTILE":
        if m.get("beam_length", 0.0) > 0.0:
            return [(mid + "_" + part, None, "rayo_solar_" + part) for part in ("carga", "rayo", "impacto")]
        return [(mid, GENS[look or "orb"], "")]
    if kind == "MELEE":
        return [(mid, GENS[look or "slash"], "")]
    if kind in ("DASH", "LUNGE"):
        return [(mid + "_cuerpo", GENS[look or "streak"], "")]
    if kind == "ZONE":
        if m.get("zone_strike"):
            return [(mid + "_caida", GENS[look if look in ("drop",) else "drop"], "")]
        return [(mid + "_zona", GENS[look or "cloud"], "")]
    if kind == "AREA":
        return [(mid, GENS[look or "ring"], "")]
    if kind == "SELF_BUFF":
        return [(mid + "_cuerpo", GENS[look or "aura"], "")]
    if kind == "CHANNEL":
        return [(mid + "_chorro", None, "lanzallamas_chorro")]
    return []  # (el látigo se dibuja por código)


def build(root):
    dest = os.path.join(root, "sprites/fx/moves")
    out = {}
    for k in KITS_RESTO.values():
        for m in k["moves"] + [k["mobility"]]:
            pal = PALETTES[m["element"]]
            for name, gen, src in plan(m):
                if gen is not None:
                    out[name] = gen(pal)
                elif m["element"] == "fuego" and src.startswith("lanzallamas"):
                    out[name] = Image.open(os.path.join(dest, src + ".png")).convert("RGBA")
                else:
                    out[name] = B.recolor(os.path.join(dest, src + ".png"), pal)
    return out
