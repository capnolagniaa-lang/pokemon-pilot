"""Ventanas de los edificios de FireRed, para prenderlas de noche (docs/PLAN_DIA_NOCHE.md parte C).

Uso:  python -I -B tools/find_windows.py <proyecto> [--debug <carpeta>]

Arma cada mapa exterior de art_src/pret (data/layouts) con los atlas importados (art/pret/tiles) y busca los vidrios:
manchas celestes chicas y más o menos rectangulares sobre celdas sólidas de edificios (el techo celeste de la Tienda
es una mancha enorme y no entra). Junta lo que encuentra por metatile (un píxel queda prendido si se prendió en al
menos la mitad de las veces que aparece ese metatile en un edificio) y lo guarda en data/world/night_windows.json:
    {"windows": {"<id global>": [16 filas, cada una una máscara de 16 bits (bit x = píxel x)]}, "paths": [ids]}
Además junta los metatiles de camino (para los faroles, StreetLamps): suelo transitable que no es verde (tierra,
arena, baldosas, el suelo claro de los pueblos), sin pasto alto, agua, flores ni árboles; las categorías del catálogo
no alcanzan (en Paleta y Azulona los caminos figuran como "suelos").
No toca zonas ni el TileSet: ZoneLights (scripts/world/zone_lights.gd) lee el JSON al cargar cada zona.
--debug guarda <carpeta>/<mapa>.png con lo prendido pintado de amarillo, para revisar.
"""
import collections
import importlib.util
import json
import os
import struct
import sys

from PIL import Image

T = 16
MIN_W, MAX_W = 5, 40
MIN_H, MAX_H = 4, 14
MAX_PIXELS = 320
MIN_FILL = 0.45
VOTE = 0.5
NOT_PATH_CATS = {"flores", "arboles", "otros_arboles", "salientes", "otros_salientes", "agua", "otros_agua", "cercas",
                 "escaleras", "otros_escaleras", "carteles", "otros_carteles", "edificios", "otros_edificios"}
MERGE_GAP = 3
# Celeste que no es vidrio (revisado con --debug): el logo de la Tienda Pokémon.
NOT_WINDOWS = {57, 58}


def load_pret_import(project):
    spec = importlib.util.spec_from_file_location("pret_import", os.path.join(project, "tools", "pret_import.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def is_glass(p):
    r, g, b = p[0], p[1], p[2]
    return b >= 150 and b - r >= 45 and b - g >= 10


def is_green(tile):
    """¿El metatile es pasto? Promedio verde y saturado (el suelo claro de Paleta es verdoso pero apagado)."""
    r, g, b = [sum(c) / len(c) for c in zip(*[p[:3] for p in tile.get_flattened_data()])]
    return g > r + 12 and g > b + 4 and max(r, g, b) - min(r, g, b) > 65


def is_bright(p):
    return 0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2] >= 170


class Atlas:
    def __init__(self, tiles_dir, manifest):
        self.dir, self.manifest, self.cache, self.tiles = tiles_dir, manifest, {}, {}

    def _sheet(self, name, part):
        key = (name, part)
        if key not in self.cache:
            path = os.path.join(self.dir, "%s_%s.png" % (name, part))
            self.cache[key] = Image.open(path).convert("RGBA") if os.path.exists(path) else None
        return self.cache[key]

    def tile(self, g):
        if g not in self.tiles:
            k = g // 1000
            name = "general" if k == 0 else self.manifest["order"][k - 1]
            local = g % 1000
            im = Image.new("RGBA", (T, T), (0, 0, 0, 255))
            for part in ("below", "above"):
                sheet = self._sheet(name, part)
                x, y = (local % 16) * T, (local // 16) * T
                if sheet is not None and y + T <= sheet.height:
                    im.alpha_composite(sheet.crop((x, y, x + T, y + T)))
            self.tiles[g] = im
        return self.tiles[g]


def blobs(img, allowed):
    """Manchas de vidrio (4-vecinos) dentro de las celdas permitidas: listas de (x, y)."""
    w, h = img.size
    px = img.load()
    seen = bytearray(w * h)
    out = []
    for cy, cx in allowed:
        for y in range(cy * T, cy * T + T):
            for x in range(cx * T, cx * T + T):
                i = y * w + x
                if seen[i] or not is_glass(px[x, y]):
                    continue
                seen[i] = 1
                stack, blob = [(x, y)], []
                while stack:
                    bx, by = stack.pop()
                    blob.append((bx, by))
                    if len(blob) > MAX_PIXELS * 4:
                        break
                    for nx, ny in ((bx + 1, by), (bx - 1, by), (bx, by + 1), (bx, by - 1)):
                        if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx] \
                                and (ny // T, nx // T) in allowed and is_glass(px[nx, ny]):
                            seen[ny * w + nx] = 1
                            stack.append((nx, ny))
                out.append(blob)
    return out


def merge_panes(blobs_list):
    """Junta los paños de una misma ventana (vidrios separados por marcos finos, como en Carmín): manchas chicas cuyos
    rectángulos se tocan o están a MERGE_GAP píxeles. Las grandes (techos) quedan como están."""
    boxes = []
    for b in blobs_list:
        xs = [p[0] for p in b]
        ys = [p[1] for p in b]
        boxes.append((min(xs), min(ys), max(xs), max(ys)))
    parent = list(range(len(blobs_list)))

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    small = [i for i, b in enumerate(blobs_list) if len(b) <= MAX_PIXELS]
    for a_i, i in enumerate(small):
        ax0, ay0, ax1, ay1 = boxes[i]
        for j in small[a_i + 1:]:
            bx0, by0, bx1, by1 = boxes[j]
            if bx0 - ax1 <= MERGE_GAP and ax0 - bx1 <= MERGE_GAP and by0 - ay1 <= MERGE_GAP and ay0 - by1 <= MERGE_GAP:
                parent[find(i)] = find(j)
    groups = collections.defaultdict(list)
    for i, b in enumerate(blobs_list):
        groups[find(i)].extend(b)
    return list(groups.values())


def window_pixels(img, blob):
    """Los píxeles de una ventana (rectángulo de la mancha: vidrio y brillos), o [] si no parece una ventana."""
    if len(blob) > MAX_PIXELS:
        return []
    xs = [p[0] for p in blob]
    ys = [p[1] for p in blob]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    bw, bh = x1 - x0 + 1, y1 - y0 + 1
    if not (MIN_W <= bw <= MAX_W and MIN_H <= bh <= MAX_H) or len(blob) < MIN_FILL * bw * bh * 0.5:
        return []
    px = img.load()
    out = []
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if is_glass(px[x, y]) or is_bright(px[x, y]):
                out.append((x, y))
    return out if len(out) >= MIN_FILL * bw * bh else []


def main():
    project = sys.argv[1]
    debug = sys.argv[sys.argv.index("--debug") + 1] if "--debug" in sys.argv else None
    pi = load_pret_import(project)
    root = os.path.join(project, "art_src", "pret")
    tiles_dir = os.path.join(project, "art", "pret", "tiles")
    manifest = json.load(open(os.path.join(tiles_dir, "manifest.json")))
    catalog = json.load(open(os.path.join(tiles_dir, "catalog.json"), encoding="utf8"))
    building_cats = {"edificios", "otros_edificios"}
    headers = pi.parse_headers(root)
    layouts = [l for l in json.load(open(os.path.join(root, "data", "layouts", "layouts.json")))["layouts"] if l]
    atlas = Atlas(tiles_dir, manifest)
    uses = collections.Counter()
    lit = collections.defaultdict(collections.Counter)  # id global -> {(x, y): veces prendido}
    ground_uses, walk_uses = collections.Counter(), collections.Counter()
    for l in layouts:
        psym, ssym = l.get("primary_tileset"), l.get("secondary_tileset")
        if psym not in headers or ssym not in headers:
            continue
        pn, sn = headers[psym]["name"], headers[ssym]["name"]
        if pn not in manifest or sn not in manifest or manifest[sn]["group"] != "exterior":
            continue
        w, h = l["width"], l["height"]
        raw = open(os.path.join(root, l["blockdata_filepath"]), "rb").read()
        vals = struct.unpack("<%dH" % (w * h), raw[:w * h * 2])
        grid = {}
        img = Image.new("RGBA", (w * T, h * T), (0, 0, 0, 255))
        allowed = set()
        for i, v in enumerate(vals):
            mt, col = v & 0x3FF, (v >> 10) & 3
            setn, local = (pn, mt) if mt < pi.NUM_METATILES_PRIMARY else (sn, mt - pi.NUM_METATILES_PRIMARY)
            info = manifest[setn]
            if local >= info["count"] or info["empty"][local]:
                continue
            g = info["base"] + local
            cx, cy = i % w, i // w
            grid[(cy, cx)] = g
            img.alpha_composite(atlas.tile(g), (cx * T, cy * T))
            ground_uses[g] += 1
            if not col:
                walk_uses[g] += 1
            if col and catalog["categories"].get(str(g)) in building_cats:
                allowed.add((cy, cx))
                uses[g] += 1
        found = set()
        for blob in merge_panes(blobs(img, allowed)):
            found.update(window_pixels(img, blob))
        per_cell = collections.defaultdict(set)
        for x, y in found:
            per_cell[(y // T, x // T)].add((x % T, y % T))
        for cell, pixels in per_cell.items():
            for p in pixels:
                lit[grid[cell]][p] += 1
        if debug and found:
            os.makedirs(debug, exist_ok=True)
            px = img.load()
            for x, y in found:
                px[x, y] = (255, 0, 255, 255)  # magenta: se distingue de las paredes amarillas
            img.save(os.path.join(debug, l["name"].replace("_Layout", "") + ".png"))
    windows = {}
    for g, counts in sorted(lit.items()):
        rows = [0] * T
        for (x, y), n in counts.items():
            if n >= VOTE * uses[g]:
                rows[y] |= 1 << x
        if any(rows) and g not in NOT_WINDOWS:
            windows[str(g)] = rows
    paths = []
    for g, n in sorted(ground_uses.items()):
        tags = catalog["tags"].get(str(g), [])
        if walk_uses[g] < 0.8 * n or "pasto_alto" in tags or "agua" in tags or "puerta" in tags                 or catalog["categories"].get(str(g)) in NOT_PATH_CATS:
            continue
        if not is_green(atlas.tile(g)):
            paths.append(g)
    out = os.path.join(project, "data", "world", "night_windows.json")
    with open(out, "w", encoding="utf8") as f:
        json.dump({"_info": "Generado por tools/find_windows.py: vidrios de cada metatile (16 filas de 16 bits).",
                   "windows": windows, "paths": paths}, f)
    print("metatiles con ventana:", len(windows), "- de camino:", len(paths), "->", out)


if __name__ == "__main__":
    main()
