"""Objetos equipables del Modo Desafío (paso O-b de docs/PROPUESTA_ROGUELIKE.md, sección 11): objetos reales de Pokémon
adaptados al tiempo real, solo de la partida. Arma data/rogue_items/<id>.tres (BoonData con `giver` = "objeto": usan el
mismo motor que las bendiciones, scripts/world/rogue_boons.gd) y baja su ícono de PokeAPI a sprites/items/ si falta
(como tools/fetch_items.py). También arma el ícono de la recompensa (sprites/ui/premios/objeto.png).
Correrlo de nuevo pisa esos .tres (los datos viven acá).

Uso: python -I -B tools/build_rogue_items.py .   (después: godot --headless --path . --import)   Necesita Pillow.
"""
import json
import os
import sys
import urllib.request

SPRITES = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/%s.png"

# id, nombre, ícono (nombre en PokeAPI), efecto, params, claves que escalan, texto
ITEMS = [
    ("restos", "Restos", "leftovers", "regen", {"pct": 0.005}, ["pct"],
     "Mientras peleás recuperás {pct%1} de tu vida por segundo."),
    ("campana_concha", "Campana Concha", "shell-bell", "lifesteal", {"pct": 0.05}, ["pct"],
     "Te curás {pct%} del daño que hacés con tus ataques."),
    ("cinta_focus", "Cinta Focus", "focus-band", "guard", {"below": 0.25, "time": 1.6}, ["time"],
     "Una vez por sala, al bajar de 25 % de vida aguantás: nada te hace daño por {time} s."),
    ("garra_rapida", "Garra Rápida", "quick-claw", "dodge_cd", {"pct": 0.15}, ["pct"],
     "El esquive ({tecla}) recarga {pct%} más rápido."),
    ("roca_del_rey", "Roca del Rey", "kings-rock", "hit_status", {"slot": -1, "status": "azotado", "chance": 0.14}, ["chance"],
     "Tus golpes tienen {chance%} de dejar al enemigo sin poder actuar un instante."),
    ("periscopio", "Periscopio", "scope-lens", "crit", {"chance": 0.18, "pct": 0.5}, ["chance"],
     "Tus golpes tienen {chance%} de ser críticos: 50 % más de daño."),
    ("casco_dentado", "Casco Dentado", "rocky-helmet", "thorns", {"status": "", "cooldown": 2.5, "power": 0.35}, ["power"],
     "El que te pega recibe {power} de daño (una vez cada 2,5 s)."),
    ("panuelo_elegido", "Pañuelo Elegido", "choice-scarf", "speed", {"pct": 0.15}, ["pct"],
     "Te movés {pct%} más rápido."),
    ("baya_zidra", "Baya Zidra", "sitrus-berry", "phoenix", {"below": 0.5, "heal": 0.2, "word": "¡Baya Zidra!"}, ["heal"],
     "Una vez por sala, al bajar de 50 % de vida recuperás {heal%}."),
    ("huevo_suerte", "Huevo Suerte", "lucky-egg", "exp", {"pct": 0.2}, ["pct"],
     "Ganás {pct%} más de experiencia."),
    ("moneda_amuleto", "Moneda Amuleto", "amulet-coin", "money", {"pct": 0.5}, ["pct"],
     "Cada sala limpia y cada bolsa de dinero te dan {pct%} más de plata."),
]

# Potenciadores de tipo: solo se ofrecen los del tipo de alguno de tus ataques.
BOOSTERS = [
    ("carbon", "Carbón", "charcoal", "fuego"), ("agua_mistica", "Agua Mística", "mystic-water", "agua"),
    ("iman", "Imán", "magnet", "electrico"), ("semilla_milagro", "Semilla Milagro", "miracle-seed", "planta"),
    ("panuelo_seda", "Pañuelo Seda", "silk-scarf", "normal"), ("cinturon_negro", "Cinturón Negro", "black-belt", "lucha"),
    ("pico_afilado", "Pico Afilado", "sharp-beak", "volador"), ("arena_fina", "Arena Fina", "soft-sand", "tierra"),
    ("piedra_dura", "Piedra Dura", "hard-stone", "roca"), ("flecha_venenosa", "Flecha Venenosa", "poison-barb", "veneno"),
    ("cuchara_torcida", "Cuchara Torcida", "twisted-spoon", "psiquico"), ("antiderretir", "Antiderretir", "never-melt-ice", "hielo"),
    ("polvo_plata", "Polvo Plata", "silver-powder", "bicho"), ("hechizo", "Hechizo", "spell-tag", "fantasma"),
    ("gafas_de_sol", "Gafas de Sol", "black-glasses", "siniestro"), ("colmillo_dragon", "Colmillo Dragón", "dragon-fang", "dragon"),
    ("revestimiento_metalico", "Revestimiento Metálico", "metal-coat", "acero"),
]
TYPE_NAMES = {"fuego": "Fuego", "agua": "Agua", "electrico": "Eléctrico", "planta": "Planta", "normal": "Normal", "lucha": "Lucha",
              "volador": "Volador", "tierra": "Tierra", "roca": "Roca", "veneno": "Veneno", "psiquico": "Psíquico", "hielo": "Hielo",
              "bicho": "Bicho", "fantasma": "Fantasma", "siniestro": "Siniestro", "dragon": "Dragón", "acero": "Acero"}
for bid, name, api, element in BOOSTERS:
    ITEMS.append((bid, name, api, "bonus_type", {"type": element, "pct": 0.12}, ["pct"],
                  "Tus ataques de tipo %s hacen {pct%%} más de daño." % TYPE_NAMES[element]))


def gd(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, dict):
        return "{\n" + ",\n".join("%s: %s" % (gd(k), gd(v)) for k, v in value.items()) + "\n}"
    raise TypeError(value)


def main(root):
    out = os.path.join(root, "data/rogue_items")
    os.makedirs(out, exist_ok=True)
    for old in os.listdir(out):
        if old.endswith(".tres"):
            os.remove(os.path.join(out, old))
    for bid, name, api, effect, params, scaled, text in ITEMS:
        assert all(k in params for k in scaled), bid
        icon = os.path.join(root, "sprites", "items", api + ".png")
        if not os.path.exists(icon):
            req = urllib.request.Request(SPRITES % api, headers={"User-Agent": "pokemon-pilot-fangame"})
            with urllib.request.urlopen(req, timeout=40) as r, open(icon, "wb") as f:
                f.write(r.read())
            print("ícono nuevo:", api)
        slot = "esquive" if effect == "dodge_cd" else "pasiva"
        body = ('[gd_resource type="Resource" script_class="BoonData" format=3]\n\n'
                '[ext_resource type="Script" path="res://scripts/resources/boon_data.gd" id="1_boon"]\n\n'
                '[resource]\nscript = ExtResource("1_boon")\n'
                'id = %s\ndisplay_name = %s\ngiver = "objeto"\nslot = %s\neffect = %s\nparams = %s\nscaled = PackedStringArray(%s)\ntext = %s\nicon_path = %s\n'
                % (gd(bid), gd(name), gd(slot), gd(effect), gd(params), ", ".join(gd(k) for k in scaled), gd(text),
                   gd("res://sprites/items/%s.png" % api)))
        with open(os.path.join(out, bid + ".tres"), "w", encoding="utf8", newline="\n") as f:
            f.write(body)
    # El ícono de la recompensa "Objeto" (puerta y Tienda): los Restos, agrandados sin suavizar.
    from PIL import Image
    src = Image.open(os.path.join(root, "sprites/items/leftovers.png")).convert("RGBA")
    box = src.getbbox()
    src = src.crop(box)
    k = max(1, 84 // max(src.size))
    big = src.resize((src.width * k, src.height * k), Image.NEAREST)
    canvas = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    canvas.paste(big, ((96 - big.width) // 2, (96 - big.height) // 2), big)
    canvas.save(os.path.join(root, "sprites/ui/premios/objeto.png"))
    ball = Image.open(os.path.join(root, "sprites/items/poke-ball.png")).convert("RGBA")
    ball = ball.crop(ball.getbbox())
    k = max(1, 84 // max(ball.size))
    big = ball.resize((ball.width * k, ball.height * k), Image.NEAREST)
    canvas = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    canvas.paste(big, ((96 - big.width) // 2, (96 - big.height) // 2), big)
    canvas.save(os.path.join(root, "sprites/ui/premios/bola.png"))
    print("%d objetos" % len(ITEMS))


if __name__ == "__main__":
    main(sys.argv[1])
