"""Genera los kits v6 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda A; pedido del usuario 2026-10-26): Raichu (JEFE de
Lt. Surge, ya no hereda el de Pikachu), Zubat, Ekans, Machop, Nidoran♀, Nidoran♂, Horsea, Shellder, Tentacool y
Voltorb en data/kits/<especie>/, más sus estados nuevos y el estado de celda "chamuscado_electrico". Mismo formato
que tools/build_kits_v4.py (reusa write_kit y hook_species).

Firmas genéricas por parámetros (sin `if especie`): grounding_mechanic.gd (Toma de Tierra), still_mechanic.gd
(Enroscarse, Ancla, Camuflaje) y body_trait_mechanic.gd (Ecolocalización, Incansable, Púas, Oído Fino, Concha
Bivalva, Cuerpo de Agua).

Uso: python -I -B tools/build_kits_v6.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos (los ajustes a mano se pierden). Después: tools/build_learnsets.gd y
tools/apply_evolutions.gd (para que Golbat, Arbok, Machoke... hereden).
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_kits_v3 import move_tres, write  # noqa: E402
from build_kits_v4 import write_status, hook_species, write_kit  # noqa: E402

STATUSES = {
    "plantado": dict(name="Toma de Tierra", color=(1.0, 0.9, 0.3), duration=1.0, element="electrico", can_move=False,
                     can_act=False, tint_strength=0.35, fx_amount=8),
    "sobrecarga": dict(name="Sobrecarga", color=(1.0, 0.85, 0.2), duration=30.0, element="electrico", attack_mult=1.2,
                       tint_strength=0.3, fx_amount=5),
    "refuerzo": dict(name="Refuerzo", color=(0.7, 0.55, 0.95), duration=4.0, element="veneno", damage_taken_mult=0.7,
                     tint_strength=0.3, fx_amount=3),
}

GROUND_STATE = '''[gd_resource type="Resource" script_class="EnvCellState" format=3]

[ext_resource type="Script" path="res://scripts/resources/env_cell_state.gd" id="1_x"]
[ext_resource type="Resource" path="res://data/status/paralizado.tres" id="2_x"]

[resource]
script = ExtResource("1_x")
id = "chamuscado_electrico"
display_name = "Chamuscado (electrificado)"
duration = 8.0
restore_previous = true
creature_status = ExtResource("2_x")
look = 1
color = Color(1, 0.85, 0.3, 1)
'''


def mv(id, name, el, kind, cat, power, cooldown, knockback, **kw):
    d = dict(id=id, name=name, el=el, kind=kind, cat=cat, power=power, cooldown=cooldown, knockback=knockback)
    d.update(kw)
    return d


def melee(id, name, el, power, cd, steps=2, **kw):
    return mv(id, name, el, "MELEE", "fis", power, cd, kw.pop("knockback", 50), combo_steps=steps,
              combo_window=kw.pop("combo_window", 0.6), combo_step_cooldown=kw.pop("step_cd", 0.25),
              final_knockback=kw.pop("final_knockback", 190), melee_range=kw.pop("melee_range", 13),
              swing_radius=kw.pop("swing_radius", 11), **kw)


def acid(sp):
    return mv("acido_" + sp, "Ácido", "veneno", "ZONE", "esp", 20, 6.0, 0, zone_radius=22, zone_duration=4,
              placement_range=100, zone_traps=False, zone_tick=0.6, zone_max_count=2, on_hit=["expuesto"])


def sig(id, name, script, color, desc, params, max=100, gains=None):
    return dict(id=id, name=name, script=script, color=color, max=max, gains=gains or {}, params=params, desc=desc)


KITS = {
    # --- Raichu: JEFE de Lt. Surge. Pesado y lento, pega como un camión y electrifica el suelo. ---
    "raichu": ("bruiser", 45, sig("toma_de_tierra", "Toma de Tierra", "grounding_mechanic.gd", (1.0, 0.85, 0.25),
               "Jefe. La barra sube al pegar y al recibir; llena, planta la cola 1 s (quieto: castigalo) y suelta una descarga en anillo que deja el suelo chamuscado y electrificado 8 s. Cuerpo ×1,3, casi no lo empujan. A mitad de vida entra en Sobrecarga (+20% de daño) hasta el final.",
               {"plant_status": "plantado", "plant_time": 1.0, "discharge_move": "res://data/kits/raichu/descarga_cola.tres",
                "ground_state": "chamuscado_electrico", "ground_radius": 56.0, "scale": 1.3, "knockback_mult": 0.35,
                "phase_at": 0.5, "phase_status": "sobrecarga"},
               gains={"hit_dealt": 9.0, "damage_received": 7.0}), [
        melee("puno_trueno_raichu", "Puño Trueno", "electrico", 75, 1.4, 2, knockback=80, final_knockback=290,
              melee_range=16, swing_radius=14, status="paralizado", chance=0.25, recovery=0.15),
        mv("impactrueno_triple_raichu", "Impactrueno Triple", "electrico", "PROJECTILE", "esp", 40, 2.0, 90,
           speed=320, size=5, lifetime=0.8, projectile_count=3, spread_deg=26, status="paralizado", chance=0.15,
           recovery=0.15),
        mv("chispa_raichu", "Chispa", "electrico", "DASH", "fis", 65, 6.0, 260, cast_time=0.3, dash_time=0.45,
           invulnerable_time=0.0, status="paralizado", chance=0.3, recovery=0.7),
        mv("trueno_raichu", "Trueno", "electrico", "ZONE", "esp", 90, 9.0, 180, cast_time=0.3, zone_radius=24,
           placement_range=150, zone_traps=False, zone_strike=True, strike_delay=0.7, strike_count=3, strike_spread=40,
           status="paralizado", chance=1.0, recovery=0.3),
    ], [mv("descarga_cola", "Toma de Tierra", "electrico", "AREA", "esp", 45, 0, 240, radius=70,
           status="paralizado", chance=0.5)]),
    # --- Zubat: hostigador vampiro y ciego. ---
    "zubat": ("hostigador", 40, sig("ecolocalizacion", "Ecolocalización", "body_trait_mechanic.gd", (0.55, 0.45, 0.85),
              "Es ciego: no lo desorientan (Ataque Arena, Supersónico, humo...). Contra un rival desorientado, Chupavidas cura el doble.",
              {"immune": ["desorientado"], "drain_bonus_status": "desorientado", "drain_bonus": 1.0}, max=0), [
        melee("chupavidas_zubat", "Chupavidas", "bicho", 30, 0.8, 2, drain=0.5),
        mv("supersonico_zubat", "Supersónico", "normal", "CHANNEL", "est", 0, 6.0, 0, channel_time=0.4,
           cone_angle_deg=40, cone_length=60, tick_interval=0.2, on_hit=["desorientado"]),
        mv("ataque_ala_zubat", "Ataque Ala", "volador", "LUNGE", "fis", 40, 4.0, 120, lunge_range=100, lunge_speed=520,
           followup_delay=0.12, followup_power_mult=0.6, followup_knockback=160, recovery=0.1),
        mv("rayo_confuso_zubat", "Rayo Confuso", "fantasma", "PROJECTILE", "est", 0, 8.0, 0, speed=150, size=6,
           lifetime=1.4, status="desorientado", chance=1.0),
    ]),
    # --- Ekans: emboscador que se enrosca. ---
    "ekans": ("control", 40, sig("enroscarse", "Enroscarse", "still_mechanic.gd", (0.65, 0.45, 0.8),
              "Quieto 0,8 s se enrosca. El próximo golpe sale como un resorte: +40% de daño y un envión hacia adelante. Moverse lo desenrosca.",
              {"still_time": 0.8, "burst_mult": 1.4, "burst_push": 260.0, "consume_on_hit": True,
               "ready_text": "¡Enroscado!", "label": "ENROSCADO"}), [
        melee("picotazo_veneno_ekans", "Picotazo Veneno", "veneno", 20, 0.7, 2, status="envenenado", chance=0.3),
        mv("constriccion_ekans", "Constricción", "normal", "WHIP", "fis", 15, 4.0, 0, whip_length=45, whip_width=10,
           on_hit=["enraizado"], recovery=0.15),
        acid("ekans"),
        mv("deslumbrar_ekans", "Deslumbrar", "normal", "CHANNEL", "est", 0, 9.0, 0, cast_time=0.3, channel_time=0.3,
           cone_angle_deg=45, cone_length=55, tick_interval=0.15, status="paralizado", chance=1.0),
    ]),
    # --- Machop: luchador incansable. ---
    "machop": ("bruiser", 30, sig("incansable", "Incansable", "body_trait_mechanic.gd", (0.75, 0.6, 0.55),
               "Cada golpe cuerpo a cuerpo que conecta le baja 0,3 s todas las recargas. No lo pueden ralentizar.",
               {"immune": ["ralentizado"], "melee_cooldown_cut": 0.3}, max=0), [
        melee("golpe_karate_machop", "Golpe Kárate", "lucha", 50, 0.9, 3, step_cd=0.2, final_knockback=220),
        mv("patada_baja_machop", "Patada Baja", "lucha", "MELEE", "fis", 50, 3.5, 120, final_knockback=120,
           melee_range=14, swing_radius=15, on_hit=["ralentizado"], recovery=0.2),
        mv("malicioso_machop", "Malicioso", "normal", "AREA", "est", 0, 8.0, 0, radius=55, on_hit=["expuesto"],
           recovery=0.1),
        mv("sismico_machop", "Sísmico", "lucha", "LUNGE", "fis", 70, 7.0, 80, lunge_range=60, lunge_speed=380,
           followup_delay=0.3, followup_power_mult=1.3, followup_knockback=320, recovery=0.3, crater_radius=12,
           crater_max=2),
    ]),
    # --- Nidoran♀: bruiser espinoso. ---
    "nidoran_f": ("bruiser", 30, sig("puas_venenosas", "Púas Venenosas", "body_trait_mechanic.gd", (0.6, 0.6, 0.95),
                  "Al que le pega cuerpo a cuerpo le devuelve 10% del daño y puede envenenarlo; con Refuerzo, 20% y veneno seguro. Mordisco pega ×1,5 a lo envenenado.",
                  {"thorns": 0.1, "thorns_boosted": 0.2, "thorns_status": "envenenado", "thorns_chance": 0.5,
                   "thorns_boost_status": "refuerzo", "bonus_vs_status": "envenenado",
                   "bonus_move_prefix": "mordisco", "bonus_mult": 1.5}, max=0), [
        melee("aranazo_nidoran_f", "Arañazo", "normal", 40, 0.9, 2),
        mv("doble_patada_nidoran_f", "Doble Patada", "lucha", "LUNGE", "fis", 30, 3.5, 60, lunge_range=55,
           lunge_speed=400, followup_delay=0.15, followup_power_mult=1.0, followup_knockback=200, recovery=0.12),
        melee("mordisco_nidoran_f", "Mordisco", "siniestro", 60, 3.0, 1, final_knockback=170, status="herido",
              chance=0.2),
        mv("refuerzo_nidoran_f", "Refuerzo", "veneno", "SELF_BUFF", "est", 0, 10.0, 0, self="refuerzo"),
    ]),
    # --- Nidoran♂: duelista de reflejos. ---
    "nidoran_m": ("asesino", 35, sig("oido_fino", "Oído Fino", "body_trait_mechanic.gd", (0.75, 0.5, 0.85),
                  "Esquive perfecto: si esquivás justo antes de que te pegue, se recarga Cornada y el próximo golpe es crítico (×1,5).",
                  {"perfect_dodge": 0.25, "perfect_slot": 3, "crit_mult": 1.5}, max=0), [
        melee("picotazo_nidoran_m", "Picotazo", "volador", 35, 0.8, 2),
        mv("doble_patada_nidoran_m", "Doble Patada", "lucha", "LUNGE", "fis", 30, 3.5, 60, lunge_range=55,
           lunge_speed=400, followup_delay=0.15, followup_power_mult=1.0, followup_knockback=200, recovery=0.12),
        mv("malicioso_nidoran_m", "Malicioso", "normal", "AREA", "est", 0, 8.0, 0, radius=55, on_hit=["expuesto"],
           recovery=0.1),
        mv("cornada_nidoran_m", "Cornada", "normal", "DASH", "fis", 65, 6.0, 240, cast_time=0.2, dash_time=0.3,
           invulnerable_time=0.0, status="envenenado", chance=0.3, recovery=0.3),
    ]),
    # --- Horsea: francotirador anclado. ---
    "horsea": ("espaciador", 110, sig("ancla", "Ancla", "still_mechanic.gd", (0.4, 0.65, 0.95),
               "Quieto 0,5 s se ancla con la cola: sus disparos pegan +30% y no lo empujan. Moverse lo suelta.",
               {"still_time": 0.5, "burst_mult": 1.3, "kinds": ["PROJECTILE"], "consume_on_hit": False,
                "anchored_knockback": 0.0, "label": "ANCLADO"}), [
        mv("burbuja_horsea", "Burbuja", "agua", "PROJECTILE", "esp", 20, 0.8, 50, speed=170, size=5, lifetime=1.0,
           projectile_count=3, spread_deg=18, on_hit=["empapado"]),
        mv("pistola_agua_horsea", "Pistola Agua", "agua", "PROJECTILE", "esp", 40, 1.2, 80, speed=380, size=4,
           lifetime=1.0),
        mv("pantalla_humo_horsea", "Pantalla de Humo", "normal", "ZONE", "est", 0, 9.0, 0, zone_radius=34,
           zone_duration=4, placement_range=70, zone_traps=False, zone_tick=0.5, on_hit=["desorientado"]),
        mv("chorro_presion_horsea", "Chorro a Presión", "agua", "PROJECTILE", "esp", 75, 6.0, 280, cast_time=0.4,
           speed=440, size=7, lifetime=0.9, recovery=0.25),
    ]),
    # --- Shellder: concha con lengua (defensa por dirección). ---
    "shellder": ("tanque", 40, sig("concha_bivalva", "Concha Bivalva", "body_trait_mechanic.gd", (0.7, 0.55, 0.85),
                 "De frente recibe 40% menos de daño; de espaldas, 40% más (la lengua). Hay que rodearlo.",
                 {"front_mult": 0.6, "back_mult": 1.4}, max=0), [
        melee("placaje_shellder", "Placaje", "normal", 40, 1.0, 2),
        mv("carambano_shellder", "Carámbano", "hielo", "PROJECTILE", "fis", 25, 1.6, 40, speed=380, size=4,
           lifetime=0.7, projectile_count=3, spread_deg=8, on_hit=["escarcha"]),
        mv("refugio_shellder", "Refugio", "agua", "SELF_BUFF", "est", 0, 9.0, 0, self="refugio"),
        mv("tenaza_shellder", "Tenaza", "agua", "LUNGE", "fis", 35, 6.0, 40, lunge_range=80, lunge_speed=420,
           followup_delay=0.35, followup_power_mult=1.0, followup_knockback=120, on_hit=["ralentizado"],
           recovery=0.2),
    ]),
    # --- Tentacool: medusa que depende del agua. ---
    "tentacool": ("control", 60, sig("cuerpo_de_agua", "Cuerpo de Agua", "body_trait_mechanic.gd", (0.4, 0.7, 0.95),
                  "Sobre agua o suelo mojado (o empapado) se cura 2% por segundo; en seco va 10% más lento.",
                  {"wet_heal": 0.02, "dry_speed": 0.9}, max=0), [
        mv("picotazo_veneno_tentacool", "Picotazo Veneno", "veneno", "WHIP", "fis", 25, 0.9, 60, whip_length=60,
           whip_width=8, status="envenenado", chance=0.3),
        mv("restriccion_tentacool", "Restricción", "normal", "WHIP", "fis", 15, 5.0, 0, whip_length=95, whip_width=10,
           on_hit=["enraizado"], recovery=0.15),
        acid("tentacool"),
        mv("rayo_burbuja_tentacool", "Rayo Burbuja", "agua", "PROJECTILE", "esp", 30, 3.0, 60, speed=240, size=5,
           lifetime=0.8, projectile_count=4, spread_deg=40, on_hit=["ralentizado", "empapado"]),
    ]),
    # --- Voltorb: bomba rodante camuflada. ---
    "voltorb": ("hostigador", 35, sig("camuflaje", "Camuflaje", "still_mechanic.gd", (0.95, 0.3, 0.3),
                "Quieto 1,5 s se camufla (casi invisible, como una Poké Ball del mapa): el próximo golpe es crítico (×1,5). Autodestrucción explota en área grande y lo deja con 1 de vida, aturdido 2 s.",
                {"still_time": 1.5, "burst_mult": 1.5, "consume_on_hit": True, "camo_alpha": 0.35,
                 "ready_text": "¡Camuflado!", "hit_text": "¡Emboscada!", "label": "CAMUFLADO",
                 "selfdestruct_move": "autodestruccion", "selfdestruct_stun": 2.0}), [
        mv("rodar_voltorb", "Rodar", "roca", "DASH", "fis", 40, 2.5, 200, dash_time=0.35, invulnerable_time=0.0,
           recovery=0.15),
        melee("chispa_voltorb", "Chispa", "electrico", 45, 1.0, 1, final_knockback=170, status="paralizado",
              chance=0.3),
        mv("bomba_sonica_voltorb", "Bomba Sónica", "normal", "AREA", "esp", 25, 4.0, 160, radius=55, recovery=0.1),
        mv("autodestruccion_voltorb", "Autodestrucción", "normal", "AREA", "fis", 130, 20.0, 340, cast_time=1.2,
           radius=85, recovery=0.2),
    ]),
}


def _drop_inherited(root, species):
    """Si la especie heredaba el kit de su preevolución (Raichu tenía el de Pikachu), lo saca para engancharle el propio."""
    path = os.path.join(root, "data", "species", species + ".tres")
    s = open(path, encoding="utf-8").read()
    if "kit_inherited = true" not in s:
        return
    s = s.replace("kit_inherited = true\n", "")
    s = re.sub(r"^kit = [^\n]*\n", "", s, count=1, flags=re.M)
    write(path, s)


def main():
    root = sys.argv[1]
    for sid, p in STATUSES.items():
        write_status(root, sid, p)
    write(os.path.join(root, "data", "environment", "states", "chamuscado_electrico.tres"), GROUND_STATE)
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
