"""Genera los kits v8 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda C; pedido del usuario 2026-10-26): Drowzee, Grimer,
Koffing, Ponyta, Slowpoke y Magikarp en data/kits/<especie>/, más sus estados nuevos. Mismo formato que
tools/build_kits_v6.py (reusa sus ayudas).

Uso: python -I -B tools/build_kits_v8.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos. Después: tools/build_learnsets.gd, tools/apply_evolutions.gd (Hypno, Muk,
Weezing, Rapidash, Slowbro, Slowking heredan; Gyarados ya tiene kit propio) y otra vez tools/build_learnsets.gd.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_kits_v3 import move_tres, write  # noqa: E402
from build_kits_v4 import write_status, hook_species, write_kit  # noqa: E402
from build_kits_v6 import mv, melee, sig, _drop_inherited  # noqa: E402

STATUSES = {
    "somnolencia": dict(name="Somnolencia", color=(0.75, 0.6, 0.95), duration=6.0, element="psiquico", max_stacks=4,
                        speed_mult=0.95, tint_strength=0.2, fx_amount=2),
    "bostezo": dict(name="Bostezo", color=(0.85, 0.8, 1.0), duration=2.4, element="normal", speed_mult=0.9,
                    tint_strength=0.25, fx_amount=3),
}

KITS = {
    # --- Drowzee: come sueños; sus ataques psíquicos dan sueño. ---
    "drowzee": ("control", 60, sig("hipnosis_acumulable", "Hipnosis Acumulable", "stack_mechanic.gd", (0.85, 0.7, 0.4),
                "Cualquier ataque psíquico suyo suma Somnolencia al rival; con 4, se duerme. Comesueños roba vida (perfecto contra dormidos).",
                {"element_marks": {"psiquico": "somnolencia"}, "stack_status": "somnolencia", "stacks": 4,
                 "trigger_status": "dormido", "text": "¡Zzz...!"}, max=0), [
        melee("destructor_drowzee", "Destructor", "normal", 40, 1.0, 2),
        mv("confusion_drowzee", "Confusión", "psiquico", "PROJECTILE", "esp", 50, 1.5, 110, speed=260, size=5,
           lifetime=0.8, status="desorientado", chance=0.2),
        mv("anulacion_drowzee", "Anulación", "normal", "PROJECTILE", "est", 0, 9.0, 0, speed=240, size=5,
           lifetime=0.9, cooldown_lock=3.0, cast_time=0.2),
        mv("comesuenos_drowzee", "Comesueños", "psiquico", "PROJECTILE", "esp", 100, 7.0, 140, speed=230, size=7,
           lifetime=0.9, drain=0.5, cast_time=0.3, recovery=0.2),
    ]),
    # --- Grimer: lodo que no se deja frenar y deja rastro tóxico. ---
    "grimer": ("tanque", 25, sig("cuerpo_de_lodo", "Cuerpo de Lodo", "body_trait_mechanic.gd", (0.6, 0.45, 0.7),
               "No lo ralentizan ni lo envenenan. Al que le pega cuerpo a cuerpo lo deja pegoteado (ralentizado). Derretirse lo vuelve un charco que se desliza dejando lodo tóxico.",
               {"immune": ["ralentizado", "envenenado"], "thorns": 0.05, "thorns_status": "ralentizado",
                "thorns_chance": 1.0}, max=0), [
        melee("destructor_grimer", "Destructor", "normal", 45, 1.1, 2, on_hit=["ralentizado"]),
        mv("residuos_grimer", "Residuos", "veneno", "PROJECTILE", "esp", 65, 2.2, 90, speed=220, size=7,
           lifetime=0.9, status="envenenado", chance=0.3),
        mv("armadura_acida_grimer", "Armadura Ácida", "veneno", "SELF_BUFF", "est", 0, 10.0, 0, self="fortaleza"),
        mv("derretirse_grimer", "Derretirse", "veneno", "DASH", "est", 0, 6.0, 0, dash_time=0.5, dash_hits=False,
           invulnerable_time=0.8, trail_power=10, trail_status="envenenado", trail_status_chance=0.5,
           trail_duration=3.0),
    ]),
    # --- Koffing: trampero de nubes que explotan. ---
    "koffing": ("control", 70, sig("gas_inflamable", "Gas Inflamable", "gas_mechanic.gd", (0.75, 0.55, 0.85),
                "Sus nubes (Gas Venenoso, Pantalla de Humo) se prenden con cualquier fuego. Detonar las hace explotar todas a la vez.",
                {"detonate_move": "detonar", "max_clouds": 3}), [
        melee("placaje_koffing", "Placaje", "normal", 40, 1.0, 2),
        mv("gas_venenoso_koffing", "Gas Venenoso", "veneno", "ZONE", "est", 0, 5.0, 0, zone_radius=28,
           zone_duration=6, placement_range=110, zone_traps=False, zone_tick=0.6, zone_max_count=3,
           zone_flammable=True, on_hit=["envenenado"]),
        mv("pantalla_humo_koffing", "Pantalla de Humo", "normal", "ZONE", "est", 0, 8.0, 0, zone_radius=32,
           zone_duration=5, placement_range=90, zone_traps=False, zone_tick=0.5, zone_max_count=2,
           zone_flammable=True, on_hit=["desorientado"]),
        mv("detonar_koffing", "Detonar", "fuego", "AREA", "esp", 30, 8.0, 200, radius=45, recovery=0.2),
    ]),
    # --- Ponyta: velocista de carrera que galopa en fuego. ---
    "ponyta": ("velocista", 35, sig("galope", "Galope", "gallop_mechanic.gd", (1.0, 0.55, 0.2),
               "Correr derecho llena el galope: hasta ×1,4 de velocidad y una estela de fuego que prende el pasto. Sus embestidas pegan hasta +40% galopando. Girar fuerte lo pierde.",
               {"turn_deg": 35.0, "build_time": 1.5, "max_speed": 1.4, "trail_every": 18.0, "dash_bonus": 0.4}), [
        melee("pisoton_ponyta", "Pisotón", "normal", 65, 1.2, 1, final_knockback=180, on_hit=["ralentizado"]),
        mv("ascuas_ponyta", "Ascuas", "fuego", "PROJECTILE", "esp", 40, 1.0, 70, speed=300, size=4, lifetime=0.7,
           status="quemado", chance=0.1),
        mv("giro_fuego_ponyta", "Giro Fuego", "fuego", "ZONE", "esp", 15, 6.0, 0, zone_radius=22, zone_duration=3,
           placement_range=90, zone_traps=True, zone_tick=0.5, status="quemado", chance=0.3),
        mv("derribo_ponyta", "Derribo", "normal", "DASH", "fis", 90, 5.0, 260, dash_time=0.35, invulnerable_time=0.0,
           recovery=0.3),
    ]),
    # --- Slowpoke: tanque despistado que reacciona tarde. ---
    "slowpoke": ("tanque", 50, sig("reaccion_tardia", "Reacción Tardía", "slow_mechanic.gd", (1.0, 0.6, 0.7),
                 "De cada golpe recibe ahora el 70%; el resto le llega 2 s tarde, salvo que en ese tiempo él conecte un golpe. Bostezo: si el rival sigue con sueño a los 2 s, se duerme.",
                 {"now_part": 0.7, "delay": 2.0, "yawn_status": "bostezo", "yawn_delay": 2.0}), [
        melee("golpe_cabeza_slowpoke", "Golpe Cabeza", "normal", 70, 1.4, 1, final_knockback=220),
        mv("pistola_agua_slowpoke", "Pistola Agua", "agua", "PROJECTILE", "esp", 40, 1.2, 70, speed=300, size=4,
           lifetime=0.8),
        mv("pesca_cola_slowpoke", "Pesca con Cola", "agua", "WHIP", "fis", 20, 4.0, -220, whip_length=100,
           whip_width=10, recovery=0.15),
        mv("bostezo_slowpoke", "Bostezo", "normal", "PROJECTILE", "est", 0, 9.0, 0, speed=160, size=6, lifetime=1.2,
           on_hit=["bostezo"]),
    ]),
    # --- Magikarp: el chiste... con Azote y determinación. ---
    "magikarp": ("caotico", 30, sig("determinacion", "Determinación", "flail_mechanic.gd", (1.0, 0.5, 0.35),
                 "Azote pega más cuanto menos vida tiene (hasta ×3). Cada rival que derriba y sigue en pie le da 20 de EXP extra, para llegar a Gyarados.",
                 {"flail_move": "azote", "flail_max": 3.0, "exp_bonus": 20}), [
        mv("salpicadura_magikarp", "Salpicadura", "normal", "DASH", "est", 0, 1.5, 0, dash_time=0.3, dash_hits=False,
           invulnerable_time=0.2),
        melee("placaje_magikarp", "Placaje", "normal", 40, 1.0, 2),
        melee("azote_magikarp", "Azote", "normal", 40, 2.5, 1, final_knockback=200),
        mv("salpicadura_alta_magikarp", "Salpicadura Alta", "normal", "DASH", "est", 0, 6.0, 0, dash_time=0.5,
           dash_hits=False, invulnerable_time=0.45),
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
