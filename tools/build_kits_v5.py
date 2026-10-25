"""Genera los kits v5 (capítulo 2, docs/PLAN_CAPITULO_2.md parte K): Staryu y **Starmie jefa** (la de Misty, como
Onix con Brock) en data/kits/<especie>/, más sus estados nuevos. Usa el mismo formato que tools/build_kits_v4.py.

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
