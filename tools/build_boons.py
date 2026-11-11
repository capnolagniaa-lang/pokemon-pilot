"""Bendiciones del Modo Desafío (R-2 de docs/PROPUESTA_ROGUELIKE.md): arma data/boons/<id>.tres (BoonData) desde la
tabla BOONS y data/rogue/bendiciones.json (los dadores con sus frases y las rarezas). Lo que hace cada `effect` está en
scripts/world/rogue_boons.gd. Correrlo de nuevo pisa esos archivos (los datos viven acá).

Uso: python -I -B tools/build_boons.py .   (después: godot --headless --path . --import)
"""
import json
import os
import sys

GIVERS = {
    "zapdos": {
        "name": "Zapdos", "species": "zapdos", "title": "Señor de la tormenta", "color": [1.0, 0.86, 0.25],
        "banner": "res://sprites/ui/bendiciones/zapdos.png",
        "lines": [
            "(Un trueno parte el cielo.) «Sos lento. Tomá mi tormenta y dejá de serlo.»",
            "«Mewtwo cree que el cielo es suyo. Demostrale que se equivoca, chispa.»",
            "«No te regalo nada: te lo presto. Devolvémelo en rayos.»",
        ],
    },
    "articuno": {
        "name": "Articuno", "species": "articuno", "title": "Dama de la escarcha", "color": [0.55, 0.85, 1.0],
        "banner": "res://sprites/ui/bendiciones/articuno.png",
        "lines": [
            "(El aire se enfría de golpe.) «Tranquilo. El que se apura, se quiebra. Llevá mi calma.»",
            "«Todo lo que corre, se cansa. Todo lo que se congela, espera. Elegí con paciencia.»",
            "«Vi caer a muchos por este camino. Que mi hielo te cuide un poco más que a ellos.»",
        ],
    },
    "moltres": {
        "name": "Moltres", "species": "moltres", "title": "Ave de las llamas", "color": [1.0, 0.5, 0.2],
        "banner": "res://sprites/ui/bendiciones/moltres.png",
        "lines": [
            "(Una llamarada te envuelve sin quemarte.) «¡Por fin alguien con ganas de pelear! ¡Tomá, que arda todo!»",
            "«¡Eso, eso! ¡No pares! Lo que Mewtwo apagó, vos lo volvés a prender.»",
            "«Si vas a caer, caé prendido fuego. Y después levantate, como yo.»",
        ],
    },
}

# Rarezas: peso al sortear y por cuánto multiplica los números `scaled` de la bendición.
RARITIES = [
    {"id": "comun", "name": "Común", "weight": 60, "mult": 1.0, "color": [0.82, 0.86, 0.9]},
    {"id": "rara", "name": "Rara", "weight": 28, "mult": 1.25, "color": [0.35, 0.65, 1.0]},
    {"id": "epica", "name": "Épica", "weight": 10, "mult": 1.5, "color": [0.75, 0.4, 1.0]},
    {"id": "legendaria", "name": "Legendaria", "weight": 2, "mult": 1.8, "color": [1.0, 0.72, 0.2]},
]

# id, nombre, dador, ranura, efecto, params, claves que escalan, texto
BOONS = [
    # --- Zapdos: Paralizado ---
    ("golpe_estatico", "Golpe Estático", "zapdos", "ataque1", "hit_status",
     {"slot": 0, "status": "paralizado", "chance": 0.2}, ["chance"],
     "Tus golpes con el Ataque 1 ({tecla}) tienen {chance%} de dejar Paralizado."),
    ("rayo_celeste", "Rayo Celeste", "zapdos", "ataque2", "hit_blast",
     {"slot": 1, "pct": 0.25, "radius": 30.0, "status": "paralizado", "status_chance": 0.2, "element": "electrico", "word": "¡Rayo!"}, ["pct"],
     "Donde pega tu Ataque 2 ({tecla}) cae un rayo: {pct%} del daño de más a él y a los que estén cerca."),
    ("paso_de_trueno", "Paso de Trueno", "zapdos", "esquive", "dodge_blast",
     {"power": 0.45, "radius": 42.0, "cooldown": 3.0, "status": "paralizado", "status_chance": 0.35, "element": "electrico", "word": "¡Descarga!"}, ["power"],
     "Al esquivar ({tecla}) soltás una descarga: {power} de daño a los que tenías cerca y a veces los paraliza (una vez cada 3 s)."),
    ("sobrecarga", "Sobrecarga", "zapdos", "pasiva", "bonus_vs_status",
     {"statuses": ["paralizado"], "pct": 0.2}, ["pct"],
     "Hacés {pct%} más de daño a los Paralizados."),
    ("cadena", "Rayo en Cadena", "zapdos", "pasiva", "chain",
     {"status": "paralizado", "pct": 0.3, "range": 70.0}, ["pct"],
     "Pegarle a un Paralizado hace saltar una chispa al enemigo más cercano: {pct%} del daño."),
    ("pila", "Pila Cargada", "zapdos", "pasiva", "kill_pp",
     {"pct": 0.06}, ["pct"],
     "Cada enemigo que cae te devuelve {pct%} de la barra de PP."),
    # --- Articuno: Frenado, Escarcha, Congelado ---
    ("toque_gelido", "Toque Gélido", "articuno", "ataque1", "hit_status",
     {"slot": 0, "status": "escarcha", "chance": 0.35}, ["chance"],
     "Tus golpes con el Ataque 1 ({tecla}) tienen {chance%} de sumar Escarcha (con 5 se congela)."),
    ("ventisca", "Ventisca", "articuno", "ataque3", "hit_blast",
     {"slot": 2, "pct": 0.2, "radius": 38.0, "status": "frenado", "status_chance": 1.0, "element": "hielo", "word": "¡Ventisca!"}, ["pct"],
     "Donde pega tu Ataque 3 ({tecla}) estalla una ventisca: Frenado y {pct%} del daño a los que estén cerca."),
    ("estela_helada", "Estela Helada", "articuno", "esquive", "dodge_blast",
     {"power": 0.3, "radius": 44.0, "cooldown": 3.0, "status": "frenado", "status_chance": 1.0, "element": "hielo", "word": "¡Escarcha!"}, ["power"],
     "Al esquivar ({tecla}) dejás una ráfaga helada: Frenado y {power} de daño a los que tenías cerca (una vez cada 3 s)."),
    ("hielo_quebradizo", "Hielo Quebradizo", "articuno", "pasiva", "bonus_vs_status",
     {"statuses": ["congelado", "frenado", "escarcha"], "pct": 0.18}, ["pct"],
     "Hacés {pct%} más de daño a los Frenados, con Escarcha o Congelados."),
    ("coraza_de_escarcha", "Coraza de Escarcha", "articuno", "pasiva", "thorns",
     {"status": "frenado", "cooldown": 5.0, "power": 0.4}, ["power"],
     "El que te pega queda Frenado y recibe {power} de daño (una vez cada 5 s)."),
    ("aliento_polar", "Aliento Polar", "articuno", "pasiva", "first_strike",
     {"pct": 0.3}, ["pct"],
     "Tu primer golpe a un enemigo con la vida entera hace {pct%} más de daño."),
    # --- Moltres: Quemado ---
    ("garra_ardiente", "Garra Ardiente", "moltres", "ataque1", "hit_status",
     {"slot": 0, "status": "quemado", "chance": 0.25}, ["chance"],
     "Tus golpes con el Ataque 1 ({tecla}) tienen {chance%} de dejar Quemado."),
    ("estallido", "Estallido Ígneo", "moltres", "ataque4", "hit_blast",
     {"slot": 3, "pct": 0.3, "radius": 36.0, "status": "quemado", "status_chance": 0.4, "element": "fuego", "word": "¡Estallido!"}, ["pct"],
     "Donde pega tu Ataque 4 ({tecla}) hay una explosión: {pct%} del daño de más a él y a los que estén cerca, y suele quemar."),
    ("estela_de_fuego", "Estela de Fuego", "moltres", "esquive", "dodge_blast",
     {"power": 0.4, "radius": 42.0, "cooldown": 3.0, "status": "quemado", "status_chance": 0.5, "element": "fuego", "word": "¡Llamas!"}, ["power"],
     "Al esquivar ({tecla}) dejás una llamarada: {power} de daño a los que tenías cerca y la mitad de las veces los quema (una vez cada 3 s)."),
    ("combustion", "Combustión", "moltres", "pasiva", "kill_blast",
     {"need": "quemado", "power": 0.8, "radius": 46.0, "status": "quemado", "status_chance": 0.5, "element": "fuego", "word": "¡Combustión!"}, ["power"],
     "Los Quemados explotan al caer: {power} de daño a los enemigos que tengan cerca."),
    ("brasas", "Brasas Vivas", "moltres", "pasiva", "bonus_vs_status",
     {"statuses": ["quemado"], "pct": 0.2}, ["pct"],
     "Hacés {pct%} más de daño a los Quemados."),
    ("ave_fenix", "Ave Fénix", "moltres", "pasiva", "phoenix",
     {"below": 0.25, "heal": 0.2}, ["heal"],
     "Una vez por sala, si tu vida baja de 25 %, recuperás {heal%} de golpe."),
]


def gd(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return "[" + ", ".join(gd(v) for v in value) + "]"
    if isinstance(value, dict):
        return "{\n" + ",\n".join("%s: %s" % (gd(k), gd(v)) for k, v in value.items()) + "\n}"
    raise TypeError(value)


def main(root):
    out = os.path.join(root, "data/boons")
    os.makedirs(out, exist_ok=True)
    for old in os.listdir(out):
        if old.endswith(".tres"):
            os.remove(os.path.join(out, old))
    for bid, name, giver, slot, effect, params, scaled, text in BOONS:
        assert giver in GIVERS and all(k in params for k in scaled), bid
        body = ('[gd_resource type="Resource" script_class="BoonData" format=3]\n\n'
                '[ext_resource type="Script" path="res://scripts/resources/boon_data.gd" id="1_boon"]\n\n'
                '[resource]\nscript = ExtResource("1_boon")\n'
                'id = %s\ndisplay_name = %s\ngiver = %s\nslot = %s\neffect = %s\nparams = %s\nscaled = PackedStringArray(%s)\ntext = %s\n'
                % (gd(bid), gd(name), gd(giver), gd(slot), gd(effect), gd(params), ", ".join(gd(k) for k in scaled), gd(text)))
        with open(os.path.join(out, bid + ".tres"), "w", encoding="utf8", newline="\n") as f:
            f.write(body)
    cfg = {
        "_doc": "Bendiciones del Modo Desafío (R-2): los dadores (legendarios con su especie, color, cartel y frases) y las rarezas (peso al sortear y multiplicador de los números). Lo genera tools/build_boons.py: editar ahí. level_step = cuánto suma cada nivel de más de una bendición (Caramelo Raro, R-3). options = cuántas te ofrecen.",
        "options": 3,
        "level_step": 0.25,
        "givers": GIVERS,
        "rarities": RARITIES,
    }
    with open(os.path.join(root, "data/rogue/bendiciones.json"), "w", encoding="utf8", newline="\n") as f:
        json.dump(cfg, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("%d bendiciones, %d dadores" % (len(BOONS), len(GIVERS)))


if __name__ == "__main__":
    main(sys.argv[1])
