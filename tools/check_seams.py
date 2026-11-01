"""Revisa los empalmes entre las zonas exteriores de data/world/frlg_maps.json (docs/EMPALMES.md).

Uso:  python -I -B tools/check_seams.py <proyecto> [--png <carpeta>]

Imprime, por cada borde compartido entre dos zonas: cuántas celdas se cruzan caminando, los tramos caminables de un
lado que dan contra algo sólido del otro (un camino cortado o corrido) y cuántas celdas de agua no siguen del otro lado.
Avisa también las conexiones de FireRed (map.json) entre dos zonas que no se tocan. Las uniones por garita (Azafrán,
Meseta Añil) se cruzan por puertas: ahí 0 pasos es lo esperado.
Con --png dibuja cada empalme (las dos zonas y la línea del borde en rojo) en <carpeta>/<zona>__<zona>.png
(necesita Pillow).
"""
import json
import os
import sys


def main():
    root = sys.argv[1]
    png = sys.argv[sys.argv.index("--png") + 1] if "--png" in sys.argv else None
    d = json.load(open(os.path.join(root, "data", "world", "frlg_maps.json"), encoding="utf8"))
    cat = json.load(open(os.path.join(root, "art", "pret", "tiles", "catalog.json"), encoding="utf8"))
    phys = cat["physics"]
    zones = [z for z in d["zones"] if z["kind"] == "exterior"]
    grid = {}
    for z in zones:
        ox, oy = z["origin"]
        w, h = z["size"]
        for y in range(h):
            for x in range(w):
                grid[(ox + x, oy + y)] = (z, y * w + x)

    def walk(z, i):
        return z["col"][i] == 0 and phys.get(str(z["cells"][i])) != 1

    def water(z, i):
        return phys.get(str(z["cells"][i])) == 1

    def runs(flags):
        out, s = [], None
        for k, f in enumerate(flags + [False]):
            if f and s is None:
                s = k
            elif not f and s is not None:
                out.append((s, k - 1))
                s = None
        return out

    seams = {}
    for (x, y), (z, i) in grid.items():
        for dx, dy in ((1, 0), (0, 1)):
            o = grid.get((x + dx, y + dy))
            if o is None or o[0] is z:
                continue
            seams.setdefault((z["id"], o[0]["id"], dx), []).append((y if dx else x, z, i, o[0], o[1], (x, y)))
    for (a, b, vert), edges in sorted(seams.items()):
        edges.sort(key=lambda e: e[0])
        base, n = edges[0][0], edges[-1][0] - edges[0][0] + 1
        wa, wb, aa, ab, pos = [False] * n, [False] * n, [False] * n, [False] * n, {}
        for along, z, i, o, j, xy in edges:
            k = along - base
            wa[k], wb[k], aa[k], ab[k], pos[k] = walk(z, i), walk(o, j), water(z, i), water(o, j), xy
        print("%s | %s (%s) largo %d, pasos %d, agua que no sigue %d" % (
            a, b, "vertical" if vert else "horizontal", n, sum(1 for k in range(n) if wa[k] and wb[k]),
            sum(1 for k in range(n) if aa[k] != ab[k])))
        for side, ra, other in (("lado de " + a, runs(wa), wb), ("lado de " + b, runs(wb), wa)):
            for s, e in ra:
                touch = sum(1 for k in range(s, e + 1) if other[k])
                if e > s and touch < e - s + 1:
                    print("  %s: tramo de %d celdas en %s, %d siguen del otro lado" % (side, e - s + 1, pos[s], touch))

    # Conexiones de FireRed entre zonas que no se tocan.
    by_map = {z["map"]: z for z in zones}
    for z in zones:
        path = os.path.join(root, "art_src", "pret", "data", "maps", z["map"], "map.json")
        if not os.path.exists(path):
            continue
        for c in json.load(open(path, encoding="utf8")).get("connections") or []:
            const = c["map"][len("MAP_"):].replace("_", "")
            o = next((q for q in zones if q["map"].upper().replace("_", "") == const), None)
            if o is None:
                continue
            ax0, ay0 = z["origin"]
            bx0, by0 = o["origin"]
            ax1, ay1 = ax0 + z["size"][0], ay0 + z["size"][1]
            bx1, by1 = bx0 + o["size"][0], by0 + o["size"][1]
            side = (ax1 == bx0 or bx1 == ax0) and min(ay1, by1) > max(ay0, by0)
            top = (ay1 == by0 or by1 == ay0) and min(ax1, bx1) > max(ax0, bx0)
            if not side and not top:
                print("NO SE TOCAN: %s (%s) y %s" % (z["id"], c["direction"], o["id"]))

    if png:
        _draw(root, png, grid, seams)


def _draw(root, out, grid, seams, margin=12):
    from PIL import Image, ImageDraw
    sys.path.insert(0, os.path.join(root, "tools"))
    import find_windows as fw
    t = fw.T
    tiles = os.path.join(root, "art", "pret", "tiles")
    atlas = fw.Atlas(tiles, json.load(open(os.path.join(tiles, "manifest.json"), encoding="utf8")))
    os.makedirs(out, exist_ok=True)
    for (a, b, vert), edges in seams.items():
        cells = [e[5] for e in edges]
        xs, ys = [c[0] for c in cells], [c[1] for c in cells]
        x0, x1, y0, y1 = min(xs) - margin, max(xs) + margin + 1, min(ys) - margin, max(ys) + margin + 1
        img = Image.new("RGBA", ((x1 - x0) * t, (y1 - y0) * t), (0, 0, 0, 255))
        for y in range(y0, y1):
            for x in range(x0, x1):
                g = grid.get((x, y))
                if g and g[0]["cells"][g[1]] >= 0:
                    img.alpha_composite(atlas.tile(g[0]["cells"][g[1]]), ((x - x0) * t, (y - y0) * t))
        dr = ImageDraw.Draw(img)
        for x, y in cells:
            if vert:
                dr.line(((x - x0 + 1) * t, (y - y0) * t, (x - x0 + 1) * t, (y - y0 + 1) * t), fill=(255, 0, 0, 255))
            else:
                dr.line(((x - x0) * t, (y - y0 + 1) * t, (x - x0 + 1) * t, (y - y0 + 1) * t), fill=(255, 0, 0, 255))
        img.convert("RGB").save(os.path.join(out, "%s__%s.png" % (a, b)))


if __name__ == "__main__":
    main()
