"""Arma los kits de 5 teclas del Modo Desafío (pedido del usuario 2026-11-12; referencia: Pokémon Arena 2D).

    python -I -B tools/build_desafio_kits.py .

Escribe data/desafio_kits/<especie>/ (kit.tres + sus 5 ataques) y los estados nuevos en data/status/. Un kit por línea
evolutiva (la evolución usa el de su preevolución: RogueKits.of). Editar la tabla KITS y volver a correrlo: pisa esos
.tres. Los ids de los ataques llevan "d_" adelante para no chocar con los de data/moves; sus hojas de efecto las hace
tools/make_desafio_vfx.py.

Orden de `moves`: básico (Clic izq., gratis), habilidad (Clic der.), habilidad (Q), definitiva (R, con la barra llena).
`mobility` = Espacio (en vez del esquive).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from desafio_kits_bosque import KITS_BOSQUE  # noqa: E402

KIND = {"PROJECTILE": 0, "DASH": 1, "AREA": 2, "SHIELD": 3, "MELEE": 4, "ZONE": 5, "CHANNEL": 6, "LUNGE": 7, "WHIP": 8,
        "SELF_BUFF": 9}
CAT = {"fisico": 0, "especial": 1, "estado": 2}

BASIC_MULT = 1.2
ABILITY_CD = 0.6

# Estados propios de los kits: id -> (tipo, campos)
STATUSES = {
    "cegado": ("normal", dict(display_name="Cegado", color="Color(0.55, 0.55, 0.6, 1)", duration=2.0, speed_mult=0.85,
                              aim_jitter_deg=40.0, tint_strength=0.3, fx_amount=5, fx_gravity=-12.0, fx_size=1.6)),
    "caparazon": ("agua", dict(display_name="Caparazón", color="Color(0.45, 0.75, 1, 1)", duration=1.5, can_move=False,
                               damage_taken_mult=0.25, knockback_mult=0.0, tint_strength=0.35, fx_amount=4)),
}

# Campos de MoveData; "st:<id>" = un estado de data/status, "[st:<id>]" = lista de uno.
KITS = {
    "charmander": dict(
        role="A distancia", archetype="hostigador", preferred_range=95.0, mobility_back=True,
        moves=[
            dict(id="d_ascuas", display_name="Ascuas", element="fuego", kind="PROJECTILE", category="especial",
                 power=40.0, power_mult=0.55, cooldown=0.5, knockback=60.0, speed=300.0, lifetime=0.7, size=4.0,
                 status="st:quemado", status_chance=0.25),
            dict(id="d_colmillo_igneo", display_name="Colmillo Ígneo", element="fuego", kind="MELEE", category="fisico",
                 power=65.0, cooldown=4.0, knockback=220.0, final_knockback=220.0, melee_step=34.0, melee_range=16.0,
                 swing_radius=13.0, recovery=0.15, bonus_vs_status="quemado", bonus_vs_mult=2.0),
            dict(id="d_pantalla_humo", display_name="Pantalla de Humo", element="normal", kind="ZONE", category="estado",
                 power=0.0, cooldown=9.0, knockback=0.0, zone_radius=44.0, zone_duration=4.0, placement_range=30.0,
                 zone_traps=False, zone_tick=0.4, zone_max_count=1, statuses_on_hit="[st:cegado]"),
            dict(id="d_infierno", display_name="Infierno", element="fuego", kind="AREA", category="especial",
                 power=110.0, cooldown=1.0, cast_time=0.5, knockback=260.0, radius=95.0, recovery=0.3,
                 statuses_on_hit="[st:quemado]"),
        ],
        mobility=dict(id="d_salto_cola", display_name="Salto de Cola", element="fuego", kind="DASH", category="estado",
                      power=0.0, cooldown=3.5, knockback=0.0, dash_time=0.2, dash_hits=False, invulnerable_time=0.3,
                      trail_power=20.0, trail_status="st:quemado", trail_status_chance=0.5, trail_duration=2.0),
    ),
    "squirtle": dict(
        role="Tanque", archetype="tanque", preferred_range=55.0, mobility_back=False,
        moves=[
            dict(id="d_pistola_agua", display_name="Pistola Agua", element="agua", kind="PROJECTILE", category="especial",
                 power=40.0, power_mult=0.6, cooldown=0.55, knockback=150.0, speed=280.0, lifetime=0.5, size=4.0,
                 skip_element_status=True),
            dict(id="d_burbujas", display_name="Burbujas", element="agua", kind="PROJECTILE", category="especial",
                 power=40.0, power_mult=0.6, cooldown=5.0, knockback=40.0, speed=150.0, lifetime=1.2, size=5.0,
                 projectile_count=3, spread_deg=32.0, skip_element_status=True, statuses_on_hit="[st:frenado]"),
            dict(id="d_refugio", display_name="Refugio", element="agua", kind="SELF_BUFF", category="estado",
                 power=0.0, cooldown=8.0, knockback=0.0, self_status="st:caparazon", duration=1.5),
            dict(id="d_hidrobomba", display_name="Hidrobomba", element="agua", kind="CHANNEL", category="especial",
                 power=110.0, power_mult=0.22, cooldown=1.0, cast_time=0.3, knockback=200.0, channel_time=1.2,
                 cone_angle_deg=14.0, cone_length=150.0, tick_interval=0.15, skip_element_status=True),
        ],
        mobility=dict(id="d_giro_rapido", display_name="Giro Rápido", element="normal", kind="DASH", category="fisico",
                      power=30.0, cooldown=3.5, knockback=120.0, dash_time=0.3, dash_hits=True, invulnerable_time=0.32,
                      cleanse_self=True),
    ),
    "bulbasaur": dict(
        role="Híbrido", archetype="control", preferred_range=70.0, mobility_back=False,
        moves=[
            dict(id="d_latigo_cepa", display_name="Látigo Cepa", element="planta", kind="WHIP", category="fisico",
                 power=45.0, power_mult=0.6, cooldown=0.65, knockback=50.0, whip_length=80.0, whip_width=8.0),
            dict(id="d_hoja_afilada", display_name="Hoja Afilada", element="planta", kind="PROJECTILE", category="fisico",
                 power=55.0, power_mult=0.7, cooldown=4.0, knockback=110.0, speed=340.0, lifetime=0.6, size=5.0,
                 projectile_count=2, spread_deg=14.0),
            dict(id="d_drenadoras", display_name="Drenadoras", element="planta", kind="ZONE", category="estado",
                 power=0.0, cooldown=7.0, knockback=0.0, zone_radius=26.0, zone_duration=8.0, placement_range=110.0,
                 zone_traps=False, zone_tick=0.5, zone_max_count=2, statuses_on_hit="[st:drenado]"),
            dict(id="d_rayo_solar", display_name="Rayo Solar", element="planta", kind="PROJECTILE", category="especial",
                 power=120.0, cooldown=1.0, cast_time=0.8, knockback=240.0, beam_length=260.0, size=8.0, recovery=0.3,
                 bonus_vs_status="drenado", bonus_vs_mult=1.4),
        ],
        mobility=dict(id="d_liana", display_name="Liana", element="planta", kind="LUNGE", category="fisico",
                      power=30.0, cooldown=4.0, knockback=60.0, lunge_range=110.0, lunge_speed=420.0,
                      followup_delay=0.12, followup_power_mult=0.6, followup_knockback=140.0),
    ),
}


def val(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    return '"%s"' % v


def tres(script_class, script, fields, raw=()):
    """fields: nombre -> valor; los "st:x", "[st:x]", "type:x" y "res:path" pasan a recursos externos."""
    ext = [('Script', 'res://scripts/resources/%s.gd' % script)]
    body = []

    def ref(kind, path):
        if (kind, path) not in ext:
            ext.append((kind, path))
        return 'ExtResource("%d")' % (ext.index((kind, path)) + 1)

    for k, v in fields.items():
        if isinstance(v, str) and v.startswith("st:"):
            s = ref('Resource', 'res://data/status/%s.tres' % v[3:])
        elif isinstance(v, str) and v.startswith("[st:"):  # "[st:a,b]" = varios
            ref('Script', 'res://scripts/resources/status_effect.gd')
            s = 'Array[ExtResource("%d")]([%s])' % (ext.index(('Script', 'res://scripts/resources/status_effect.gd')) + 1,
                                                  ", ".join(ref('Resource', 'res://data/status/%s.tres' % x)
                                                            for x in v[4:-1].split(",")))
        elif isinstance(v, str) and v.startswith("type:"):
            s = ref('Resource', 'res://data/types/%s.tres' % v[5:])
        elif isinstance(v, str) and v.startswith("res:"):
            s = ref('Resource', v[4:])
        elif isinstance(v, list):
            ref('Script', 'res://scripts/resources/move_data.gd')
            s = 'Array[ExtResource("%d")]([%s])' % (ext.index(('Script', 'res://scripts/resources/move_data.gd')) + 1,
                                                  ", ".join(ref('Resource', p) for p in v))
        elif isinstance(v, str) and v.startswith("Color("):
            s = v
        else:
            s = val(v)
        body.append("%s = %s" % (k, s))
    out = ['[gd_resource type="Resource" script_class="%s" load_steps=%d format=3]' % (script_class, len(ext) + 1), '']
    for i, (kind, path) in enumerate(ext):
        out.append('[ext_resource type="%s" path="%s" id="%d"]' % (kind, path, i + 1))
    out += ['', '[resource]', 'script = ExtResource("1")'] + body + ['']
    return "\n".join(out)


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def move_fields(m):
    f = dict(m)
    f["element"] = "type:" + f["element"]
    f["kind"] = KIND[f["kind"]]
    f["category"] = CAT[f["category"]]
    return f


def main(root):
    KITS.update(KITS_BOSQUE)
    ids = [m["id"] for k in KITS.values() for m in k["moves"] + [k["mobility"]]]
    assert len(ids) == len(set(ids)), "ids repetidos: %s" % sorted(x for x in ids if ids.count(x) > 1)
    for sid, (elem, fields) in STATUSES.items():
        f = dict(id=sid)
        f.update(fields)
        f["element"] = "type:" + elem
        write(os.path.join(root, "data/status/%s.tres" % sid), tres("StatusEffect", "status_effect", f))
    for sp, kit in KITS.items():
        base = "data/desafio_kits/%s" % sp
        # Ritmo general (se ajusta acá para todos; medido con --autotest-rogue-balance): cuánto pega el básico sobre su
        # potencia y cuánto duran las recargas de las habilidades y la movilidad sobre lo escrito en la tabla.
        kit["moves"][0]["power_mult"] = BASIC_MULT
        for m in kit["moves"][1:3] + [kit["mobility"]]:
            m["cooldown"] = round(m["cooldown"] * ABILITY_CD, 2)
        paths = []
        for m in kit["moves"] + [kit["mobility"]]:
            write(os.path.join(root, base, m["id"] + ".tres"), tres("MoveData", "move_data", move_fields(m)))
            paths.append("res://%s/%s.tres" % (base, m["id"]))
        f = dict(archetype=kit["archetype"], preferred_range=kit["preferred_range"], moves=paths[:4], role=kit["role"],
                 mobility="res:" + paths[4], mobility_back=kit["mobility_back"])
        write(os.path.join(root, base, "kit.tres"), tres("Kit", "kit", f))
        print(sp, kit["role"], [m["display_name"] for m in kit["moves"]], "+", kit["mobility"]["display_name"])


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else ".")
