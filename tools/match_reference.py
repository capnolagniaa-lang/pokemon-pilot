"""Cruza las hojas de referencia de FireRed/LeafGreen (The Spriters Resource) con los metatiles importados y
los mapas reales, y genera los datos curados del editor de mapas.

Uso: python -I tools/match_reference.py <carpeta del proyecto> [--report carpeta]

Entradas:
  art_src/referencia/frlg_edificios.png   hoja de edificios (asset 3862)
  art_src/referencia/frlg_tiles_mundo.png  hoja de tiles del mundo (asset 3863)
  art/pret/tiles/*_below|above.png + manifest.json   (de tools/pret_import.py)
  art_src/pret/data/layouts/                         mapas reales de FireRed
  data/world/reference_curation.json                 nombres, grupos y piezas (curado a mano)
Salidas:
  data/world/stamps.json          sellos (edificios y piezas del mundo) con origen en un mapa real
  data/world/palette_layout.json  secciones y orden de la paleta (como en la hoja del mundo)

Las hojas son una grilla de tiles de 16 px con 1 px de separación transparente; el fondo detrás de las piezas
también es transparente, así que cada celda se compara solo en sus píxeles opacos. Los colores se comparan en
los 5 bits por canal de la GBA (la hoja usa valor×8; nuestras paletas, valor×255/31).
Sin dependencias (reusa el lector/escritor de PNG de pret_import.py).
"""
import collections
import json
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pret_import as P  # noqa: E402

PITCH = 17
# Fase de la grilla de cada hoja: (x de la primera columna de píxeles de una celda, y de la primera fila).
SHEETS = {
    "edificios": ("art_src/referencia/frlg_edificios.png", 0, 7),
    "mundo": ("art_src/referencia/frlg_tiles_mundo.png", 1, 1),
}
DOOR_BEHAVIORS = {0x69, 0x60, 0x67, 0x62, 0x63, 0x64, 0x65}
NUM_PRIMARY = 640


def gba5(p):
    """Color a los 5 bits por canal de la GBA (nuestras paletas JASC usan valor×255/31)."""
    return ((p[0] * 31 + 127) // 255, (p[1] * 31 + 127) // 255, (p[2] * 31 + 127) // 255)


# --- Hojas de referencia ----------------------------------------------------------

def load_sheet(path, x0, y0):
    """Celdas de la grilla: {(col, fila): [256 píxeles RGBA o None si transparente]} (solo las que tienen algo)."""
    im = P.read_png(path)
    px, w, h = im["px"], im["w"], im["h"]
    cells = {}
    for row in range((h - y0) // PITCH + 1):
        for col in range((w - x0) // PITCH + 1):
            ox, oy = x0 + col * PITCH, y0 + row * PITCH
            if ox + 16 > w or oy + 16 > h or ox < 0 or oy < 0:
                continue
            data, opaque = [], 0
            for y in range(16):
                r = px[oy + y]
                for x in range(16):
                    p = r[ox + x]
                    if len(p) == 3 or p[3] == 255:
                        data.append((p[0] >> 3, p[1] >> 3, p[2] >> 3))  # la hoja usa valor×8
                        opaque += 1
                    else:
                        data.append(None)
            if opaque:
                cells[(col, row)] = data
    return cells


def components(cells):
    """Piezas de la hoja: grupos de celdas ocupadas conectadas (4 vecinos)."""
    seen, out = set(), []
    for c in sorted(cells, key=lambda k: (k[1], k[0])):
        if c in seen:
            continue
        comp, stack = [], [c]
        seen.add(c)
        while stack:
            cur = stack.pop()
            comp.append(cur)
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (cur[0] + d[0], cur[1] + d[1])
                if n in cells and n not in seen:
                    seen.add(n)
                    stack.append(n)
        xs = [k[0] for k in comp]
        ys = [k[1] for k in comp]
        out.append({"cells": set(comp), "x": min(xs), "y": min(ys), "w": max(xs) - min(xs) + 1, "h": max(ys) - min(ys) + 1})
    return out


# --- Metatiles renderizados ---------------------------------------------------------

class Metatiles:
    """Imagen compuesta (abajo + arriba) de cada metatile importado, indexada para buscar por píxeles."""

    def __init__(self, root):
        tiles = os.path.join(root, "art", "pret", "tiles")
        self.manifest = json.load(open(os.path.join(tiles, "manifest.json")))
        self.order = ["general"] + self.manifest["order"]
        self.img = {}           # id global -> 256 RGB (None = transparente)
        self.frames = {}        # id global -> [imagen de cada cuadro] (uno solo si no es animado)
        self.by_row = collections.defaultdict(list)  # (fila, 16 píxeles) -> ids
        for name in self.order:
            info = self.manifest[name]
            below = P.read_png(os.path.join(tiles, name + "_below.png"))["px"]
            above = P.read_png(os.path.join(tiles, name + "_above.png"))["px"]
            for l in range(info["count"]):
                if info["empty"][l]:
                    continue
                g = info["base"] + l
                ox, oy = (l % 16) * 16, (l // 16) * 16
                data = []
                for y in range(16):
                    for x in range(16):
                        a = above[oy + y][ox + x]
                        b = below[oy + y][ox + x]
                        p = a if a[3] else b
                        data.append(gba5(p) if p[3] else None)
                self.img[g] = data
                self.frames[g] = [data]
                for y in range(16):
                    row = tuple(data[y * 16:y * 16 + 16])
                    if None not in row:
                        self.by_row[(y, row)].append(g)
            # Cuadros de las animaciones (agua, flores): la hoja puede mostrar cualquiera.
            anim_path = os.path.join(tiles, name + "_anim.png")
            if info["anim"] and os.path.exists(anim_path):
                anim = P.read_png(anim_path)["px"]
                for key, a in info["anim"].items():
                    l = int(key)
                    g = info["base"] + l
                    if g not in self.img:
                        continue
                    ox, oy = (l % 16) * 16, (l // 16) * 16
                    for f in range(1, int(a["frames"])):
                        data = []
                        for y in range(16):
                            for x in range(16):
                                ab = above[oy + y][ox + x]
                                b = anim[int(a["row"]) * 16 + y][f * 16 + x]
                                pp = ab if ab[3] else b
                                data.append(gba5(pp) if pp[3] else None)
                        self.frames[g].append(data)
                        for y in range(16):
                            row = tuple(data[y * 16:y * 16 + 16])
                            if None not in row:
                                self.by_row[(y, row)].append(g)

    def matches(self, cell):
        """Metatiles que coinciden con una celda de la referencia en sus píxeles opacos, con tolerancia (hasta 1/6
        de los píxeles distintos: la hoja tiene retoques chicos). Devuelve (menor diferencia, {id: diferencia})."""
        rows = [y for y in range(16) if None not in cell[y * 16:y * 16 + 16]]
        cands = set()
        for y in rows:
            cands.update(self.by_row.get((y, tuple(cell[y * 16:y * 16 + 16])), []))
        if not rows:  # celda casi toda transparente (borde de una pieza): contra todos
            cands = self.img.keys()
        limit = sum(1 for p in cell if p is not None) // 6
        out = {}
        for g in cands:
            for img in self.frames[g]:
                bad = 0
                for i in range(256):
                    if cell[i] is not None and img[i] != cell[i]:
                        bad += 1
                        if bad > limit:
                            break
                if bad <= limit and bad < out.get(g, 999):
                    out[g] = bad
        return (min(out.values()) if out else None), out

    def behavior(self, g):
        name = self.order[g // 1000]
        return self.manifest[name]["behavior"][g % 1000]


# --- Mapas reales -------------------------------------------------------------------

def load_maps(root, meta):
    """Mapas de FireRed: [{"name", "w", "h", "ids": [id global o -1], "col": [bits de colisión]}]."""
    pret = os.path.join(root, "art_src", "pret")
    hdr = P.parse_headers(pret)
    sets = meta.manifest
    out = []
    for l in json.load(open(os.path.join(pret, "data", "layouts", "layouts.json")))["layouts"]:
        if not l or l.get("primary_tileset") not in hdr or l.get("secondary_tileset") not in hdr:
            continue
        pn, sn = hdr[l["primary_tileset"]]["name"], hdr[l["secondary_tileset"]]["name"]
        if pn not in sets or sn not in sets:
            continue
        w, h = l["width"], l["height"]
        raw = open(os.path.join(pret, l["blockdata_filepath"]), "rb").read()
        vals = struct.unpack("<%dH" % (w * h), raw[:w * h * 2])
        ids, col = [], []
        for v in vals:
            mt = v & 0x3FF
            setn, local = (pn, mt) if mt < NUM_PRIMARY else (sn, mt - NUM_PRIMARY)
            info = sets[setn]
            ok = local < info["count"] and not info["empty"][local]
            ids.append(info["base"] + local if ok else -1)
            col.append((v >> 10) & 3)
        out.append({"name": l["name"].replace("_Layout", ""), "w": w, "h": h, "ids": ids, "col": col})
    return out


def map_pairs(maps):
    """Pares de metatiles vecinos en los mapas reales: (izquierda, derecha, "R") y (arriba, abajo, "D")."""
    pairs = set()
    for m in maps:
        w, ids = m["w"], m["ids"]
        for i, g in enumerate(ids):
            if g < 0:
                continue
            if (i + 1) % w and ids[i + 1] >= 0:
                pairs.add((g, ids[i + 1], "R"))
            if i + w < len(ids) and ids[i + w] >= 0:
                pairs.add((g, ids[i + w], "D"))
    return pairs


def segment(cells, cand, pairs):
    """Piezas de la hoja: celdas vecinas de la grilla que también son vecinas así en algún mapa real (las de
    la hoja se tocan, separadas solo por la línea de 1 px). Las celdas sin coincidencia se agrupan entre sí."""
    def linked(a, b, d):
        ca, cb = cand[a], cand[b]
        if not ca or not cb:
            return not ca and not cb
        return any((x, y, d) in pairs for x in ca for y in cb)

    parent = {c: c for c in cells}

    def root(c):
        while parent[c] != c:
            parent[c] = parent[parent[c]]
            c = parent[c]
        return c
    for (x, y) in cells:
        for d, n in (("R", (x + 1, y)), ("D", (x, y + 1))):
            if n in cells and linked((x, y), n, d):
                parent[root(n)] = root((x, y))
    groups = collections.defaultdict(set)
    for c in cells:
        groups[root(c)].add(c)
    out = []
    for comp in groups.values():
        xs = [k[0] for k in comp]
        ys = [k[1] for k in comp]
        out.append({"cells": comp, "x": min(xs), "y": min(ys), "w": max(xs) - min(xs) + 1, "h": max(ys) - min(ys) + 1})
    out.sort(key=lambda p: (p["y"], p["x"]))
    return out


def find_in_maps(piece, cand, maps):
    """Lugares de los mapas donde aparece la pieza: cada celda con un metatile de sus candidatos.
    Devuelve [(mapa, x, y)]."""
    cells = sorted(piece["cells"])
    rel = [(c[0] - piece["x"], c[1] - piece["y"], cand[c]) for c in cells]
    rel.sort(key=lambda r: len(r[2]))  # primero la celda más selectiva
    first = rel[0]
    found = []
    for m in maps:
        w, h, ids = m["w"], m["h"], m["ids"]
        for i, g in enumerate(ids):
            if g not in first[2]:
                continue
            x0, y0 = i % w - first[0], i // w - first[1]
            if x0 < 0 or y0 < 0 or x0 + piece["w"] > w or y0 + piece["h"] > h:
                continue
            if all(ids[(y0 + dy) * w + x0 + dx] in cs for dx, dy, cs in rel):
                found.append((m, x0, y0))
    return found


def occurrence_index(maps):
    """id global -> [(índice del mapa, celda)] de todas sus apariciones."""
    idx = collections.defaultdict(list)
    for mi, m in enumerate(maps):
        for ci, g in enumerate(m["ids"]):
            if g >= 0:
                idx[g].append((mi, ci))
    return idx


def place(piece, cand, maps, index):
    """Mejor ubicación de una pieza de la hoja en los mapas reales: la que más celdas hace coincidir (las celdas
    sin coincidencia en los tiles no cuentan, pero tampoco impiden). Devuelve (coincidencias, celdas con
    candidatos, [(mapa, x, y)])."""
    matched = [c for c in piece["cells"] if cand[c]]
    if not matched:
        return 0, 0, []
    # Anclas: las celdas más raras, pero de filas distintas (si las más raras son justo las retocadas de la
    # hoja, apuntan a cualquier lado; con varias filas alguna cae en el lugar correcto).
    anchors, rows = [], set()
    for c in sorted(matched, key=lambda c: sum(len(index.get(g, ())) for g in cand[c])):
        if c[1] not in rows and sum(len(index.get(g, ())) for g in cand[c]) < 5000:
            anchors.append(c)
            rows.add(c[1])
        if len(anchors) >= 8:
            break
    best, hits, seen = 0, [], set()
    for a in anchors:
        for g in cand[a]:
            for mi, ci in index.get(g, ()):
                m = maps[mi]
                w = m["w"]
                ox, oy = ci % w - (a[0] - piece["x"]), ci // w - (a[1] - piece["y"])
                if (mi, ox, oy) in seen:
                    continue
                seen.add((mi, ox, oy))
                ids, h = m["ids"], m["h"]
                # Puede salirse del mapa (techos o torres que en el juego siguen más allá del borde, como la Torre
                # Pokémon de Lavanda): al menos 1/3 tiene que caer adentro.
                inside = [c for c in piece["cells"] if 0 <= ox + c[0] - piece["x"] < w and 0 <= oy + c[1] - piece["y"] < h]
                if len(inside) * 3 < len(piece["cells"]):
                    continue
                score = sum(1 for c in inside if cand[c] and ids[(oy + c[1] - piece["y"]) * w + ox + c[0] - piece["x"]] in cand[c])
                if score > best:
                    best, hits = score, [(mi, ox, oy)]
                elif score == best:
                    hits.append((mi, ox, oy))
    return best, len(matched), hits


def cell_diff(sheet_cell, img):
    """Píxeles distintos entre una celda de la hoja (solo los opacos) y un metatile renderizado (o la lista de
    cuadros de un metatile animado: el que más se parece)."""
    if img is None:
        return sum(1 for p in sheet_cell if p is not None)
    if isinstance(img, list) and img and isinstance(img[0], list):
        return min(cell_diff(sheet_cell, f) for f in img)
    return sum(1 for i in range(256) if sheet_cell[i] is not None and img[i] != sheet_cell[i])


def locate_pieces(cells, cand, maps, meta, min_ratio=0.5):
    """Segmenta la hoja y ubica cada pieza en un mapa real. Une las piezas vecinas que caen en el mismo mapa con
    el mismo corrimiento (una pieza cortada en la segmentación) y les suma las celdas vecinas sin coincidencia
    exacta cuyo dibujo en ese mapa se parece (hasta 1/3 de píxeles distintos). Devuelve (ubicadas, no ubicadas)."""
    pairs = map_pairs(maps)
    index = occurrence_index(maps)
    pieces = segment(cells, cand, pairs)
    for p in pieces:
        p["score"], p["matched"], p["hits"] = place(p, cand, maps, index)
        p["ok"] = _accept(p, min_ratio)

    def shift(p, h):
        return (h[0], h[1] - p["x"], h[2] - p["y"])

    changed = True
    while changed:
        changed = False
        owner = {}
        for i, p in enumerate(pieces):
            for c in p["cells"]:
                owner[c] = i
        for i, p in enumerate(pieces):
            if not p["ok"]:
                continue
            shifts = {shift(p, h) for h in p["hits"]}
            for c in list(p["cells"]):
                for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    n = (c[0] + d[0], c[1] + d[1])
                    j = owner.get(n)
                    if j is None or j == i:
                        continue
                    q = pieces[j]
                    if q["ok"] and shifts & {shift(q, h) for h in q["hits"]}:
                        merged = _union(p, q)
                    elif not q["ok"] and q["matched"] < 2:
                        # Celdas sueltas o sin coincidencia: entran si en el mapa, en ese lugar, se parecen.
                        mi, sx, sy = next(iter(shifts))
                        m = maps[mi]
                        good = True
                        for k in q["cells"]:
                            x, y = k[0] + sx, k[1] + sy
                            if not (0 <= x < m["w"] and 0 <= y < m["h"]):
                                good = False
                                break
                            g = m["ids"][y * m["w"] + x]
                            if cell_diff(cells[k], meta.frames.get(g)) > sum(1 for px in cells[k] if px is not None) // 3:
                                good = False
                                break
                        if not good:
                            continue
                        merged = _union(p, q)
                    else:
                        continue
                    merged["score"], merged["matched"], merged["hits"] = place(merged, cand, maps, index)
                    merged["ok"] = _accept(merged, min_ratio)
                    if not merged["ok"]:
                        continue
                    pieces = [x for k, x in enumerate(pieces) if k not in (i, j)] + [merged]
                    changed = True
                    break
                if changed:
                    break
            if changed:
                break
    found = [p for p in pieces if p["ok"]]
    lost = [p for p in pieces if not p["ok"]]
    found.sort(key=lambda p: (p["y"], p["x"]))
    lost.sort(key=lambda p: (p["y"], p["x"]))
    return found, lost


def _accept(p, min_ratio):
    """Ubicación aceptada: la mitad de las celdas coinciden, o al menos 12 (un edificio grande que en la hoja
    tiene una parte distinta del juego, como la entrada de la Meseta Añil: se usa la del mapa real)."""
    return p["matched"] >= 2 and (p["score"] >= max(2, min_ratio * p["matched"]) or p["score"] >= 12)


def _union(p, q):
    cells = p["cells"] | q["cells"]
    xs = [k[0] for k in cells]
    ys = [k[1] for k in cells]
    return {"cells": cells, "x": min(xs), "y": min(ys), "w": max(xs) - min(xs) + 1, "h": max(ys) - min(ys) + 1}


def silhouette(piece):
    """Celdas dentro del contorno: las ocupadas más las vacías encerradas (no conectadas con el borde del rect)."""
    w, h = piece["w"], piece["h"]
    occ = {(c[0] - piece["x"], c[1] - piece["y"]) for c in piece["cells"]}
    outside, stack = set(), [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while stack:
        c = stack.pop()
        if c in outside or c in occ or not (0 <= c[0] < w and 0 <= c[1] < h):
            continue
        outside.add(c)
        stack += [(c[0] + 1, c[1]), (c[0] - 1, c[1]), (c[0], c[1] + 1), (c[0], c[1] - 1)]
    return {(x, y) for x in range(w) for y in range(h) if (x, y) not in outside}


# --- Análisis -----------------------------------------------------------------------

def analyze(root):
    meta = Metatiles(root)
    maps = load_maps(root, meta)
    print("metatiles:", len(meta.img), "mapas:", len(maps))
    result = {}
    for key, (path, x0, y0) in SHEETS.items():
        cells = load_sheet(os.path.join(root, path), x0, y0)
        cand, near, diff = {}, {}, {}
        for c, data in cells.items():
            diff[c], near[c] = meta.matches(data)
            cand[c] = set(near[c])
        exact = sum(1 for d in diff.values() if d == 0)
        close = sum(1 for d in diff.values() if d)
        print("[%s] celdas ocupadas: %d, exactas: %d, parecidas: %d, sin coincidencia: %d"
              % (key, len(cells), exact, close, len(cells) - exact - close))
        result[key] = {"cells": cells, "cand": cand, "near": near, "diff": diff}
    return meta, maps, result


# --- Sellos -------------------------------------------------------------------------

def usage(maps):
    """Por metatile: (veces que aparece en los mapas, veces que tiene colisión)."""
    uses, solid = collections.Counter(), collections.Counter()
    for m in maps:
        for g, c in zip(m["ids"], m["col"]):
            if g >= 0:
                uses[g] += 1
                if c:
                    solid[g] += 1
    return uses, solid


def best_id(near, uses):
    return min(near, key=lambda g: (near[g], -uses.get(g, 0), g))


def make_stamp(p, sheet, res, maps, meta, uses, solid):
    """Sello desde una pieza ubicada: el rectángulo de la pieza tomado del mapa real (metatiles y colisión), con
    la silueta rellena. Lo que en la hoja sigue más allá del borde del mapa sale de la coincidencia con la hoja."""
    cells, near = res["cells"], res["near"]
    # La aparición con más celdas adentro del mapa.
    def inside_count(h):
        m = maps[h[0]]
        return sum(1 for c in p["cells"] if 0 <= h[1] + c[0] - p["x"] < m["w"] and 0 <= h[2] + c[1] - p["y"] < m["h"])
    hit = max(p["hits"], key=lambda h: (inside_count(h), -h[0]))
    m, ox, oy = maps[hit[0]], hit[1], hit[2]
    inside = silhouette(p)
    ids, col, doors = [], [], []
    diff = from_sheet = 0
    for ry in range(p["h"]):
        for rx in range(p["w"]):
            sc = (p["x"] + rx, p["y"] + ry)
            if (rx, ry) not in inside:
                ids.append(-1)
                col.append(0)
                continue
            mx, my = ox + rx, oy + ry
            g, c = -1, 0
            if 0 <= mx < m["w"] and 0 <= my < m["h"] and m["ids"][my * m["w"] + mx] >= 0:
                g = m["ids"][my * m["w"] + mx]
                c = 1 if m["col"][my * m["w"] + mx] else 0
            elif near.get(sc):
                g = best_id(near[sc], uses)
                c = 1 if solid[g] * 2 > uses[g] else 0
                from_sheet += 1
            ids.append(g)
            col.append(c)
            if g >= 0 and meta.behavior(g) in DOOR_BEHAVIORS:
                doors.append(len(ids) - 1)
            if g >= 0 and sc in cells:
                diff += cell_diff(cells[sc], meta.frames[g])
    return {"id": "%s_%d_%d" % (m["name"], ox, oy), "map": m["name"], "map_rect": [ox, oy, p["w"], p["h"]],
            "ref": {"sheet": sheet, "rect": [p["x"], p["y"], p["w"], p["h"]]}, "size": [p["w"], p["h"]],
            "cells": ids, "solid": col, "doors": doors, "ref_diff": diff, "from_sheet": from_sheet,
            "maps": len({maps[h[0]]["name"] for h in p["hits"]}), "place": P.place_name(m["name"] + "_Layout")}


def sheet_pixels(st, res):
    """Píxeles (5 bits, sin fondo) de la pieza en la hoja de referencia."""
    cells = res[st["ref"]["sheet"]]["cells"]
    x, y, w, h = st["ref"]["rect"]
    out = []
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            c = cells.get((xx, yy))
            out.extend(c if c else [None] * 256)
    return out


def similarity(a, b, res):
    """(colores consistentes, píxeles iguales) entre dos piezas de la hoja del mismo tamaño: la primera mide si
    una se pasa a la otra con una tabla de colores (mismo dibujo, otro color), en los dos sentidos."""
    if a["size"] != b["size"]:
        return 0.0, 0.0
    pa, pb = sheet_pixels(a, res), sheet_pixels(b, res)
    fwd, bwd = collections.defaultdict(collections.Counter), collections.defaultdict(collections.Counter)
    total = same = other = 0
    for u, v in zip(pa, pb):
        if (u is None) != (v is None):
            other += 1  # píxel de silueta distinta
            continue
        if u is None:
            continue
        fwd[u][v] += 1
        bwd[v][u] += 1
        total += 1
        same += u == v
    if not total or other > 0.03 * total:
        return 0.0, 0.0
    ok = min(sum(c.most_common(1)[0][1] for c in fwd.values()), sum(c.most_common(1)[0][1] for c in bwd.values()))
    return ok / total, same / total


def build(root):
    cur = json.load(open(os.path.join(root, "data", "world", "reference_curation.json"), encoding="utf8"))
    meta, maps, res = analyze(root)
    uses, solid = usage(maps)
    report = {"lost": {}}

    # Edificios
    b = res["edificios"]
    found, lost = locate_pieces(b["cells"], b["cand"], maps, meta)
    report["lost"]["edificios"] = [p for p in lost]
    stamps = [make_stamp(p, "edificios", b, maps, meta, uses, solid) for p in found if len(p["cells"]) >= 4]
    for st in stamps:
        st["group"] = "edificios"

    # Piezas del mundo: en cada sección marcada en la curación, los rectángulos más grandes que aparecen
    # exactos en algún mapa real, sin pisarse (en esa hoja las piezas están pegadas: no se pueden separar por
    # conectividad). El resto de la hoja va a la paleta.
    w = res["mundo"]
    sections = cur["sections"]
    wfound, wlost = locate_pieces(w["cells"], w["cand"], maps, meta)
    report["lost"]["mundo"] = []
    world_ids = {}  # celda de la hoja -> id exacto del mapa (si la pieza se ubicó)
    for p in wfound:
        st = make_stamp(p, "mundo", w, maps, meta, uses, solid)
        for i, g in enumerate(st["cells"]):
            c = (p["x"] + i % p["w"], p["y"] + i // p["w"])
            if c in w["cells"] and g >= 0 and st["ref_diff"] == 0:
                world_ids[c] = g
    index = occurrence_index(maps)
    for sec in sections:
        if sec["name"] not in cur["world_stamps"]:
            continue
        sx, sy, sw, sh = sec["rect"]
        taken = set()
        sizes = sorted({(a, b) for a in range(2, min(8, sw) + 1) for b in range(2, min(8, sh) + 1)}, key=lambda t: -t[0] * t[1])
        for (pw, ph) in sizes:
            for y in range(sy, sy + sh - ph + 1):
                for x in range(sx, sx + sw - pw + 1):
                    rect = {(x + i, y + j) for i in range(pw) for j in range(ph)}
                    if rect & taken:
                        continue
                    occ = {c for c in rect if c in w["cells"]}
                    if len(occ) * 4 < len(rect) * 3 or any(not w["cand"][c] for c in occ):
                        continue
                    piece = {"cells": occ, "x": x, "y": y, "w": pw, "h": ph}
                    score, matched, hits = place(piece, w["cand"], maps, index)
                    if not hits or score < matched:
                        continue
                    piece["hits"] = hits
                    st = make_stamp(piece, "mundo", w, maps, meta, uses, solid)
                    if st["from_sheet"]:
                        continue
                    st["group"] = "mundo"
                    st["section"] = sec["name"]
                    stamps.append(st)
                    taken |= rect
                    for i, g in enumerate(st["cells"]):
                        c = (x + i % pw, y + i // pw)
                        if c in w["cells"] and g >= 0:
                            world_ids[c] = g

    # Sin repetidos: mismas celdas, o el mismo dibujo en la hoja (la hoja repite algunos edificios).
    # Variantes: mismo dibujo con otros colores (97% de colores consistentes).
    stamps.sort(key=lambda s: (s["group"], s["ref"]["rect"][1], s["ref"]["rect"][0]))
    unique = []
    for st in stamps:
        for u in unique:
            if u["group"] == st["group"] and (u["cells"] == st["cells"] or similarity(u, st, res)[1] >= 0.97):
                u["maps"] += st["maps"]
                u.setdefault("duplicates", []).append(st["id"])
                break
        else:
            unique.append(st)
    groups = []
    for st in unique:
        for g in groups:
            if st["group"] == g[0]["group"] and similarity(g[0], st, res)[0] >= 0.97:
                g.append(st)
                break
        else:
            groups.append([st])
    out = []
    for g in groups:
        main = dict(g[0])
        c = cur["stamps"].get(main["id"], {})
        if c.get("skip"):
            continue
        main["name"] = c.get("name", main.get("section", "") if main["group"] == "mundo" else "%s (%s)" % (main["place"], main["id"]))
        main["group"] = c.get("group", "Piezas del mundo" if main["group"] == "mundo" else "Edificios especiales")
        main["place"] = c.get("place", main["place"])
        main["variants"] = [{"name": cur["stamps"].get(v["id"], {}).get("variant", v["place"]), "id": v["id"], "map": v["map"],
                             "map_rect": v["map_rect"], "ref": v["ref"], "cells": v["cells"], "solid": v["solid"],
                             "doors": v["doors"], "ref_diff": v["ref_diff"]} for v in g]
        main["variants"][0]["name"] = c.get("variant", main["variants"][0]["name"])
        out.append(main)

    # Paleta como en la hoja del mundo
    sheet_cells = []
    for c in sorted(w["cells"], key=lambda k: (k[1], k[0])):
        g = world_ids.get(c)
        if g is None and w["near"][c]:
            g = best_id(w["near"][c], uses)
        if g is not None:
            sheet_cells.append([c[0], c[1], g])
    cols = max(c[0] for c in w["cells"]) + 1
    rows = max(c[1] for c in w["cells"]) + 1
    palette = {"size": [cols, rows], "cells": sheet_cells, "sections": sections, "categories": cur["categories"]}
    return out, palette, report, meta, maps, res


def write_outputs(root, stamps, palette):
    def clean(st):
        return {k: v for k, v in st.items() if k not in ("from_sheet",)}
    with open(os.path.join(root, "data", "world", "stamps.json"), "w", encoding="utf8") as f:
        json.dump({"_info": "Generado por tools/match_reference.py (no editar a mano: los nombres van en reference_curation.json).",
                   "stamps": [clean(s) for s in stamps]}, f, ensure_ascii=False, indent=1)
    with open(os.path.join(root, "data", "world", "palette_layout.json"), "w", encoding="utf8") as f:
        json.dump(dict(palette, _info="Generado por tools/match_reference.py: la paleta del editor como en la hoja del mundo."),
                  f, ensure_ascii=False, indent=1)


def enclosed_holes(st):
    """Celdas -1 adentro del contorno (no conectadas con el borde del rectángulo por otras -1)."""
    w, h = st["size"]
    cells = st["cells"]
    seen, stack = set(), [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while stack:
        x, y = stack.pop()
        if (x, y) in seen or not (0 <= x < w and 0 <= y < h) or cells[y * w + x] >= 0:
            continue
        seen.add((x, y))
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return [i for i, g in enumerate(cells) if g < 0 and (i % w, i // w) not in seen]


def check(root):
    """Verifica data/world/stamps.json contra los mapas reales y la referencia. Devuelve la lista de fallas."""
    meta = Metatiles(root)
    maps = {m["name"]: m for m in load_maps(root, meta)}
    stamps = json.load(open(os.path.join(root, "data", "world", "stamps.json"), encoding="utf8"))["stamps"]
    cur = json.load(open(os.path.join(root, "data", "world", "reference_curation.json"), encoding="utf8"))
    fails, keys = [], set()
    for st in stamps:
        for v in st["variants"]:
            vv = dict(v, size=st["size"])
            if enclosed_holes(vv):
                fails.append("%s: celdas vacías adentro del contorno" % v["id"])
            m = maps.get(v["map"])
            ox, oy, w, h = v["map_rect"]
            for i, g in enumerate(v["cells"]):
                x, y = ox + i % w, oy + i // w
                if g < 0 or not m or not (0 <= x < m["w"] and 0 <= y < m["h"]):
                    continue
                if m["ids"][y * m["w"] + x] != g or (1 if m["col"][y * m["w"] + x] else 0) != v["solid"][i]:
                    fails.append("%s: la celda %d no coincide con el mapa %s" % (v["id"], i, v["map"]))
                    break
            key = (tuple(st["size"]), tuple(v["cells"]))
            if key in keys:
                fails.append("%s: sello repetido" % v["id"])
            keys.add(key)
    # Todos los edificios de la referencia que están en los mapas tienen su sello (salvo los descartados a mano).
    stamps2, _, _, _, _, _ = build(root)
    ids = {v["id"] for s in stamps for v in s["variants"]}
    for s in stamps2:
        for v in s["variants"]:
            if v["id"] not in ids and not cur["stamps"].get(v["id"], {}).get("skip"):
                fails.append("%s: está en la referencia y en los mapas pero falta el sello" % v["id"])
    return fails, len(stamps)


if __name__ == "__main__":
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    if "--check" in sys.argv:
        fails, n = check(root)
        for f in fails:
            print("FALLO", f)
        print("[check-stamps] %d sellos -> %s" % (n, "OK" if not fails else "FALLO (%d)" % len(fails)))
        sys.exit(1 if fails else 0)
    stamps, palette, report, meta, maps, res = build(root)
    write_outputs(root, stamps, palette)
    nvar = sum(len(s["variants"]) for s in stamps)
    print("sellos: %d (%d con variantes, %d variantes en total)" % (len(stamps), sum(1 for s in stamps if len(s["variants"]) > 1), nvar))
    print("edificios: %d · piezas del mundo: %d" % (sum(1 for s in stamps if s["group"] != "Piezas del mundo"),
                                                  sum(1 for s in stamps if s["group"] == "Piezas del mundo")))
    holes = [s["id"] for s in stamps for v in s["variants"] for i, g in enumerate(v["cells"]) if g < 0 and False]
    for key, lost in report["lost"].items():
        big = [p for p in lost if len(p["cells"]) > 1]
        print("[%s] sin ubicar en los mapas: %d piezas de varias celdas, %d sueltas" % (key, len(big), len(lost) - len(big)))
        for p in big:
            print("   hoja (%d,%d) %dx%d" % (p["x"], p["y"], p["w"], p["h"]))
    print("celdas de la paleta como en la hoja:", len(palette["cells"]))
