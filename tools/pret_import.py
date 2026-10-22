"""Convierte los gráficos del decomp pret/pokefirered (art_src/pret) en atlas PNG para Godot.

Uso: python -I tools/pret_import.py <carpeta art_src/pret> <carpeta salida> [carpeta debug]

Por cada tileset genera:
  <nombre>_below.png  capa que va debajo de los personajes (16 metatiles por fila)
  <nombre>_above.png  capa que va encima (copas de árboles, techos)
  <nombre>_anim.png   metatiles animados de la capa inferior: una fila por metatile, frames en horizontal
y un manifest.json con comportamiento, capa y animación de cada metatile.
Sin dependencias: decodifica y codifica PNG a mano.
"""
import collections
import json
import math
import os
import re
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
    """Un tileset de FireRed. `src` = carpetas de sus tiles, paletas y metatiles (pueden ser de otro tileset:
    Silph Co usa los tiles de Condominios), resueltas desde src/data/tilesets/headers.h."""

    def __init__(self, root, name, src, primary=None):
        self.name = name
        d = lambda key: os.path.join(root, src[key])
        self.tiles = tiles_of(read_png(os.path.join(d("tiles"), "tiles.png")))
        self.pals = [read_pal(os.path.join(d("palettes"), "palettes", "%02d.pal" % i)) for i in range(16)]
        mt = open(os.path.join(d("metatiles"), "metatiles.bin"), "rb").read()
        self.metatiles = [struct.unpack("<8H", mt[i:i + 16]) for i in range(0, len(mt), 16)]
        at = open(os.path.join(d("metatiles"), "metatile_attributes.bin"), "rb").read()
        self.attrs = [struct.unpack("<I", at[i:i + 4])[0] for i in range(0, len(at), 4)]
        self.primary = primary or self
        self.anim_tiles = {}  # tile -> (lista de frames de 64 índices, ticks por frame)
        d = d("tiles")
        if name == "general":
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
    """Atlas below/above/anim del tileset + su entrada del manifest. Devuelve (below, above, colores medios)."""
    n = len(ts.metatiles)
    rows = (n + COLS - 1) // COLS
    below, above = Canvas(COLS * 16, rows * 16), Canvas(COLS * 16, rows * 16)
    info = {"count": n, "behavior": [], "layer_type": [], "above_used": [], "anim": {}, "empty": []}
    anim_rows, colors = [], []
    for i in range(n):
        attr = ts.attrs[i] if i < len(ts.attrs) else 0
        lo, hi = layers_for(attr)
        x, y = (i % COLS) * 16, (i // COLS) * 16
        acc = [0, 0, 0, 0]
        for half in lo:
            img = ts.render(i, half)
            below.blit(img, x, y)
            _accumulate(acc, img)
        used = False
        for half in hi:
            img = ts.render(i, half)
            used = used or any(img.data[3::4])
            above.blit(img, x, y)
            _accumulate(acc, img)
        info["behavior"].append(attr & 0x1FF)
        info["layer_type"].append((attr >> 29) & 3)
        info["above_used"].append(used)
        info["empty"].append(acc[3] == 0)
        colors.append([acc[k] // max(1, acc[3]) for k in range(3)])
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
    return below, above, colors


def _accumulate(acc, img):
    d = img.data
    for o in range(0, len(d), 4):
        if d[o + 3]:
            acc[0] += d[o]
            acc[1] += d[o + 1]
            acc[2] += d[o + 2]
            acc[3] += 1


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


# --- Todos los tilesets de FireRed ----------------------------------------------

# Nombres para mostrar (lo que no esté acá se arma con el nombre del archivo).
TILESET_NAMES = {
    "general": "General (exteriores)", "building": "Interiores (base)",
    "pallet_town": "Pueblo Paleta", "viridian_city": "Ciudad Verde", "viridian_forest": "Bosque Verde",
    "pewter_city": "Ciudad Plateada", "cerulean_city": "Ciudad Celeste", "vermilion_city": "Ciudad Carmín",
    "lavender_town": "Pueblo Lavanda", "celadon_city": "Ciudad Azulona", "fuchsia_city": "Ciudad Fucsia",
    "saffron_city": "Ciudad Azafrán", "cinnabar_island": "Isla Canela", "indigo_plateau": "Meseta Añil",
    "cave": "Cuevas", "mt_ember": "Monte Ascuas", "seafoam_islands": "Islas Espuma", "rock_tunnel": "Túnel Roca",
    "digletts_cave": "Cueva Diglett", "cerulean_cave": "Cueva Celeste", "berry_forest": "Bosque Baya",
    "sevii_islands_123": "Islas Sete 1-3", "sevii_islands_45": "Islas Sete 4-5", "sevii_islands_67": "Islas Sete 6-7",
    "tanoby_ruins": "Ruinas Tanoby", "navel_rock": "Roca Ombligo", "island_harbor": "Puerto de las islas",
    "pokemon_center": "Centro Pokémon", "mart": "Tienda Pokémon", "lab": "Laboratorio", "pokemon_tower": "Torre Pokémon",
    "pokemon_mansion": "Mansión Pokémon", "silph_co": "Silph S.A.", "ss_anne": "S.S. Anne", "game_corner": "Casino",
    "department_store": "Centro Comercial", "power_plant": "Central Eléctrica", "museum": "Museo",
    "safari_zone_building": "Zona Safari (edificio)", "underground_path": "Paso subterráneo",
    "trainer_tower": "Torre Entrenador", "pokemon_league": "Liga Pokémon", "hall_of_fame": "Salón de la Fama",
    "pewter_gym": "Gimnasio Plateada", "cerulean_gym": "Gimnasio Celeste", "vermilion_gym": "Gimnasio Carmín",
    "celadon_gym": "Gimnasio Azulona", "fuchsia_gym": "Gimnasio Fucsia", "saffron_gym": "Gimnasio Azafrán",
    "cinnabar_gym": "Gimnasio Canela", "viridian_gym": "Gimnasio Verde", "generic_building_1": "Casas 1",
    "generic_building_2": "Casas 2", "school": "Escuela", "restaurant_hotel": "Restaurante y hotel",
    "condominiums": "Condominios", "fan_club_daycare": "Club de fans y guardería", "bike_shop": "Tienda de bicis",
    "burgled_house": "Casa robada", "cable_club": "Club de cable", "sea_cottage": "Cabaña del mar",
    "hoenn_building": "Edificio de Hoenn", "unused_gatehouse_1": "Garita 1", "unused_gatehouse_2": "Garita 2",
    "one_island": "Isla Prima", "two_island": "Isla Secunda", "three_island": "Isla Tera", "four_island": "Isla Cuarta",
    "five_island": "Isla Quinta", "six_island": "Isla Sexta", "seven_island": "Isla Séptima",
}

# Categorías por tipo (orden de la paleta del editor).
CATEGORIES = [
    ("terreno", "Terreno y caminos"), ("pasto", "Pasto alto"), ("arena", "Arena"), ("agua", "Agua"),
    ("hielo", "Hielo"), ("arboles", "Árboles y plantas"), ("rocas", "Rocas y montaña"), ("edificios", "Edificios"),
    ("puertas", "Puertas y entradas"), ("escaleras", "Escaleras"), ("salientes", "Salientes (saltos)"),
    ("carteles", "Carteles"), ("obstaculos", "Cercas y obstáculos"), ("suelo_especial", "Suelos especiales"),
    ("suelo", "Suelo (interior)"), ("paredes", "Paredes (interior)"), ("muebles", "Muebles y objetos"),
    ("sin_usar", "Sin usar en FireRed"),
]
CATEGORY_TAGS = {
    "terreno": ["suelo"], "pasto": ["suelo", "pasto_alto", "inflamable"], "arena": ["suelo", "arena"],
    "agua": ["agua", "conductor", "congelable"], "hielo": ["suelo", "hielo"], "arboles": ["arbol", "inflamable"],
    "rocas": ["roca"], "edificios": ["edificio"], "puertas": ["puerta"], "escaleras": ["escalera"],
    "salientes": ["saliente"], "carteles": ["cartel"], "obstaculos": [], "suelo_especial": ["suelo"],
    "suelo": ["suelo"], "paredes": ["pared"], "muebles": ["mueble"], "sin_usar": [],
}
WATER = {0x10, 0x11, 0x12, 0x13, 0x15, 0x16, 0x19, 0x1A, 0x1B, 0x22, 0x28, 0x50, 0x51, 0x52, 0x53}
DOOR = 0x69
NUM_METATILES_PRIMARY = 640
MAX_STAMP = (16, 14)


def behavior_category(b):
    if b in WATER:
        return "agua"
    if b == 0x17:
        return "terreno"  # agua poco profunda: se camina
    if b in (0x02, 0xD1):
        return "pasto"
    if b in (0x21, 0x2B):
        return "arena"
    if b in (0x23, 0x26, 0x27):
        return "hielo"
    if b in (0x2A, 0x61, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F):
        return "escaleras"
    if b in (0x60, 0x62, 0x63, 0x64, 0x65, 0x67, 0x69, 0x71):
        return "puertas"
    if 0x38 <= b <= 0x3B:
        return "salientes"
    if b in (0x84, 0x87, 0x88, 0x91, 0x92):
        return "carteles"
    if 0x80 <= b <= 0xA3:
        return "muebles"
    if 0x40 <= b <= 0x58 or b == 0x20:
        return "suelo_especial"
    return None


def snake(name):
    out = ""
    for i, ch in enumerate(name):
        if i and ((ch.isupper() and not name[i - 1].isupper()) or (ch.isdigit() and not name[i - 1].isdigit())):
            out += "_"
        out += ch.lower()
    return out


def place_name(layout_name):
    """'PalletTown_Layout' -> 'Pueblo Paleta', 'Route21_North_Layout' -> 'Ruta 21 Norte'."""
    parts = layout_name.replace("_Layout", "").split("_")
    head = snake(parts[0])
    if head.startswith("route_"):
        txt = "Ruta " + head.split("_")[1]
    else:
        txt = TILESET_NAMES.get(head, " ".join(w.capitalize() for w in head.split("_")))
    extra = {"North": "Norte", "South": "Sur", "East": "Este", "West": "Oeste"}
    return " ".join([txt] + [extra[p] for p in parts[1:] if p in extra])


def parse_headers(root):
    """gTileset_X -> {"name", "secondary", "tiles", "palettes", "metatiles"} (carpetas relativas a root)."""
    hdir = os.path.join(root, "src", "data", "tilesets")
    text = open(os.path.join(hdir, "headers.h")).read()
    gfx = open(os.path.join(hdir, "graphics.h")).read() + open(os.path.join(hdir, "metatiles.h")).read()

    def folder(symbol):
        m = re.search(re.escape(symbol) + r"\b[^=]*=\s*(?:\{\s*)?INC\w+\(\"([^\"]+)\"", gfx)
        if not m:
            return None
        path = os.path.dirname(m.group(1))
        return os.path.dirname(path) if path.endswith("palettes") else path

    out = {}
    for m in re.finditer(r"const struct Tileset (gTileset_\w+) =\s*\{(.*?)\};", text, re.S):
        body = m.group(2)
        field = lambda k: re.search(r"\." + k + r"\s*=\s*(\w+)", body).group(1)
        src = {k: folder(field(k)) for k in ("tiles", "palettes", "metatiles")}
        if src["metatiles"] is None:
            continue
        for k in ("tiles", "palettes"):  # algunos se declaran en otro archivo: misma carpeta que sus metatiles
            src[k] = src[k] or src["metatiles"]
        secondary = re.search(r"isSecondary\s*=\s*(\w+)", body).group(1) == "TRUE"
        out[m.group(1)] = dict(src, name=os.path.basename(src["metatiles"]), secondary=secondary)
    return out


def main():
    root, out_dir = sys.argv[1], sys.argv[2]
    debug_dir = sys.argv[3] if len(sys.argv) > 3 else None
    tiles_dir = os.path.join(out_dir, "tiles")
    headers = parse_headers(root)
    layouts = [l for l in json.load(open(os.path.join(root, "data", "layouts", "layouts.json")))["layouts"] if l]
    # Primario de cada secundario: el que usan sus mapas (los que no usa ningún mapa se saltean).
    pair = {}
    for l in layouts:
        if l.get("secondary_tileset") in headers and l.get("primary_tileset") in headers:
            pair.setdefault(l["secondary_tileset"], collections.Counter())[l["primary_tileset"]] += 1
    by_name = {h["name"]: dict(h, sym=sym) for sym, h in headers.items() if not h["secondary"] or sym in pair}
    skipped = sorted(h["name"] for sym, h in headers.items() if h["secondary"] and sym not in pair)

    # Orden estable (los ids globales de los metatiles dependen de esto): se conserva el del manifest anterior.
    old_path = os.path.join(tiles_dir, "manifest.json")
    old = json.load(open(old_path)) if os.path.exists(old_path) else {}
    names = [n for n in by_name if n != "general"]
    order = [n for n in old.get("order", []) if n in names]
    order += sorted(n for n in names if n not in order)

    manifest = {"order": order}
    built, colors = {}, {}
    for name in ["general"] + order:
        h = by_name[name]
        primary = None
        if h["secondary"]:
            pname = headers[pair[h["sym"]].most_common(1)[0][0]]["name"]
            if pname not in built:
                built[pname] = Tileset(root, pname, by_name[pname])
            primary = built[pname]
        ts = built.get(name) or Tileset(root, name, h, primary)
        built[name] = ts
        below, above, colors[name] = export_tileset(ts, tiles_dir, manifest)
        info = manifest[name]
        k = order.index(name) if name in order else -1
        info["display"] = TILESET_NAMES.get(name, name.replace("_", " ").capitalize())
        info["primary"] = ts.primary.name
        info["group"] = "interior" if ts.primary.name == "building" else "exterior"
        info["base"] = 0 if name == "general" else 1000 * (k + 1)
        info["sources"] = [0, 1, 2] if name == "general" else [3 + 3 * k, 4 + 3 * k, 5 + 3 * k]
        if debug_dir:
            debug_sheet(os.path.join(debug_dir, name + "_debug.png"), below, above, len(ts.metatiles))
        print(name, "metatiles:", len(ts.metatiles), "animados:", len(info["anim"]), "grupo:", info["group"])
    if skipped:
        print("Sin mapas que los usen (no se importan):", skipped)

    catalog = analyze(root, layouts, headers, manifest, colors)
    for pic, pal, out in SPRITES:
        w, h = export_sprite(root, pic, pal, os.path.join(out_dir, out))
        print(out, w, "x", h)
    with open(os.path.join(tiles_dir, "manifest.json"), "w") as f:
        json.dump(manifest, f)
    with open(os.path.join(tiles_dir, "catalog.json"), "w", encoding="utf8") as f:
        json.dump(catalog, f, ensure_ascii=False)


def analyze(root, layouts, headers, manifest, colors):
    """Con los mapas reales de FireRed: colisión habitual de cada metatile, categoría por tipo y sellos de
    edificios (lo sólido pegado a cada puerta). Ids globales: base del tileset + índice local."""
    uses, solid, votes = collections.Counter(), collections.Counter(), collections.Counter()
    components = []  # (lugar, ancho del mapa, {celda: id global}, {celda: behavior}) de cada edificio con puerta
    for l in layouts:
        psym, ssym = l.get("primary_tileset"), l.get("secondary_tileset")
        if psym not in headers or ssym not in headers:
            continue
        pn, sn = headers[psym]["name"], headers[ssym]["name"]
        if pn not in manifest or sn not in manifest:
            continue
        w, h = l["width"], l["height"]
        raw = open(os.path.join(root, l["blockdata_filepath"]), "rb").read()
        vals = struct.unpack("<%dH" % (w * h), raw[:w * h * 2])
        grid = []
        for v in vals:
            mt, col = v & 0x3FF, (v >> 10) & 3
            setn, local = (pn, mt) if mt < NUM_METATILES_PRIMARY else (sn, mt - NUM_METATILES_PRIMARY)
            info = manifest[setn]
            if local >= info["count"] or info["empty"][local]:
                grid.append((-1, col, 0, (0, 0, 0)))
                continue
            g = info["base"] + local
            grid.append((g, col, info["behavior"][local], colors[setn][local]))
            uses[g] += 1
            if col:
                solid[g] += 1
        if manifest[pn]["group"] != "exterior":
            continue
        # Edificios: lo sólido pegado a cada puerta. La vegetación entra solo como borde (no se sigue de ella),
        # así entran las piezas del edificio que tienen pasto de fondo sin arrastrar la arboleda de al lado.
        for i, cell in enumerate(grid):
            if cell[2] != DOOR:
                continue
            seen, stack = {i}, [i]
            while stack and len(seen) <= 1500:
                c = stack.pop()
                cx, cy = c % w, c // w
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = cx + dx, cy + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        n = ny * w + nx
                        g, col, b, rgb = grid[n]
                        if n in seen or g < 0 or not col or b != 0:
                            continue
                        seen.add(n)
                        if not _greenish(rgb):
                            stack.append(n)
            if len(seen) < 4 or len(seen) > 1500:
                continue
            for c in seen:
                votes[grid[c][0]] += 1
            below = {(c % w) + (c // w + 1) * w for c in seen if c // w + 1 < h}
            components.append((place_name(l["name"]), w, {c: grid[c][0] for c in seen},
                               {grid[c][2] for c in seen | below if c < len(grid)}))

    categories, tags, physics = {}, {}, {}
    for name in manifest["order"] + ["general"]:
        info = manifest[name]
        town = name.endswith(("_city", "_town")) or name in ("cinnabar_island", "indigo_plateau")
        for local in range(info["count"]):
            if info["empty"][local]:
                continue
            g = info["base"] + local
            b = info["behavior"][local]
            ratio = solid[g] / uses[g] if uses[g] else 0.0
            rgb = colors[name][local]
            cat = behavior_category(b)
            if cat is None:
                if uses[g] == 0:
                    cat = "sin_usar"
                elif info["group"] == "interior":
                    cat = "paredes" if ratio > 0.5 else "suelo"
                elif ratio > 0.5 and _greenish(rgb) and votes[g] < 0.5 * solid[g]:
                    cat = "arboles"
                elif (votes[g] and votes[g] >= 0.3 * max(1, solid[g])) or (town and ratio > 0.5):
                    cat = "edificios"
                elif ratio > 0.5:
                    cat = "rocas" if _stony(rgb) else "obstaculos"
                else:
                    cat = "terreno"
            phys = -1
            if cat == "agua":
                phys = 1
            elif ratio > 0.5 or cat == "salientes":
                phys = 0
            t = list(CATEGORY_TAGS[cat])
            if phys == 0 and "solido" not in t:
                t.append("solido")
            categories[str(g)] = cat
            physics[str(g)] = phys
            if t:
                tags[str(g)] = t

    # Sellos: cada edificio con solo sus piezas (edificio, puerta, cartel), sin repetidos.
    stamps = {}
    keep = {"edificios", "puertas", "carteles"}
    for place, w, cells, behaviors in components:
        cells = {c: g for c, g in cells.items() if categories.get(str(g)) in keep}
        if len(cells) < 4:
            continue
        xs = [c % w for c in cells]
        ys = [c // w for c in cells]
        x0, y0, x1, y1 = min(xs), min(ys), max(xs), max(ys)
        if x1 - x0 + 1 > MAX_STAMP[0] or y1 - y0 + 1 > MAX_STAMP[1]:
            continue
        flat = [cells.get(y * w + x, -1) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1)]
        st = stamps.setdefault((x1 - x0 + 1, tuple(flat)), {"place": place, "size": [x1 - x0 + 1, y1 - y0 + 1],
                                                             "cells": flat, "maps": 0, "behaviors": set()})
        st["maps"] += 1
        st["behaviors"] |= behaviors

    out_stamps = []
    per_place = collections.Counter()
    for st in sorted(stamps.values(), key=lambda s: (s["place"], -s["maps"])):
        kind = "Centro Pokémon" if 0x87 in st["behaviors"] else ("Tienda Pokémon" if 0x88 in st["behaviors"] else None)
        if kind is None:
            per_place[st["place"]] += 1
            kind = "Edificio %d" % per_place[st["place"]]
        out_stamps.append({"name": kind, "place": st["place"], "size": st["size"], "cells": st["cells"], "maps": st["maps"]})
    print("Categorías:", collections.Counter(categories.values()).most_common())
    print("Sellos de edificios:", len(out_stamps))
    return {"categories": categories, "tags": tags, "physics": physics, "stamps": out_stamps,
            "category_order": [c[0] for c in CATEGORIES], "category_names": dict(CATEGORIES)}


def _greenish(rgb):
    r, g, b = rgb
    return g > r + 12 and g > b + 4


def _stony(rgb):
    r, g, b = rgb
    return max(rgb) - min(rgb) < 60 or r >= g >= b or (b > r and b - r < 110 and g > r)  # gris, marrón o azulado


if __name__ == "__main__":
    main()
