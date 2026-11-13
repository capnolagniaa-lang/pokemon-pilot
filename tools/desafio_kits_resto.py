"""Kits de 5 teclas de los Pokémon del Volcán, la Costa, la Cueva, el Hielo y el Cementerio del Modo Desafío (pedido del
usuario 2026-11-13; los lee tools/build_desafio_kits.py). Mismo criterio que los del Bosque (desafio_kits_bosque.py): un
kit por línea evolutiva; `moves` = básico, habilidad de daño (la que también usan los esbirros), habilidad de control o
utilidad, definitiva; Espacio = movilidad para tomar distancia.

Acá los ataques se escriben con ayudantes por forma (b_shot, hit, rush, zone...) y **sin id**: `finish` les pone
"d_<nombre>_<especie>", así dos kits pueden tener un ataque con el mismo nombre. `look` (opcional) elige la hoja de
efecto en tools/desafio_vfx_resto.py; no va al .tres.
"""
import unicodedata

from desafio_kits_bosque import M, dash as _dash


def _m(name, element, kind, category, base, kw):
    d = dict(base)
    d.update(kw)
    return M("", name, element, kind, category, **d)


# --- Básicos (Clic izq.) ---
def b_shot(name, el, cat="especial", **kw):
    return _m(name, el, "PROJECTILE", cat, dict(power=40.0, cooldown=0.55, knockback=50.0, speed=300.0, lifetime=0.6,
                                               size=4.0), kw)


def b_hit(name, el, **kw):
    return _m(name, el, "MELEE", "fisico", dict(power=40.0, cooldown=0.5, knockback=70.0, final_knockback=70.0,
                                                melee_step=28.0), kw)


# --- Habilidades ---
def shot(name, el, power=55.0, cat="especial", **kw):
    return _m(name, el, "PROJECTILE", cat, dict(power=power, cooldown=4.0, knockback=100.0, speed=320.0, lifetime=0.6,
                                               size=5.0), kw)


def curse(name, el, status, **kw):
    """Disparo que no pega: solo deja el estado."""
    return _m(name, el, "PROJECTILE", "estado", dict(power=0.0, cooldown=9.0, knockback=0.0, speed=220.0, lifetime=0.7,
                                                     size=6.0, statuses_on_hit="[st:%s]" % status), kw)


def hit(name, el, power=60.0, **kw):
    kb = kw.pop("knockback", 180.0)
    return _m(name, el, "MELEE", "fisico", dict(power=power, cooldown=3.5, knockback=kb, final_knockback=kb,
                                                melee_step=30.0), kw)


def combo(name, el, power=26.0, steps=2, **kw):
    return _m(name, el, "MELEE", "fisico", dict(power=power, cooldown=3.5, knockback=40.0, final_knockback=220.0,
                                                melee_step=26.0, combo_steps=steps, combo_window=0.7,
                                                combo_step_cooldown=0.2), kw)


def rush(name, el, power=60.0, **kw):
    return _m(name, el, "DASH", "fisico", dict(power=power, cooldown=4.0, knockback=200.0, dash_time=0.22,
                                               dash_hits=True, invulnerable_time=0.15), kw)


def zone(name, el, status, **kw):
    return _m(name, el, "ZONE", "estado", dict(power=0.0, cooldown=8.0, knockback=0.0, zone_radius=36.0,
                                               zone_duration=5.0, placement_range=90.0, zone_traps=False, zone_tick=0.5,
                                               zone_max_count=1, statuses_on_hit="[st:%s]" % status), kw)


def strike(name, el, power=65.0, cat="especial", **kw):
    return _m(name, el, "ZONE", cat, dict(power=power, cooldown=4.5, knockback=200.0, zone_radius=34.0,
                                          placement_range=130.0, zone_strike=True, strike_delay=0.45), kw)


def area(name, el, status, **kw):
    """Onda alrededor que no pega: deja el estado."""
    return _m(name, el, "AREA", "estado", dict(power=0.0, cooldown=8.0, knockback=0.0, radius=62.0,
                                               statuses_on_hit="[st:%s]" % status), kw)


def blast(name, el, power=55.0, cat="fisico", **kw):
    return _m(name, el, "AREA", cat, dict(power=power, cooldown=4.5, knockback=200.0, radius=56.0), kw)


def buff(name, el, status, duration=5.0, **kw):
    return _m(name, el, "SELF_BUFF", "estado", dict(power=0.0, cooldown=10.0, knockback=0.0,
                                                    self_status="st:%s" % status, duration=duration), kw)


def whip(name, el, power=50.0, **kw):
    return _m(name, el, "WHIP", "fisico", dict(power=power, cooldown=4.0, knockback=60.0, whip_length=95.0,
                                               whip_width=9.0), kw)


# --- Definitivas (R, con la barra llena) ---
def u_area(name, el, power=110.0, cat="especial", **kw):
    return _m(name, el, "AREA", cat, dict(power=power, cooldown=1.0, cast_time=0.5, knockback=260.0, radius=92.0,
                                          recovery=0.3), kw)


def u_beam(name, el, power=110.0, **kw):
    return _m(name, el, "PROJECTILE", "especial", dict(power=power, cooldown=1.0, cast_time=0.6, knockback=220.0,
                                                       beam_length=220.0, size=7.0, recovery=0.25), kw)


def u_channel(name, el, power=100.0, **kw):
    return _m(name, el, "CHANNEL", "especial", dict(power=power, power_mult=0.22, cooldown=1.0, cast_time=0.3,
                                                    knockback=120.0, channel_time=1.2, cone_angle_deg=34.0,
                                                    cone_length=110.0, tick_interval=0.15), kw)


def u_fan(name, el, power=60.0, **kw):
    return _m(name, el, "PROJECTILE", "especial", dict(power=power, power_mult=0.5, cooldown=1.0, cast_time=0.4,
                                                       knockback=120.0, speed=320.0, lifetime=0.6, size=5.0,
                                                       projectile_count=7, spread_deg=70.0), kw)


def u_rain(name, el, power=80.0, cat="especial", **kw):
    return _m(name, el, "ZONE", cat, dict(power=power, power_mult=0.6, cooldown=1.0, knockback=180.0, zone_radius=30.0,
                                          placement_range=140.0, zone_strike=True, strike_delay=0.4, strike_count=5,
                                          strike_spread=50.0), kw)


def u_strike(name, el, power=125.0, cat="especial", **kw):
    return _m(name, el, "ZONE", cat, dict(power=power, cooldown=1.0, knockback=240.0, zone_radius=48.0,
                                          placement_range=150.0, zone_strike=True, strike_delay=0.55), kw)


def u_lunge(name, el, power=110.0, **kw):
    return _m(name, el, "LUNGE", "fisico", dict(power=power, cooldown=1.0, cast_time=0.3, knockback=160.0,
                                                lunge_range=115.0, lunge_speed=480.0, followup_delay=0.12,
                                                followup_power_mult=0.5, followup_knockback=260.0), kw)


def u_rush(name, el, power=110.0, **kw):
    return _m(name, el, "DASH", "fisico", dict(power=power, cooldown=1.0, cast_time=0.3, knockback=300.0,
                                               dash_time=0.35, dash_hits=True, invulnerable_time=0.35, recovery=0.25), kw)


def u_smash(name, el, power=120.0, **kw):
    return _m(name, el, "MELEE", "fisico", dict(power=power, cooldown=1.0, cast_time=0.3, knockback=340.0,
                                                final_knockback=340.0, melee_step=50.0, melee_range=18.0,
                                                swing_radius=20.0, recovery=0.25), kw)


def dash(name, el, **kw):
    return _dash("", name, el, **kw)


FIRE_TRAIL = dict(trail_power=20.0, trail_status="st:quemado", trail_status_chance=0.5, trail_duration=2.0)


def kit(role, archetype, rng, basic, a1, a2, ult, mobility):
    return dict(role=role, archetype=archetype, preferred_range=rng, mobility_back=True, moves=[basic, a1, a2, ult],
                mobility=mobility)


RANGED, MELEE, TANK, HYBRID = "A distancia", "Cuerpo a cuerpo", "Tanque", "Híbrido"

KITS_RESTO = {
    # ------------------------------------------------ Volcán ------------------------------------------------
    "vulpix": kit(RANGED, "hostigador", 95.0,
                  b_shot("Ascuas", "fuego", status="st:quemado", status_chance=0.2),
                  shot("Lanzallamas", "fuego", status="st:quemado", status_chance=0.4),
                  curse("Rayo Confuso", "fantasma", "desorientado"),
                  u_fan("Llamarada", "fuego", statuses_on_hit="[st:quemado]"),
                  dash("Paso de Zorro", "fuego", cooldown=3.0)),
    "growlithe": kit(MELEE, "bruiser", 30.0,
                     b_hit("Mordisco", "normal", look="bite"),
                     rush("Rueda Fuego", "fuego", status="st:quemado", status_chance=0.4, look="spin"),
                     area("Rugido", "normal", "intimidado"),
                     u_rush("Envite Ígneo", "fuego", statuses_on_hit="[st:quemado]", look="spin"),
                     dash("Carrera", "normal", cooldown=3.0)),
    "ponyta": kit(MELEE, "velocista", 32.0,
                  b_hit("Pisotón", "normal", cooldown=0.45),
                  rush("Nitrocarga", "fuego", power=55.0, **FIRE_TRAIL),
                  buff("Agilidad", "psiquico", "agilidad", duration=4.0),
                  u_area("Giro Fuego", "fuego", power=100.0, radius=85.0, statuses_on_hit="[st:quemado]"),
                  dash("Galope", "fuego", cooldown=3.0, time=0.24, **FIRE_TRAIL)),
    "geodude": kit(TANK, "tanque", 34.0,
                   b_hit("Placaje", "normal"),
                   shot("Lanzarrocas", "roca", cat="fisico", knockback=160.0, speed=280.0),
                   buff("Fortaleza", "normal", "fortaleza", duration=3.0),
                   u_area("Terremoto", "tierra", cat="fisico", radius=95.0),
                   dash("Rodar", "roca", time=0.25, look="spin")),
    "koffing": kit(RANGED, "control", 85.0,
                   b_shot("Residuos", "veneno", status="st:envenenado", status_chance=0.25),
                   strike("Bomba Lodo", "veneno", statuses_on_hit="[st:envenenado]"),
                   zone("Gas Venenoso", "veneno", "envenenado", zone_radius=40.0),
                   u_area("Explosión", "normal", power=130.0, cat="fisico", cast_time=0.6, radius=100.0, knockback=320.0),
                   dash("Flotar", "veneno", time=0.26)),
    "grimer": kit(TANK, "desgaste", 36.0,
                  b_hit("Golpe Lodo", "veneno", status="st:envenenado", status_chance=0.3),
                  shot("Residuos", "veneno", status="st:envenenado", status_chance=0.5),
                  zone("Charco Tóxico", "veneno", "frenado", zone_duration=6.0, look="puddle"),
                  u_rain("Bomba Lodo", "veneno", statuses_on_hit="[st:envenenado]"),
                  dash("Deslizarse", "veneno", time=0.26)),
    "cubone": kit(MELEE, "bruiser", 34.0,
                  b_hit("Hueso Palo", "tierra", melee_range=14.0),
                  shot("Huesomerang", "tierra", cat="fisico", lifetime=0.5, knockback=140.0, look="egg"),
                  area("Gruñido", "normal", "intimidado"),
                  u_lunge("Hueso Veloz", "tierra", followup_power_mult=1.0),
                  dash("Salto", "tierra")),
    "rhyhorn": kit(TANK, "tanque", 34.0,
                   b_hit("Cornada", "normal"),
                   rush("Derribo", "normal", power=65.0, knockback=260.0),
                   area("Cara Susto", "normal", "frenado"),
                   u_lunge("Perforador", "normal", power=130.0, cast_time=0.4, execute_below=0.2, look="spin"),
                   dash("Trote", "roca")),
    "doduo": kit(MELEE, "velocista", 28.0,
                 b_hit("Picotazo", "volador", power=35.0, cooldown=0.45),
                 combo("Ataque Furia", "normal", power=22.0, steps=3),
                 buff("Furia", "normal", "enfurecido"),
                 u_rush("Pico Taladro", "volador", look="spin"),
                 dash("Sprint", "normal", cooldown=2.2, time=0.16, inv=0.28)),
    "magmar": kit(RANGED, "artillero", 95.0,
                  b_shot("Ascuas", "fuego", status="st:quemado", status_chance=0.2),
                  hit("Puño Fuego", "fuego", power=65.0, statuses_on_hit="[st:quemado]"),
                  zone("Pantalla de Humo", "normal", "cegado", zone_radius=44.0, zone_duration=4.0, placement_range=30.0),
                  u_channel("Lanzallamas", "fuego", statuses_on_hit="[st:quemado]"),
                  dash("Salto Ígneo", "fuego", **FIRE_TRAIL)),
    # ------------------------------------------------ Costa -------------------------------------------------
    "poliwag": kit(HYBRID, "control", 60.0,
                   b_shot("Burbuja", "agua", status="st:frenado", status_chance=0.2),
                   combo("Doble Bofetón", "normal"),
                   curse("Hipnosis", "psiquico", "dormido", cooldown=10.0, speed=160.0, lifetime=0.8),
                   u_beam("Hidrobomba", "agua"),
                   dash("Chapuzón", "agua")),
    "psyduck": kit(RANGED, "control", 85.0,
                   b_shot("Pistola Agua", "agua"),
                   shot("Confusión", "psiquico", status="st:desorientado", status_chance=0.5),
                   curse("Anulación", "normal", "intimidado", speed=320.0, lifetime=0.5),
                   u_area("Psíquico", "psiquico", statuses_on_hit="[st:desorientado]"),
                   dash("Tropezón", "agua")),
    "krabby": kit(MELEE, "bruiser", 30.0,
                  b_hit("Agarre", "normal", look="bite"),
                  hit("Martillazo", "agua", power=65.0, knockback=220.0),
                  buff("Fortaleza", "normal", "fortaleza", duration=3.0),
                  u_lunge("Guillotina", "normal", power=120.0, execute_below=0.3, look="xslash"),
                  dash("Paso Lateral", "agua", cooldown=3.0)),
    "shellder": kit(TANK, "tanque", 50.0,
                    b_shot("Carámbano", "hielo", cat="fisico", power=35.0),
                    hit("Tenaza", "agua", power=50.0, knockback=60.0, statuses_on_hit="[st:enraizado]", look="bite"),
                    buff("Refugio", "agua", "refugio", duration=1.5),
                    u_beam("Rayo Aurora", "hielo", statuses_on_hit="[st:frenado]"),
                    dash("Chorro", "agua")),
    "staryu": kit(RANGED, "hostigador", 90.0,
                  b_shot("Rapidez", "normal", speed=340.0),
                  shot("Rayo Burbuja", "agua", power=28.0, power_mult=0.65, projectile_count=3, spread_deg=18.0,
                       knockback=50.0),
                  area("Destello", "normal", "cegado"),
                  u_area("Giro Estelar", "agua", radius=88.0),
                  dash("Giro Rápido", "normal", cooldown=3.0, look="spin")),
    "horsea": kit(RANGED, "artillero", 100.0,
                  b_shot("Pistola Agua", "agua"),
                  shot("Rayo Burbuja", "agua", power=28.0, power_mult=0.65, projectile_count=3, spread_deg=18.0,
                       knockback=50.0),
                  zone("Pantalla de Humo", "normal", "cegado", zone_radius=44.0, zone_duration=4.0, placement_range=30.0),
                  u_channel("Ciclón", "dragon", knockback=280.0, deflects_projectiles=True),
                  dash("Propulsión", "agua", time=0.22)),
    "tentacool": kit(HYBRID, "desgaste", 70.0,
                     b_shot("Ácido", "veneno", status="st:envenenado", status_chance=0.2),
                     whip("Látigo Tóxico", "veneno", statuses_on_hit="[st:envenenado]"),
                     area("Supersónico", "normal", "desorientado"),
                     u_area("Onda Tóxica", "veneno", power=100.0, statuses_on_hit="[st:envenenado,frenado]"),
                     dash("Deriva", "agua", time=0.24)),
    "goldeen": kit(MELEE, "velocista", 30.0,
                   b_hit("Picotazo", "volador", power=35.0, cooldown=0.45),
                   rush("Cornada", "normal"),
                   area("Supersónico", "normal", "desorientado"),
                   u_rush("Cascada", "agua"),
                   dash("Aletazo", "agua", cooldown=3.0)),
    "slowpoke": kit(TANK, "control", 70.0,
                    b_shot("Pistola Agua", "agua"),
                    hit("Cabezazo", "normal", power=65.0, knockback=240.0),
                    curse("Bostezo", "normal", "dormido", cooldown=10.0, speed=150.0, lifetime=0.8),
                    u_area("Psíquico", "psiquico", statuses_on_hit="[st:desorientado]"),
                    dash("Zambullida", "agua", cooldown=4.0, time=0.3, inv=0.42)),
    "magikarp": kit(MELEE, "asesino", 28.0,
                    b_hit("Placaje", "normal"),
                    hit("Azote", "normal", execute_below=0.3),
                    area("Salpicadura", "agua", "frenado", radius=54.0),
                    u_beam("Furia Dragón", "dragon", power=120.0),
                    dash("Coletazo", "agua", cooldown=3.0)),
    "omanyte": kit(RANGED, "artillero", 95.0,
                   b_shot("Pistola Agua", "agua"),
                   shot("Disparo Lodo", "tierra", statuses_on_hit="[st:frenado]"),
                   buff("Refugio", "agua", "refugio", duration=1.5),
                   u_rain("Poder Pasado", "roca", look="drop"),
                   dash("Propulsión", "agua", time=0.22)),
    "kabuto": kit(MELEE, "bruiser", 30.0,
                  b_hit("Arañazo", "normal"),
                  hit("Cuchillada", "normal", power=65.0),
                  buff("Fortaleza", "normal", "fortaleza", duration=3.0),
                  u_lunge("Tajo Acuático", "agua", look="xslash"),
                  dash("Deslizar", "agua", cooldown=3.0)),
    # ------------------------------------------------ Cueva -------------------------------------------------
    "zubat": kit(HYBRID, "hostigador", 50.0,
                 b_hit("Chupavidas", "bicho", power=35.0, drain=0.3, look="bite"),
                 rush("Ataque Ala", "volador"),
                 area("Supersónico", "normal", "desorientado"),
                 u_lunge("Veneno X", "veneno", followup_power_mult=1.0, statuses_on_hit="[st:envenenado,herido]",
                         look="xslash"),
                 dash("Aleteo", "volador", cooldown=3.0, time=0.24, inv=0.35)),
    "sandshrew": kit(MELEE, "bruiser", 30.0,
                     b_hit("Arañazo", "normal"),
                     hit("Cuchillada", "normal", power=65.0),
                     shot("Ataque Arena", "tierra", power=0.0, cat="estado", cooldown=7.0, knockback=0.0, speed=220.0,
                          lifetime=0.45, projectile_count=3, spread_deg=40.0, statuses_on_hit="[st:cegado]"),
                     u_area("Terremoto", "tierra", cat="fisico", radius=95.0),
                     dash("Excavar", "tierra", cooldown=4.0, time=0.3, inv=0.42)),
    "diglett": kit(MELEE, "asesino", 28.0,
                   b_hit("Arañazo", "normal", cooldown=0.45),
                   blast("Magnitud", "tierra"),
                   shot("Ataque Arena", "tierra", power=0.0, cat="estado", cooldown=7.0, knockback=0.0, speed=220.0,
                        lifetime=0.45, projectile_count=3, spread_deg=40.0, statuses_on_hit="[st:cegado]"),
                   u_strike("Fisura", "tierra", cat="fisico", placement_range=110.0, look="drop"),
                   dash("Túnel", "tierra", cooldown=3.0, time=0.28, inv=0.42)),
    "machop": kit(MELEE, "bruiser", 28.0,
                  b_hit("Golpe Kárate", "lucha", power=45.0),
                  hit("Sumisión", "lucha", power=70.0, knockback=240.0),
                  buff("Foco Energía", "normal", "potenciado", duration=6.0),
                  u_smash("Puño Dinámico", "lucha", statuses_on_hit="[st:desorientado]"),
                  dash("Finta", "lucha", cooldown=3.2)),
    "clefairy": kit(HYBRID, "control", 60.0,
                    b_hit("Destructor", "normal"),
                    combo("Doble Bofetón", "normal"),
                    curse("Canto", "normal", "dormido", cooldown=10.0, speed=160.0, lifetime=0.8),
                    u_strike("Fuerza Lunar", "hada", look="drop"),
                    dash("Brinco Lunar", "hada", time=0.26, inv=0.36)),
    "onix": kit(TANK, "tanque", 40.0,
                b_hit("Atadura", "normal", melee_range=16.0),
                shot("Lanzarrocas", "roca", cat="fisico", knockback=160.0, speed=280.0),
                buff("Fortaleza", "normal", "fortaleza", duration=3.0),
                u_rain("Avalancha", "roca", cat="fisico", look="drop"),
                dash("Deslizar", "roca", time=0.26)),
    # ------------------------------------------------ Hielo -------------------------------------------------
    "seel": kit(HYBRID, "bruiser", 50.0,
                b_shot("Viento Hielo", "hielo", status="st:frenado", status_chance=0.25, look="gust"),
                rush("Cabezazo", "normal"),
                zone("Neblina", "hielo", "cegado", zone_radius=44.0, zone_duration=4.0, placement_range=30.0),
                u_area("Ventisca", "hielo", statuses_on_hit="[st:frenado]"),
                dash("Deslizar", "hielo", cooldown=3.0)),
    "jynx": kit(RANGED, "control", 90.0,
                b_shot("Nieve Polvo", "hielo", status="st:frenado", status_chance=0.2),
                hit("Puño Hielo", "hielo", power=65.0, statuses_on_hit="[st:frenado]"),
                curse("Beso Amoroso", "normal", "dormido", cooldown=10.0, speed=160.0, lifetime=0.8),
                u_channel("Ventisca", "hielo", statuses_on_hit="[st:frenado]"),
                dash("Paso de Baile", "psiquico", cooldown=3.0)),
    "lapras": kit(TANK, "artillero", 85.0,
                  b_shot("Pistola Agua", "agua"),
                  rush("Golpe Cuerpo", "normal", power=65.0, knockback=240.0),
                  curse("Rayo Confuso", "fantasma", "desorientado"),
                  u_beam("Rayo Hielo", "hielo", power=115.0, statuses_on_hit="[st:congelado]"),
                  dash("Surcar", "agua", time=0.26)),
    # ---------------------------------------------- Cementerio ----------------------------------------------
    "gastly": kit(RANGED, "hostigador", 95.0,
                  b_shot("Tinieblas", "fantasma"),
                  shot("Bola Sombra", "fantasma", power=60.0, statuses_on_hit="[st:expuesto]"),
                  curse("Hipnosis", "psiquico", "dormido", cooldown=10.0, speed=160.0, lifetime=0.8),
                  u_area("Pulso Umbrío", "fantasma", power=100.0, drain=0.4),
                  dash("Desvanecerse", "fantasma", time=0.24, inv=0.45)),
    "drowzee": kit(HYBRID, "control", 60.0,
                   b_hit("Destructor", "normal"),
                   shot("Confusión", "psiquico", status="st:desorientado", status_chance=0.5),
                   curse("Hipnosis", "psiquico", "dormido", cooldown=10.0, speed=160.0, lifetime=0.8),
                   u_area("Psíquico", "psiquico", statuses_on_hit="[st:desorientado]"),
                   dash("Paso Onírico", "psiquico")),
    "ekans": kit(HYBRID, "desgaste", 60.0,
                 b_hit("Colmillo Veneno", "veneno", status="st:envenenado", status_chance=0.35, look="bite"),
                 shot("Ácido", "veneno", power=50.0, statuses_on_hit="[st:expuesto]"),
                 curse("Deslumbrar", "normal", "paralizado", speed=260.0),
                 u_lunge("Constricción", "normal", power=100.0, statuses_on_hit="[st:enraizado]"),
                 dash("Reptar", "veneno")),
    "abra": kit(RANGED, "artillero", 100.0,
                b_shot("Psicorrayo", "psiquico", status="st:desorientado", status_chance=0.15),
                shot("Psicocorte", "psiquico", speed=400.0, lifetime=0.5),
                area("Destello", "normal", "cegado"),
                u_strike("Premonición", "psiquico", strike_delay=0.7, zone_radius=52.0, look="drop"),
                dash("Teletransporte", "psiquico", cooldown=3.0, time=0.12, inv=0.35)),
    "meowth": kit(MELEE, "asesino", 28.0,
                  b_hit("Arañazo", "normal", cooldown=0.45),
                  shot("Día de Pago", "normal", power=26.0, power_mult=0.65, cat="fisico", projectile_count=3,
                       spread_deg=20.0, knockback=50.0),
                  area("Chirrido", "normal", "expuesto"),
                  u_lunge("Cuchillada Feroz", "normal", followup_power_mult=1.0, look="xslash"),
                  dash("Salto Gatuno", "normal", cooldown=2.2, time=0.16, inv=0.28)),
}

# Hoja de efecto elegida a mano para un ataque: id -> nombre del generador (lo lee desafio_vfx_resto.py)
LOOKS = {}


def _slug(text):
    t = unicodedata.normalize("NFD", text.lower())
    t = "".join(c for c in t if unicodedata.category(c) != "Mn")
    return "".join(c if c.isalnum() else "_" for c in t).strip("_")


def finish():
    """Pone los ids ("d_<nombre>_<especie>") y saca `look` de cada ataque (queda en LOOKS)."""
    for sp, k in KITS_RESTO.items():
        for m in k["moves"] + [k["mobility"]]:
            if m["id"] == "":
                m["id"] = "d_%s_%s" % (_slug(m["display_name"]), sp)
            if "look" in m:
                LOOKS[m["id"]] = m.pop("look")
    return KITS_RESTO


finish()
