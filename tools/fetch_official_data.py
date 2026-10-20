"""Baja de PokeAPI los datos oficiales de las especies y ataques del juego y los guarda en
data/source/official.json (fuente de verdad para tools/apply_official_data.gd).

Uso: python -I tools/fetch_official_data.py <carpeta del proyecto>
Para agregar una especie o ataque: sumalo a SPECIES / MOVES (id del juego -> nombre en PokeAPI).
"""
import json
import os
import sys
import time
import urllib.request

API = "https://pokeapi.co/api/v2"

# id del juego -> id de PokeAPI
SPECIES = {
    "bulbasaur": "bulbasaur", "charmander": "charmander", "squirtle": "squirtle", "pidgey": "pidgey",
    "rattata": "rattata", "pikachu": "pikachu", "vulpix": "vulpix", "oddish": "oddish", "psyduck": "psyduck",
    "growlithe": "growlithe", "poliwag": "poliwag", "bellsprout": "bellsprout", "seel": "seel", "eevee": "eevee",
}
MOVES = {
    "ascuas": "ember", "lanzallamas": "flamethrower", "giro_fuego": "fire-spin", "pistola_agua": "water-gun",
    "burbuja": "bubble", "surf": "surf", "hoja_afilada": "razor-leaf", "latigo_cepa": "vine-whip",
    "danza_petalo": "petal-dance", "placaje": "tackle", "aranazo": "scratch", "ataque_rapido": "quick-attack",
    "mordisco": "bite", "rapidez": "swift", "tornado": "gust", "vozarron": "hyper-voice", "proteccion": "protect",
    "impactrueno": "thunder-shock", "trueno": "thunder", "rayo_aurora": "aurora-beam", "ventisca": "blizzard",
}
STAT_NAMES = {"hp": "hp", "attack": "attack", "defense": "defense", "special-attack": "sp_attack",
              "special-defense": "sp_defense", "speed": "speed"}


def get(path):
    req = urllib.request.Request(API + path, headers={"User-Agent": "pokemon-pilot-fangame"})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.load(r)
    time.sleep(0.15)  # no saturar la API
    return data


def main():
    root = sys.argv[1]
    out = {"source": "https://pokeapi.co (datos de los juegos actuales)", "species": {}, "moves": {}}
    for gid, api_id in SPECIES.items():
        p = get("/pokemon/" + api_id)
        s = get("/pokemon-species/" + api_id)
        out["species"][gid] = {
            "dex": p["id"],
            "types": [t["type"]["name"] for t in sorted(p["types"], key=lambda t: t["slot"])],
            "base_stats": {STAT_NAMES[st["stat"]["name"]]: st["base_stat"] for st in p["stats"]},
            "base_experience": p["base_experience"],
            "growth_rate": s["growth_rate"]["name"],
            "capture_rate": s["capture_rate"],
        }
        print("especie", gid, out["species"][gid]["base_stats"])
    for gid, api_id in MOVES.items():
        m = get("/move/" + api_id)
        out["moves"][gid] = {
            "name_en": api_id,
            "type": m["type"]["name"],
            "power": m["power"] or 0,
            "category": m["damage_class"]["name"],
            "accuracy": m["accuracy"],
            "effect_chance": m["effect_chance"] or 0,
        }
        print("ataque", gid, out["moves"][gid])
    os.makedirs(os.path.join(root, "data", "source"), exist_ok=True)
    with open(os.path.join(root, "data", "source", "official.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1, ensure_ascii=False)


if __name__ == "__main__":
    main()
