"""Plantillas de encuentros salvajes de FireRed para el editor de mapas ("Copiar de FireRed").

Uso: python -I -B tools/build_encounter_templates.py
Lee art_src/pret/src/data/wild_encounters.json (decomp pret/pokefirered) y escribe
data/world/encounters/plantillas_frlg.json: una plantilla por mapa de FireRed con filas
{especie, peso %, nivel mín/máx, dónde}. Pasto (land_mons) -> "pasto_alto", agua (water_mons) -> "agua";
pesca y rocas rompibles no se usan (el juego todavía no tiene pesca ni encuentros en rocas).
Las especies repetidas en varias casillas se juntan (se suman los % y se amplía el rango de niveles).
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pret_import as P  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "art_src", "pret", "src", "data", "wild_encounters.json")
OUT = os.path.join(ROOT, "data", "world", "encounters", "plantillas_frlg.json")
KINDS = {"land_mons": "pasto_alto", "water_mons": "agua"}
NAMES = {"viridian_forest": "Bosque Verde", "mt_moon": "Monte Moon", "rock_tunnel": "Túnel Roca",
         "safari_zone": "Zona Safari", "seafoam_islands": "Islas Espuma", "victory_road": "Calle Victoria",
         "pokemon_mansion": "Mansión Pokémon", "pokemon_tower": "Torre Pokémon", "power_plant": "Central Eléctrica",
         "digletts_cave": "Cueva Diglett", "cerulean_cave": "Cueva Celeste", "mt_ember": "Monte Ascuas",
         "berry_forest": "Bosque Baya", "icefall_cave": "Cueva Helada", "pattern_bush": "Arbusto Raro",
         "lost_cave": "Cueva Perdida", "altering_cave": "Cueva Mutante", "tanoby_ruins": "Ruinas Tanoby",
         "kindle_road": "Camino Ascuas", "treasure_beach": "Playa Tesoro", "cape_brink": "Cabo Extremo",
         "bond_bridge": "Puente Unión", "three_isle_port": "Puerto Tera", "resort_gorgeous": "Resort Deluxe",
         "water_labyrinth": "Laberinto Acuático", "five_isle_meadow": "Pradera Quinta", "memorial_pillar": "Pilar Memorial",
         "outcast_island": "Isla Paria", "green_path": "Sendero Verde", "water_path": "Senda Acuática",
         "ruin_valley": "Valle Ruinas", "trainer_tower": "Torre Entrenador", "canyon_entrance": "Entrada del Cañón",
         "sevault_canyon": "Cañón Sevault", "meadow": "Pradera Quinta", "port": "Puerto Tera",
         "ssanne_exterior": "S.S. Anne (exterior)"}
FLOORS = {"1f": "1.er piso", "2f": "2.º piso", "3f": "3.er piso", "b1f": "Subsuelo 1", "b2f": "Subsuelo 2",
          "b3f": "Subsuelo 3", "b4f": "Subsuelo 4"}


WORDS = {"entrance": "entrada", "back": "fondo", "room": "sala ", "north": "norte", "south": "sur", "east": "este",
         "west": "oeste", "center": "centro", "summit_path": "sendero de la cumbre", "summit": "cumbre",
         "ruby_path": "sendero rubí", "stairs": "escaleras", "chamber": "cámara", "exterior": "exterior"}


def _floor(token):
    m = re.fullmatch(r"(b?)(\d+)f", token)
    if not m:
        return None
    n = int(m.group(2))
    return "Subsuelo %d" % n if m.group(1) else "%d.%s piso" % (n, "er" if n in (1, 3) else "º")


def _words(text):
    out = []
    for tok in text.split("_"):
        f = _floor(tok)
        out.append(f if f else tok)
    text = " ".join(out)
    for en, es in sorted(WORDS.items(), key=lambda kv: -len(kv[0])):
        text = text.replace(en.replace("_", " "), es)
    return re.sub(r"\s+", " ", text).strip()


def map_name(map_const):
    """MAP_ROUTE1 -> 'Ruta 1'; MAP_MT_MOON_B1F -> 'Monte Moon · Subsuelo 1'."""
    key = map_const.replace("MAP_", "").lower()
    if key.startswith("route"):
        num, _, rest = key[5:].partition("_")
        return "Ruta " + num + (" " + _words(rest) if rest else "")
    for island, label in (("one_island_", "Isla Prima"), ("two_island_", "Isla Secunda"), ("three_island_", "Isla Tera"),
                          ("four_island_", "Isla Cuarta"), ("five_island_", "Isla Quinta"), ("six_island_", "Isla Sexta"),
                          ("seven_island_", "Isla Séptima")):
        if key.startswith(island):
            key = key[len(island):]
            break
    if key in NAMES:
        return NAMES[key]
    for k in sorted(NAMES, key=len, reverse=True):
        if key.startswith(k + "_"):
            return NAMES[k] + " · " + _words(key[len(k) + 1:])
    return P.TILESET_NAMES.get(key) or _words(key).capitalize()


def _sort_key(t):
    m = re.match(r"Ruta (\d+)", t["name"])
    return ("Ruta", int(m.group(1)), t["name"]) if m else (t["name"], 0, t["id"])


def main():
    data = json.load(open(SRC, encoding="utf8"))
    groups = data["wild_encounter_groups"]
    rates = {f["type"]: f.get("encounter_rates", []) for f in groups[0]["fields"]}
    out = []
    for e in groups[0]["encounters"]:
        if not e["base_label"].endswith("_FireRed"):
            continue
        rows = {}
        for kind, where in KINDS.items():
            if kind not in e:
                continue
            for slot, mon in enumerate(e[kind]["mons"]):
                sp = mon["species"].replace("SPECIES_", "").lower()
                key = (sp, where)
                r = rows.setdefault(key, {"species": sp, "weight": 0, "min_level": mon["min_level"],
                                          "max_level": mon["max_level"], "where": where})
                r["weight"] += rates[kind][slot]
                r["min_level"] = min(r["min_level"], mon["min_level"])
                r["max_level"] = max(r["max_level"], mon["max_level"])
        if rows:
            ordered = sorted(rows.values(), key=lambda r: (r["where"] != "pasto_alto", -r["weight"]))
            out.append({"id": e["map"].replace("MAP_", "").lower(), "name": map_name(e["map"]), "rows": ordered})
    out.sort(key=_sort_key)
    seen = {}
    for t in out:  # nombres repetidos (la Cueva Mutante tiene 9 variantes): se numeran
        seen[t["name"]] = seen.get(t["name"], 0) + 1
    count = {}
    for t in out:
        if seen[t["name"]] > 1:
            count[t["name"]] = count.get(t["name"], 0) + 1
            t["name"] = "%s %d" % (t["name"], count[t["name"]])
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf8", newline="\n") as f:
        json.dump({"_info": "Generado por tools/build_encounter_templates.py desde pret/pokefirered (FireRed).",
                   "templates": out}, f, ensure_ascii=False, indent=1)
    print("plantillas:", len(out))


if __name__ == "__main__":
    main()
