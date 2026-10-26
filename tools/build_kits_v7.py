"""Genera los kits v7 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda B; pedido del usuario 2026-10-26): Clefairy, Jigglypuff,
Abra, Goldeen, Magnemite y Meowth en data/kits/<especie>/, más sus estados nuevos. Mismo formato que
tools/build_kits_v6.py (reusa sus ayudas).

Decisiones (con lo que recomendaba la propuesta): el Metrónomo elige entre los ataques de **todos los kits** (no los
que lanza una firma, ni Autodestrucción); las monedas del Día de Pago de **tu** Meowth suman a tu dinero.

Uso: python -I -B tools/build_kits_v7.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos. Después: tools/build_learnsets.gd, tools/apply_evolutions.gd (Clefable,
Wigglytuff, Seaking, Magneton, Persian heredan) y otra vez tools/build_learnsets.gd.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_kits_v3 import move_tres, write  # noqa: E402
from build_kits_v4 import write_status, hook_species, write_kit  # noqa: E402
from build_kits_v6 import mv, melee, sig, _drop_inherited  # noqa: E402

STATUSES = {
    "inflado": dict(name="Inflado", color=(1.0, 0.75, 0.85), duration=6.0, element="normal", max_stacks=3,
                    knockback_mult=0.6, tint_strength=0.2, fx_amount=2),
    "reducido": dict(name="Reducción", color=(1.0, 0.8, 0.9), duration=3.0, element="normal", speed_mult=1.15,
                     damage_taken_mult=0.75, tint_strength=0.25, fx_amount=3),
}

DEFENSES = ["fortaleza", "refugio", "rizo", "sintesis", "refuerzo"]

KITS = {
    # --- Clefairy: caótico lunar con Metrónomo. ---
    "clefairy": ("caotico", 45, sig("luz_de_luna", "Luz de Luna", "metronome_mechanic.gd", (1.0, 0.75, 0.85),
                 "Metrónomo lanza un ataque al azar de cualquier kit del juego. Cada uno carga la luna (3 marcas); con la luna llena, el próximo elige entre los 5 más fuertes.",
                 {"metronome_move": "metronomo", "charges": 3, "top": 5, "exclude": ["autodestruccion"]}), [
        melee("doble_bofeton_clefairy", "Doble Bofetón", "normal", 20, 1.0, 4, combo_window=0.45, step_cd=0.12,
              final_knockback=180),
        mv("canto_clefairy", "Canto", "normal", "ZONE", "est", 0, 12.0, 0, zone_radius=42, zone_duration=3,
           placement_range=0, zone_traps=False, zone_tick=99.0, dwell_time=0.6, dwell_status="dormido"),
        mv("reduccion_clefairy", "Reducción", "normal", "SELF_BUFF", "est", 0, 9.0, 0, self="reducido"),
        mv("metronomo_clefairy", "Metrónomo", "normal", "SELF_BUFF", "est", 0, 6.0, 0),
    ]),
    # --- Jigglypuff: cantante inflable que castiga a los dormidos. ---
    "jigglypuff": ("control", 35, sig("inflado_marcador", "Inflado y Marcador", "puff_mechanic.gd", (1.0, 0.7, 0.8),
                   "Cada golpe que recibe lo infla (hasta 3: menos empuje). Rodar gasta el inflado (+25% por cada uno). Sus golpes a un dormido le dejan un garabato en la cara (Expuesto).",
                   {"puff_status": "inflado", "roll_move": "rodar", "roll_per_stack": 0.25, "doodle_status": "expuesto"},
                   max=0), [
        melee("destructor_jigglypuff", "Destructor", "normal", 40, 1.0, 2),
        mv("rodar_jigglypuff", "Rodar", "roca", "DASH", "fis", 40, 3.5, 220, dash_time=0.4, invulnerable_time=0.0,
           recovery=0.2),
        mv("rizo_defensa_jigglypuff", "Rizo Defensa", "normal", "SELF_BUFF", "est", 0, 9.0, 0, self="rizo"),
        mv("canto_jigglypuff", "Canto", "normal", "ZONE", "est", 0, 12.0, 0, cast_time=0.6, zone_radius=60,
           zone_duration=3, placement_range=0, zone_traps=False, zone_tick=99.0, dwell_time=0.8,
           dwell_status="dormido"),
    ]),
    # --- Abra: el que no se deja atrapar. ---
    "abra": ("velocista", 90, sig("sueno_vigilante", "Sueño Vigilante", "wary_mechanic.gd", (0.95, 0.8, 0.4),
             "Cuando le pegan se teletransporta solo lejos del atacante (cada 6 s). Dormido o paralizado no se escapa: así se lo atrapa.",
             {"blink_distance": 90.0, "cooldown": 6.0, "pinned_by": ["dormido", "paralizado"]}), [
        mv("destello_psiquico_abra", "Destello Psíquico", "psiquico", "PROJECTILE", "esp", 30, 1.0, 70, speed=300,
           size=4, lifetime=0.8),
        mv("teletransporte_abra", "Teletransporte", "psiquico", "DASH", "est", 0, 3.0, 0, dash_time=0.2,
           dash_hits=False, invulnerable_time=0.3),
        mv("confusion_abra", "Confusión", "psiquico", "PROJECTILE", "esp", 50, 2.0, 110, speed=260, size=5,
           lifetime=0.8, status="desorientado", chance=0.3),
        mv("teletransporte_lejano_abra", "Teletransporte Lejano", "psiquico", "DASH", "est", 0, 10.0, 0,
           dash_time=0.45, dash_hits=False, invulnerable_time=0.5),
    ]),
    # --- Goldeen: anti-tanque con cuerno; rápido en el agua, aletea en seco. ---
    "goldeen": ("perseguidor", 35, sig("cuerno_perforador", "Cuerno Perforador", "body_trait_mechanic.gd", (0.95, 0.55, 0.35),
                "Sus golpes de cuerno (Picotazo, Cornada) atraviesan las defensas: ×1,6 contra Fortaleza, Refugio, Rizo Defensa... Mojado se mueve ×1,3; en seco, ×0,85.",
                {"pierce_prefixes": ["picotazo", "cornada"], "pierce_statuses": DEFENSES, "pierce_mult": 1.6,
                 "wet_speed": 1.3, "dry_speed": 0.85}, max=0), [
        melee("picotazo_goldeen", "Picotazo", "volador", 35, 0.8, 2),
        mv("supersonico_goldeen", "Supersónico", "normal", "CHANNEL", "est", 0, 6.0, 0, channel_time=0.4,
           cone_angle_deg=40, cone_length=60, tick_interval=0.2, on_hit=["desorientado"]),
        mv("hidrochorro_goldeen", "Hidrochorro", "agua", "AREA", "esp", 15, 6.0, 120, radius=55, on_hit=["empapado"],
           recovery=0.1),
        mv("cornada_goldeen", "Cornada", "normal", "DASH", "fis", 65, 5.0, 240, cast_time=0.15, dash_time=0.35,
           invulnerable_time=0.0, recovery=0.25),
    ]),
    # --- Magnemite: torreta magnética que atrae. ---
    "magnemite": ("espaciador", 100, sig("magnetismo", "Magnetismo", "body_trait_mechanic.gd", (0.7, 0.75, 0.85),
                  "Flota: no lo ralentizan ni lo enraízan. Sus disparos eléctricos atraen un poco al rival en vez de empujarlo, y pega +25% a lo que marcó con Fijar Blanco (Expuesto).",
                  {"immune": ["ralentizado", "enraizado"], "bonus_vs_status": "expuesto", "bonus_move_prefix": "",
                   "bonus_mult": 1.25}, max=0), [
        mv("impactrueno_magnemite", "Impactrueno", "electrico", "PROJECTILE", "esp", 40, 1.0, -70, speed=330, size=4,
           lifetime=0.9, status="paralizado", chance=0.1),
        mv("bomba_sonica_magnemite", "Bomba Sónica", "normal", "AREA", "esp", 25, 4.0, 160, radius=55, recovery=0.1),
        mv("supersonico_magnemite", "Supersónico", "normal", "CHANNEL", "est", 0, 6.0, 0, channel_time=0.4,
           cone_angle_deg=40, cone_length=60, tick_interval=0.2, on_hit=["desorientado"]),
        mv("fijar_blanco_magnemite", "Fijar Blanco", "normal", "PROJECTILE", "est", 0, 8.0, -120, speed=360,
           size=5, lifetime=1.0, on_hit=["expuesto"]),
    ]),
    # --- Meowth: ladrón de monedas. ---
    "meowth": ("asesino", 30, sig("dia_de_pago", "Día de Pago", "payday_mechanic.gd", (1.0, 0.85, 0.3),
               "Cada golpe que conecta hace saltar monedas: si es tu Meowth, suman a tu dinero. Cada 4 golpes le bajan 0,5 s todas las recargas.",
               {"coins_per_hit": 5, "hits_for_rush": 4, "rush_cut": 0.5}), [
        melee("aranazo_meowth", "Arañazo", "normal", 40, 0.8, 3, step_cd=0.18),
        melee("mordisco_meowth", "Mordisco", "siniestro", 60, 2.5, 1, final_knockback=170, status="herido",
              chance=0.3),
        mv("finta_meowth", "Finta", "siniestro", "LUNGE", "fis", 40, 4.0, 90, lunge_range=90, lunge_speed=560,
           followup_delay=0.1, followup_power_mult=0.8, followup_knockback=160, recovery=0.1),
        melee("golpes_furia_meowth", "Golpes Furia", "normal", 18, 4.0, 5, combo_window=0.4, step_cd=0.1,
              knockback=20, final_knockback=150),
    ]),
}


def main():
    root = sys.argv[1]
    for sid, p in STATUSES.items():
        write_status(root, sid, p)
    for species, spec in KITS.items():
        folder = os.path.join(root, "data", "kits", species)
        os.makedirs(folder, exist_ok=True)
        for m in spec[3] + (spec[4] if len(spec) > 4 else []):
            write(os.path.join(folder, m["id"] + ".tres"), re.sub(r"strike_count = (\d+)\.0", r"strike_count = \1", move_tres(m)))
        write_kit(root, species, spec)
        _drop_inherited(root, species)
        hook_species(root, species)
        print(species, "->", [m["name"] for m in spec[3]])


if __name__ == "__main__":
    main()
