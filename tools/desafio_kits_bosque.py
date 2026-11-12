"""Kits de 5 teclas de los Pokémon del Bosque del Modo Desafío (los lee tools/build_desafio_kits.py).

Un kit por línea evolutiva (Metapod y Butterfree usan el de Caterpie, etc.). Orden de `moves`: básico, habilidad de daño
(la que también usan los esbirros), habilidad de control o utilidad, definitiva. Los ids llevan "d_" + algo propio de la
especie cuando el nombre se repite entre kits.
"""


def M(id, name, element, kind, category, **kw):
    d = dict(id=id, display_name=name, element=element, kind=kind, category=category)
    d.update(kw)
    return d


def dash(id, name, element, cooldown=3.5, time=0.2, inv=0.3, **kw):
    """Movilidad que no pega."""
    return M(id, name, element, "DASH", "estado", power=0.0, cooldown=cooldown, knockback=0.0, dash_time=time,
             dash_hits=False, invulnerable_time=inv, **kw)


KITS_BOSQUE = {
    "caterpie": dict(
        role="A distancia", archetype="control", preferred_range=85.0, mobility_back=True,
        moves=[
            M("d_disparo_demora", "Disparo Demora", "bicho", "PROJECTILE", "especial", power=30.0, power_mult=0.55,
              cooldown=0.6, knockback=30.0, speed=260.0, lifetime=0.6, size=4.0, statuses_on_hit="[st:seda]"),
            M("d_picadura", "Picadura", "bicho", "MELEE", "fisico", power=50.0, cooldown=3.5, knockback=160.0,
              final_knockback=160.0, melee_step=30.0),
            M("d_telarana", "Telaraña", "bicho", "ZONE", "estado", power=0.0, cooldown=8.0, knockback=0.0,
              zone_radius=34.0, zone_duration=5.0, placement_range=100.0, zone_traps=False, zone_tick=0.4,
              zone_max_count=2, statuses_on_hit="[st:enredado]"),
            M("d_red_pegajosa", "Red Pegajosa", "bicho", "AREA", "especial", power=70.0, cooldown=1.0, cast_time=0.45,
              knockback=60.0, radius=80.0, recovery=0.25, statuses_on_hit="[st:enraizado]"),
        ],
        mobility=M("d_hilo", "Hilo", "bicho", "LUNGE", "fisico", power=15.0, cooldown=3.5, knockback=40.0,
                   lunge_range=95.0, lunge_speed=400.0, followup_delay=0.1, followup_power_mult=0.5),
    ),
    "weedle": dict(
        role="Cuerpo a cuerpo", archetype="desgaste", preferred_range=30.0, mobility_back=False,
        moves=[
            M("d_picotazo_veneno", "Picotazo Veneno", "veneno", "MELEE", "fisico", power=35.0, power_mult=0.65,
              cooldown=0.55, knockback=70.0, final_knockback=70.0, melee_step=26.0, status="st:envenenado",
              status_chance=0.4),
            M("d_pin_misil", "Pin Misil", "bicho", "PROJECTILE", "fisico", power=25.0, power_mult=0.65, cooldown=4.0,
              knockback=50.0, speed=330.0, lifetime=0.55, size=3.0, projectile_count=3, spread_deg=18.0),
            M("d_puas_toxicas", "Púas Tóxicas", "veneno", "ZONE", "fisico", power=20.0, power_mult=0.3, cooldown=8.0,
              knockback=0.0, zone_radius=30.0, zone_duration=6.0, placement_range=90.0, zone_traps=False,
              zone_tick=0.5, zone_max_count=2, statuses_on_hit="[st:envenenado]"),
            M("d_doble_ataque", "Doble Ataque", "bicho", "LUNGE", "fisico", power=90.0, cooldown=1.0, cast_time=0.3,
              knockback=120.0, lunge_range=120.0, lunge_speed=480.0, followup_delay=0.15, followup_power_mult=1.0,
              followup_knockback=260.0, statuses_on_hit="[st:envenenado]"),
        ],
        mobility=M("d_arremetida", "Arremetida", "bicho", "DASH", "fisico", power=25.0, cooldown=3.5, knockback=90.0,
                   dash_time=0.2, dash_hits=True, invulnerable_time=0.25),
    ),
    "pidgey": dict(
        role="A distancia", archetype="hostigador", preferred_range=90.0, mobility_back=True,
        moves=[
            M("d_tornado", "Tornado", "volador", "PROJECTILE", "especial", power=40.0, power_mult=0.5, cooldown=0.55,
              knockback=110.0, speed=260.0, lifetime=0.6, size=5.0),
            M("d_ataque_ala", "Ataque Ala", "volador", "DASH", "fisico", power=60.0, cooldown=4.0, knockback=200.0,
              dash_time=0.22, dash_hits=True, invulnerable_time=0.15),
            M("d_ataque_arena", "Ataque Arena", "tierra", "PROJECTILE", "estado", power=0.0, cooldown=7.0, knockback=0.0,
              speed=220.0, lifetime=0.45, size=5.0, projectile_count=3, spread_deg=40.0, statuses_on_hit="[st:cegado]"),
            M("d_vendaval", "Vendaval", "volador", "CHANNEL", "especial", power=100.0, power_mult=0.22, cooldown=1.0,
              cast_time=0.3, knockback=320.0, channel_time=1.2, cone_angle_deg=40.0, cone_length=110.0,
              tick_interval=0.15, deflects_projectiles=True),
        ],
        mobility=dash("d_vuelo_corto", "Vuelo Corto", "volador", cooldown=3.0, time=0.28, inv=0.38),
    ),
    "rattata": dict(
        role="Cuerpo a cuerpo", archetype="asesino", preferred_range=28.0, mobility_back=False,
        moves=[
            M("d_mordisco", "Mordisco", "normal", "MELEE", "fisico", power=40.0, power_mult=0.6, cooldown=0.5,
              knockback=70.0, final_knockback=70.0, melee_step=28.0),
            M("d_ataque_rapido", "Ataque Rápido", "normal", "DASH", "fisico", power=40.0, cooldown=3.0, knockback=120.0,
              dash_time=0.16, dash_hits=True, invulnerable_time=0.12),
            M("d_foco_energia", "Foco Energía", "normal", "SELF_BUFF", "estado", power=0.0, cooldown=10.0,
              knockback=0.0, self_status="st:enfurecido", duration=5.0),
            M("d_hipercolmillo", "Hipercolmillo", "normal", "LUNGE", "fisico", power=110.0, cooldown=1.0,
              cast_time=0.25, knockback=160.0, lunge_range=110.0, lunge_speed=480.0, followup_delay=0.12,
              followup_power_mult=0.5, followup_knockback=240.0, execute_below=0.25),
        ],
        mobility=dash("d_escurrirse", "Escurrirse", "normal", cooldown=2.2, time=0.16, inv=0.28),
    ),
    "oddish": dict(
        role="Híbrido", archetype="desgaste", preferred_range=65.0, mobility_back=True,
        moves=[
            M("d_absorber", "Absorber", "planta", "PROJECTILE", "especial", power=30.0, power_mult=0.6, cooldown=0.6,
              knockback=30.0, speed=240.0, lifetime=0.5, size=4.0, drain=0.5),
            M("d_acido", "Ácido", "veneno", "PROJECTILE", "especial", power=50.0, cooldown=4.0, knockback=80.0,
              speed=280.0, lifetime=0.6, size=5.0, statuses_on_hit="[st:expuesto]"),
            M("d_polvo_veneno", "Polvo Veneno", "veneno", "ZONE", "estado", power=0.0, cooldown=8.0, knockback=0.0,
              zone_radius=36.0, zone_duration=5.0, placement_range=80.0, zone_traps=False, zone_tick=0.5,
              zone_max_count=1, statuses_on_hit="[st:envenenado]"),
            M("d_megaagotar", "Megaagotar", "planta", "CHANNEL", "especial", power=90.0, power_mult=0.22, cooldown=1.0,
              cast_time=0.3, knockback=40.0, channel_time=1.2, cone_angle_deg=30.0, cone_length=95.0,
              tick_interval=0.15, drain=0.6),
        ],
        mobility=dash("d_saltito", "Saltito", "planta"),
    ),
    "bellsprout": dict(
        role="A distancia", archetype="espaciador", preferred_range=80.0, mobility_back=True,
        moves=[
            M("d_latigazo", "Latigazo", "planta", "WHIP", "fisico", power=45.0, power_mult=0.6, cooldown=0.65,
              knockback=50.0, whip_length=90.0, whip_width=8.0),
            M("d_hoja_filo", "Hoja Afilada", "planta", "PROJECTILE", "fisico", power=55.0, cooldown=3.5, knockback=110.0,
              speed=360.0, lifetime=0.6, size=5.0),
            M("d_constriccion", "Constricción", "planta", "WHIP", "fisico", power=20.0, cooldown=7.0, knockback=-120.0,
              whip_length=100.0, whip_width=9.0, statuses_on_hit="[st:enraizado]"),
            M("d_tormenta_hojas", "Tormenta de Hojas", "planta", "PROJECTILE", "especial", power=60.0, power_mult=0.5,
              cooldown=1.0, cast_time=0.4, knockback=120.0, speed=320.0, lifetime=0.6, size=5.0, projectile_count=7,
              spread_deg=70.0),
        ],
        mobility=dash("d_resorte", "Resorte", "planta"),
    ),
    "paras": dict(
        role="Tanque", archetype="control", preferred_range=34.0, mobility_back=False,
        moves=[
            M("d_aranazo", "Arañazo", "normal", "MELEE", "fisico", power=40.0, power_mult=0.6, cooldown=0.55,
              knockback=70.0, final_knockback=70.0, melee_step=26.0),
            M("d_chupavidas", "Chupavidas", "bicho", "MELEE", "fisico", power=50.0, cooldown=4.0, knockback=90.0,
              final_knockback=90.0, melee_step=30.0, drain=0.6),
            M("d_paralizador", "Paralizador", "planta", "ZONE", "estado", power=0.0, cooldown=10.0, knockback=0.0,
              zone_radius=34.0, zone_duration=3.0, placement_range=70.0, zone_traps=False, zone_tick=0.6,
              zone_max_count=1, statuses_on_hit="[st:paralizado]"),
            M("d_espora", "Espora", "planta", "AREA", "estado", power=0.0, cooldown=1.0, cast_time=0.5, knockback=0.0,
              radius=72.0, recovery=0.2, statuses_on_hit="[st:dormido]"),
        ],
        mobility=dash("d_bajo_tierra", "Bajo Tierra", "tierra", cooldown=4.0, time=0.3, inv=0.42),
    ),
    "venonat": dict(
        role="A distancia", archetype="control", preferred_range=85.0, mobility_back=True,
        moves=[
            M("d_psicorrayo", "Psicorrayo", "psiquico", "PROJECTILE", "especial", power=40.0, power_mult=0.55,
              cooldown=0.55, knockback=50.0, speed=300.0, lifetime=0.6, size=4.0, status="st:desorientado",
              status_chance=0.2),
            M("d_chupavidas_venonat", "Chupavidas", "bicho", "MELEE", "fisico", power=50.0, cooldown=4.0, knockback=90.0,
              final_knockback=90.0, melee_step=30.0, drain=0.5),
            M("d_supersonico", "Supersónico", "normal", "AREA", "estado", power=0.0, cooldown=8.0, knockback=0.0,
              radius=62.0, statuses_on_hit="[st:desorientado]"),
            M("d_onda_mental", "Onda Mental", "psiquico", "PROJECTILE", "especial", power=100.0, cooldown=1.0,
              cast_time=0.6, knockback=200.0, beam_length=220.0, size=7.0, recovery=0.25,
              statuses_on_hit="[st:desorientado]"),
        ],
        mobility=dash("d_revoloteo", "Revoloteo", "bicho", time=0.22),
    ),
    "spearow": dict(
        role="Cuerpo a cuerpo", archetype="bruiser", preferred_range=28.0, mobility_back=False,
        moves=[
            M("d_picotazo", "Picotazo", "volador", "MELEE", "fisico", power=35.0, power_mult=0.6, cooldown=0.45,
              knockback=70.0, final_knockback=70.0, melee_step=28.0),
            M("d_ataque_furia", "Ataque Furia", "normal", "MELEE", "fisico", power=22.0, cooldown=4.0, knockback=40.0,
              final_knockback=200.0, melee_step=24.0, combo_steps=3, combo_window=0.7, combo_step_cooldown=0.2),
            M("d_malicioso", "Malicioso", "normal", "PROJECTILE", "estado", power=0.0, cooldown=8.0, knockback=0.0,
              speed=320.0, lifetime=0.5, size=6.0, statuses_on_hit="[st:expuesto]"),
            M("d_pico_taladro", "Pico Taladro", "volador", "DASH", "fisico", power=110.0, cooldown=1.0, cast_time=0.3,
              knockback=300.0, dash_time=0.35, dash_hits=True, invulnerable_time=0.35, recovery=0.25),
        ],
        mobility=M("d_persecucion", "Persecución", "siniestro", "LUNGE", "fisico", power=25.0, cooldown=3.5,
                   knockback=60.0, lunge_range=100.0, lunge_speed=440.0, followup_delay=0.1, followup_power_mult=0.5),
    ),
    "pikachu": dict(
        role="A distancia", archetype="hostigador", preferred_range=90.0, mobility_back=True,
        moves=[
            M("d_impactrueno", "Impactrueno", "electrico", "PROJECTILE", "especial", power=40.0, power_mult=0.55,
              cooldown=0.5, knockback=50.0, speed=320.0, lifetime=0.6, size=4.0, status="st:paralizado",
              status_chance=0.1),
            M("d_chispa", "Chispa", "electrico", "DASH", "fisico", power=55.0, cooldown=4.0, knockback=160.0,
              dash_time=0.2, dash_hits=True, invulnerable_time=0.15, status="st:paralizado", status_chance=0.3),
            M("d_onda_trueno", "Onda Trueno", "electrico", "PROJECTILE", "estado", power=0.0, cooldown=9.0,
              knockback=0.0, speed=200.0, lifetime=0.7, size=6.0, statuses_on_hit="[st:paralizado]"),
            M("d_trueno", "Trueno", "electrico", "ZONE", "especial", power=120.0, cooldown=1.0, knockback=220.0,
              zone_radius=46.0, placement_range=150.0, zone_strike=True, strike_delay=0.5,
              statuses_on_hit="[st:paralizado]"),
        ],
        mobility=dash("d_ataque_rapido_pika", "Ataque Rápido", "normal", cooldown=2.2, time=0.15, inv=0.25),
    ),
    "exeggcute": dict(
        role="A distancia", archetype="artillero", preferred_range=100.0, mobility_back=True,
        moves=[
            M("d_bombardeo", "Bombardeo", "normal", "PROJECTILE", "fisico", power=30.0, power_mult=0.6, cooldown=0.6,
              knockback=60.0, speed=220.0, lifetime=0.6, size=5.0),
            M("d_bomba_huevo", "Bomba Huevo", "normal", "ZONE", "fisico", power=70.0, cooldown=4.5, knockback=200.0,
              zone_radius=34.0, placement_range=130.0, zone_strike=True, strike_delay=0.45),
            M("d_hipnosis", "Hipnosis", "psiquico", "PROJECTILE", "estado", power=0.0, cooldown=10.0, knockback=0.0,
              speed=160.0, lifetime=0.8, size=7.0, statuses_on_hit="[st:dormido]"),
            M("d_lluvia_huevos", "Lluvia de Huevos", "normal", "ZONE", "fisico", power=80.0, power_mult=0.6, cooldown=1.0,
              knockback=180.0, zone_radius=30.0, placement_range=140.0, zone_strike=True, strike_delay=0.4,
              strike_count=5, strike_spread=50.0),
        ],
        mobility=dash("d_rodar", "Rodar", "normal", time=0.25),
    ),
    "nidoran_f": dict(
        role="Tanque", archetype="tanque", preferred_range=30.0, mobility_back=False,
        moves=[
            M("d_aranazo_nido", "Arañazo", "normal", "MELEE", "fisico", power=40.0, power_mult=0.6, cooldown=0.55,
              knockback=70.0, final_knockback=70.0, melee_step=26.0),
            M("d_doble_patada", "Doble Patada", "lucha", "MELEE", "fisico", power=30.0, cooldown=3.5, knockback=50.0,
              final_knockback=240.0, melee_step=26.0, combo_steps=2, combo_window=0.7, combo_step_cooldown=0.2),
            M("d_grunido", "Gruñido", "normal", "AREA", "estado", power=0.0, cooldown=8.0, knockback=0.0, radius=62.0,
              statuses_on_hit="[st:intimidado]"),
            M("d_mordisco_toxico", "Mordisco Tóxico", "veneno", "LUNGE", "fisico", power=100.0, cooldown=1.0,
              cast_time=0.3, knockback=140.0, lunge_range=100.0, lunge_speed=440.0, followup_delay=0.14,
              followup_power_mult=0.5, followup_knockback=220.0, statuses_on_hit="[st:envenenado,herido]"),
        ],
        mobility=M("d_embate", "Embate", "normal", "DASH", "fisico", power=20.0, cooldown=3.5, knockback=110.0,
                   dash_time=0.2, dash_hits=True, invulnerable_time=0.25),
    ),
    "nidoran_m": dict(
        role="Cuerpo a cuerpo", archetype="bruiser", preferred_range=30.0, mobility_back=False,
        moves=[
            M("d_picotazo_nido", "Picotazo", "volador", "MELEE", "fisico", power=35.0, power_mult=0.6, cooldown=0.5,
              knockback=70.0, final_knockback=70.0, melee_step=28.0),
            M("d_cornada", "Cornada", "normal", "DASH", "fisico", power=65.0, cooldown=4.0, knockback=240.0,
              dash_time=0.22, dash_hits=True, invulnerable_time=0.12),
            M("d_foco_nido", "Foco Energía", "normal", "SELF_BUFF", "estado", power=0.0, cooldown=10.0, knockback=0.0,
              self_status="st:potenciado", duration=6.0),
            M("d_perforador", "Perforador", "normal", "LUNGE", "fisico", power=130.0, cooldown=1.0, cast_time=0.4,
              knockback=200.0, lunge_range=100.0, lunge_speed=460.0, followup_delay=0.12, followup_power_mult=0.4,
              followup_knockback=280.0, execute_below=0.2),
        ],
        mobility=dash("d_brinco", "Brinco", "normal"),
    ),
    "mankey": dict(
        role="Cuerpo a cuerpo", archetype="bruiser", preferred_range=28.0, mobility_back=False,
        moves=[
            M("d_golpe_karate", "Golpe Kárate", "lucha", "MELEE", "fisico", power=45.0, power_mult=0.6, cooldown=0.5,
              knockback=80.0, final_knockback=80.0, melee_step=28.0),
            M("d_patada_baja", "Patada Baja", "lucha", "MELEE", "fisico", power=50.0, cooldown=3.5, knockback=120.0,
              final_knockback=120.0, melee_step=30.0, swing_radius=16.0, statuses_on_hit="[st:frenado]"),
            M("d_furia", "Furia", "normal", "SELF_BUFF", "estado", power=0.0, cooldown=10.0, knockback=0.0,
              self_status="st:enfurecido", duration=5.0),
            M("d_tajo_cruzado", "Tajo Cruzado", "lucha", "MELEE", "fisico", power=120.0, cooldown=1.0, cast_time=0.3,
              knockback=340.0, final_knockback=340.0, melee_step=50.0, melee_range=18.0, swing_radius=20.0,
              recovery=0.25),
        ],
        mobility=M("d_salto_mono", "Salto Mono", "lucha", "LUNGE", "fisico", power=20.0, cooldown=3.2, knockback=60.0,
                   lunge_range=110.0, lunge_speed=440.0, followup_delay=0.1, followup_power_mult=0.5),
    ),
    "scyther": dict(
        role="Cuerpo a cuerpo", archetype="velocista", preferred_range=30.0, mobility_back=False,
        moves=[
            M("d_corte_furia", "Corte Furia", "bicho", "MELEE", "fisico", power=40.0, power_mult=0.65, cooldown=0.4,
              knockback=60.0, final_knockback=60.0, melee_step=30.0, swing_radius=14.0),
            M("d_ala_guadana", "Ataque Ala", "volador", "DASH", "fisico", power=60.0, cooldown=3.5, knockback=200.0,
              dash_time=0.2, dash_hits=True, invulnerable_time=0.15),
            M("d_danza_espada", "Danza Espada", "normal", "SELF_BUFF", "estado", power=0.0, cooldown=10.0,
              knockback=0.0, self_status="st:potenciado", duration=6.0),
            M("d_tijera_x", "Tijera X", "bicho", "LUNGE", "fisico", power=110.0, cooldown=1.0, cast_time=0.25,
              knockback=160.0, lunge_range=130.0, lunge_speed=520.0, followup_delay=0.12, followup_power_mult=1.0,
              followup_knockback=280.0),
        ],
        mobility=dash("d_agilidad", "Agilidad", "psiquico", cooldown=2.0, time=0.16, inv=0.3),
    ),
}
