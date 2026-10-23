"""Baja del decomp pret/pokefirered los sprites de las personas (NPC) que aparecen en los mapas importados
(art_src/pret/data/maps/*/map.json) y los exporta a art/pret/characters/<gfx>.png (RGBA, con su paleta) para la
historia (docs/PLAN_HISTORIA.md). También deja art/pret/characters/npcs.json: gfx -> {png, ancho, alto, cuadros}.

Uso: python -I -B tools/fetch_npc_sprites.py <carpeta del proyecto>
No vuelve a bajar lo que ya está en art_src/pret. Los cuadros de cada hoja: 0 quieto abajo, 1 arriba, 2 costado.
"""
import json
import os
import re
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pret_import import export_sprite  # noqa: E402

BASE = "https://raw.githubusercontent.com/pret/pokefirered/master/"
HEADERS = ["src/data/object_events/object_event_graphics_info.h",
           "src/data/object_events/object_event_pic_tables.h",
           "src/data/object_events/object_event_graphics.h"]
# Objetos que no son personas (los hace el juego de otra forma).
SKIP = {"OBJ_EVENT_GFX_CUT_TREE", "OBJ_EVENT_GFX_ROCK_SMASH_ROCK",
        "OBJ_EVENT_GFX_PUSHABLE_BOULDER", "OBJ_EVENT_GFX_POKEDEX", "OBJ_EVENT_GFX_TOWN_MAP", "OBJ_EVENT_GFX_FOSSIL",
        "OBJ_EVENT_GFX_OLD_AMBER", "OBJ_EVENT_GFX_CLIPBOARD", "OBJ_EVENT_GFX_METEORITE"}
# Siempre (aunque no estén en los mapas importados): personajes de la historia.
EXTRA = ["OBJ_EVENT_GFX_MOM", "OBJ_EVENT_GFX_NURSE", "OBJ_EVENT_GFX_PROF_OAK", "OBJ_EVENT_GFX_CLERK",
         "OBJ_EVENT_GFX_BLUE", "OBJ_EVENT_GFX_DAISY", "OBJ_EVENT_GFX_OLD_MAN_1", "OBJ_EVENT_GFX_OLD_MAN_LYING_DOWN",
         "OBJ_EVENT_GFX_BUG_CATCHER", "OBJ_EVENT_GFX_CAMPER", "OBJ_EVENT_GFX_BROCK", "OBJ_EVENT_GFX_BOY",
         "OBJ_EVENT_GFX_LITTLE_GIRL", "OBJ_EVENT_GFX_YOUNGSTER", "OBJ_EVENT_GFX_FAT_MAN", "OBJ_EVENT_GFX_WOMAN_1",
         "OBJ_EVENT_GFX_GENTLEMAN", "OBJ_EVENT_GFX_SCIENTIST", "OBJ_EVENT_GFX_WORKER_F"]


def fetch(root, rel):
    path = os.path.join(root, "art_src", "pret", *rel.split("/"))
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with urllib.request.urlopen(BASE + rel, timeout=30) as r:
            data = r.read()
        with open(path, "wb") as f:
            f.write(data)
    return path


def main():
    root = sys.argv[1]
    texts = {h: open(fetch(root, h), encoding="utf-8").read() for h in HEADERS}
    info, tables, graphics = texts[HEADERS[0]], texts[HEADERS[1]], texts[HEADERS[2]]
    wanted = set(EXTRA)
    maps_dir = os.path.join(root, "art_src", "pret", "data", "maps")
    for m in os.listdir(maps_dir):
        p = os.path.join(maps_dir, m, "map.json")
        if os.path.exists(p):
            for o in json.load(open(p, encoding="utf-8")).get("object_events", []):
                g = o.get("graphics_id", "")
                if g.startswith("OBJ_EVENT_GFX_") and g not in SKIP:
                    wanted.add(g)
    out_dir = os.path.join(root, "art", "pret", "characters")
    os.makedirs(out_dir, exist_ok=True)
    index = {}
    for gfx in sorted(wanted):
        name = gfx[len("OBJ_EVENT_GFX_"):]
        camel = "".join(w.capitalize() for w in name.split("_"))
        mi = re.search(r"gObjectEventGraphicsInfo_%s = \{(.*?)\};" % re.escape(camel), info, re.S)
        if not mi:
            print("sin info:", gfx)
            continue
        body = mi.group(1)
        pal = re.search(r"\.paletteTag = OBJ_EVENT_PAL_TAG_(\w+)", body).group(1).lower()
        w = int(re.search(r"\.width = (\d+)", body).group(1))
        h = int(re.search(r"\.height = (\d+)", body).group(1))
        table = re.search(r"\.images = (\w+)", body).group(1)
        mt = re.search(r"%s\[\] = \{(.*?)\};" % re.escape(table), tables, re.S)
        pic = re.search(r"(gObjectEventPic_\w+)", mt.group(1)).group(1) if mt else None
        mp = re.search(r"%s\[\] = INCBIN_U\d+\(\"([^\"]+)\.4bpp\"\)" % re.escape(pic), graphics) if pic else None
        if not mp:
            print("sin dibujo:", gfx)
            continue
        png_rel = mp.group(1) + ".png"
        pal_rel = "graphics/object_events/palettes/%s.pal" % pal
        try:
            fetch(root, png_rel)
            fetch(root, pal_rel)
        except Exception as e:  # noqa: BLE001
            print("no se pudo bajar", gfx, e)
            continue
        out = os.path.join(out_dir, name.lower() + ".png")
        pw, ph = export_sprite(os.path.join(root, "art_src", "pret"), png_rel[len("graphics/object_events/pics/"):],
                               pal + ".pal", out)
        index[name.lower()] = {"png": "res://art/pret/characters/%s.png" % name.lower(), "w": w, "h": h,
                               "frames": pw // w}
        print(gfx, "->", name.lower(), "(%dx%d, %d cuadros)" % (w, h, pw // w))
    with open(os.path.join(out_dir, "npcs.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(index, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
