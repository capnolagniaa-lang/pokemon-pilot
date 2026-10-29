"""Arma las 50 MT y las 8 MO de FireRed como objetos (data/items/mtNN.tres y moNN.tres) + sus íconos.

Pedido del usuario (2026-10-29): las MT son objetos que se consiguen como en FireRed, **no se gastan**, y un ataque de
MT/MO se equipa recién cuando se le enseña la máquina al Pokémon (CreatureInstance.can_learn_tm / learned_moves).
Qué ataque enseña cada una y su precio salen de pret/pokefirered (include/constants/items.h y src/data/items.json):
la tabla MACHINES de abajo. El ataque es el oficial de data/moves (por su nombre en inglés de official.json).
Dónde se consiguen: tools/build_story_npcs.py (Pokébolas del mapa, líderes, regalos) y data/shops/ (Azulona).

    python -I -B tools/build_tms.py .

Pisa los mtNN.tres y moNN.tres (las MO las armaba tools/fetch_items.py; ya no). Íconos: PokeAPI (tm-<tipo>, hmNN).
"""
import json
import os
import sys
import urllib.request

SPRITES = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/%s.png"
# (número, ataque en inglés como en pret, precio de FireRed). Las MO no se compran (precio 0).
MACHINES = [
    ("mt01", "focus-punch", 3000), ("mt02", "dragon-claw", 3000), ("mt03", "water-pulse", 3000),
    ("mt04", "calm-mind", 3000), ("mt05", "roar", 1000), ("mt06", "toxic", 3000), ("mt07", "hail", 3000),
    ("mt08", "bulk-up", 3000), ("mt09", "bullet-seed", 3000), ("mt10", "hidden-power", 3000),
    ("mt11", "sunny-day", 2000), ("mt12", "taunt", 3000), ("mt13", "ice-beam", 3000), ("mt14", "blizzard", 5500),
    ("mt15", "hyper-beam", 7500), ("mt16", "light-screen", 3000), ("mt17", "protect", 3000),
    ("mt18", "rain-dance", 2000), ("mt19", "giga-drain", 3000), ("mt20", "safeguard", 3000),
    ("mt21", "frustration", 1000), ("mt22", "solar-beam", 3000), ("mt23", "iron-tail", 3000),
    ("mt24", "thunderbolt", 3000), ("mt25", "thunder", 5500), ("mt26", "earthquake", 3000),
    ("mt27", "return", 1000), ("mt28", "dig", 2000), ("mt29", "psychic", 2000), ("mt30", "shadow-ball", 3000),
    ("mt31", "brick-break", 3000), ("mt32", "double-team", 2000), ("mt33", "reflect", 3000),
    ("mt34", "shock-wave", 3000), ("mt35", "flamethrower", 3000), ("mt36", "sludge-bomb", 1000),
    ("mt37", "sandstorm", 2000), ("mt38", "fire-blast", 5500), ("mt39", "rock-tomb", 3000),
    ("mt40", "aerial-ace", 3000), ("mt41", "torment", 3000), ("mt42", "facade", 3000),
    ("mt43", "secret-power", 3000), ("mt44", "rest", 3000), ("mt45", "attract", 3000), ("mt46", "thief", 3000),
    ("mt47", "steel-wing", 3000), ("mt48", "skill-swap", 3000), ("mt49", "snatch", 3000),
    ("mt50", "overheat", 3000),
    ("mo01", "cut", 0), ("mo02", "fly", 0), ("mo03", "surf", 0), ("mo04", "strength", 0), ("mo05", "flash", 0),
    # MO06 y MO07 en FireRed están en las Islas Sete (no están en el juego) y la MO08 no se consigue: se compran en la
    # tienda de MT de Azulona (data/shops/ciudad_azulona_mt.tres).
    ("mo06", "rock-smash", 3000), ("mo07", "waterfall", 3000), ("mo08", "dive", 3000),
]
# Lo que dice además la descripción (de dónde viene o para qué sirve fuera de la pelea).
EXTRA = {
    "mt28": "La MT que el Team Rocket robó en Ciudad Celeste.",
    "mt39": "Máquina técnica de Brock.",
    "mo01": "Con la Medalla Cascada, tus Pokémon cortan los árboles finos que tapan el camino (caminá contra el árbol).",
    "mo03": "Con la Medalla Alma, navegás por el agua (caminá hacia el agua).",
    "mo04": "Con la Medalla Arcoíris, empujás las rocas grandes (caminá contra la roca).",
}
# Orden en la mochila de las MO (objetos clave): las que ya estaban conservan su lugar.
MO_ORDER = {"mo01": 6, "mo03": 7, "mo04": 8, "mo02": 16, "mo05": 17, "mo06": 18, "mo07": 19, "mo08": 20}


def main():
    root = sys.argv[1]
    official = json.load(open(os.path.join(root, "data", "source", "official.json"), encoding="utf-8"))
    api_to_gid = {v["name_en"]: k for k, v in official["moves"].items()}
    os.makedirs(os.path.join(root, "sprites", "items"), exist_ok=True)
    for item_id, api, price in MACHINES:
        gid = api_to_gid.get(api)
        move_path = os.path.join(root, "data", "moves", "%s.tres" % gid) if gid else ""
        if not gid or not os.path.exists(move_path):
            print("FALTA el ataque", api, "para", item_id)
            continue
        move = official["moves"][gid]
        hm = item_id.startswith("mo")
        icon = item_id.replace("mo", "hm") if hm else "tm-" + move["type"]
        icon_path = os.path.join(root, "sprites", "items", icon + ".png")
        if not os.path.exists(icon_path):
            req = urllib.request.Request(SPRITES % icon, headers={"User-Agent": "pokemon-pilot-fangame"})
            with urllib.request.urlopen(req, timeout=40) as r, open(icon_path, "wb") as f:
                f.write(r.read())
        name = "%s %s" % (item_id.upper(), move["name_es"])
        desc = " ".join(x for x in [EXTRA.get(item_id, ""), "Enseña %s." % move["name_es"],
                                     "No se gasta: sirve para todos los Pokémon que la puedan aprender."] if x)
        lines = ['[gd_resource type="Resource" script_class="ItemData" format=3]', "",
                 '[ext_resource type="Script" path="res://scripts/resources/item_data.gd" id="1_s"]',
                 '[ext_resource type="Texture2D" path="res://sprites/items/%s.png" id="2_i"]' % icon,
                 '[ext_resource type="Resource" path="res://data/moves/%s.tres" id="3_m"]' % gid, "",
                 "[resource]", 'script = ExtResource("1_s")', 'id = "%s"' % item_id, 'display_name = "%s"' % name,
                 'description = "%s"' % desc.replace('"', '\\"'), 'icon = ExtResource("2_i")',
                 "pocket = %d" % (2 if hm else 0), "sort_order = %d" % (MO_ORDER[item_id] if hm else 100 + int(item_id[2:])),
                 "price = %d" % price, 'teaches_move = ExtResource("3_m")', "usable_in_battle = false"]
        with open(os.path.join(root, "data", "items", item_id + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")
        print(item_id, "->", name)


if __name__ == "__main__":
    main()
