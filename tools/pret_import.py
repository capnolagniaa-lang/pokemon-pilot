"""Convierte los gráficos del decomp pret/pokefirered (art_src/pret) en atlas PNG para Godot.

Uso: python -I tools/pret_import.py <carpeta art_src/pret> <carpeta salida> [carpeta debug]

Por cada tileset genera:
  <nombre>_below.png  capa que va debajo de los personajes (16 metatiles por fila)
  <nombre>_above.png  capa que va encima (copas de árboles, techos)
  <nombre>_anim.png   metatiles animados de la capa inferior: una fila por metatile, frames en horizontal
y un manifest.json con comportamiento, capa y animación de cada metatile.
Sin dependencias: decodifica y codifica PNG a mano.
"""
import json
import math
import os
import struct
import sys
import zlib

NUM_TILES_PRIMARY = 640
NUM_PALS_PRIMARY = 7
COLS = 16

# Animaciones del tileset general: (tile destino, cantidad, carpeta, frames, ticks por frame a 60 fps)
GENERAL_ANIMS = [
    (508, 4, "flower", 5, 16),
    (416, 48, "water_current_landwatersedge", 8, 16),
    (464, 18, "sandwatersedge", 8, 8),
]


# --- PNG ---------------------------------------------------------------------

def read_png(path):
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", path
    pos, idat, plte, trns = 8, b"", None, b""
    while pos < len(data):
        (ln,) = struct.unpack(">I", data[pos:pos + 4])
        typ, body = data[pos + 4:pos + 8], data[pos + 8:pos + 8 + ln]
        pos += 12 + ln
        if typ == b"IHDR":
            w, h, bd, ct, _, _, inter = struct.unpack(">IIBBBBB", body)
            assert inter == 0, "PNG entrelazado no soportado"
        elif typ == b"PLTE":
            plte = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif typ == b"tRNS":
            trns = body
        elif typ == b"IDAT":
            idat += body
    raw = zlib.decompress(idat)
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ct]
    bits = bd * channels
    stride = (w * bits + 7) // 8
    bpp = max(1, bits // 8)
    prev, i, px = bytearray(stride), 0, []
    for _ in range(h):
        f = raw[i]
        line = bytearray(raw[i + 1:i + 1 + stride])
        i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else (b if pb <= pc else c))) & 255
        prev = line
        if bd < 8:
            per, mask = 8 // bd, (1 << bd) - 1
            px.append([(line[x // per] >> (8 - bd * (x % per + 1))) & mask for x in range(w)])
        elif channels == 1:
            px.append(list(line[:w]))
        else:
            px.append([tuple(line[x * channels:(x + 1) * channels]) for x in range(w)])
    return {"w": w, "h": h, "ct": ct, "bd": bd, "plte": plte, "trns": trns, "px": px}


def write_png(path, img):
    w, h = img.w, img.h
    raw = b"".join(b"\x00" + bytes(img.data[y * w * 4:(y + 1) * w * 4]) for y in range(h))

    def chunk(t, b):
        return struct.pack(">I", len(b)) + t + b + struct.pack(">I", zlib.crc32(t + b) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "wb").write(png)


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.data = bytearray(w * h * 4)

    def set(self, x, y, rgba):
        if 0 <= x < self.w and 0 <= y < self.h:
            o = (y * self.w + x) * 4
            self.data[o:o + 4] = bytes(rgba)

    def get(self, x, y):
        o = (y * self.w + x) * 4
        return tuple(self.data[o:o + 4])

    def blit(self, src, dx, dy):
        for y in range(src.h):
            for x in range(src.w):
                p = src.get(x, y)
                if p[3]:
                    self.set(dx + x, dy + y, p)


# --- GBA ---------------------------------------------------------------------

def read_pal(path):
    lines = open(path).read().split()
    n = int(lines[2])
    vals = list(map(int, lines[3:3 + n * 3]))
    return [tuple(vals[i * 3:i * 3 + 3]) for i in range(n)]


def tiles_of(img):
    tw, th = img["w"] // 8, img["h"] // 8
    px = img["px"]
    return [[px[ty * 8 + y][tx * 8 + x] for y in range(8) for x in range(8)] for ty in range(th) for tx in range(tw)]


class Tileset:
    def __init__(self, root, name, primary=None):
        self.name = name.split("/")[-1]
        d = os.path.join(root, "data", "tilesets", name)
        self.tiles = tiles_of(read_png(os.path.join(d, "tiles.png")))
        self.pals = [read_pal(os.path.join(d, "palettes", "%02d.pal" % i)) for i in range(16)]
        mt = open(os.path.join(d, "metatiles.bin"), "rb").read()
        self.metatiles = [struct.unpack("<8H", mt[i:i + 16]) for i in range(0, len(mt), 16)]
        at = open(os.path.join(d, "metatile_attributes.bin"), "rb").read()
        self.attrs = [struct.unpack("<I", at[i:i + 4])[0] for i in range(0, len(at), 4)]
        self.primary = primary or self
        self.anim_tiles = {}  # tile -> (lista de frames de 64 índices, ticks por frame)
        if name == "primary/general":
            for dest, count, folder, frames, ticks in GENERAL_ANIMS:
                frame_tiles = [tiles_of(read_png(os.path.join(d, "anim", folder, "%d.png" % f))) for f in range(frames)]
                for k in range(count):
                    self.anim_tiles[dest + k] = ([ft[k] for ft in frame_tiles], ticks)

    def tile(self, idx, frame_tick):
        """Índices de color del tile, aplicando la animación en el tick dado."""
        prim = self.primary
        if idx < NUM_TILES_PRIMARY:
            if idx in prim.anim_tiles:
                frames, ticks = prim.anim_tiles[idx]
                return frames[(frame_tick // ticks) % len(frames)]
            return prim.tiles[idx] if idx < len(prim.tiles) else None
        idx -= NUM_TILES_PRIMARY
        return self.tiles[idx] if self is not prim and idx < len(self.tiles) else None

    def palette(self, p):
        return self.primary.pals[p] if p < NUM_PALS_PRIMARY else self.pals[p]

    def anim_period(self, mt_index):
        """(cantidad de frames, ticks por frame) si el metatile usa tiles animados en su capa inferior."""
        cycles, steps = [], []
        for e in self.metatiles[mt_index][:4]:
            t = e & 0x3FF
            if t in self.primary.anim_tiles:
                frames, ticks = self.primary.anim_tiles[t]
                cycles.append(len(frames) * ticks)
                steps.append(ticks)
        if not cycles:
            return None
        period = 1
        for c in cycles:
            period = period * c // math.gcd(period, c)
        step = steps[0]
        for s in steps[1:]:
            step = math.gcd(step, s)
        return min(period // step, 32), step

    def render(self, mt_index, layer, tick=0):
        """Dibuja la mitad (0 = 4 primeros tiles, 1 = 4 últimos) de un metatile en 16x16."""
        c = Canvas(16, 16)
        entries = self.metatiles[mt_index][layer * 4:layer * 4 + 4]
        for k, e in enumerate(entries):
            t = self.tile(e & 0x3FF, tick)
            if t is None:
                continue
            hf, vf, pal = (e >> 10) & 1, (e >> 11) & 1, self.palette(e >> 12)
            ox, oy = (k % 2) * 8, (k // 2) * 8
            for y in range(8):
                for x in range(8):
                    ci = t[(7 - y if vf else y) * 8 + (7 - x if hf else x)]
                    if ci:
                        r, g, b = pal[ci]
                        c.set(ox + x, oy + y, (r, g, b, 255))
        return c


def layers_for(attr):
    """Qué mitades van abajo y cuáles arriba de los personajes, según el tipo de capa."""
    layer_type = (attr >> 29) & 3
    if layer_type == 1:  # COVERED: todo debajo
        return [0, 1], []
    return [0], [1]  # NORMAL / SPLIT: la segunda mitad tapa al personaje


def export_tileset(ts, out_dir, manifest):
    n = len(ts.metatiles)
    rows = (n + COLS - 1) // COLS
    below, above = Canvas(COLS * 16, rows * 16), Canvas(COLS * 16, rows * 16)
    info = {"count": n, "behavior": [], "layer_type": [], "above_used": [], "anim": {}}
    anim_rows = []
    for i in range(n):
        attr = ts.attrs[i] if i < len(ts.attrs) else 0
        lo, hi = layers_for(attr)
        x, y = (i % COLS) * 16, (i // COLS) * 16
        for half in lo:
            below.blit(ts.render(i, half), x, y)
        used = False
        for half in hi:
            img = ts.render(i, half)
            used = used or any(img.data[3::4])
            above.blit(img, x, y)
        info["behavior"].append(attr & 0x1FF)
        info["layer_type"].append((attr >> 29) & 3)
        info["above_used"].append(used)
        period = ts.anim_period(i)
        if period:
            frames, step = period
            strip = Canvas(frames * 16, 16)
            for f in range(frames):
                for half in lo:
                    strip.blit(ts.render(i, half, f * step), f * 16, 0)
            info["anim"][str(i)] = {"row": len(anim_rows), "frames": frames, "duration": step / 60.0}
            anim_rows.append(strip)
    write_png(os.path.join(out_dir, ts.name + "_below.png"), below)
    write_png(os.path.join(out_dir, ts.name + "_above.png"), above)
    if anim_rows:
        width = max(s.w for s in anim_rows)
        anim = Canvas(width, len(anim_rows) * 16)
        for r, s in enumerate(anim_rows):
            anim.blit(s, 0, r * 16)
        write_png(os.path.join(out_dir, ts.name + "_anim.png"), anim)
    manifest[ts.name] = info
    return below, above


# --- Debug: hoja ampliada con el número de cada metatile ----------------------

DIGITS = ["111101101101111", "010110010010111", "111001111100111", "111001111001111", "101101111001001",
          "111100111001111", "111100111101111", "111001001001001", "111101111101111", "111101111001111"]


def debug_sheet(path, below, above, count, scale=3):
    cols = COLS
    cell = 16 * scale + 2
    rows = (count + cols - 1) // cols
    c = Canvas(cols * cell, rows * cell)
    for i in range(c.w * c.h):
        c.data[i * 4:i * 4 + 4] = b"\xff\x00\xff\xff"
    for i in range(count):
        bx, by = (i % cols) * cell + 1, (i // cols) * cell + 1
        sx, sy = (i % cols) * 16, (i // cols) * 16
        for y in range(16 * scale):
            for x in range(16 * scale):
                p = above.get(sx + x // scale, sy + y // scale)
                if not p[3]:
                    p = below.get(sx + x // scale, sy + y // scale)
                if not p[3]:
                    p = (40, 40, 40, 255)
                c.set(bx + x, by + y, p)
        for k, ch in enumerate(str(i)):
            bits = DIGITS[int(ch)]
            for yy in range(5):
                for xx in range(3):
                    col = (255, 255, 0, 255) if bits[yy * 3 + xx] == "1" else (0, 0, 0, 255)
                    for s in range(4):
                        c.set(bx + 1 + k * 8 + xx * 2 + s % 2, by + 1 + yy * 2 + s // 2, col)
    write_png(path, c)


def export_sprite(root, pic, pal_name, out_path):
    """Sprite de objeto (indexado) + su paleta -> PNG RGBA."""
    img = read_png(os.path.join(root, "graphics", "object_events", "pics", pic))
    pal = read_pal(os.path.join(root, "graphics", "object_events", "palettes", pal_name))
    c = Canvas(img["w"], img["h"])
    for y in range(img["h"]):
        for x in range(img["w"]):
            ci = img["px"][y][x]
            if ci:
                r, g, b = pal[ci]
                c.set(x, y, (r, g, b, 255))
    write_png(out_path, c)
    return img["w"], img["h"]


SPRITES = [
    ("people/red_normal.png", "player.pal", "characters/red.png"),
    ("misc/rock_smash_rock.png", "npc_white.pal", "objects/rock_smash_rock.png"),
    ("misc/strength_boulder.png", "npc_white.pal", "objects/strength_boulder.png"),
    ("misc/cut_tree.png", "npc_green.pal", "objects/cut_tree.png"),
]


def main():
    root, out_dir = sys.argv[1], sys.argv[2]
    debug_dir = sys.argv[3] if len(sys.argv) > 3 else None
    manifest = {}
    general = Tileset(root, "primary/general")
    sets = [general, Tileset(root, "secondary/viridian_forest", general), Tileset(root, "secondary/pallet_town", general)]
    for ts in sets:
        below, above = export_tileset(ts, os.path.join(out_dir, "tiles"), manifest)
        if debug_dir:
            debug_sheet(os.path.join(debug_dir, ts.name + "_debug.png"), below, above, len(ts.metatiles))
        print(ts.name, "metatiles:", len(ts.metatiles), "animados:", len(manifest[ts.name]["anim"]))
    for pic, pal, out in SPRITES:
        w, h = export_sprite(root, pic, pal, os.path.join(out_dir, out))
        print(out, w, "x", h)
    with open(os.path.join(out_dir, "tiles", "manifest.json"), "w") as f:
        json.dump(manifest, f)


if __name__ == "__main__":
    main()
