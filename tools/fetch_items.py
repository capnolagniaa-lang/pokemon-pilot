"""Baja de PokeAPI los objetos de la mochila (nombre y descripción en español, ícono, precio) y genera
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
    # Capítulo 2 (docs/PLAN_CAPITULO_2.md): Mt. Moon, Puente Pepita y Bill.
    "caramelo_raro": ("rare-candy", "items", 30, {"level_up": 1, "usable_in_battle": False}),
    "piedra_lunar": ("moon-stone", "items", 40, {"evolves": True, "usable_in_battle": False}),
    "piedra_fuego": ("fire-stone", "items", 41, {"evolves": True, "usable_in_battle": False}),
    "piedra_agua": ("water-stone", "items", 42, {"evolves": True, "usable_in_battle": False}),
    "piedra_trueno": ("thunder-stone", "items", 43, {"evolves": True, "usable_in_battle": False}),
    "piedra_hoja": ("leaf-stone", "items", 44, {"evolves": True, "usable_in_battle": False}),
    "piedra_solar": ("sun-stone", "items", 45, {"evolves": True, "usable_in_battle": False}),
    "trozo_estrella": ("star-piece", "items", 50, {"usable_in_battle": False}),
    "pepita": ("nugget", "items", 51, {"usable_in_battle": False}),
    # Objetos clave de la historia (docs/PLAN_HISTORIA.md, H-2): no se usan, los mira la historia.
    "paquete_oak": ("oaks-parcel", "key", 1, {}),
    "mapa": ("town-map", "key", 2, {}),
    "fosil_helix": ("helix-fossil", "key", 3, {}),
    "fosil_domo": ("dome-fossil", "key", 4, {}),
    "ticket_barco": ("ss-ticket", "key", 5, {}),
    # Capítulo 3 (docs/PLAN_CAPITULO_3.md): el capitán del S.S. Anne te da Corte (cortar árboles finos: FieldMoves).
    "mo01": ("hm01", "key", 6, {}),
    # Resto de Kanto (docs/PLAN_RESTO_KANTO.md): MO y objetos clave de la historia (FieldMoves y StoryDirector).
    "mo03": ("hm03", "key", 7, {}),
    "mo04": ("hm04", "key", 8, {}),
    "poke_flauta": ("poke-flute", "key", 9, {}),
    "te": ("tea", "key", 10, {}),
    "silph_scope": ("silph-scope", "key", 11, {}),
    "dientes_oro": ("gold-teeth", "key", 12, {}),
    "llave_ascensor": ("lift-key", "key", 13, {}),
    "tarjeta_llave": ("card-key", "key", 14, {}),
    "llave_secreta": ("secret-key", "key", 15, {}),
}
# Precio en la Tienda Pokémon (FireRed/LeafGreen, 3ª gen). PokeAPI ya no los trae (`prices` viene vacío).
# Sin precio (Master Ball, objetos clave) = no se compra ni se vende.
PRICES = {
    "poke_ball": 200, "super_ball": 600, "ultra_ball": 1200,
    "pocion": 300, "superpocion": 700, "hiperpocion": 1200, "pocion_maxima": 2500,
    "antidoto": 100, "antiparalizador": 200, "despertar": 250, "antiquemar": 250, "antihielo": 250,
    "cura_total": 600, "revivir": 1500,
    "caramelo_raro": 4800, "piedra_lunar": 2100, "piedra_fuego": 2100, "piedra_agua": 2100,
    "piedra_trueno": 2100, "piedra_hoja": 2100, "piedra_solar": 2100, "trozo_estrella": 9800, "pepita": 10000,
}
# Nombre propio cuando el de PokeAPI no alcanza.
NAMES = {"mo01": "MO01 Corte", "mo03": "MO03 Surf", "mo04": "MO04 Fuerza", "te": "Té", "silph_scope": "Scope Silph",
         "dientes_oro": "Dientes de Oro", "llave_ascensor": "Llave Ascensor", "tarjeta_llave": "Tarjeta Llave",
         "llave_secreta": "Llave Secreta", "poke_flauta": "Poké Flauta"}
# Descripción propia (manda sobre la de PokeAPI, que a veces no tiene una en español o dice "- - -").
DESCRIPTIONS = {
    "mo01": "MO01 Corte. Con la Medalla Cascada, tus Pokémon cortan los árboles finos que tapan el camino (E frente al árbol).",
    "mo03": "MO03 Surf. Con la Medalla Alma, tu Pokémon te lleva sobre el agua (E frente al agua). Al pisar tierra te bajás.",
    "mo04": "MO04 Fuerza. Con la Medalla Arcoíris, tus Pokémon empujan rocas grandes (E frente a la roca y después caminá contra ella).",
    "poke_flauta": "Una flauta que toca una melodía capaz de despertar a cualquier Pokémon dormido (E frente al Snorlax).",
    "te": "Un té riquísimo. Los guardias de Ciudad Azafrán se mueren de sed...",
    "silph_scope": "Un visor de Silph S.A. que deja ver a los fantasmas tal como son. Sin él, en la Torre Pokémon no se puede pelear contra ellos.",
    "dientes_oro": "La dentadura de oro del guarda de la Zona Safari. Se le cayó en algún lado...",
    "llave_ascensor": "La llave del ascensor del Escondite Rocket.",
    "tarjeta_llave": "La tarjeta que abre todas las puertas de Silph S.A.",
    "llave_secreta": "La llave del Gimnasio de Isla Canela. Estaba en la Mansión Pokémon.",
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
        name = NAMES.get(gid) or es(it["names"]) or api
        desc = (DESCRIPTIONS.get(gid) or flavor(it)).replace('"', '\\"')
        lines = ['[gd_resource type="Resource" script_class="ItemData" format=3]', "",
                 '[ext_resource type="Script" path="res://scripts/resources/item_data.gd" id="1_s"]',
                 '[ext_resource type="Texture2D" path="res://sprites/items/%s.png" id="2_i"]' % api, "",
                 "[resource]", 'script = ExtResource("1_s")', 'id = "%s"' % gid, 'display_name = "%s"' % name,
                 'description = "%s"' % desc, 'icon = ExtResource("2_i")', "pocket = %d" % POCKET[pocket],
                 "sort_order = %d" % order]
        if gid in PRICES:
            lines.append("price = %d" % PRICES[gid])  # precio oficial de la Tienda (se vende a la mitad)
        for k, v in effect.items():
            lines.append("%s = %s" % (k, tres_value(v)))
        with open(os.path.join(root, "data", "items", gid + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")
        print(gid, "->", name)


if __name__ == "__main__":
    main()
