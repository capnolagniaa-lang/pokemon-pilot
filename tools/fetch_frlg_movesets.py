"""Ataques de los equipos de entrenadores que FireRed arma a mano (pret: src/data/trainer_parties.h, los
TrainerMon*CustomMoves: líderes, Alto Mando, rival, Giovanni y algunos más; el resto de los entrenadores usa los últimos
4 por nivel). Genera data/source/trainer_movesets.json:
  [{"party": "LeaderBrock", "mons": [["geodude", 12, ["placaje", "rizo_defensa"]], ...]}, ...]
con las especies y ataques en los ids del juego (data/species, data/moves; nombres en inglés vía data/source/official.json).
Lo usa TrainerMovesets (scripts/world/trainer_movesets.gd): "FireRed mejorado", decisión del usuario 2026-11-08.
Lo bajado queda en tools/.pret_cache (no se versiona), igual que tools/fetch_frlg_trainers.py.

Uso: python -I -B tools/fetch_frlg_movesets.py <carpeta del proyecto>
"""
import json
import os
import re
import sys
import urllib.error
import urllib.request

BASE = "https://raw.githubusercontent.com/pret/pokefirered/master/"
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".pret_cache")
# Nombres de pret que en PokeAPI se escriben distinto.
ALIASES = {"faint-attack": "feint-attack", "hi-jump-kick": "high-jump-kick", "smelling-salt": "smelling-salts",
           "vice-grip": "vise-grip", "sonic-boom": "sonic-boom"}


def get(path):
    file = os.path.join(CACHE, path.replace("/", "_"))
    if os.path.exists(file):
        with open(file, encoding="utf-8") as f:
            return f.read()
    req = urllib.request.Request(BASE + path, headers={"User-Agent": "pokemon-pilot-fangame"})
    try:
        with urllib.request.urlopen(req, timeout=40) as r:
            text = r.read().decode("utf-8")
    except urllib.error.HTTPError:
        text = ""
    os.makedirs(CACHE, exist_ok=True)
    with open(file, "w", encoding="utf-8") as f:
        f.write(text)
    return text


def main():
    root = sys.argv[1]
    species = {f[:-5] for f in os.listdir(os.path.join(root, "data", "species")) if f.endswith(".tres")}
    have = {f[:-5] for f in os.listdir(os.path.join(root, "data", "moves")) if f.endswith(".tres")}
    official = json.load(open(os.path.join(root, "data", "source", "official.json"), encoding="utf-8"))["moves"]
    en2id = {v["name_en"]: k for k, v in official.items()}
    parties = get("src/data/trainer_parties.h")
    out, missing = [], {}
    for kind, name, body in re.findall(r"static const struct (\w+) (sParty_\w+)\[\] = \{(.*?)\};", parties, re.S):
        if "CustomMoves" not in kind:
            continue
        mons = []
        for mon in re.findall(r"\n    \{(.*?)\n    \}", body, re.S):  # (un Pokémon por bloque, por la sangría)
            lvl = re.search(r"\.lvl\s*=\s*(\d+)", mon)
            sp = re.search(r"\.species\s*=\s*SPECIES_(\w+)", mon)
            mv = re.search(r"\.moves\s*=\s*\{(.*?)\}", mon, re.S)
            if not (lvl and sp and mv):
                continue
            sid = sp.group(1).lower()
            if sid not in species:
                continue
            ids = []
            for m in re.findall(r"MOVE_(\w+)", mv.group(1)):
                if m == "NONE":
                    continue
                en = m.lower().replace("_", "-")
                mid = en2id.get(ALIASES.get(en, en))
                if mid in have:
                    ids.append(mid)
                else:
                    missing[en] = missing.get(en, 0) + 1
            mons.append([sid, int(lvl.group(1)), ids])
        if mons:
            out.append({"party": name.replace("sParty_", ""), "mons": mons})
    path = os.path.join(root, "data", "source", "trainer_movesets.json")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    print("equipos con ataques propios: %d, Pokémon: %d -> %s" % (len(out), sum(len(p["mons"]) for p in out), path))
    if missing:
        print("ataques que no están en el juego (se saltean):", missing)


if __name__ == "__main__":
    main()
