"""Tablas de pesca (pedido del usuario 2026-11-06): lo que se pesca en cada zona con cada caña, de FireRed
(art_src/pret/src/data/wild_encounters.json, `fishing_mons`) → data/world/pesca.json. Los puntos de pesca salen aparte:
`--autotest-fishing --generate-spots` los elige sobre el mapa de verdad (data/world/pesca_puntos.json).

Uso: python -I -B tools/build_fishing.py .
"""
import json
import os
import sys


def main(root):
    wild = json.load(open(os.path.join(root, "art_src/pret/src/data/wild_encounters.json"), encoding="utf8"))
    group = wild["wild_encounter_groups"][0]
    field = next(f for f in group["fields"] if f["type"] == "fishing_mons")
    rates = field["encounter_rates"]
    rods = {"vieja": field["groups"]["old_rod"], "buena": field["groups"]["good_rod"], "super": field["groups"]["super_rod"]}
    maps = json.load(open(os.path.join(root, "data/world/frlg_maps.json"), encoding="utf8"))["zones"]
    by_const = {z["map"].upper().replace("_", ""): z["id"] for z in maps}
    tables = {}
    for e in group["encounters"]:
        zone = by_const.get(e["map"].replace("MAP_", "").replace("_", ""))
        if zone is None or "fishing_mons" not in e or "FireRed" not in e["base_label"]:
            continue
        table = {}
        for rod, slots in rods.items():
            rows = {}
            for i in slots:
                mon = e["fishing_mons"]["mons"][i]
                sp = mon["species"].replace("SPECIES_", "").lower()
                row = rows.setdefault(sp, {"species": sp, "pct": 0, "min": mon["min_level"], "max": mon["max_level"]})
                row["pct"] += rates[i]
                row["min"] = min(row["min"], mon["min_level"])
                row["max"] = max(row["max"], mon["max_level"])
            table[rod] = sorted(rows.values(), key=lambda r: -r["pct"])
        tables[zone] = table
    with open(os.path.join(root, "data/world/pesca.json"), "w", encoding="utf8", newline="\n") as f:
        json.dump(tables, f, ensure_ascii=False, indent=1)
    print(len(tables), "zonas:", ", ".join(sorted(tables)))


if __name__ == "__main__":
    main(sys.argv[1])
