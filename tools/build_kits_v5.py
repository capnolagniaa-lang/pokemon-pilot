"""Genera los kits v5 (capítulo 2, docs/PLAN_CAPITULO_2.md parte K): Staryu y **Starmie jefa** (la de Misty, como
Onix con Brock) y las evoluciones que cambian mucho su forma de pelear (Butterfree, Beedrill, Kadabra, Gyarados;
las demás heredan el kit de su preevolución con tools/apply_evolutions.gd) en data/kits/<especie>/, más sus estados
nuevos. Usa el mismo formato que tools/build_kits_v4.py.

Uso: python -I -B tools/build_kits_v5.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos (los ajustes a mano se pierden). Después: tools/build_learnsets.gd.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_kits_v3 import move_tres, write  # noqa: E402
from build_kits_v4 import write_status, hook_species, write_kit  # noqa: E402

STATUSES = {
    "nucleo_brillante": dict(name="Núcleo Brillante", color=(0.95, 0.45, 0.8), duration=30.0, element="psiquico",
                             attack_mult=1.2, speed_mult=1.2, tint_strength=0.3, fx_amount=4),
    "agilidad": dict(name="Agilidad", color=(0.95, 0.9, 0.4), duration=4.0, element="psiquico", speed_mult=1.4,
                     tint_strength=0.2, fx_amount=3),
    "recuperando": dict(name="Recuperación", color=(0.55, 0.9, 1.0), duration=2.5, element="normal", speed_mult=0.5,
                        heal_per_second=0.08, tint_strength=0.3, fx_amount=6),
}


def giro_rapido(i, power, cooldown, knockback, dash_time):
    return dict(id="giro_rapido_" + i, name="Giro Rápido", el="normal", kind="DASH", cat="fis", power=power,
                cooldown=cooldown, knockback=knockback, dash_time=dash_time, invulnerable_time=0.0, recovery=0.2)


KITS = {
    # Staryu: estrella que gira y se regenera. Moja con Pistola Agua y le pega más a lo mojado.
    "staryu": ("velocista", 55, dict(id="nucleo_staryu", name="Núcleo", script="core_mechanic.gd",
               color=(0.95, 0.75, 0.35), max=100, gains={"hit_dealt": 12.0, "damage_received": 8.0},
               params={"spin_move": "giro_rapido", "deflect_radius": 18.0, "wet_bonus": 1.2, "core_heal": 0.1},
               desc="Girando (Giro Rápido) desvía los proyectiles. Le pega 20% más a lo Empapado. La barra sube al pegar y al recibir: llena, el núcleo regenera 10% de la vida."), [
        dict(id="placaje_staryu", name="Placaje", el="normal", kind="MELEE", cat="fis", power=40, cooldown=0.9,
             combo_steps=2, combo_window=0.6, combo_step_cooldown=0.25, knockback=50, final_knockback=190,
             melee_range=12, swing_radius=11),
        dict(id="pistola_agua_staryu", name="Pistola Agua", el="agua", kind="PROJECTILE", cat="esp", power=40,
             cooldown=1.0, knockback=60, speed=330, size=4, lifetime=0.6, on_hit=["empapado"]),
        giro_rapido("staryu", 20, 4.0, 170, 0.35),
        dict(id="fortaleza_staryu", name="Fortaleza", el="normal", kind="SELF_BUFF", cat="est", power=0,
             cooldown=9.0, knockback=0, self="fortaleza"),
    ]),
    # Starmie: la JEFA de Misty (Nv. 21). Hidropulso marea, Rapidez no se esquiva fácil (abanico), Giro Rápido
    # desvía, Recuperación cura. A mitad de vida el núcleo brilla: onda que empuja y moja, y más ataque/velocidad.
    "starmie": ("control", 85, dict(id="nucleo_starmie", name="Núcleo Prisma", script="core_mechanic.gd",
                color=(0.95, 0.45, 0.8), max=100, gains={"hit_dealt": 8.0, "damage_received": 6.0},
                params={"spin_move": "giro_rapido", "deflect_radius": 24.0, "wet_bonus": 1.25, "core_heal": 0.08,
                        "phase_at": 0.5, "phase_status": "nucleo_brillante", "scale": 1.3, "knockback_mult": 0.35,
                        "pulse_move": "res://data/kits/starmie/pulso_nucleo.tres"},
                desc="Jefa. Grande y casi no la empujan. Girando desvía los proyectiles; le pega 25% más a lo Empapado; la barra llena regenera 8% de la vida. A mitad de vida el núcleo brilla: una onda empuja y moja a todos y queda más fuerte y rápida hasta el final."), [
        dict(id="hidropulso_starmie", name="Hidropulso", el="agua", kind="PROJECTILE", cat="esp", power=60,
             cooldown=1.4, knockback=120, speed=300, size=6, lifetime=0.8, on_hit=["empapado"],
             status="desorientado", chance=0.2, recovery=0.1),
        dict(id="rapidez_starmie", name="Rapidez", el="normal", kind="PROJECTILE", cat="esp", power=35,
             cooldown=3.5, knockback=50, speed=360, size=4, lifetime=0.7, projectile_count=5, spread_deg=50,
             recovery=0.15),
        giro_rapido("starmie", 30, 3.5, 220, 0.4),
        dict(id="recuperacion_starmie", name="Recuperación", el="normal", kind="SELF_BUFF", cat="est", power=0,
             cooldown=16.0, knockback=0, self="recuperando"),
    ], [dict(id="pulso_nucleo", name="Pulso del Núcleo", el="psiquico", kind="AREA", cat="esp", power=40, cooldown=0,
             knockback=260, radius=95, on_hit=["empapado", "expuesto"])]),
    # --- Evoluciones con kit propio (criterio del usuario 2026-10-25: "siguen con el mismo kit a menos que cambie
    # mucho su forma de pelear") ---
    # Butterfree: de capullo a mariposa. Vuela como Pidgey (Aliento) y controla con polvos y Confusión.
    "butterfree": ("control", 95, dict(id="vuelo_butterfree", name="Alas de Polvo", script="flight_mechanic.gd",
                   color=(0.75, 0.7, 1.0), max=100, gains={},
                   params={"lift_cost": 30.0, "max_air_time": 1.8, "drain_per_second": 35.0, "regen_per_second": 30.0,
                           "height": 14.0, "dive_damage_mult": 1.3},
                   desc="Vuela como Pidgey: al esquivar con Aliento se eleva y en el aire no le llegan los golpes cuerpo a cuerpo. El primer ataque desde el aire pega más."), [
        dict(id="confusion_butterfree", name="Confusión", el="psiquico", kind="PROJECTILE", cat="esp", power=50,
             cooldown=1.6, knockback=110, speed=260, size=5, lifetime=0.8, status="desorientado", chance=0.3),
        dict(id="tornado_butterfree", name="Tornado", el="volador", kind="PROJECTILE", cat="esp", power=40,
             cooldown=1.6, knockback=190, speed=210, size=7, lifetime=0.6, deflects_projectiles=True, recovery=0.08),
        dict(id="paralizador_butterfree", name="Paralizador", el="planta", kind="ZONE", cat="est", power=0,
             cooldown=6.0, knockback=0, zone_radius=24, zone_duration=4, placement_range=110, zone_traps=False,
             zone_tick=0.6, zone_max_count=2, on_hit=["paralizado"]),
        dict(id="somnifero_butterfree", name="Somnífero", el="planta", kind="ZONE", cat="est", power=0,
             cooldown=12.0, cast_time=0.3, knockback=0, recovery=0.2, placement_range=110, zone_traps=False,
             zone_tick=99.0, dwell_time=0.6, dwell_status="dormido"),
    ]),
    # Beedrill: de capullo a avispa asesina. Rápida; remata lo envenenado (Aguijón más fuerte que el de Weedle).
    "beedrill": ("asesino", 35, dict(id="aguijon_letal", name="Aguijón Letal", script="venom_mechanic.gd",
                 color=(0.95, 0.8, 0.2), max=0, gains={}, params={"per_stack": 0.12, "max_mult": 1.6},
                 desc="Le pega más a lo envenenado: +12% por cada stack de Envenenado del rival (hasta +60%)."), [
        dict(id="ataque_furia_beedrill", name="Ataque Furia", el="normal", kind="MELEE", cat="fis", power=18,
             cooldown=3.0, combo_steps=5, combo_window=0.4, combo_step_cooldown=0.1, knockback=20,
             final_knockback=160, melee_range=14, swing_radius=11, status="envenenado", chance=0.2),
        dict(id="doble_ataque_beedrill", name="Doble Ataque", el="bicho", kind="LUNGE", cat="fis", power=30,
             cooldown=3.0, knockback=60, lunge_range=80, lunge_speed=480, followup_delay=0.14,
             followup_power_mult=1.0, followup_knockback=150, status="envenenado", chance=0.5, recovery=0.1),
        dict(id="pin_misil_beedrill", name="Pin Misil", el="bicho", kind="PROJECTILE", cat="fis", power=25,
             cooldown=4.5, knockback=50, speed=380, size=3, lifetime=0.6, projectile_count=5, spread_deg=36,
             recovery=0.15),
        dict(id="agilidad_beedrill", name="Agilidad", el="psiquico", kind="SELF_BUFF", cat="est", power=0,
             cooldown=10.0, knockback=0, self="agilidad"),
    ]),
    # Kadabra: de Abra que solo huye a psíquico ofensivo. Teletransporte prepara un Golpe Mental.
    "kadabra": ("control", 105, dict(id="mente_rapida", name="Mente Rápida", script="blink_mechanic.gd",
                color=(0.95, 0.55, 0.95), max=100, gains={}, params={"blink_move": "teletransporte", "window": 2.0,
                "bonus": 1.5},
                desc="Después de Teletransporte, el próximo golpe (2 s) es un Golpe Mental: +50% de daño y desorienta seguro."), [
        dict(id="confusion_kadabra", name="Confusión", el="psiquico", kind="PROJECTILE", cat="esp", power=50,
             cooldown=1.3, knockback=110, speed=280, size=5, lifetime=0.8, status="desorientado", chance=0.3),
        dict(id="psicorrayo_kadabra", name="Psicorrayo", el="psiquico", kind="CHANNEL", cat="esp", power=65,
             cooldown=6.0, knockback=60, channel_time=0.9, cone_angle_deg=12, cone_length=140, tick_interval=0.15,
             status="desorientado", chance=0.3),
        dict(id="kinetico_kadabra", name="Kinético", el="psiquico", kind="AREA", cat="est", power=0, cooldown=8.0,
             knockback=120, radius=60, on_hit=["desorientado"], recovery=0.1),
        dict(id="teletransporte_kadabra", name="Teletransporte", el="psiquico", kind="DASH", cat="est", power=0,
             cooldown=4.0, knockback=0, dash_time=0.2, dash_hits=False, invulnerable_time=0.3),
    ]),
    # Gyarados: de Magikarp que salpica a serpiente marina furiosa. Pesada; cuanto más le pegan, peor.
    "gyarados": ("bruiser", 45, dict(id="ira_gyarados", name="Ira de Dragón", script="rage_mechanic.gd",
                 color=(0.3, 0.5, 1.0), max=100, gains={"damage_received": 15.0, "hit_dealt": 4.0},
                 params={"self_status": "enfurecido"},
                 desc="Sube al recibir golpes (y un poco al pegar). Llena, Gyarados se enfurece 5 s: pega 30% más y se mueve más rápido."), [
        dict(id="mordisco_gyarados", name="Mordisco", el="siniestro", kind="MELEE", cat="fis", power=60,
             cooldown=1.1, combo_steps=2, combo_window=0.6, combo_step_cooldown=0.25, knockback=70,
             final_knockback=230, melee_range=16, swing_radius=14, status="herido", chance=0.3),
        dict(id="furia_dragon_gyarados", name="Furia Dragón", el="dragon", kind="PROJECTILE", cat="esp", power=50,
             cooldown=2.0, knockback=140, speed=260, size=8, lifetime=0.8),
        dict(id="ciclon_gyarados", name="Ciclón", el="dragon", kind="AREA", cat="esp", power=40, cooldown=6.0,
             knockback=220, radius=65, status="desorientado", chance=0.2, recovery=0.15),
        dict(id="hidrobomba_gyarados", name="Hidrobomba", el="agua", kind="PROJECTILE", cat="esp", power=110,
             cooldown=8.0, cast_time=0.5, knockback=320, speed=330, size=9, lifetime=0.8, on_hit=["empapado"],
             recovery=0.35),
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
            write(os.path.join(folder, m["id"] + ".tres"), move_tres(m))
        write_kit(root, species, spec)
        hook_species(root, species)
        print(species, "->", [m["name"] for m in spec[3]])


if __name__ == "__main__":
    main()
