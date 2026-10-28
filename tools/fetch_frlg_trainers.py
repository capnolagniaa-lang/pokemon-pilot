"""Entrenadores de FireRed para la historia (docs/PLAN_RESTO_KANTO.md): para cada persona de los mapas importados
(data/world/frlg_maps.json) busca en el script de su mapa (pret: data/maps/<Mapa>/scripts.inc y data/scripts/trainers.inc) con qué entrenador pelea
y arma su equipo (src/data/trainers.h + trainer_parties.h). Genera data/source/trainers_frlg.json:
{zona: {script: {"const", "class", "name", "team": [[especie, nivel], ...], "sight", "double"}}}
Las especies con los ids de data/species. Lo bajado queda en tools/.pret_cache (no se versiona).

Uso: python -I -B tools/fetch_frlg_trainers.py <carpeta del proyecto>
"""
import json
import os
import re
import sys
import urllib.error
import urllib.request

BASE = "https://raw.githubusercontent.com/pret/pokefirered/master/"
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".pret_cache")


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


def species_id(name, known):
    sid = name.lower()
    return sid if sid in known else None


def main():
    root = sys.argv[1]
    known = {f[:-5] for f in os.listdir(os.path.join(root, "data", "species")) if f.endswith(".tres")}
    trainers = get("src/data/trainers.h")
    parties = get("src/data/trainer_parties.h")
    common = get("data/scripts/trainers.inc")
    zones = json.load(open(os.path.join(root, "data", "world", "frlg_maps.json"), encoding="utf-8"))["zones"]

    def party(const):
        m = re.search(r"\[%s\]\s*=\s*\{(.*?)\n    \}," % re.escape(const), trainers, re.S)
        if not m:
            return None
        body = m.group(1)
        cls = re.search(r"\.trainerClass\s*=\s*TRAINER_CLASS_(\w+)", body)
        name = re.search(r'\.trainerName\s*=\s*_\("([^"]*)"\)', body)
        double = "doubleBattle = TRUE" in body
        pm = re.search(r"(sParty_\w+)", body)
        team = []
        if pm:
            pb = re.search(r"%s\[\]\s*=\s*\{(.*?)\};" % pm.group(1), parties, re.S)
            for lvl, sp in re.findall(r"\.lvl\s*=\s*(\d+).*?\.species\s*=\s*SPECIES_(\w+)", pb.group(1) if pb else "", re.S):
                sid = species_id(sp, known)
                if sid:
                    team.append([sid, int(lvl)])
        return {"const": const, "class": cls.group(1) if cls else "", "name": name.group(1).title() if name else "",
                "team": team, "double": double}

    out = {}
    for z in zones:
        if not z.get("npcs"):
            continue
        inc = get("data/maps/%s/scripts.inc" % z["map"]) + "\n" + common  # los de ruta están en trainers.inc
        mj = json.loads(get("data/maps/%s/map.json" % z["map"]) or "{}")
        sight = {o.get("script", ""): o.get("trainer_sight_or_berry_tree_id", 0) for o in mj.get("object_events", [])}
        for n in z["npcs"]:
            label = n["script"]
            start = inc.find(label + "::")
            if start < 0:
                continue
            nxt = inc.find("::", start + len(label) + 2)
            block = inc[start: nxt if nxt > 0 else len(inc)]
            m = re.search(r"trainerbattle\w*\s+(TRAINER_\w+)", block)
            if not m:
                continue
            p = party(m.group(1))
            if not p or not p["team"]:
                continue
            try:
                p["sight"] = int(str(sight.get(label, 0)), 0)
            except ValueError:
                p["sight"] = 0
            out.setdefault(z["id"], {})[label.split("EventScript_")[-1]] = p
    path = os.path.join(root, "data", "source", "trainers_frlg.json")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False, indent=1, sort_keys=True)
    total = sum(len(v) for v in out.values())
    classes = sorted({t["class"] for v in out.values() for t in v.values()})
    print("zonas con entrenadores:", len(out), "| entrenadores:", total)
    print("clases:", classes)


if __name__ == "__main__":
    main()
