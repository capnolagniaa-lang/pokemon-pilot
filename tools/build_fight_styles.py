"""Arma los estilos de combate de arena (data/estilos/<especie>.tres, FightStyle): cómo se mueve cada Pokémon con kit
y sus combos con nombre (docs/PLAN_IDENTIDAD_COMBATE.md, "Combate de arena"; pedido del usuario 2026-10-24).

Uso: python -I -B tools/build_fight_styles.py <carpeta del proyecto>
Correrlo de nuevo PISA data/estilos/ (los ajustes a mano en el inspector se pierden).
"""
import os
import sys

# especie -> (estilo, [(nombre, primer ataque, segundo ataque, daño, empuje, estado)])
STYLES = {
    "charmander": ("normal", [("Garra Ardiente", "aranazo_embestida", "ascuas_abanico", 1.4, 1.0, "quemado")]),
    "bulbasaur": ("normal", [("Látigo Tóxico", "latigo_cepa", "polvo_veneno", 1.3, 1.0, "envenenado")]),
    "bellsprout": ("normal", [("Látigo Tóxico", "latigo_cepa", "polvo_veneno", 1.3, 1.0, "envenenado")]),
    "squirtle": ("normal", [("Chorro a Quemarropa", "placaje_kit", "pistola_agua_kit", 1.5, 1.5, "")]),
    "pikachu": ("agil", [("Descarga Relámpago", "ataque_rapido_kit", "impactrueno_kit", 1.4, 1.0, "paralizado")]),
    "pidgey": ("volador", [("Picada del Viento", "pidgey_tornado", "pidgey_ataque_rapido", 1.5, 1.2, "")]),
    "rattata": ("agil", [("Mordida Veloz", "rattata_ataque_rapido", "rattata_mordisco", 1.4, 1.0, "herido")]),
    "vulpix": ("normal", [("Llama Fatua", "fuego_fatuo", "vulpix_ascuas", 1.4, 1.0, "quemado")]),
    "oddish": ("normal", [("Polen Pegajoso", "absorber_kit", "paralizador_kit", 1.3, 1.0, "esporas")]),
    "paras": ("normal", [("Corte Vampiro", "aranazo_kit", "chupavidas_kit", 1.4, 1.0, "")]),
    "psyduck": ("normal", [("Chorro Mareado", "confusion_kit", "pistola_agua_psyduck", 1.4, 1.0, "desorientado")]),
    "poliwag": ("agil", [("Burbuja Reventada", "burbuja_kit", "pistola_agua_poliwag", 1.6, 1.5, "")]),
    "growlithe": ("agil", [("Colmillo Ígneo", "mordisco_kit", "ascuas_growlithe", 1.4, 1.0, "quemado")]),
    "eevee": ("agil", [("Placaje a Ciegas", "ataque_arena_eevee", "placaje_eevee", 1.4, 1.0, ""),
                       ("Embestida Doble", "ataque_rapido_eevee", "derribo_kit", 1.4, 1.3, "")]),
    "seel": ("pesado", [("Cabezazo Helado", "viento_hielo_kit", "golpe_cabeza_kit", 1.5, 1.2, "escarcha")]),
    "geodude": ("pesado", [("Avalancha", "lanzarrocas_kit", "rodar_kit", 1.4, 1.3, "")]),
    "caterpie": ("normal", [("Placaje Enredado", "disparo_demora_caterpie", "placaje_caterpie", 1.4, 1.0, "seda")]),
    "weedle": ("agil", [("Aguijón Doble", "disparo_demora_weedle", "doble_ataque_weedle", 1.4, 1.0, "envenenado")]),
    "metapod": ("pesado", [("Embestida de Capullo", "disparo_demora_metapod", "derribo_metapod", 1.5, 1.3, "")]),
    "kakuna": ("pesado", [("Púas Rodantes", "picotazo_veneno_kakuna", "derribo_kakuna", 1.4, 1.2, "envenenado")]),
    "spearow": ("volador", [("Caza", "grunido_spearow", "persecucion_spearow", 1.5, 1.2, "")]),
    "mankey": ("agil", [("Golpe Bajo y Alto", "patada_baja_mankey", "golpe_karate_mankey", 1.5, 1.3, "")]),
    "sandshrew": ("normal", [("Garra en la Tormenta", "ataque_arena_sandshrew", "aranazo_sandshrew", 1.4, 1.0, "")]),
    "onix": ("pesado", [("Sepultura", "atadura_onix", "tumba_rocas_onix", 1.5, 1.0, "ralentizado"),
                        ("Derrumbe", "atadura_onix", "excavar_onix", 1.4, 1.3, "")]),
    # Capítulo 2 (docs/PLAN_CAPITULO_2.md, parte K): sin combos con nombre (los combos están apagados,
    # GameConfig.combos_enabled); el estilo de movimiento y el salto valen igual.
    "staryu": ("agil", []),
    "starmie": ("agil", []),
    "nidoran_f": ("normal", []),
    "nidoran_m": ("agil", []),
    "nidorina": ("normal", []),
    "nidorino": ("agil", []),
    "jigglypuff": ("normal", []),
    "clefairy": ("normal", []),
    "zubat": ("volador", []),
    "ekans": ("normal", []),
    "abra": ("agil", []),
    "kadabra": ("agil", []),
    "magnemite": ("volador", []),
    "voltorb": ("agil", []),
    "grimer": ("pesado", []),
    "koffing": ("volador", []),
    "horsea": ("normal", []),
    "shellder": ("pesado", []),
    "goldeen": ("normal", []),
    "magikarp": ("normal", []),
    "slowpoke": ("pesado", []),
    "krabby": ("normal", []),
    "venonat": ("normal", []),
    "meowth": ("agil", []),
    "pidgeotto": ("volador", []),
    "raticate": ("agil", []),
    "butterfree": ("volador", []),
    "beedrill": ("volador", []),
    "ivysaur": ("normal", []),
    "charmeleon": ("normal", []),
    "wartortle": ("normal", []),
    "gyarados": ("pesado", []),
    # Kits v6 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda A): Raichu jefe es pesado (lento, como en el anime).
    "raichu": ("pesado", []),
    "machop": ("normal", []),
    "tentacool": ("normal", []),
    "omanyte": ("pesado", []),
    "kabuto": ("pesado", []),
}


# Saltan los cráteres con el esquive (pedido del usuario 2026-10-24: "como Charmander, Pikachu, Squirtle").
JUMPERS = {"charmander", "squirtle", "bulbasaur", "pikachu", "rattata", "vulpix", "growlithe", "eevee", "mankey",
           "sandshrew", "psyduck", "poliwag", "paras", "oddish", "bellsprout",
           # capítulo 2
           "nidoran_f", "nidoran_m", "nidorina", "nidorino", "jigglypuff", "clefairy", "meowth", "venonat", "raticate",
           "ivysaur", "charmeleon", "wartortle", "krabby", "abra", "kadabra", "machop"}


def main():
    root = sys.argv[1]
    out = os.path.join(root, "data", "estilos")
    os.makedirs(out, exist_ok=True)
    for sp, (style, combos) in STYLES.items():
        ext = ['[ext_resource type="Script" path="res://scripts/resources/fight_style.gd" id="1_s"]',
               '[ext_resource type="Script" path="res://scripts/resources/combo_data.gd" id="2_c"]']
        statuses = {}
        subs, ids = [], []
        for i, (name, a, b, dmg, kb, status) in enumerate(combos):
            body = ['[sub_resource type="Resource" id="Combo_%d"]' % i, 'script = ExtResource("2_c")',
                    'display_name = "%s"' % name, 'first = "%s"' % a, 'second = "%s"' % b,
                    "damage_mult = %s" % dmg, "knockback_mult = %s" % kb]
            if status:
                if status not in statuses:
                    statuses[status] = "st_%d" % len(statuses)
                    ext.append('[ext_resource type="Resource" path="res://data/status/%s.tres" id="%s"]' % (status, statuses[status]))
                body.append('status = ExtResource("%s")' % statuses[status])
            subs.append("\n".join(body))
            ids.append('SubResource("Combo_%d")' % i)
        text = "\n".join(['[gd_resource type="Resource" script_class="FightStyle" format=3]', ""] + ext + [""]
                         + ["\n\n".join(subs), "", "[resource]", 'script = ExtResource("1_s")', 'species_id = "%s"' % sp,
                            'move_style = "%s"' % style, "can_jump = %s" % ("true" if sp in JUMPERS else "false"), 'combos = Array[ExtResource("2_c")]([%s])' % ", ".join(ids), ""])
        with open(os.path.join(out, sp + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
    print("estilos:", len(STYLES))


if __name__ == "__main__":
    main()
