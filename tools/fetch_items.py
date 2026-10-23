"""Baja de PokeAPI los objetos de la mochila (nombre y descripción en español, ícono) y genera
data/items/<id>.tres (ItemData) + sprites/items/<api>.png. El efecto en el juego está en ITEMS (a mano).

Uso: python -I -B tools/fetch_items.py <carpeta del proyecto>
Para sumar un objeto: agregarlo a ITEMS y volver a correrlo.
"""
import json
import os
import sys
import urllib.request

API = "https://pokeapi.co/api/v2"
SPRITES = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/%s.png"
POCKET = {"items": 0, "balls": 1, "key": 2}
ALL_BAD = "all"

# id del juego -> (id PokeAPI, bolsillo, orden, efecto)
ITEMS = {
    "poke_ball": ("poke-ball", "balls", 1, {"catch_mult": 1.0}),
    "super_ball": ("great-ball", "balls", 2, {"catch_mult": 1.5}),
    "ultra_ball": ("ultra-ball", "balls", 3, {"catch_mult": 2.0}),
    "master_ball": ("master-ball", "balls", 4, {"catch_mult": 255.0}),
    "pocion": ("potion", "items", 1, {"heal_hp": 20.0}),
    "superpocion": ("super-potion", "items", 2, {"heal_hp": 50.0}),
    "hiperpocion": ("hyper-potion", "items", 3, {"heal_hp": 200.0, "use_time": 0.8}),
    "pocion_maxima": ("max-potion", "items", 4, {"heal_full": True, "use_time": 0.9}),
    "antidoto": ("antidote", "items", 10, {"cures": ["envenenado"]}),
    "antiparalizador": ("paralyze-heal", "items", 11, {"cures": ["paralizado"]}),
    "despertar": ("awakening", "items", 12, {"cures": ["dormido"]}),
    "antiquemar": ("burn-heal", "items", 13, {"cures": ["quemado"]}),
    "antihielo": ("ice-heal", "items", 14, {"cures": ["congelado"]}),
    "cura_total": ("full-heal", "items", 15, {"cures": [ALL_BAD]}),
    "revivir": ("revive", "items", 20, {"revive_ratio": 0.5, "use_time": 1.0}),
    # Objetos clave de la historia (docs/PLAN_HISTORIA.md, H-2): no se usan, los mira la historia.
    "paquete_oak": ("oaks-parcel", "key", 1, {}),
    "mapa": ("town-map", "key", 2, {}),
}
# Descripción propia cuando PokeAPI no tiene una en español.
DESCRIPTIONS = {
    "paquete_oak": "Un correo para el Profesor Oak. Te lo dio el vendedor de la Tienda Pokémon de Ciudad Verde.",
}


def get(path):
    req = urllib.request.Request(API + path, headers={"User-Agent": "pokemon-pilot-fangame"})
    with urllib.request.urlopen(req, timeout=40) as r:
        return json.load(r)


def es(entries, field="name"):
    for e in entries:
        if e["language"]["name"] == "es":
            return e[field]
    return ""


def flavor(item):
    entries = [e for e in item["flavor_text_entries"] if e["language"]["name"] == "es"]
    return " ".join(entries[-1]["text"].split()) if entries else ""


def tres_value(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, list):
        return "PackedStringArray(" + ", ".join('"%s"' % x for x in v) + ")"
    return str(v)


def main():
    root = sys.argv[1]
    os.makedirs(os.path.join(root, "data", "items"), exist_ok=True)
    os.makedirs(os.path.join(root, "sprites", "items"), exist_ok=True)
    for gid, (api, pocket, order, effect) in ITEMS.items():
        it = get("/item/" + api)
        icon = os.path.join(root, "sprites", "items", api + ".png")
        if not os.path.exists(icon):
            req = urllib.request.Request(SPRITES % api, headers={"User-Agent": "pokemon-pilot-fangame"})
            with urllib.request.urlopen(req, timeout=40) as r, open(icon, "wb") as f:
                f.write(r.read())
        name = es(it["names"]) or api
        desc = (flavor(it) or DESCRIPTIONS.get(gid, "")).replace('"', '\\"')
        lines = ['[gd_resource type="Resource" script_class="ItemData" format=3]', "",
                 '[ext_resource type="Script" path="res://scripts/resources/item_data.gd" id="1_s"]',
                 '[ext_resource type="Texture2D" path="res://sprites/items/%s.png" id="2_i"]' % api, "",
                 "[resource]", 'script = ExtResource("1_s")', 'id = "%s"' % gid, 'display_name = "%s"' % name,
                 'description = "%s"' % desc, 'icon = ExtResource("2_i")', "pocket = %d" % POCKET[pocket],
                 "sort_order = %d" % order]
        for k, v in effect.items():
            lines.append("%s = %s" % (k, tres_value(v)))
        with open(os.path.join(root, "data", "items", gid + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")
        print(gid, "->", name)


if __name__ == "__main__":
    main()
