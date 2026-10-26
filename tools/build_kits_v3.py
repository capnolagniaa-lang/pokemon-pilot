"""Genera los 10 kits nuevos (v3, docs/PLAN_IDENTIDAD_COMBATE.md "v3 — 10 kits nuevos") en data/kits/<especie>/:
los 4 ataques (MoveData), la mecánica de firma (SignatureData) y kit.tres, más los estados nuevos que usan
(data/status/). Después hay que enganchar el kit a la especie y correr tools/build_learnsets.gd.

Uso: python -I -B tools/build_kits_v3.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos (los ajustes a mano se pierden): para retocar un kit ya probado, editar
su .tres en el inspector y no volver a correr esto.
"""
import os
import sys

KIND = {"PROJECTILE": 0, "DASH": 1, "AREA": 2, "SHIELD": 3, "MELEE": 4, "ZONE": 5, "CHANNEL": 6, "LUNGE": 7,
        "WHIP": 8, "SELF_BUFF": 9}
CAT = {"fis": 0, "esp": 1, "est": 2}

# Estados nuevos: id -> propiedades (elemento por id de tipo)
STATUSES = {
    "refugio": dict(name="Refugio", color=(0.4, 0.75, 1.0), duration=1.5, element="agua", can_move=False,
                    damage_taken_mult=0.3, knockback_mult=0.0, tint_strength=0.3, fx_amount=4),
    "esporas": dict(name="Esporas", color=(0.8, 0.55, 1.0), duration=8.0, element="planta", max_stacks=5,
                    tint_strength=0.2, fx_amount=3),
    "rastreado": dict(name="Rastreado", color=(1.0, 0.55, 0.2), duration=6.0, element="fuego", tint_strength=0.15,
                      fx_amount=2),
    "escarcha": dict(name="Escarcha", color=(0.7, 0.92, 1.0), duration=6.0, element="hielo", max_stacks=3,
                     speed_mult=0.9, tint_strength=0.3, fx_amount=3),
    "rizo": dict(name="Rizo Defensa", color=(0.75, 0.65, 0.45), duration=4.0, element="roca", damage_taken_mult=0.5,
                 tint_strength=0.25, fx_amount=3),
    "descansando": dict(name="Descansando", color=(0.75, 0.8, 1.2), duration=2.0, element="normal", can_act=False,
                        heal_per_second=0.25, tint_strength=0.3, fx_amount=4),
}

# Kits: especie -> (arquetipo, rango, firma, [4 ataques])
# Ataque: dict(id, name, el, kind, cat, power, ...props). "status"/"chance", "on_hit": [estados], "self": estado
KITS = {
    "squirtle": ("tanque", 34, dict(id="caparazon", name="Presión", script="shell_mechanic.gd", color=(0.35, 0.65, 1.0),
                 max=100, gains={}, params={"parry_window": 0.3, "parry_stun": 0.6, "parry_gain": 40.0,
                 "block_gain": 300.0, "max_bonus": 1.0},
                 desc="Con Refugio recibe menos y no lo empujan; si le pegan justo al meterse en el caparazón es un parry (anula el golpe y aturde). Lo bloqueado carga la Presión, que el próximo golpe gasta para pegar más."), [
        dict(id="placaje_kit", name="Placaje", el="normal", kind="MELEE", cat="fis", power=40, cooldown=1.0,
             combo_steps=2, combo_window=0.7, combo_step_cooldown=0.3, knockback=60, final_knockback=230,
             melee_range=13, swing_radius=12, recovery=0.12),
        dict(id="pistola_agua_kit", name="Pistola Agua", el="agua", kind="PROJECTILE", cat="esp", power=40,
             cooldown=1.3, knockback=170, speed=300, size=4.5, lifetime=0.75, recovery=0.08),
        dict(id="refugio_kit", name="Refugio", el="agua", kind="SELF_BUFF", cat="est", power=0, cooldown=4.0,
             knockback=0, self="refugio"),
        dict(id="giro_rapido_kit", name="Giro Rápido", el="normal", kind="DASH", cat="fis", power=50, cooldown=7.0,
             knockback=200, dash_time=0.35, invulnerable_time=0.15, recovery=0.15, cleanse_self=True),
    ]),
    "pikachu": ("velocista", 70, dict(id="estatica", name="Estática", script="static_mechanic.gd", color=(1.0, 0.85, 0.2),
                max=100, gains={"moved": 0.25, "dodged": 20.0}, params={"idle_loss": 30.0, "discharge_mult": 1.3},
                thresholds=[20.0, 40.0, 60.0, 80.0, 100.0],
                desc="Moverse y esquivar generan cargas (5); quieto las pierde. Rayo gasta todas y pega más. Con las 5, el próximo golpe es una Descarga que paraliza."), [
        dict(id="impactrueno_kit", name="Impactrueno", el="electrico", kind="PROJECTILE", cat="esp", power=40,
             cooldown=0.8, knockback=90, speed=380, size=3.5, lifetime=0.65, recovery=0.05),
        dict(id="ataque_rapido_kit", name="Ataque Rápido", el="normal", kind="DASH", cat="fis", power=40, cooldown=2.2,
             knockback=130, dash_time=0.2, invulnerable_time=0.1, recovery=0.08),
        dict(id="onda_trueno_kit", name="Onda Trueno", el="electrico", kind="AREA", cat="est", power=0, cooldown=6.0,
             knockback=0, radius=48, on_hit=["paralizado", "paralizado"], recovery=0.15),
        dict(id="rayo_kit", name="Rayo", el="electrico", kind="PROJECTILE", cat="esp", power=90, cooldown=7.0,
             cast_time=0.25, knockback=160, speed=360, size=6, lifetime=0.7, recovery=0.3, resource_cost=-1,
             resource_scaling=1.0),
    ]),
    "oddish": ("desgaste", 75, dict(id="esporas", name="Esporas", script="spores_mechanic.gd", color=(0.8, 0.55, 1.0),
               max=0, gains={}, params={"bloom_move": "florecer", "radius": 150.0, "heal_per_spore": 0.03},
               desc="Sus ataques dejan esporas en el rival (hasta 5). Florecer las hace florecer: 1+ envenena, 3+ paraliza, 5 duerme, y Oddish se cura por cada una."), [
        dict(id="absorber_kit", name="Absorber", el="planta", kind="PROJECTILE", cat="esp", power=20, cooldown=0.9,
             knockback=50, speed=260, size=4, lifetime=0.8, drain=0.5, on_hit=["esporas"]),
        dict(id="polvo_veneno_kit", name="Polvo Veneno", el="veneno", kind="ZONE", cat="est", power=0, cooldown=1.6,
             knockback=0, zone_radius=18, zone_duration=6, placement_range=95, zone_traps=False, zone_tick=0.6,
             zone_max_count=3, on_hit=["ralentizado", "envenenado", "esporas"]),
        dict(id="paralizador_kit", name="Paralizador", el="planta", kind="ZONE", cat="est", power=0, cooldown=5.0,
             knockback=0, zone_radius=20, zone_duration=4, placement_range=95, zone_traps=False, zone_tick=0.6,
             zone_max_count=2, on_hit=["paralizado", "esporas"]),
        dict(id="florecer", name="Florecer", el="planta", kind="SELF_BUFF", cat="est", power=0, cooldown=9.0,
             knockback=0, cast_time=0.3),
    ]),
    "paras": ("control", 55, None, [
        dict(id="aranazo_kit", name="Arañazo", el="normal", kind="MELEE", cat="fis", power=40, cooldown=0.9,
             combo_steps=2, combo_window=0.6, combo_step_cooldown=0.25, knockback=50, final_knockback=170,
             melee_range=12, swing_radius=11),
        dict(id="paralizador_paras", name="Paralizador", el="planta", kind="ZONE", cat="est", power=0, cooldown=4.0,
             knockback=0, zone_radius=22, zone_duration=4, placement_range=100, zone_traps=False, zone_tick=0.6,
             zone_max_count=2, on_hit=["paralizado"], zone_flammable=True),
        dict(id="chupavidas_kit", name="Chupavidas", el="bicho", kind="MELEE", cat="fis", power=80, power_mult=0.6,
             cooldown=3.0, knockback=120, final_knockback=120, melee_range=13, swing_radius=12, drain=0.5,
             recovery=0.15),
        dict(id="espora_kit", name="Espora", el="planta", kind="ZONE", cat="est", power=0, cooldown=11.0,
             cast_time=0.4, knockback=0, zone_radius=26, zone_duration=4, placement_range=100, zone_traps=False,
             zone_tick=0.5, dwell_time=1.2, dwell_status="dormido", zone_flammable=True),
    ]),
    "psyduck": ("caotico", 65, dict(id="jaqueca", name="Jaqueca", script="headache_mechanic.gd", color=(0.95, 0.4, 0.6),
                max=100, gains={"damage_received": 15.0}, params={"combat_gain": 3.0,
                "burst_move": "res://data/kits/psyduck/jaqueca_estallido.tres"},
                desc="Sube al recibir daño y de a poco mientras pelea. Al llenarse estalla una Confusión en área que desorienta."), [
        dict(id="pistola_agua_psyduck", name="Pistola Agua", el="agua", kind="PROJECTILE", cat="esp", power=40,
             cooldown=1.2, knockback=150, speed=300, size=4.5, lifetime=0.75),
        dict(id="aranazo_psyduck", name="Arañazo", el="normal", kind="MELEE", cat="fis", power=40, power_mult=0.6,
             cooldown=1.0, combo_steps=3, combo_window=0.5, combo_step_cooldown=0.18, knockback=30,
             final_knockback=140, melee_range=12, swing_radius=11),
        dict(id="confusion_kit", name="Confusión", el="psiquico", kind="PROJECTILE", cat="esp", power=50,
             cooldown=2.0, knockback=110, speed=260, size=5, lifetime=0.8, status="desorientado", chance=0.3),
        dict(id="anulacion_kit", name="Anulación", el="normal", kind="PROJECTILE", cat="est", power=0, cooldown=9.0,
             knockback=0, speed=240, size=5, lifetime=0.9, cooldown_lock=3.0, cast_time=0.2),
    ], [dict(id="jaqueca_estallido", name="Jaqueca", el="psiquico", kind="AREA", cat="esp", power=50, cooldown=0,
             knockback=180, radius=60, status="desorientado", chance=1.0)]),
    "poliwag": ("velocista", 70, dict(id="deslizamiento", name="Deslizamiento", script="slide_mechanic.gd",
                color=(0.4, 0.6, 1.0), max=0, gains={}, params={"speed_bonus": 1.4, "dodge_mult": 0.5},
                desc="Sobre el agua o el suelo mojado se mueve más rápido y esquiva el doble de seguido. Danza Lluvia moja el piso alrededor."), [
        dict(id="burbuja_kit", name="Burbuja", el="agua", kind="PROJECTILE", cat="esp", power=40, power_mult=0.45,
             cooldown=1.1, knockback=60, speed=200, size=3.5, lifetime=0.8, projectile_count=3, spread_deg=26,
             status="ralentizado", chance=0.1),
        dict(id="pistola_agua_poliwag", name="Pistola Agua", el="agua", kind="PROJECTILE", cat="esp", power=40,
             cooldown=1.4, knockback=160, speed=310, size=4.5, lifetime=0.75),
        dict(id="danza_lluvia_kit", name="Danza Lluvia", el="agua", kind="AREA", cat="est", power=0, cooldown=7.0,
             knockback=0, radius=64, recovery=0.15),
        dict(id="hipnosis_kit", name="Hipnosis", el="psiquico", kind="PROJECTILE", cat="est", power=0, cooldown=10.0,
             cast_time=0.4, knockback=0, speed=170, size=6, lifetime=1.1, on_hit=["dormido"], recovery=0.2),
    ]),
    "growlithe": ("perseguidor", 40, dict(id="rastreo", name="Rastreo", script="track_mechanic.gd",
                  color=(1.0, 0.55, 0.2), max=0, gains={}, params={"speed_bonus": 1.25, "damage_bonus": 1.25},
                  desc="Sus golpes marcan al rival 6 s. Contra el marcado corre más rápido y pega más."), [
        dict(id="mordisco_kit", name="Mordisco", el="siniestro", kind="MELEE", cat="fis", power=60, power_mult=0.55,
             cooldown=1.1, combo_steps=2, combo_window=0.6, combo_step_cooldown=0.25, knockback=40,
             final_knockback=170, melee_range=13, swing_radius=12, on_hit=["rastreado"]),
        dict(id="ascuas_growlithe", name="Ascuas", el="fuego", kind="PROJECTILE", cat="esp", power=40, cooldown=1.3,
             knockback=80, speed=280, size=4, lifetime=0.8, status="quemado", chance=0.1, on_hit=["rastreado"]),
        dict(id="rugido_kit", name="Rugido", el="normal", kind="AREA", cat="est", power=0, cooldown=6.0,
             knockback=300, radius=42, on_hit=["desorientado"], recovery=0.15),
        dict(id="rueda_fuego_kit", name="Rueda Fuego", el="fuego", kind="DASH", cat="fis", power=60, cooldown=6.0,
             knockback=170, dash_time=0.3, invulnerable_time=0.12, recovery=0.2, status="quemado", chance=0.3,
             on_hit=["rastreado"]),
    ]),
    "eevee": ("adaptativo", 45, dict(id="adaptacion", name="Adaptación", script="adapt_mechanic.gd",
              color=(0.85, 0.7, 0.5), max=0, gains={}, params={"duration": 8.0, "resist_mult": 0.7},
              desc="Al recibir un golpe de un tipo, durante 8 s recibe menos daño de ese tipo."), [
        dict(id="placaje_eevee", name="Placaje", el="normal", kind="MELEE", cat="fis", power=40, cooldown=0.9,
             combo_steps=2, combo_window=0.6, combo_step_cooldown=0.25, knockback=50, final_knockback=180,
             melee_range=13, swing_radius=12),
        dict(id="ataque_arena_eevee", name="Ataque Arena", el="normal", kind="PROJECTILE", cat="est", power=0,
             cooldown=5.0, knockback=0, speed=250, size=2.5, lifetime=0.32, projectile_count=5, spread_deg=50,
             on_hit=["desorientado"]),
        dict(id="ataque_rapido_eevee", name="Ataque Rápido", el="normal", kind="DASH", cat="fis", power=40,
             cooldown=2.5, knockback=130, dash_time=0.2, invulnerable_time=0.1, recovery=0.08),
        dict(id="derribo_kit", name="Derribo", el="normal", kind="DASH", cat="fis", power=90, cooldown=6.0,
             knockback=240, dash_time=0.3, recovery=0.35),
    ]),
    "seel": ("tanque", 55, dict(id="escarcha", name="Escarcha", script="frost_mechanic.gd", color=(0.7, 0.92, 1.0),
             max=0, gains={}, params={"stacks_to_freeze": 3},
             desc="Sus ataques de hielo dejan escarcha en el rival (hasta 3). Con 3, se congela."), [
        dict(id="golpe_cabeza_kit", name="Golpe Cabeza", el="normal", kind="MELEE", cat="fis", power=70,
             cooldown=1.6, knockback=210, final_knockback=210, melee_range=14, swing_radius=13, recovery=0.15),
        dict(id="viento_hielo_kit", name="Viento Hielo", el="hielo", kind="PROJECTILE", cat="esp", power=55,
             power_mult=0.45, cooldown=2.2, knockback=60, speed=230, size=3.5, lifetime=0.6, projectile_count=3,
             spread_deg=30, on_hit=["ralentizado", "escarcha"]),
        dict(id="rayo_aurora_kit", name="Rayo Aurora", el="hielo", kind="PROJECTILE", cat="esp", power=65,
             cooldown=2.5, cast_time=0.15, knockback=110, speed=260, size=4.5, lifetime=0.9, on_hit=["escarcha"]),
        dict(id="descanso_kit", name="Descanso", el="psiquico", kind="SELF_BUFF", cat="est", power=0, cooldown=14.0,
             knockback=0, self="descansando"),
    ]),
    "geodude": ("tanque", 30, dict(id="impulso", name="Impulso", script="momentum_mechanic.gd", color=(0.75, 0.65, 0.45),
                max=100, gains={}, params={"roll_move": "rodar_kit", "chain_time": 3.0, "step_bonus": 0.5,
                "max_chain": 2, "max_mult": 2.0, "curl_mult": 2.0}, thresholds=[50.0, 100.0],
                desc="Cada Rodar dentro de 3 s del anterior pega +50% (hasta ×2). Con Rizo Defensa activo, Rodar pega el doble."), [
        dict(id="placaje_geodude", name="Placaje", el="normal", kind="MELEE", cat="fis", power=40, cooldown=1.1,
             knockback=210, final_knockback=210, melee_range=13, swing_radius=13, recovery=0.12),
        dict(id="rodar_kit", name="Rodar", el="roca", kind="DASH", cat="fis", power=30, cooldown=2.0, knockback=150,
             dash_time=0.4, recovery=0.1),
        dict(id="lanzarrocas_kit", name="Lanzarrocas", el="roca", kind="PROJECTILE", cat="fis", power=50,
             cooldown=1.6, knockback=140, speed=220, size=6, lifetime=0.85),
        dict(id="rizo_defensa_kit", name="Rizo Defensa", el="normal", kind="SELF_BUFF", cat="est", power=0,
             cooldown=10.0, knockback=0, self="rizo"),
    ]),
}

SKIP = {"id", "name", "el", "kind", "cat", "status", "chance", "on_hit", "self", "dwell_status", "trail_status"}


def val(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, float):
        return repr(v)
    return str(v)


def write(path, text):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def move_tres(m):
    ext = [("Script", "res://scripts/resources/move_data.gd"), ("Script", "res://scripts/resources/status_effect.gd"),
           ("Resource", "res://data/types/%s.tres" % m["el"])]
    refs = {}

    def ref(path):
        if path not in refs:
            ext.append(("Resource", path))
            refs[path] = "%d_x" % len(ext)
        return refs[path]

    body = ['script = ExtResource("1_x")', 'id = "%s"' % m["id"], 'display_name = "%s"' % m["name"],
            'element = ExtResource("3_x")', "kind = %d" % KIND[m["kind"]], "category = %d" % CAT[m["cat"]]]
    for k, v in m.items():
        if k not in SKIP:
            body.append("%s = %s" % (k, val(float(v) if isinstance(v, int) and not isinstance(v, bool) and k not in (
                "combo_steps", "projectile_count", "zone_max_count", "resource_cost") else v)))
    if "status" in m:
        body.append('status = ExtResource("%s")' % ref("res://data/status/%s.tres" % m["status"]))
        body.append("status_chance = %s" % val(float(m.get("chance", 1.0))))
    if "self" in m:
        body.append('self_status = ExtResource("%s")' % ref("res://data/status/%s.tres" % m["self"]))
    if "trail_status" in m:
        body.append('trail_status = ExtResource("%s")' % ref("res://data/status/%s.tres" % m["trail_status"]))
    if "dwell_status" in m:
        body.append('dwell_status = ExtResource("%s")' % ref("res://data/status/%s.tres" % m["dwell_status"]))
    if "on_hit" in m:
        ids = ", ".join('ExtResource("%s")' % ref("res://data/status/%s.tres" % s) for s in m["on_hit"])
        body.append('statuses_on_hit = Array[ExtResource("2_x")]([%s])' % ids)
    head = ['[gd_resource type="Resource" script_class="MoveData" format=3]', ""]
    head += ['[ext_resource type="%s" path="%s" id="%d_x"]' % (t, p, i + 1) for i, (t, p) in enumerate(ext)]
    return "\n".join(head + ["", "[resource]"] + body) + "\n"


def color(c):
    return "Color(%s, %s, %s, 1)" % c


def main():
    root = sys.argv[1]
    for sid, p in STATUSES.items():
        body = ['script = ExtResource("2_x")', 'id = "%s"' % sid, 'display_name = "%s"' % p["name"],
                "color = %s" % color(p["color"]), "duration = %s" % val(float(p["duration"])), 'element = ExtResource("1_x")']
        for k in ("can_move", "can_act", "damage_taken_mult", "knockback_mult", "max_stacks", "speed_mult",
                  "heal_per_second", "tint_strength", "fx_amount"):
            if k in p:
                body.append("%s = %s" % (k, val(p[k])))
        write(os.path.join(root, "data", "status", sid + ".tres"),
              '[gd_resource type="Resource" script_class="StatusEffect" format=3]\n\n'
              '[ext_resource type="Resource" path="res://data/types/%s.tres" id="1_x"]\n'
              '[ext_resource type="Script" path="res://scripts/resources/status_effect.gd" id="2_x"]\n\n[resource]\n'
              % p["element"] + "\n".join(body) + "\n")
    for species, spec in KITS.items():
        arch, rng, sig, moves = spec[0], spec[1], spec[2], spec[3]
        extra = spec[4] if len(spec) > 4 else []
        folder = os.path.join(root, "data", "kits", species)
        os.makedirs(folder, exist_ok=True)
        for m in moves + extra:
            write(os.path.join(folder, m["id"] + ".tres"), move_tres(m))
        ext = ['[ext_resource type="Script" path="res://scripts/resources/move_data.gd" id="1_md"]',
               '[ext_resource type="Script" path="res://scripts/resources/kit.gd" id="2_kit"]']
        for i, m in enumerate(moves):
            ext.append('[ext_resource type="Resource" path="res://data/kits/%s/%s.tres" id="%d_mv"]' % (species, m["id"], i + 4))
        sig_line = ""
        if sig is not None:
            gains = ", ".join('"%s": %s' % (k, val(float(v))) for k, v in sig["gains"].items())
            params = ", ".join('"%s": %s' % (k, ('"%s"' % v) if isinstance(v, str) else val(v)) for k, v in sig["params"].items())
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
            sig_line = 'signature = ExtResource("3_sig")\n'
        arr = ", ".join('ExtResource("%d_mv")' % (i + 4) for i in range(len(moves)))
        write(os.path.join(folder, "kit.tres"), '[gd_resource type="Resource" script_class="Kit" format=3]\n\n'
              + "\n".join(ext) + '\n\n[resource]\nscript = ExtResource("2_kit")\narchetype = "%s"\npreferred_range = %s\n'
              % (arch, val(float(rng))) + sig_line + 'moves = Array[ExtResource("1_md")]([%s])\n' % arr)
        print(species, "->", [m["name"] for m in moves])


if __name__ == "__main__":
    main()
