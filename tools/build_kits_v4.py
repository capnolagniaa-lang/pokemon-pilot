"""Genera los kits v4 (docs/PLAN_IDENTIDAD_COMBATE.md "v4 — kits de Kanto hasta Ciudad Plateada"): los Pokémon que
aparecen de Pueblo Paleta a Ciudad Plateada (salvajes de FireRed + el gimnasio de Brock) en data/kits/<especie>/,
más sus estados nuevos (data/status/). Reusa el formato de tools/build_kits_v3.py.

Uso: python -I -B tools/build_kits_v4.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos (los ajustes a mano se pierden): para retocar un kit ya probado, editar
su .tres en el inspector y no volver a correr esto. Después: enganchar los kits (lo hace este mismo script en
data/species/<especie>.tres si falta) y correr tools/build_learnsets.gd.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_kits_v3 import move_tres, write, val, color  # noqa: E402

STATUSES = {
    "seda": dict(name="Seda", color=(0.92, 0.92, 0.85), duration=5.0, element="bicho", max_stacks=3, speed_mult=0.9,
                 tint_strength=0.25, fx_amount=2),
    "fortaleza": dict(name="Fortaleza", color=(0.65, 0.8, 0.45), duration=3.0, element="bicho", damage_taken_mult=0.6,
                      knockback_mult=0.3, tint_strength=0.3, fx_amount=3),
    "intimidado": dict(name="Intimidado", color=(0.75, 0.6, 0.5), duration=5.0, element="normal", attack_mult=0.8,
                       tint_strength=0.2, fx_amount=2),
    "expuesto": dict(name="Expuesto", color=(1.0, 0.45, 0.45), duration=5.0, element="normal", damage_taken_mult=1.25,
                     tint_strength=0.25, fx_amount=2),
    "furia_roca": dict(name="Furia de Roca", color=(1.0, 0.5, 0.3), duration=30.0, element="roca", attack_mult=1.25,
                       speed_mult=1.2, tint_strength=0.3, fx_amount=4),
    "enfurecido": dict(name="Enfurecido", color=(1.0, 0.35, 0.2), duration=5.0, element="lucha", attack_mult=1.3,
                       speed_mult=1.15, tint_strength=0.35, fx_amount=5),
}

# Ataques que se repiten en varios kits (cada kit tiene su copia en su carpeta para ajustarla sola).
def disparo_demora(i):
    return dict(id="disparo_demora_" + i, name="Disparo Demora", el="bicho", kind="PROJECTILE", cat="est", power=0,
                cooldown=2.5, knockback=0, speed=230, size=5, lifetime=0.9, on_hit=["ralentizado", "seda"],
                recovery=0.1)


def fortaleza(i):
    return dict(id="fortaleza_" + i, name="Fortaleza", el="normal", kind="SELF_BUFF", cat="est", power=0,
                cooldown=8.0, knockback=0, self="fortaleza")


def placaje(i, mult=1.0):
    return dict(id="placaje_" + i, name="Placaje", el="normal", kind="MELEE", cat="fis", power=40, power_mult=mult,
                cooldown=1.0, combo_steps=2, combo_window=0.7, combo_step_cooldown=0.3, knockback=60,
                final_knockback=200, melee_range=12, swing_radius=11, recovery=0.1)


def picotazo_veneno(i):
    return dict(id="picotazo_veneno_" + i, name="Picotazo Veneno", el="veneno", kind="PROJECTILE", cat="fis", power=15,
                cooldown=0.7, knockback=40, speed=360, size=3, lifetime=0.6, status="envenenado", chance=0.3)


def derribo(i):
    return dict(id="derribo_" + i, name="Derribo", el="normal", kind="DASH", cat="fis", power=70, cooldown=6.0,
                knockback=230, dash_time=0.3, invulnerable_time=0.0, recovery=0.35)


KITS = {
    "caterpie": ("control", 80, dict(id="seda_firma", name="Seda", script="stack_mechanic.gd", color=(0.92, 0.92, 0.85),
                 max=0, gains={}, params={"stack_status": "seda", "stacks": 3, "trigger_status": "enraizado",
                 "text": "¡Enredado!"},
                 desc="Disparo Demora y Telaraña dejan seda en el rival (hasta 3). Con 3, queda enredado: no se puede mover un rato."), [
        placaje("caterpie", 0.8),
        disparo_demora("caterpie"),
        dict(id="telarana_caterpie", name="Telaraña", el="bicho", kind="ZONE", cat="est", power=0, cooldown=6.0,
             knockback=0, zone_radius=22, zone_duration=5, placement_range=100, zone_traps=False, zone_tick=0.8,
             zone_max_count=2, on_hit=["ralentizado", "seda"]),
        fortaleza("caterpie"),
    ]),
    "weedle": ("asesino", 60, dict(id="aguijon", name="Aguijón Venenoso", script="venom_mechanic.gd",
               color=(0.75, 0.4, 0.85), max=0, gains={}, params={"per_stack": 0.1, "max_mult": 1.5},
               desc="Le pega más a lo que está envenenado: +10% por cada stack de Envenenado del rival (hasta +50%)."), [
        picotazo_veneno("weedle"),
        disparo_demora("weedle"),
        dict(id="doble_ataque_weedle", name="Doble Ataque", el="bicho", kind="LUNGE", cat="fis", power=25,
             cooldown=3.5, knockback=60, lunge_range=60, lunge_speed=400, followup_delay=0.16, followup_power_mult=1.0,
             followup_knockback=140, status="envenenado", chance=0.3, recovery=0.12),
        dict(id="pin_misil_weedle", name="Pin Misil", el="bicho", kind="PROJECTILE", cat="fis", power=25,
             cooldown=6.0, knockback=50, speed=340, size=3, lifetime=0.6, projectile_count=5, spread_deg=40,
             recovery=0.2),
    ]),
    "metapod": ("tanque", 30, dict(id="capullo_metapod", name="Capullo", script="cocoon_mechanic.gd",
                color=(0.55, 0.8, 0.35), max=100, gains={}, params={"harden_per_s": 50.0, "soften_per_s": 120.0,
                "max_reduction": 0.5},
                desc="Quieto se endurece: con la barra llena recibe la mitad de daño. Moverse la baja rápido."), [
        placaje("metapod"),
        disparo_demora("metapod"),
        fortaleza("metapod"),
        derribo("metapod"),
    ]),
    "kakuna": ("tanque", 30, dict(id="capullo_kakuna", name="Capullo Venenoso", script="cocoon_mechanic.gd",
               color=(0.85, 0.75, 0.3), max=100, gains={}, params={"harden_per_s": 50.0, "soften_per_s": 120.0,
               "max_reduction": 0.5, "poison_contact": 0.5},
               desc="Quieto se endurece (hasta la mitad de daño). Endurecido, al que le pega cuerpo a cuerpo lo puede envenenar."), [
        picotazo_veneno("kakuna"),
        disparo_demora("kakuna"),
        fortaleza("kakuna"),
        derribo("kakuna"),
    ]),
    "spearow": ("asesino", 30, dict(id="furia_spearow", name="Furia", script="fury_mechanic.gd", color=(0.95, 0.5, 0.3),
                max=100, gains={}, params={"per_stack": 0.1, "max_stacks": 5, "window": 2.0},
                thresholds=[20.0, 40.0, 60.0, 80.0, 100.0],
                desc="Cada golpe seguido al mismo rival suma una marca (hasta 5): +10% de daño por marca. Si pasan 2 s sin pegarle, o cambia de rival, se pierde."), [
        dict(id="picotazo_spearow", name="Picotazo", el="volador", kind="MELEE", cat="fis", power=35, cooldown=0.8,
             combo_steps=3, combo_window=0.55, combo_step_cooldown=0.2, knockback=40, final_knockback=170,
             melee_range=13, swing_radius=10),
        dict(id="grunido_spearow", name="Gruñido", el="normal", kind="AREA", cat="est", power=0, cooldown=8.0,
             knockback=0, radius=55, on_hit=["intimidado"], recovery=0.1),
        dict(id="ataque_furia_spearow", name="Ataque Furia", el="normal", kind="MELEE", cat="fis", power=15,
             cooldown=4.0, combo_steps=5, combo_window=0.4, combo_step_cooldown=0.1, knockback=20,
             final_knockback=150, melee_range=13, swing_radius=10),
        dict(id="persecucion_spearow", name="Persecución", el="siniestro", kind="LUNGE", cat="fis", power=40,
             cooldown=5.0, knockback=80, lunge_range=110, lunge_speed=520, followup_delay=0.15,
             followup_power_mult=0.8, followup_knockback=160, recovery=0.1),
    ]),
    "mankey": ("bruiser", 30, dict(id="rabia", name="Rabia", script="rage_mechanic.gd", color=(1.0, 0.35, 0.2),
               max=100, gains={"damage_received": 20.0, "hit_dealt": 5.0}, params={"self_status": "enfurecido"},
               desc="Sube al recibir golpes (y un poco al pegar). Llena, Mankey se enfurece 5 s: pega 30% más y corre más rápido."), [
        dict(id="aranazo_mankey", name="Arañazo", el="normal", kind="MELEE", cat="fis", power=40, cooldown=0.9,
             combo_steps=3, combo_window=0.55, combo_step_cooldown=0.2, knockback=40, final_knockback=190,
             melee_range=12, swing_radius=11),
        dict(id="malicioso_mankey", name="Malicioso", el="normal", kind="AREA", cat="est", power=0, cooldown=8.0,
             knockback=0, radius=55, on_hit=["expuesto"], recovery=0.1),
        dict(id="patada_baja_mankey", name="Patada Baja", el="lucha", kind="MELEE", cat="fis", power=50,
             cooldown=4.0, knockback=120, final_knockback=120, melee_range=13, swing_radius=13,
             on_hit=["ralentizado"], recovery=0.2),
        dict(id="golpe_karate_mankey", name="Golpe Kárate", el="lucha", kind="LUNGE", cat="fis", power=50,
             cooldown=5.0, knockback=60, lunge_range=70, lunge_speed=420, followup_delay=0.18,
             followup_power_mult=1.2, followup_knockback=260, recovery=0.15),
    ]),
    "sandshrew": ("control", 45, dict(id="velo_arena", name="Velo Arena", script="sand_veil_mechanic.gd",
                  color=(0.9, 0.78, 0.5), max=0, gains={}, params={"cloud_move": "res://data/kits/sandshrew/nube_arena.tres",
                  "cooldown": 4.0},
                  desc="Al esquivar deja una nube de arena donde estaba, que desorienta a los rivales que la pisan (cada 4 s)."), [
        dict(id="aranazo_sandshrew", name="Arañazo", el="normal", kind="MELEE", cat="fis", power=40, cooldown=0.9,
             combo_steps=2, combo_window=0.6, combo_step_cooldown=0.25, knockback=50, final_knockback=180,
             melee_range=12, swing_radius=11),
        dict(id="ataque_arena_sandshrew", name="Ataque Arena", el="tierra", kind="CHANNEL", cat="est", power=0,
             cooldown=6.0, knockback=0, channel_time=0.5, cone_angle_deg=40, cone_length=60, tick_interval=0.25,
             on_hit=["desorientado"]),
        dict(id="picotazo_veneno_sandshrew", name="Picotazo Veneno", el="veneno", kind="PROJECTILE", cat="fis",
             power=15, cooldown=1.0, knockback=40, speed=340, size=3, lifetime=0.6, status="envenenado", chance=0.3),
        dict(id="rizo_defensa_sandshrew", name="Rizo Defensa", el="normal", kind="SELF_BUFF", cat="est", power=0,
             cooldown=9.0, knockback=0, self="rizo"),
    ], [dict(id="nube_arena", name="Velo Arena", el="tierra", kind="ZONE", cat="est", power=0, cooldown=0,
             knockback=0, zone_radius=22, zone_duration=3, zone_traps=False, zone_tick=0.5, on_hit=["desorientado"])]),
    # Onix es el de Brock: un JEFE (pedido del usuario; referencia: el Onix del anime, que atrapa con Atadura, tira
    # rocas y se mete bajo tierra). Enorme, no lo empujan, y a mitad de vida ruge y entra en furia.
    "onix": ("tanque", 70, dict(id="coloso", name="Coloso", script="colossus_mechanic.gd", color=(0.75, 0.65, 0.55),
             max=100, gains={}, params={"physical_mult": 0.75, "stagger_bonus": 1.3, "knockback_mult": 0.0,
             "scale": 1.4, "phase_at": 0.5, "phase_status": "furia_roca",
             "roar_move": "res://data/kits/onix/rugido_onix.tres"},
             desc="Jefe. Enorme: no lo empujan ni lo tambalean y recibe 25% menos de daño físico. Aplasta lo atrapado: +30% contra lo ralentizado. A mitad de vida ruge (empuja y deja Expuesto) y entra en Furia de Roca hasta el final."), [
        dict(id="atadura_onix", name="Atadura", el="normal", kind="WHIP", cat="fis", power=15, cooldown=3.0,
             knockback=-180, whip_length=95, whip_width=12, on_hit=["ralentizado"], recovery=0.15),
        dict(id="lanzarrocas_onix", name="Lanzarrocas", el="roca", kind="PROJECTILE", cat="fis", power=50,
             cooldown=1.8, knockback=170, speed=250, size=6, lifetime=0.9, projectile_count=3, spread_deg=24,
             recovery=0.15, crater_radius=8, crater_max=4),
        dict(id="excavar_onix", name="Excavar", el="tierra", kind="ZONE", cat="fis", power=80, cooldown=8.0,
             knockback=260, zone_radius=34, placement_range=150, zone_traps=False, zone_strike=True,
             strike_delay=1.0, strike_burrow=True, recovery=0.3, crater_radius=34, crater_max=2),
        dict(id="tumba_rocas_onix", name="Tumba Rocas", el="roca", kind="ZONE", cat="fis", power=50, cooldown=9.0,
             cast_time=0.3, knockback=80, zone_radius=24, placement_range=130, zone_traps=False, zone_strike=True,
             strike_delay=0.55, strike_count=3, strike_spread=40, on_hit=["ralentizado"], recovery=0.3, crater_radius=16, crater_max=3),
    ], [dict(id="rugido_onix", name="Rugido", el="normal", kind="AREA", cat="est", power=0, cooldown=0,
             knockback=260, radius=90, on_hit=["expuesto"])]),
}


def write_status(root, sid, p):
    body = ['script = ExtResource("2_x")', 'id = "%s"' % sid, 'display_name = "%s"' % p["name"],
            "color = %s" % color(p["color"]), "duration = %s" % val(float(p["duration"])), 'element = ExtResource("1_x")']
    for k in ("can_move", "can_act", "damage_taken_mult", "knockback_mult", "max_stacks", "speed_mult", "attack_mult",
              "heal_per_second", "tint_strength", "fx_amount"):
        if k in p:
            body.append("%s = %s" % (k, val(p[k])))
    write(os.path.join(root, "data", "status", sid + ".tres"),
          '[gd_resource type="Resource" script_class="StatusEffect" format=3]\n\n'
          '[ext_resource type="Resource" path="res://data/types/%s.tres" id="1_x"]\n'
          '[ext_resource type="Script" path="res://scripts/resources/status_effect.gd" id="2_x"]\n\n[resource]\n'
          % p["element"] + "\n".join(body) + "\n")


def hook_species(root, species):
    """Engancha data/kits/<especie>/kit.tres en la especie (si no lo tiene ya)."""
    path = os.path.join(root, "data", "species", species + ".tres")
    s = open(path, encoding="utf-8").read()
    s = s.replace('kit = ExtResource("0_kitv4")\n', "")  # arregla enganches viejos mal ubicados
    if re.search(r"^kit = ", s, re.M):
        return
    if "0_kitv4" not in s:
        lines = s.split("\n")
        lines.insert(2, '[ext_resource type="Resource" path="res://data/kits/%s/kit.tres" id="0_kitv4"]' % species)
        s = "\n".join(lines)
    # Después de la línea `script = ...` del [resource] (antes del script, Godot ignora la propiedad).
    s = re.sub(r"(\[resource\]\nscript = [^\n]*\n)", lambda m: m.group(1) + 'kit = ExtResource("0_kitv4")\n', s, count=1)
    write(path, s)


def _param(v):
    """Valor de un parámetro de firma en formato .tres (texto, número, booleano o lista de textos)."""
    if isinstance(v, str):
        return '"%s"' % v
    if isinstance(v, list):
        return "[%s]" % ", ".join(_param(x) for x in v)
    if isinstance(v, dict):
        return "{%s}" % ", ".join('"%s": %s' % (k, _param(x)) for k, x in v.items())
    return val(v)


def write_kit(root, species, spec):
    """Escribe la firma y el kit.tres de una especie (los ataques ya están en data/kits/<especie>/)."""
    arch, rng, sig, moves = spec[0], spec[1], spec[2], spec[3]
    folder = os.path.join(root, "data", "kits", species)
    ext = ['[ext_resource type="Script" path="res://scripts/resources/move_data.gd" id="1_md"]',
           '[ext_resource type="Script" path="res://scripts/resources/kit.gd" id="2_kit"]']
    for i, m in enumerate(moves):
        ext.append('[ext_resource type="Resource" path="res://data/kits/%s/%s.tres" id="%d_mv"]' % (species, m["id"], i + 4))
    gains = ", ".join('"%s": %s' % (k, val(float(v))) for k, v in sig["gains"].items())
    params = ", ".join('"%s": %s' % (k, _param(v)) for k, v in sig["params"].items())
    thr = "thresholds = Array[float]([%s])\n" % ", ".join(val(float(t)) for t in sig["thresholds"]) if "thresholds" in sig else ""
    write(os.path.join(folder, sig["id"] + ".tres"),
          '[gd_resource type="Resource" script_class="SignatureData" format=3]\n\n'
          '[ext_resource type="Script" path="res://scripts/combat/signatures/%s" id="1_mech"]\n'
          '[ext_resource type="Script" path="res://scripts/resources/signature_data.gd" id="2_sd"]\n\n[resource]\n'
          'script = ExtResource("2_sd")\nid = "%s"\ndisplay_name = "%s"\ndescription = "%s"\ncolor = %s\n'
          "max_value = %s\ngains = {%s}\ndecay_out_of_combat = 6.0\n%smechanic_script = ExtResource(\"1_mech\")\n"
          "params = {%s}\n" % (sig["script"], sig["id"], sig["name"], sig["desc"], color(sig["color"]),
                               val(float(sig["max"])), gains, thr, params))
    ext.append('[ext_resource type="Resource" path="res://data/kits/%s/%s.tres" id="3_sig"]' % (species, sig["id"]))
    arr = ", ".join('ExtResource("%d_mv")' % (i + 4) for i in range(len(moves)))
    write(os.path.join(folder, "kit.tres"), '[gd_resource type="Resource" script_class="Kit" format=3]\n\n'
          + "\n".join(ext) + '\n\n[resource]\nscript = ExtResource("2_kit")\narchetype = "%s"\npreferred_range = %s\n'
          % (arch, val(float(rng))) + 'signature = ExtResource("3_sig")\n'
          + 'moves = Array[ExtResource("1_md")]([%s])\n' % arr)


def main():
    root = sys.argv[1]
    for sid, p in STATUSES.items():
        write_status(root, sid, p)
    for species, spec in KITS.items():
        extra = spec[4] if len(spec) > 4 else []
        folder = os.path.join(root, "data", "kits", species)
        os.makedirs(folder, exist_ok=True)
        for m in spec[3] + extra:
            write(os.path.join(folder, m["id"] + ".tres"), re.sub(r"strike_count = (\d+)\.0", r"strike_count = \1", move_tres(m)))
        write_kit(root, species, spec)
        hook_species(root, species)
        print(species, "->", [m["name"] for m in spec[3]])


if __name__ == "__main__":
    main()
