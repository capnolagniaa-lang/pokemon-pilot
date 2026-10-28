"""Baja de PokeAPI los datos oficiales de las especies y ataques del juego y los guarda en
data/source/official.json (fuente de verdad para tools/apply_official_data.gd y tools/build_learnsets.gd).

Especies: las 386 de las 3 primeras regiones (Kanto, Johto y Hoenn). Ataques: los de MOVES (hechos a mano)
más todos los que esas especies aprenden por nivel en FireRed/LeafGreen (Esmeralda si FRLG no lo tiene) y, desde
2026-10-28, los de **MT/MO** de FRLG (`mt_frlg` / `mt` por especie: qué máquinas puede aprender). Los ataques que solo
salen por MT se agregan después de los demás, así los ids de los que ya existían no cambian.

Uso: python -I tools/fetch_official_data.py <carpeta del proyecto>
Las respuestas quedan en tools/.pokeapi_cache (no se versiona): volver a correrlo no vuelve a bajar nada.
"""
import json
import os
import re
import sys
import time
import unicodedata
import urllib.request
from concurrent.futures import ThreadPoolExecutor

API = "https://pokeapi.co/api/v2"
MAX_DEX = 386
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".pokeapi_cache")

# Especies hechas a mano antes (id del juego -> id de PokeAPI). Las demás usan el nombre de PokeAPI.
SPECIES = {
    "bulbasaur": "bulbasaur", "charmander": "charmander", "squirtle": "squirtle", "pidgey": "pidgey",
    "rattata": "rattata", "pikachu": "pikachu", "vulpix": "vulpix", "oddish": "oddish", "psyduck": "psyduck",
    "growlithe": "growlithe", "poliwag": "poliwag", "bellsprout": "bellsprout", "seel": "seel", "eevee": "eevee",
}
# Ataques hechos a mano (id del juego -> id de PokeAPI): su forma (proyectil, embestida...) se ajustó a mano
# y apply_official_data.gd no la toca. El resto se genera solo (id = nombre en español).
MOVES = {
    "ascuas": "ember", "lanzallamas": "flamethrower", "giro_fuego": "fire-spin", "pistola_agua": "water-gun",
    "burbuja": "bubble", "surf": "surf", "hoja_afilada": "razor-leaf", "latigo_cepa": "vine-whip",
    "danza_petalo": "petal-dance", "placaje": "tackle", "aranazo": "scratch", "ataque_rapido": "quick-attack",
    "mordisco": "bite", "rapidez": "swift", "tornado": "gust", "vozarron": "hyper-voice", "proteccion": "protect",
    "impactrueno": "thunder-shock", "trueno": "thunder", "rayo_aurora": "aurora-beam", "ventisca": "blizzard",
    # Extras de los learnsets (Etapa 2c)
    "cuchillada": "slash", "ataque_ala": "wing-attack", "persecucion": "pursuit", "rayo_solar": "solar-beam",
    "acido": "acid", "rueda_fuego": "flame-wheel", "rayo": "thunderbolt", "hidrobomba": "hydro-pump",
    "derribo": "take-down", "golpe_cuerpo": "body-slam", "rayo_hielo": "ice-beam", "viento_hielo": "icy-wind",
}
STAT_NAMES = {"hp": "hp", "attack": "attack", "defense": "defense", "special-attack": "sp_attack",
              "special-defense": "sp_defense", "speed": "speed"}
VERSION_GROUPS = ["firered-leafgreen", "emerald", "ruby-sapphire"]


def get(path):
    key = os.path.join(CACHE, path.strip("/").replace("/", "_") + ".json")
    if os.path.exists(key):
        with open(key, encoding="utf-8") as f:
            return json.load(f)
    for attempt in range(4):
        try:
            req = urllib.request.Request(API + path, headers={"User-Agent": "pokemon-pilot-fangame"})
            with urllib.request.urlopen(req, timeout=40) as r:
                data = json.load(r)
            break
        except Exception:
            if attempt == 3:
                raise
            time.sleep(2 + attempt * 3)
    os.makedirs(CACHE, exist_ok=True)
    with open(key, "w", encoding="utf-8") as f:
        json.dump(data, f)
    time.sleep(0.05)  # no saturar la API
    return data


def es(entries, field="name"):
    for e in entries:
        if e["language"]["name"] == "es":
            return e[field]
    for e in entries:
        if e["language"]["name"] == "en":
            return e[field]
    return ""


def slug(text):
    t = unicodedata.normalize("NFKD", text.lower()).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", t).strip("_")


def flavor(species):
    entries = [e for e in species["flavor_text_entries"] if e["language"]["name"] == "es"]
    order = ["omega-ruby", "alpha-sapphire", "x", "y"]
    entries.sort(key=lambda e: order.index(e["version"]["name"]) if e["version"]["name"] in order else 99)
    return " ".join(entries[0]["flavor_text"].split()) if entries else ""


def learnset(pokemon):
    for vg in VERSION_GROUPS:
        out = sorted(
            [max(1, d["level_learned_at"]), m["move"]["name"]]
            for m in pokemon["moves"] for d in m["version_group_details"]
            if d["version_group"]["name"] == vg and d["move_learn_method"]["name"] == "level-up")
        if out:
            return out
    return []


def machines(pokemon):
    """Ataques de MT/MO que puede aprender en FRLG (Esmeralda si FRLG no lo tiene)."""
    for vg in VERSION_GROUPS:
        out = sorted({m["move"]["name"] for m in pokemon["moves"] for d in m["version_group_details"]
                      if d["version_group"]["name"] == vg and d["move_learn_method"]["name"] == "machine"})
        if out:
            return out
    return []


def fetch_species(n):
    p = get("/pokemon/%d" % n)
    s = get("/pokemon-species/%d" % n)
    return n, p, s


def main():
    root = sys.argv[1]
    by_api = {v: k for k, v in SPECIES.items()}
    with ThreadPoolExecutor(8) as pool:
        raw = sorted(pool.map(fetch_species, range(1, MAX_DEX + 1)))
    out = {"source": "https://pokeapi.co (datos de los juegos actuales)", "species": {}, "moves": {}}
    api_moves = set()
    mt_moves = set()
    for n, p, s in raw:
        gid = by_api.get(s["name"], slug(s["name"]))
        ls = learnset(p)
        api_moves.update(m for _, m in ls)
        mts = machines(p)
        mt_moves.update(mts)
        out["species"][gid] = {
            "dex": n,
            "name_es": es(s["names"]),
            "genus_es": es(s["genera"], "genus"),
            "flavor_es": flavor(s),
            "height_m": p["height"] / 10.0,
            "weight_kg": p["weight"] / 10.0,
            "types": [t["type"]["name"] for t in sorted(p["types"], key=lambda t: t["slot"])],
            "base_stats": {STAT_NAMES[st["stat"]["name"]]: st["base_stat"] for st in p["stats"]},
            "base_experience": p["base_experience"] or 60,
            "growth_rate": s["growth_rate"]["name"],
            "capture_rate": s["capture_rate"],
            # [nivel, ataque en PokeAPI] por nivel en FRLG (o Esmeralda). build_learnsets.gd lo traduce a ids.
            "learnset_frlg": ls,
            # Ataques de MT/MO en FRLG (PokeAPI). build_learnsets.gd los guarda en SpeciesData.tm_moves.
            "mt_frlg": mts,
        }
    print("especies:", len(out["species"]))

    manual = {v: k for k, v in MOVES.items()}
    api_list = sorted(set(MOVES.values()) | api_moves)
    api_list += sorted(mt_moves - set(api_list))  # los de solo MT, al final (no corren los ids de los demás)
    with ThreadPoolExecutor(8) as pool:
        moves = dict(zip(api_list, pool.map(lambda a: get("/move/" + a), api_list)))
    used = set(MOVES)
    for api_id in api_list:
        m = moves[api_id]
        gid = manual.get(api_id)
        if gid is None:
            gid = slug(es(m["names"])) or slug(api_id)
            while gid in used:
                gid += "_2"
        used.add(gid)
        meta = m.get("meta") or {}
        variable = m["power"] is None and m["damage_class"]["name"] != "status"
        out["moves"][gid] = {
            "name_en": api_id,
            "name_es": es(m["names"]),
            "auto": api_id not in manual,
            "type": m["type"]["name"],
            # Ataques de potencia variable (Patada Baja, Retribución...): 60 fijo (adaptación).
            "power": 60 if variable else (m["power"] or 0),
            "power_variable": variable,
            "category": m["damage_class"]["name"],
            "accuracy": m["accuracy"],
            "effect_chance": m["effect_chance"] or 0,
            "priority": m["priority"],
            "target": m["target"]["name"],
            "ailment": (meta.get("ailment") or {}).get("name", "none"),
            "ailment_chance": meta.get("ailment_chance") or 0,
            "meta_category": (meta.get("category") or {}).get("name", ""),
            "healing": meta.get("healing") or 0,
            "drain": meta.get("drain") or 0,
        }
    api_to_gid = {v["name_en"]: k for k, v in out["moves"].items()}
    for sp in out["species"].values():
        sp["learnset"] = [[lvl, api_to_gid[a]] for lvl, a in sp["learnset_frlg"]]
        sp["mt"] = [api_to_gid[a] for a in sp["mt_frlg"]]
    print("ataques:", len(out["moves"]))
    os.makedirs(os.path.join(root, "data", "source"), exist_ok=True)
    with open(os.path.join(root, "data", "source", "official.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1, ensure_ascii=False)


if __name__ == "__main__":
    main()
