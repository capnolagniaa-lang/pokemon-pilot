"""Baja de PokeAPI las habilidades de 3ª generación (las de nacimiento, como en Rubí/Zafiro/Esmeralda/FRLG) de las 386
especies y las guarda en data/source/abilities.json (pedido del usuario 2026-10-28: "que se respeten las habilidades
que tienen los Pokémon"). Lo usa tools/apply_abilities.gd.

PokeAPI da las habilidades de hoy: acá se deshacen los cambios de generaciones posteriores (`past_abilities`), se
sacan las ocultas y las que se inventaron después de la 3ª generación (por ejemplo Experto o Rivalidad, de la 4ª).

Uso: python -I -B tools/fetch_abilities.py <carpeta del proyecto>
Las respuestas quedan en tools/.pokeapi_cache (las de /pokemon ya las bajó tools/fetch_official_data.py).
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fetch_official_data import get, es, slug, MAX_DEX, SPECIES  # noqa: E402


def gen_of(url):
    return int(re.search(r"/(\d+)/?$", url).group(1))


def gen3_abilities(pokemon, ability_gen):
    slots = {a["slot"]: a["ability"]["name"] for a in pokemon["abilities"] if not a["is_hidden"]}
    # past_abilities: cómo eran ANTES de la generación indicada. La más vieja (≥ 4ª) es la de la 3ª.
    past = sorted(pokemon.get("past_abilities", []), key=lambda p: gen_of(p["generation"]["url"]))
    for p in past:
        if gen_of(p["generation"]["url"]) >= 4:
            for a in p["abilities"]:
                if a.get("is_hidden"):
                    continue
                if a["ability"] is None:
                    slots.pop(a["slot"], None)
                else:
                    slots[a["slot"]] = a["ability"]["name"]
            break
    return [n for s, n in sorted(slots.items()) if ability_gen(n) <= 3]


def flavor(ab):
    entries = [e for e in ab.get("flavor_text_entries", []) if e["language"]["name"] == "es"]
    return " ".join(entries[-1]["flavor_text"].split()) if entries else ""


def main():
    root = sys.argv[1]
    by_api = {v: k for k, v in SPECIES.items()}
    cache = {}

    def ability(name):
        if name not in cache:
            cache[name] = get("/ability/" + name)
        return cache[name]

    def ability_gen(name):
        return gen_of(ability(name)["generation"]["url"])

    out = {"source": "https://pokeapi.co (habilidades de 3ª generación)", "species": {}, "abilities": {}}
    for n in range(1, MAX_DEX + 1):
        p = get("/pokemon/%d" % n)
        s = get("/pokemon-species/%d" % n)
        gid = by_api.get(s["name"], slug(s["name"]))
        out["species"][gid] = [slug(es(ability(a)["names"])) for a in gen3_abilities(p, ability_gen)]
    for name, ab in cache.items():
        if ability_gen(name) > 3:
            continue
        out["abilities"][slug(es(ab["names"]))] = {"name_en": name, "name_es": es(ab["names"]), "desc_es": flavor(ab)}
    with open(os.path.join(root, "data", "source", "abilities.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1, ensure_ascii=False)
    print("especies: %d · habilidades de 3ª gen: %d" % (len(out["species"]), len(out["abilities"])))


if __name__ == "__main__":
    main()
