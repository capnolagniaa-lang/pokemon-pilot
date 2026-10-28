"""Genera efectos de ataque en pixel art por código (sin IA ni dependencias), con los colores de cada tipo.

Uso: python -I -B tools/make_vfx.py <carpeta del proyecto> [--sheet <png de contacto>]
  - sprites/fx/types/<tipo>_impacto.png: impacto al pegar, 32×32, 7 cuadros (los 18 tipos).
  - sprites/fx/moves/<ataque>.png: cuerpo de algunos proyectiles, 16×16, 4 cuadros en bucle, apuntando a la derecha.
Formato que lee el juego (DB.vfx_sheet): una fila de cuadros cuadrados. Pisa las hojas que genera; si hiciste una
a mano (PixelLab, Sorceress) con el mismo nombre, sacala de ESTILOS/BODIES o guardala con otro nombre.
Los colores salen de data/types/<tipo>.tres (color, core_color). Ver docs/TUTORIAL_PIXELLAB_SORCERESS.md.
"""
import math
import os
import random
import re
import struct
import sys
import zlib

IMPACT_SIZE = 32
IMPACT_FRAMES = 7
BODY_SIZE = 16
BODY_FRAMES = 4

## Estilo de impacto de cada tipo.
ESTILOS = {
    "normal": "estrella", "lucha": "estrella", "acero": "estrella",
    "fuego": "fuego", "agua": "agua", "electrico": "rayo", "planta": "hojas", "bicho": "hojas",
    "hielo": "hielo", "tierra": "escombros", "roca": "escombros", "volador": "viento",
    "veneno": "burbujas", "fantasma": "aros", "psiquico": "aros", "siniestro": "aros", "hada": "destellos",
    "dragon": "aros",
}
## Impactos que ya no se hacen por código: los reemplazó una hoja hecha con IA (docs/COMFYUI.md). No pisarlos.
HECHOS_CON_IA = {"hielo", "planta", "psiquico", "roca"}
## Cuerpos de proyectil por ataque: (tipo, estilo).
BODIES = {
    "ascuas": ("fuego", "bola_fuego"), "impactrueno": ("electrico", "bola_rayo"),
    "pistola_agua": ("agua", "chorro"), "burbuja": ("agua", "burbuja"), "hoja_afilada": ("planta", "hoja"),
}


# --- Lienzo y PNG ------------------------------------------------------------------------------------------

class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[None] * w for _ in range(h)]

    def plot(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if c is not None and 0 <= x < self.w and 0 <= y < self.h:
            self.px[y][x] = c

    def disc(self, cx, cy, r, c, dither=False):
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r and (not dither or (x + y) % 2 == 0):
                    self.plot(x, y, c)

    def ring(self, cx, cy, r, thick, c, squash=1.0, dither=False):
        for y in range(int(cy - r - 2), int(cy + r + 3)):
            for x in range(int(cx - r - 2), int(cx + r + 3)):
                d = math.hypot(x - cx, (y - cy) / squash)
                if r - thick <= d <= r and (not dither or (x + y) % 2 == 0):
                    self.plot(x, y, c)

    def line(self, x0, y0, x1, y1, c, width=1):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        for i in range(n + 1):
            t = i / n
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            if width <= 1:
                self.plot(x, y, c)
            else:
                self.disc(x, y, width / 2.0, c)

    def poly(self, pts, c):
        ys = [p[1] for p in pts]
        for y in range(int(min(ys)), int(max(ys)) + 1):
            xs = []
            for (x0, y0), (x1, y1) in zip(pts, pts[1:] + pts[:1]):
                if (y0 <= y + 0.5 < y1) or (y1 <= y + 0.5 < y0):
                    xs.append(x0 + (y + 0.5 - y0) / (y1 - y0) * (x1 - x0))
            xs.sort()
            for a, b in zip(xs[::2], xs[1::2]):
                for x in range(int(round(a)), int(round(b))):
                    self.plot(x, y, c)

    def outline(self, c):
        """Contorno oscuro de 1 px alrededor de lo dibujado (el estilo de los sprites PMD)."""
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.px[y][x] is None and any(
                        0 <= x + dx < self.w and 0 <= y + dy < self.h and self.px[y + dy][x + dx] not in (None, c)
                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    add.append((x, y))
        for x, y in add:
            self.px[y][x] = c


def write_png(path, frames, size):
    """Hoja de una fila: los cuadros uno al lado del otro."""
    strip = Canvas(size * len(frames), size)
    for k, f in enumerate(frames):
        for y in range(size):
            strip.px[y][k * size:(k + 1) * size] = f.px[y]
    os.makedirs(os.path.dirname(path), exist_ok=True)
    _write_rect(path, strip)


# --- Paleta del tipo ---------------------------------------------------------------------------------------

def read_type(root, tid):
    text = open(os.path.join(root, "data", "types", tid + ".tres"), encoding="utf-8").read()
    def col(key):
        m = re.search(r"^%s = Color\(([^)]*)\)" % key, text, re.M)
        return [float(v) for v in m.group(1).split(",")[:3]]
    return palette(col("color"), col("core_color"))


def palette(base, core):
    mix = lambda a, b, t: tuple(int(round(255 * min(1.0, a[i] + (b[i] - a[i]) * t))) for i in range(3))
    white = [1.0, 1.0, 1.0]
    return {"dark": mix([0, 0, 0], base, 0.38), "base": mix(base, base, 0), "mid": mix(base, core, 0.5),
            "core": mix(core, core, 0), "hi": mix(core, white, 0.6)}


# --- Impactos (32×32, 7 cuadros) ---------------------------------------------------------------------------

def impact(style, pal, rng):
    frames = []
    S, n = IMPACT_SIZE, IMPACT_FRAMES
    c = S / 2.0
    parts = [(rng.uniform(0, math.tau), rng.uniform(0.6, 1.0)) for _ in range(10)]
    for i in range(n):
        t = i / (n - 1)
        f = Canvas(S, S)
        fade = t > 0.6  # últimos cuadros: tramado (se desvanece sin transparencias)
        if i <= 1:  # destello inicial (sin blanco: el glow del juego ya lo hace brillar)
            f.disc(c, c, 2 + 2 * i, pal["base"])
            f.disc(c, c, 1 + i, pal["core"])
        if style == "estrella":
            spikes = 8
            for k in range(spikes):
                a = k * math.tau / spikes + 0.2
                L = (5 + 9 * math.sin(min(1.0, t * 1.4) * math.pi)) * (1.0 if k % 2 == 0 else 0.6)
                inner = 2 + 6 * t
                f.line(c + math.cos(a) * inner, c + math.sin(a) * inner, c + math.cos(a) * (inner + L),
                       c + math.sin(a) * (inner + L), pal["hi"] if k % 2 == 0 else pal["mid"], 2 if t < 0.4 else 1)
            if 0.2 < t < 0.8:
                f.ring(c, c, 4 + 10 * t, 1.2, pal["base"], dither=fade)
        elif style == "fuego":
            for k, (a0, s) in enumerate(parts[:7]):
                a = -math.pi / 2 + (k - 3) * 0.45
                d = 3 + 9 * t * s
                bx, by = c + math.cos(a) * d * 0.8, c + 6 + math.sin(a) * d * 0.5 - 3 * t
                h = (5 + 3 * s) * (1 - t * 0.6)
                w = 2.5 * (1 - t * 0.5) + 1
                tip = (bx + math.cos(a) * h, by + math.sin(a) * h - 3)
                f.poly([(bx - w, by), tip, (bx + w, by), (bx, by + w * 1.2)], pal["base"] if t > 0.3 else pal["mid"])
                if t < 0.7:
                    f.disc(bx, by, w * 0.7, pal["core"])
            if t > 0.5:
                for a0, s in parts:
                    f.disc(c + math.cos(a0) * 10 * s, c - 4 - 8 * t * s, 1.5, pal["dark"], dither=True)
        elif style == "agua":
            f.ring(c, c + 4, 3 + 11 * t, 1.5, pal["mid"], squash=0.45, dither=fade)
            for a0, s in parts:
                a = -math.pi * (0.15 + 0.7 * (a0 / math.tau))
                v = 14 * s
                x = c + math.cos(a) * v * t
                y = c + 2 + math.sin(a) * v * t + 18 * t * t
                f.disc(x, y, 1.6 if t < 0.6 else 1.0, pal["core"] if s > 0.8 else pal["base"])
            if t < 0.5:
                f.poly([(c - 5, c + 3), (c - 2, c - 6 + 6 * t), (c, c - 2), (c + 2, c - 6 + 6 * t), (c + 5, c + 3)], pal["mid"])
        elif style == "rayo":
            for k in range(4):
                a = rng.uniform(0, math.tau)
                x, y = c, c
                L = 6 + 9 * math.sin(min(1.0, t * 1.5) * math.pi)
                steps = 4
                for _ in range(steps):
                    nx = x + math.cos(a) * L / steps + rng.uniform(-2.5, 2.5)
                    ny = y + math.sin(a) * L / steps + rng.uniform(-2.5, 2.5)
                    f.line(x, y, nx, ny, pal["hi"] if k % 2 == 0 else pal["base"])
                    x, y = nx, ny
            if t < 0.7:
                f.disc(c, c, 3 - 3 * t, pal["core"])
        elif style == "hojas":
            for a0, s in parts[:8]:
                d = 3 + 12 * t * s
                x, y = c + math.cos(a0) * d, c + math.sin(a0) * d + 3 * t
                rot = a0 + t * 5 * s
                L, W = 3.0, 1.5
                pts = [(x + math.cos(rot) * L, y + math.sin(rot) * L), (x + math.cos(rot + 1.57) * W, y + math.sin(rot + 1.57) * W),
                       (x - math.cos(rot) * L, y - math.sin(rot) * L), (x - math.cos(rot + 1.57) * W, y - math.sin(rot + 1.57) * W)]
                if not fade or int(s * 10) % 2 == 0:
                    f.poly(pts, pal["base"] if s < 0.8 else pal["mid"])
                    f.plot(x, y, pal["hi"])
        elif style == "hielo":
            for k, (a0, s) in enumerate(parts[:8]):
                a = k * math.tau / 8 + 0.3
                if t < 0.55:
                    L = 4 + 10 * (t / 0.55) * s
                    p0 = (c + math.cos(a + 0.35) * 2, c + math.sin(a + 0.35) * 2)
                    p1 = (c + math.cos(a) * L, c + math.sin(a) * L)
                    p2 = (c + math.cos(a - 0.35) * 2, c + math.sin(a - 0.35) * 2)
                    f.poly([p0, p1, p2], pal["mid"])
                    f.line(c, c, (c + p1[0]) / 2, (c + p1[1]) / 2, pal["hi"])
                else:  # se rompe en cristalitos
                    d = 10 + 10 * (t - 0.55) * s
                    x, y = c + math.cos(a) * d, c + math.sin(a) * d
                    f.plot(x, y, pal["hi"])
                    f.plot(x + 1, y, pal["mid"])
                    f.plot(x, y + 1, pal["mid"])
        elif style == "escombros":
            if t > 0.2:  # polvo
                f.ring(c, c + 6, 4 + 9 * t, 2, pal["core"], squash=0.45, dither=True)
            for a0, s in parts:
                a = -math.pi * (0.1 + 0.8 * (a0 / math.tau))
                v = 13 * s
                x = c + math.cos(a) * v * t
                y = c + 3 + math.sin(a) * v * t + 16 * t * t
                r = 1.6 if s > 0.75 else 1.0
                f.disc(x, y, r, pal["base"])
                f.plot(x - 0.5, y - 0.5, pal["core"])
        elif style == "viento":
            for k in range(3):
                r = 4 + 4 * k + 6 * t
                a0 = t * 4 + k * 2.1
                for j in range(14):
                    a = a0 + j * 0.16
                    if not fade or j % 2 == 0:
                        f.plot(c + math.cos(a) * r, c + math.sin(a) * r * 0.75, pal["hi"] if j > 9 else pal["base"])
        elif style in ("burbujas", "aros", "destellos"):
            f.ring(c, c, 3 + 12 * t, 2 if t < 0.5 else 1, pal["base"], dither=fade)
            if t > 0.15:
                f.ring(c, c, 1 + 8 * t, 1, pal["mid"], dither=fade)
            if style == "burbujas":
                for a0, s in parts[:6]:
                    x, y = c + math.cos(a0) * 9 * s * t, c + math.sin(a0) * 6 * s - 10 * t * s
                    f.ring(x, y, 2 if s > 0.8 else 1.5, 1, pal["mid"])
                    f.plot(x - 0.5, y - 0.5, pal["hi"])
            elif style == "destellos":
                for a0, s in parts[:6]:
                    d = 4 + 10 * t * s
                    x, y = c + math.cos(a0) * d, c + math.sin(a0) * d
                    if (i + int(s * 10)) % 2 == 0:
                        f.plot(x, y, pal["hi"]); f.plot(x - 1, y, pal["mid"]); f.plot(x + 1, y, pal["mid"])
                        f.plot(x, y - 1, pal["mid"]); f.plot(x, y + 1, pal["mid"])
            elif t < 0.5:  # aros: puntas hacia adentro
                for k in range(6):
                    a = k * math.tau / 6 + t * 2
                    r = 14 - 10 * t
                    f.line(c + math.cos(a) * r, c + math.sin(a) * r, c + math.cos(a) * (r - 3), c + math.sin(a) * (r - 3), pal["hi"])
        f.outline(pal["dark"])
        frames.append(f)
    return frames


# --- Cuerpos de proyectil (16×16, 4 cuadros en bucle, apuntando a la derecha) ---------------------------

def body(style, pal, rng):
    frames = []
    S = BODY_SIZE
    c = S / 2.0
    for i in range(BODY_FRAMES):
        f = Canvas(S, S)
        w = math.sin(i * math.pi / 2)  # oscila
        if style == "bola_fuego":
            f.poly([(c + 3, c - 3), (c - 7 - w, c - 1 + w), (c - 5, c), (c - 7 + w, c + 1 - w), (c + 3, c + 3)], pal["base"])
            f.disc(c + 2, c, 3.2, pal["mid"])
            f.disc(c + 2.5, c - 0.5, 1.8, pal["core"])
            f.plot(c + 3, c - 1, pal["hi"])
        elif style == "bola_rayo":
            f.disc(c, c, 3, pal["base"])
            f.disc(c, c, 1.8, pal["hi"])
            for k in range(3):
                a = rng.uniform(0, math.tau)
                x, y = c, c
                for _ in range(2):
                    nx, ny = x + math.cos(a) * 3 + rng.uniform(-1, 1), y + math.sin(a) * 3 + rng.uniform(-1, 1)
                    f.line(x, y, nx, ny, pal["hi"] if k == 0 else pal["base"])
                    x, y = nx, ny
        elif style == "chorro":
            for k in range(3):
                x = c + 3 - k * 3.5
                f.disc(x, c + (w if k % 2 else -w) * 0.6, 2.4 - k * 0.5, pal["base"] if k else pal["mid"])
            f.plot(c + 4, c - 1, pal["hi"])
        elif style == "burbuja":
            f.ring(c, c, 4 + 0.4 * w, 1, pal["mid"])
            f.disc(c, c, 2.6, pal["base"], dither=True)
            f.plot(c - 1.5, c - 1.5, pal["hi"])
            f.plot(c - 1, c - 2, pal["hi"])
        elif style == "hoja":
            rot = i * math.pi / 2
            L, W = 5.0, 2.2
            f.poly([(c + math.cos(rot) * L, c + math.sin(rot) * L), (c + math.cos(rot + 1.57) * W, c + math.sin(rot + 1.57) * W),
                    (c - math.cos(rot) * L, c - math.sin(rot) * L), (c - math.cos(rot + 1.57) * W, c - math.sin(rot + 1.57) * W)], pal["base"])
            f.line(c - math.cos(rot) * 4, c - math.sin(rot) * 4, c + math.cos(rot) * 4, c + math.sin(rot) * 4, pal["hi"])
        f.outline(pal["dark"])
        frames.append(f)
    return frames


def contact_sheet(path, rows, scale=4):
    """Hoja de contacto para mirar los efectos: cada fila = una hoja, agrandada y sobre fondo de pasto."""
    width = max(len(fr) * fr[0].w for _, fr in rows)
    height = sum(fr[0].h for _, fr in rows) + 2 * len(rows)
    sheet = Canvas(width, height)
    y0 = 0
    for _, frames in rows:
        for k, f in enumerate(frames):
            for y in range(f.h):
                for x in range(f.w):
                    sheet.px[y0 + y][k * f.w + x] = f.px[y][x]
        y0 += frames[0].h + 2
    big = Canvas(width * scale, height * scale)
    for y in range(big.h):
        for x in range(big.w):
            p = sheet.px[y // scale][x // scale]
            big.px[y][x] = p if p is not None else ((150, 200, 120) if ((x // 16 + y // 16) % 2) else (140, 190, 110))
    _write_rect(path, big)


def _write_rect(path, cv):
    raw = bytearray()
    for y in range(cv.h):
        raw.append(0)
        for x in range(cv.w):
            p = cv.px[y][x]
            raw += bytes(p) + b"\xff" if p is not None else b"\x00\x00\x00\x00"
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", cv.w, cv.h, 8, 6, 0, 0, 0))
                + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b""))


def main():
    root = sys.argv[1]
    sheet = sys.argv[sys.argv.index("--sheet") + 1] if "--sheet" in sys.argv else None
    rows = []
    for tid, style in ESTILOS.items():
        if tid in HECHOS_CON_IA:
            continue
        frames = impact(style, read_type(root, tid), random.Random(tid))
        write_png(os.path.join(root, "sprites", "fx", "types", tid + "_impacto.png"), frames, IMPACT_SIZE)
        rows.append((tid, frames))
    for mid, (tid, style) in BODIES.items():
        frames = body(style, read_type(root, tid), random.Random(mid))
        write_png(os.path.join(root, "sprites", "fx", "moves", mid + ".png"), frames, BODY_SIZE)
        rows.append((mid, frames))
    if sheet:
        contact_sheet(sheet, rows)
    print("impactos:", len(ESTILOS), "| cuerpos:", len(BODIES))


if __name__ == "__main__":
    main()
