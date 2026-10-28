"""Junta varias corridas de la batería de balance (`--autotest-balance`, una por semilla y por modo, se pueden correr en
paralelo) y escribe docs/BALANCE_RESUMEN.md: % de victorias de cada especie con lo que trae y con los 4 mejores ataques
que aprende (nivel + MT), con su margen de error y cuán parejo queda todo, y lo mismo por tipo.

Cada corrida deja user://balance/peleas_<juego|mejores>_<semilla>.csv (y su informe .md, de donde salen los juegos de
ataques de "mejores"). Ejemplo (en paralelo, una por núcleo):
  godot --headless --path . --fixed-fps 60 --quit-after 90000000 -- --autotest-balance --fights 1500 --seed 11 --out user://balance/juego_11.md
  godot ... --seed 21 --equip mejores --out user://balance/mejores_21.md
  python -I -B tools/balance_merge.py <carpeta del proyecto> [carpeta de user://balance] [nombre del .md en docs/]
"""
import csv
import glob
import math
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")


def species_info(root):
    info = {}
    for p in glob.glob(os.path.join(root, "data", "species", "*.tres")):
        s = open(p, encoding="utf-8").read()
        sid = os.path.basename(p)[:-5]
        name = re.search(r'^display_name = "(.*)"$', s, re.M).group(1)
        types = []
        for t in re.findall(r'path="res://data/types/(\w+)\.tres" id="([^"]+)"', s):
            types.append(t)
        tarr = re.search(r"^types = Array\[[^\]]+\]\(\[(.*?)\]\)", s, re.M)
        ids = re.findall(r'ExtResource\("([^"]+)"\)', tarr.group(1)) if tarr else []
        type_names = [t for t, i in types if i in ids]
        bst = sum(int(re.search(r"^base_%s = (\d+)" % k, s, re.M).group(1)) if re.search(r"^base_%s = (\d+)" % k, s, re.M)
                  else 50 for k in ("hp", "attack", "defense", "sp_attack", "sp_defense", "speed"))
        kit = re.search(r'path="res://data/kits/(\w+)/kit.tres"', s)
        arch = ""
        if kit:
            k = open(os.path.join(root, "data", "kits", kit.group(1), "kit.tres"), encoding="utf-8").read()
            arch = re.search(r'archetype = "(\w+)"', k).group(1)
        abil = re.findall(r'path="res://data/abilities/(\w+)\.tres"', s)
        info[sid] = dict(name=name, types=type_names, bst=bst, arch=arch,
                         abilities="/".join(x.replace("_", " ").capitalize() for x in abil))
    return info


def load(folder, mode):
    stats = {}
    n = 0
    for p in sorted(glob.glob(os.path.join(folder, "peleas_%s_*.csv" % mode))):
        for row in csv.DictReader(open(p, encoding="utf-8")):
            n += 1
            for side in ("a", "b"):
                d = stats.setdefault(row[side], [0, 0])
                d[0] += 1
                d[1] += 1 if row["ganador"] == row[side] else 0
    return stats, n


def sets_from_reports(folder):
    out = {}
    for p in glob.glob(os.path.join(folder, "mejores_*.md")):
        for line in open(p, encoding="utf-8"):
            c = [x.strip() for x in line.split("|")]
            if len(c) > 13 and c[6].endswith("%") and c[12]:
                out[c[1].replace(" ⬆", "").replace(" ⬇", "")] = c[12]
    return out


def pct(d):
    return 100.0 * d[1] / d[0] if d and d[0] else float("nan")


def err(d):
    if not d or not d[0]:
        return 0.0
    p = d[1] / d[0]
    return 196.0 * math.sqrt(p * (1 - p) / d[0])


MODES = {"juego": "Con lo que trae", "mejores": "Con los mejores", "kit": "Con el kit (viejo)"}


def spread(stats):
    """Desvío de los % de victorias entre especies (cuanto más chico, más parejo)."""
    xs = [pct(d) for d in stats.values() if d[0] >= 10]
    if len(xs) < 2:
        return float("nan")
    m = sum(xs) / len(xs)
    return math.sqrt(sum((x - m) ** 2 for x in xs) / len(xs))


def main():
    root = sys.argv[1]
    folder = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.environ["APPDATA"], "Godot", "app_userdata", "Pokémon Pilot", "balance")
    out_name = sys.argv[3] if len(sys.argv) > 3 else "BALANCE_RESUMEN.md"
    info = species_info(root)
    data = {}
    for mode in MODES:
        st, n = load(folder, mode)
        if n:
            data[mode] = (st, n)
    modes = list(data)
    sets = sets_from_reports(folder)
    L = ["# Resumen de balance", "",
         "> **Generado** por `tools/balance_merge.py` juntando corridas de `--autotest-balance` (IA contra IA en Difícil,",
         "> nivel 40, emparejados por stats base, cada pareja dos veces cambiando de lado). ± = margen de error (95%).", ""]
    for mode in modes:
        L.append("- **%s**: %d peleas · desvío entre especies %.1f puntos (cuanto más chico, más parejo)." % (
            MODES[mode], data[mode][1], spread(data[mode][0])))
    L += ["", "Con lo que trae = los últimos 4 ataques por nivel (como en los juegos). Con los mejores = los 4 que más daño",
          "estiman de todo lo que aprende por nivel o por MT. ⬆ = 65% o más, ⬇ = 35% o menos.", "",
          "## Por especie", "",
          "| Pokémon | Habilidades | Stats | " + " | ".join("%s | ±" % MODES[m] for m in modes) + " | Mejores ataques |",
          "|---|---|---|" + "---|---|" * len(modes) + "---|"]
    first = data[modes[0]][0]
    ids = sorted(set().union(*[set(data[m][0]) for m in modes]), key=lambda i: -pct(first.get(i)))
    for sid in ids:
        sp = info.get(sid, dict(name=sid, types=[], bst=0, abilities=""))
        d0 = first.get(sid)
        flag = (" ⬆" if pct(d0) >= 65 else (" ⬇" if pct(d0) <= 35 else "")) if d0 and d0[0] >= 10 else ""
        cols = []
        for m in modes:
            d = data[m][0].get(sid)
            cols.append("%.0f%% (%d) | %.0f" % (pct(d), d[0], err(d)) if d else "— | ")
        L.append("| %s%s | %s | %d | %s | %s |" % (sp["name"], flag, sp.get("abilities", ""), sp["bst"], " | ".join(cols),
                                               sets.get(sp["name"], "")))
    L.append("")
    L += ["## Por tipo", "", "| | " + " | ".join(MODES[m] for m in modes) + " |", "|---|" + "---|" * len(modes)]
    g = {}
    for i, m in enumerate(modes):
        for sid, d in data[m][0].items():
            for key in info.get(sid, dict(types=[]))["types"]:
                e = g.setdefault(key, [[0, 0] for _ in modes])
                e[i][0] += d[0]
                e[i][1] += d[1]
    for key in sorted(g, key=lambda x: -pct(g[x][0])):
        L.append("| %s | %s |" % (key.capitalize(), " | ".join("%.0f%%" % pct(e) for e in g[key])))
    L.append("")
    out = os.path.join(root, "docs", out_name)
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(L) + "\n")
    print("listo: %s (%s)" % (out, ", ".join("%s %d" % (m, data[m][1]) for m in modes)))


if __name__ == "__main__":
    main()
