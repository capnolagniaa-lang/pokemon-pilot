"""Baja de PokeAPI las cadenas evolutivas de los N.º 1-386 y genera data/source/evolutions.json:
{especie: [{"to": especie, "method": "nivel"|"piedra"|"intercambio"|"amistad"|"otro", "level": n, "item": id,
            "stats": 1|0|-1 (Tyrogue: ataque > = < defensa)}]}
Solo evoluciones a especies de las 3 primeras regiones (sin las de 4ª gen en adelante). Ids de especie = los de
data/source/official.json; las piedras con los ids de data/items (piedra_lunar, piedra_fuego...).
Las respuestas quedan en tools/.pokeapi_cache (no se versiona). Después: tools/apply_evolutions.gd.

Uso: python -I -B tools/fetch_evolutions.py <carpeta del proyecto>
"""
import json
import os
import sys
import urllib.request

API = "https://pokeapi.co/api/v2"
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".pokeapi_cache")
STONES = {"moon-stone": "piedra_lunar", "fire-stone": "piedra_fuego", "water-stone": "piedra_agua",
          "thunder-stone": "piedra_trueno", "leaf-stone": "piedra_hoja", "sun-stone": "piedra_solar"}


def get(path):
    name = path.strip("/").replace("/", "_") + ".json"
    file = os.path.join(CACHE, name)
    if os.path.exists(file):
        with open(file, encoding="utf-8") as f:
            return json.load(f)
    req = urllib.request.Request(API + path, headers={"User-Agent": "pokemon-pilot-fangame"})
    with urllib.request.urlopen(req, timeout=40) as r:
        data = json.load(r)
    os.makedirs(CACHE, exist_ok=True)
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data, f)
    return data


def dex_of(url):
    return int(url.rstrip("/").split("/")[-1])


def method_of(details):
    """La forma de evolucionar de la 3ª gen (la primera que sirva de la lista de PokeAPI)."""
    for d in details:
        trig = d["trigger"]["name"]
        if trig == "level-up" and d.get("min_level"):
            out = {"method": "nivel", "level": d["min_level"]}
            if d.get("relative_physical_stats") is not None:
                out["stats"] = d["relative_physical_stats"]
            return out
        if trig == "use-item" and d.get("item") and d["item"]["name"] in STONES:
            return {"method": "piedra", "item": STONES[d["item"]["name"]]}
    for d in details:
        trig = d["trigger"]["name"]
        if trig == "level-up" and d.get("min_happiness"):
            return {"method": "amistad"}
        if trig == "trade":
            return {"method": "intercambio", "item": (d.get("held_item") or {}).get("name", "")}
    return {"method": "otro"}


def main():
    root = sys.argv[1]
    official = json.load(open(os.path.join(root, "data", "source", "official.json"), encoding="utf-8"))["species"]
    by_dex = {v["dex"]: k for k, v in official.items()}
    out = {}
    seen_chains = set()
    for sid, sp in sorted(official.items(), key=lambda kv: kv[1]["dex"]):
        chain_url = get("/pokemon-species/%d" % sp["dex"])["evolution_chain"]["url"]
        cid = dex_of(chain_url)
        if cid in seen_chains:
            continue
        seen_chains.add(cid)
        chain = get("/evolution-chain/%d" % cid)["chain"]

        def walk(node):
            frm = by_dex.get(dex_of(node["species"]["url"]))
            for nxt in node["evolves_to"]:
                to = by_dex.get(dex_of(nxt["species"]["url"]))
                if frm and to:
                    out.setdefault(frm, []).append(dict(to=to, **method_of(nxt["evolution_details"])))
                walk(nxt)
        walk(chain)
    path = os.path.join(root, "data", "source", "evolutions.json")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False, indent=1, sort_keys=True)
    counts = {}
    for evs in out.values():
        for e in evs:
            counts[e["method"]] = counts.get(e["method"], 0) + 1
    print("especies que evolucionan:", len(out), "| formas:", counts)


if __name__ == "__main__":
    main()
