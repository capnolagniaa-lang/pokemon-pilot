"""Genera los kits v9 (pedido del usuario 2026-10-28: "fijate todos los pokemons que haya implementados y ajustales un
kit como venías haciendo"): todas las especies que aparecen en el juego (salvajes, entrenadores, legendarios y
regalos de Kanto) y todavía peleaban con su learnset suelto, en data/kits/<especie>/, más sus estados nuevos. Mismo
formato que tools/build_kits_v6.py (reusa sus ayudas). Sus evoluciones heredan el kit (tools/apply_evolutions.gd).

Uso: python -I -B tools/build_kits_v9.py <carpeta del proyecto>
Correrlo de nuevo PISA estos archivos. Después: tools/build_learnsets.gd, tools/apply_evolutions.gd y otra vez
tools/build_learnsets.gd.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_kits_v3 import move_tres, write  # noqa: E402
from build_kits_v4 import write_status, hook_species, write_kit  # noqa: E402
from build_kits_v6 import mv, melee, sig, _drop_inherited  # noqa: E402

STATUSES = {
    "pavor": dict(name="Pavor", color=(0.55, 0.4, 0.75), duration=6.0, element="fantasma", max_stacks=3,
                  speed_mult=0.92, tint_strength=0.2, fx_amount=2),
    "enredado": dict(name="Enredado", color=(0.35, 0.6, 0.35), duration=5.0, element="planta", max_stacks=3,
                     speed_mult=0.88, tint_strength=0.25, fx_amount=2),
}


# Barra de 5 marcas (Estática de Pikachu).
FIVE = {"thresholds": [20.0, 40.0, 60.0, 80.0, 100.0]}


def boss_roar(id, name, el, power, radius, status=None):
    """Onda de la segunda fase de un legendario (la lanza su firma Coloso, sin recarga)."""
    kw = dict(radius=radius)
    if status:
        kw.update(status=status, chance=1.0)
    return mv(id, name, el, "AREA", "esp", power, 0, 280, **kw)


KITS = {
    # --- Gastly: fantasma que asusta y paraliza de miedo. ---
    "gastly": ("hostigador", 70, sig("pesadilla", "Pesadilla", "stack_mechanic.gd", (0.55, 0.4, 0.8),
               "Sus ataques fantasma suman Pavor al rival; con 3, queda paralizado de miedo. Comesueños roba vida.",
               {"element_marks": {"fantasma": "pavor"}, "stack_status": "pavor", "stacks": 3,
                "trigger_status": "paralizado", "text": "¡Paralizado de miedo!"}, max=0), [
        melee("lenguetazo_gastly", "Lengüetazo", "fantasma", 30, 0.8, 2, status="paralizado", chance=0.2),
        mv("tinieblas_gastly", "Tinieblas", "fantasma", "PROJECTILE", "esp", 55, 1.6, 90, speed=240, size=6,
           lifetime=0.9),
        mv("hipnosis_gastly", "Hipnosis", "psiquico", "PROJECTILE", "est", 0, 10.0, 0, speed=170, size=6,
           lifetime=1.1, cast_time=0.25, status="dormido", chance=1.0),
        mv("comesuenos_gastly", "Comesueños", "psiquico", "PROJECTILE", "esp", 100, 7.0, 140, speed=230, size=7,
           lifetime=0.9, drain=0.5, cast_time=0.3, recovery=0.2),
    ]),
    # --- Cubone: lleva el cráneo de su madre como casco; pelea a huesazos. ---
    "cubone": ("bruiser", 35, sig("casco_de_hueso", "Casco de Hueso", "body_trait_mechanic.gd", (0.85, 0.8, 0.65),
               "El cráneo lo protege de frente: recibe 30% menos de lo que le pegan de frente. Hueso Palo pega ×1,5 a lo ralentizado.",
               {"front_mult": 0.7, "back_mult": 1.1, "bonus_vs_status": "ralentizado",
                "bonus_move_prefix": "hueso_palo", "bonus_mult": 1.5}, max=0), [
        melee("hueso_palo_cubone", "Hueso Palo", "tierra", 65, 1.3, 2, on_hit=["ralentizado"], melee_range=15,
              swing_radius=13),
        mv("huesomerang_cubone", "Huesomerang", "tierra", "PROJECTILE", "fis", 50, 2.0, 100, speed=240, size=5,
           lifetime=0.9, projectile_count=2, spread_deg=10),
        mv("malicioso_cubone", "Malicioso", "normal", "PROJECTILE", "est", 0, 7.0, 0, speed=220, size=6,
           lifetime=0.7, on_hit=["expuesto"]),
        melee("golpe_cubone", "Golpe", "normal", 60, 6.0, 3, final_knockback=260, recovery=0.45),
    ]),
    # --- Doduo: dos cabezas que corren; acelera en línea recta. ---
    "doduo": ("velocista", 30, sig("carrera", "Carrera", "gallop_mechanic.gd", (0.8, 0.6, 0.35),
              "Correr derecho llena la carrera: hasta ×1,35 de velocidad, y sus embestidas pegan hasta +40%. Girar fuerte la pierde.",
              {"turn_deg": 40.0, "build_time": 1.3, "max_speed": 1.35, "trail_every": 0.0, "dash_bonus": 0.4}), [
        melee("picotazo_doduo", "Picotazo", "volador", 35, 0.8, 2),
        melee("ataque_furia_doduo", "Ataque Furia", "normal", 15, 2.0, 4, step_cd=0.15),
        mv("agilidad_doduo", "Agilidad", "psiquico", "SELF_BUFF", "est", 0, 10.0, 0, self="agilidad"),
        mv("pico_taladro_doduo", "Pico Taladro", "volador", "DASH", "fis", 80, 5.0, 240, dash_time=0.35,
           recovery=0.3),
    ]),
    # --- Rhyhorn: tanque de roca que embiste derecho y no piensa. ---
    "rhyhorn": ("tanque", 30, sig("piel_de_roca", "Piel de Roca", "colossus_mechanic.gd", (0.7, 0.65, 0.6),
                "Cuerpo de roca: recibe 20% menos de los golpes físicos y casi no lo empujan. Pega ×1,3 a lo ralentizado (Pisotón).",
                {"physical_mult": 0.8, "stagger_bonus": 1.3, "knockback_mult": 0.45, "scale": 1.1, "phase_at": 0.0}), [
        melee("cornada_rhyhorn", "Cornada", "normal", 65, 1.3, 1, final_knockback=220, melee_range=15, swing_radius=13),
        mv("pisoton_rhyhorn", "Pisotón", "tierra", "AREA", "fis", 65, 4.0, 160, radius=40, on_hit=["ralentizado"],
           recovery=0.2),
        mv("derribo_rhyhorn", "Derribo", "normal", "DASH", "fis", 90, 5.0, 280, cast_time=0.25, dash_time=0.45,
           recovery=0.5),
        melee("cornataladro_rhyhorn", "Cornataladro", "normal", 80, 14.0, 1, final_knockback=300, execute_below=0.2,
              cast_time=0.35, recovery=0.4),
    ]),
    # --- Venonat: ojos compuestos que ven todo; polvos y psíquico. ---
    "venonat": ("control", 60, sig("ojos_compuestos", "Ojos Compuestos", "body_trait_mechanic.gd", (0.6, 0.45, 0.75),
                "No lo desorientan. Psicorrayo pega ×1,5 a lo paralizado (Paralizador lo deja así).",
                {"immune": ["desorientado"], "bonus_vs_status": "paralizado", "bonus_move_prefix": "psicorrayo",
                 "bonus_mult": 1.5}, max=0), [
        melee("chupavidas_venonat", "Chupavidas", "bicho", 30, 0.9, 2, drain=0.5),
        mv("psicorrayo_venonat", "Psicorrayo", "psiquico", "PROJECTILE", "esp", 65, 1.8, 90, speed=260, size=5,
           lifetime=0.8, status="desorientado", chance=0.2),
        mv("paralizador_venonat", "Paralizador", "planta", "AREA", "est", 0, 7.0, 0, radius=40, on_hit=["paralizado"]),
        mv("somnifero_venonat", "Somnífero", "planta", "ZONE", "est", 0, 12.0, 0, zone_radius=26, zone_duration=3,
           placement_range=100, zone_traps=False, zone_tick=0.6, zone_max_count=1, on_hit=["dormido"]),
    ]),
    # --- Exeggcute: seis huevos apiñados; quieto se endurece. ---
    "exeggcute": ("control", 70, sig("racimo", "Racimo", "cocoon_mechanic.gd", (0.95, 0.85, 0.75),
                  "Quieto, los seis huevos se apiñan: recibe hasta 40% menos. Moverse los separa.",
                  {"harden_per_s": 45.0, "max_reduction": 0.4, "soften_per_s": 90.0, "poison_contact": 0.0}), [
        mv("bombardeo_exeggcute", "Bombardeo", "normal", "PROJECTILE", "fis", 15, 1.2, 50, speed=230, size=4,
           lifetime=0.8, projectile_count=3, spread_deg=24),
        mv("hipnosis_exeggcute", "Hipnosis", "psiquico", "PROJECTILE", "est", 0, 10.0, 0, speed=170, size=6,
           lifetime=1.1, cast_time=0.25, status="dormido", chance=1.0),
        mv("paralizador_exeggcute", "Paralizador", "planta", "AREA", "est", 0, 7.0, 0, radius=40,
           on_hit=["paralizado"]),
        mv("rayo_solar_exeggcute", "Rayo Solar", "planta", "PROJECTILE", "esp", 120, 8.0, 200, cast_time=0.8,
           speed=320, size=9, lifetime=0.9, recovery=0.3),
    ]),
    # --- Ditto: se transforma en su rival. ---
    "ditto": ("caotico", 40, sig("transformacion", "Transformación", "transform_mechanic.gd", (0.85, 0.6, 0.9),
              "Transformación copia los 4 ataques del rival más cercano y pelea con ellos 25 s. Después vuelve a ser Ditto.",
              {"transform_move": "transformacion", "duration": 25.0, "range": 180.0}), [
        melee("pegote_ditto", "Pegote", "normal", 25, 0.9, 2),
        mv("gel_ditto", "Gel", "normal", "PROJECTILE", "esp", 20, 1.6, 40, speed=200, size=6, lifetime=0.8,
           on_hit=["ralentizado"]),
        mv("rebote_ditto", "Rebote", "normal", "DASH", "est", 0, 4.0, 0, dash_time=0.3, dash_hits=False,
           invulnerable_time=0.25),
        mv("transformacion_ditto", "Transformación", "normal", "PROJECTILE", "est", 0, 30.0, 0, speed=260, size=5,
           lifetime=0.5, cast_time=0.3),
    ]),
    # --- Tangela: maraña de lianas que enreda. ---
    "tangela": ("control", 55, sig("marana", "Maraña", "stack_mechanic.gd", (0.35, 0.65, 0.4),
                "Sus ataques planta enredan al rival; con 3 vueltas de lianas queda enraizado (no se mueve un rato).",
                {"element_marks": {"planta": "enredado"}, "stack_status": "enredado", "stacks": 3,
                 "trigger_status": "enraizado", "text": "¡Atrapado en la maraña!"}, max=0), [
        mv("latigo_cepa_tangela", "Látigo Cepa", "planta", "WHIP", "fis", 35, 1.0, 80, whip_length=75, whip_width=8),
        mv("absorber_tangela", "Absorber", "planta", "PROJECTILE", "esp", 30, 1.5, 40, speed=240, size=5,
           lifetime=0.8, drain=0.5),
        mv("somnifero_tangela", "Somnífero", "planta", "PROJECTILE", "est", 0, 10.0, 0, speed=160, size=6,
           lifetime=1.1, status="dormido", chance=1.0),
        mv("atadura_tangela", "Atadura", "normal", "WHIP", "fis", 40, 6.0, -220, whip_length=95, whip_width=10,
           on_hit=["ralentizado", "enredado"], recovery=0.2),
    ]),
    # --- Mr. Mime: mimo de las paredes invisibles. ---
    "mr_mime": ("control", 60, sig("pantomima", "Pantomima", "blink_mechanic.gd", (0.95, 0.55, 0.7),
                "Después de levantar una Barrera, el próximo golpe sale en 2 s como un Golpe Mental: +50% y desorienta.",
                {"blink_move": "barrera", "bonus": 0.5, "window": 2.0}), [
        melee("doble_bofeton_mr_mime", "Doble Bofetón", "normal", 15, 1.0, 3, step_cd=0.15),
        mv("confusion_mr_mime", "Confusión", "psiquico", "PROJECTILE", "esp", 50, 1.4, 100, speed=260, size=5,
           lifetime=0.8, status="desorientado", chance=0.15),
        mv("barrera_mr_mime", "Barrera", "psiquico", "SHIELD", "est", 0, 6.0, 0, duration=1.2,
           deflects_projectiles=True),
        mv("psiquico_mr_mime", "Psíquico", "psiquico", "PROJECTILE", "esp", 90, 6.0, 170, cast_time=0.3, speed=280,
           size=7, lifetime=0.9, recovery=0.2),
    ]),
    # --- Kangaskhan: la madre pelea y la cría también pega. ---
    "kangaskhan": ("bruiser", 35, sig("cria", "Cría", "body_trait_mechanic.gd", (0.75, 0.6, 0.45),
                   "La cría de la bolsa también pega: cada golpe cuerpo a cuerpo que conecta se repite enseguida con un 35% del daño.",
                   {"echo_hit": 0.35, "echo_delay": 0.15, "echo_text": "¡La cría también!"}, max=0), [
        melee("puno_cometa_kangaskhan", "Puño Cometa", "normal", 18, 0.9, 4, step_cd=0.14),
        melee("mordisco_kangaskhan", "Mordisco", "siniestro", 60, 1.6, 1, final_knockback=180, status="intimidado",
              chance=0.3),
        mv("latigo_kangaskhan", "Látigo", "normal", "AREA", "est", 0, 7.0, 0, radius=45, on_hit=["expuesto"]),
        melee("megapuno_kangaskhan", "Megapuño", "normal", 80, 5.0, 1, final_knockback=300, cast_time=0.2,
              recovery=0.35, melee_range=15, swing_radius=13),
    ]),
    # --- Chansey: enfermera que se cura sola y tira huevos. ---
    "chansey": ("tanque", 55, sig("huevo_suerte", "Huevo Suerte", "body_trait_mechanic.gd", (1.0, 0.75, 0.8),
                "Si pasan 2,5 s sin que le peguen, se cura sola un 2% de la vida por segundo.",
                {"regen": 0.02, "regen_delay": 2.5}, max=0), [
        melee("destructor_chansey", "Destructor", "normal", 40, 1.0, 2),
        mv("canto_chansey", "Canto", "normal", "CHANNEL", "est", 0, 10.0, 0, channel_time=0.6, cone_angle_deg=50,
           cone_length=60, tick_interval=0.3, on_hit=["dormido"]),
        mv("amortiguador_chansey", "Amortiguador", "normal", "SELF_BUFF", "est", 0, 12.0, 0, self="recuperando"),
        mv("bomba_huevo_chansey", "Bomba Huevo", "normal", "PROJECTILE", "fis", 100, 5.0, 220, cast_time=0.4,
           speed=220, size=8, lifetime=0.9, recovery=0.3),
    ]),
    # --- Tauros: toro que encadena embestidas. ---
    "tauros": ("bruiser", 35, sig("estampida", "Estampida", "momentum_mechanic.gd", (0.75, 0.5, 0.35),
               "Cada Derribo dentro de 3 s del anterior pega +40% (hasta ×1,8): una vez que arranca, no para.",
               {"roll_move": "derribo", "chain_time": 3.0, "step_bonus": 0.4, "max_chain": 2, "max_mult": 1.8,
                "curl_mult": 1.0}), [
        melee("cornada_tauros", "Cornada", "normal", 65, 1.2, 1, final_knockback=220),
        mv("cara_susto_tauros", "Cara Susto", "normal", "PROJECTILE", "est", 0, 7.0, 0, speed=220, size=7,
           lifetime=0.7, on_hit=["ralentizado", "intimidado"]),
        mv("derribo_tauros", "Derribo", "normal", "DASH", "fis", 80, 1.8, 240, dash_time=0.35, recovery=0.25),
        mv("hiperrayo_tauros", "Hiperrayo", "normal", "PROJECTILE", "esp", 150, 12.0, 300, cast_time=0.6, speed=380,
           size=9, lifetime=0.8, recovery=1.0),
    ]),
    # --- Hitmonlee: piernas elásticas; se enrosca y patea lejísimos. ---
    "hitmonlee": ("asesino", 45, sig("piernas_elasticas", "Piernas Elásticas", "still_mechanic.gd", (0.75, 0.55, 0.4),
                  "Quieto 0,6 s recoge las piernas. La próxima patada sale como un resorte: +50% de daño y un envión.",
                  {"still_time": 0.6, "burst_mult": 1.5, "burst_push": 280.0, "consume_on_hit": True,
                   "ready_text": "¡Listo!", "label": "RESORTE"}), [
        melee("doble_patada_hitmonlee", "Doble Patada", "lucha", 30, 0.9, 2, melee_range=20, swing_radius=12),
        mv("patada_giro_hitmonlee", "Patada Giro", "lucha", "AREA", "fis", 60, 3.0, 200, radius=36),
        mv("patada_salto_hitmonlee", "Patada Salto", "lucha", "LUNGE", "fis", 85, 4.5, 160, lunge_range=120,
           lunge_speed=520, followup_delay=0.12, followup_power_mult=0.4, followup_knockback=220, recovery=0.45),
        mv("patada_salto_alta_hitmonlee", "Patada Salto Alta", "lucha", "LUNGE", "fis", 130, 8.0, 200,
           lunge_range=150, lunge_speed=560, followup_delay=0.14, followup_power_mult=0.3, followup_knockback=300,
           cast_time=0.25, recovery=0.8),
    ]),
    # --- Hitmonchan: boxeador; esquiva justo y contraataca. ---
    "hitmonchan": ("bruiser", 30, sig("juego_de_pies", "Juego de Pies", "body_trait_mechanic.gd", (0.7, 0.45, 0.6),
                   "Esquivar justo cuando le llega un golpe recarga Megapuño y deja el próximo golpe crítico (×1,6).",
                   {"perfect_dodge": 0.25, "perfect_slot": 3, "crit_mult": 1.6, "perfect_text": "¡Contra!"}, max=0), [
        melee("ultrapuno_hitmonchan", "Ultrapuño", "lucha", 40, 0.8, 3, step_cd=0.16),
        melee("puno_fuego_hitmonchan", "Puño Fuego", "fuego", 75, 2.5, 1, final_knockback=200, status="quemado",
              chance=0.15),
        melee("puno_hielo_hitmonchan", "Puño Hielo", "hielo", 75, 2.5, 1, final_knockback=200, on_hit=["ralentizado"]),
        melee("megapuno_hitmonchan", "Megapuño", "normal", 80, 5.0, 1, final_knockback=300, recovery=0.3),
    ]),
    # --- Scyther: guadañas cada vez más rápidas. ---
    "scyther": ("asesino", 30, sig("filo_furioso", "Filo Furioso", "fury_mechanic.gd", (0.55, 0.85, 0.4),
                "Cada golpe seguido al mismo rival suma una marca (hasta 5): +10% por marca. Si pasan 2,5 s sin pegarle, se pierden.",
                {"max_stacks": 5, "per_stack": 0.1, "window": 2.5}), [  # (la Furia necesita barra: max 100)
        melee("corte_furia_scyther", "Corte Furia", "bicho", 25, 0.8, 3, step_cd=0.15),
        mv("ataque_ala_scyther", "Ataque Ala", "volador", "LUNGE", "fis", 60, 3.5, 140, lunge_range=110,
           lunge_speed=540, followup_delay=0.12, followup_power_mult=0.5, followup_knockback=180, recovery=0.15),
        mv("danza_espada_scyther", "Danza Espada", "normal", "SELF_BUFF", "est", 0, 10.0, 0, self="potenciado"),
        melee("cuchillada_scyther", "Cuchillada", "normal", 70, 4.0, 1, final_knockback=240, melee_range=16,
              swing_radius=14, recovery=0.2),
    ]),
    # --- Diglett: se mete bajo tierra cuando le pegan. ---
    "diglett": ("hostigador", 35, sig("bajo_tierra", "Bajo Tierra", "wary_mechanic.gd", (0.6, 0.45, 0.3),
                "Cuando le pegan se mete bajo tierra y asoma 70 px más lejos (cada 4 s). Dormido o paralizado no puede.",
                {"blink_distance": 70.0, "cooldown": 4.0}), [
        melee("aranazo_diglett", "Arañazo", "normal", 40, 0.8, 2),
        mv("ataque_arena_diglett", "Ataque Arena", "tierra", "PROJECTILE", "est", 0, 6.0, 0, speed=220, size=6,
           lifetime=0.6, status="desorientado", chance=1.0),
        mv("excavar_diglett", "Excavar", "tierra", "ZONE", "fis", 80, 6.0, 200, zone_radius=22, placement_range=120,
           zone_traps=False, zone_strike=True, strike_delay=0.6, strike_burrow=True),
        mv("terremoto_diglett", "Terremoto", "tierra", "AREA", "fis", 100, 9.0, 220, radius=70, cast_time=0.3,
           recovery=0.3),
    ]),
    # --- Charizard: el Calor de Charmander, ahora con alas. ---
    "charizard": ("bruiser", 45, sig("calor_charizard", "Calor", "heat_mechanic.gd", (1.0, 0.45, 0.2),
                  "Sube al pegar y al recibir. Desde la mitad sus ataques queman; llena, Mar Llamas 6 s (más daño, áreas más grandes, se cura). Después, Sobrecalentado.",
                  {"blaze_area_mult": 1.6, "blaze_damage_mult": 1.3, "blaze_duration": 6.0, "blaze_regen": 0.015,
                   "burn_threshold": 50.0, "overheat_duration": 3.0, "overheat_speed": 0.75},
                  gains={"hit_dealt": 7.0, "damage_received": 5.0}), [
        melee("cuchillada_charizard", "Cuchillada", "normal", 70, 1.2, 2, melee_range=16, swing_radius=14),
        mv("ataque_ala_charizard", "Ataque Ala", "volador", "LUNGE", "fis", 60, 3.0, 150, lunge_range=120,
           lunge_speed=540, followup_delay=0.12, followup_power_mult=0.5, followup_knockback=200, recovery=0.15),
        mv("giro_fuego_charizard", "Giro Fuego", "fuego", "ZONE", "esp", 20, 6.0, 0, zone_radius=26, zone_duration=3,
           placement_range=110, zone_traps=True, zone_tick=0.5, status="quemado", chance=0.3),
        mv("lanzallamas_charizard", "Lanzallamas", "fuego", "CHANNEL", "esp", 90, 7.0, 60, channel_time=1.2,
           cone_angle_deg=40, cone_length=85, tick_interval=0.2, status="quemado", chance=0.2),
    ]),
    # --- Lapras: transporte del mar; canta y congela. ---
    "lapras": ("tanque", 60, sig("aliento_helado", "Aliento Helado", "frost_mechanic.gd", (0.55, 0.8, 1.0),
               "Sus ataques de hielo dejan escarcha; con 4, el rival se congela.",
               {"element_marks": {"hielo": "escarcha"}, "stacks_to_freeze": 4}, max=0), [
        melee("golpe_cuerpo_lapras", "Golpe Cuerpo", "normal", 85, 1.6, 1, final_knockback=240, status="paralizado",
              chance=0.2, melee_range=15, swing_radius=14),
        mv("rayo_hielo_lapras", "Rayo Hielo", "hielo", "PROJECTILE", "esp", 90, 2.4, 110, speed=280, size=5,
           lifetime=0.9, on_hit=["escarcha"]),
        mv("canto_lapras", "Canto", "normal", "CHANNEL", "est", 0, 10.0, 0, channel_time=0.6, cone_angle_deg=50,
           cone_length=65, tick_interval=0.3, on_hit=["dormido"]),
        mv("surf_lapras", "Surf", "agua", "AREA", "esp", 90, 7.0, 260, radius=65, cast_time=0.3, recovery=0.3),
    ]),
    # --- Lickitung: lengua larguísima que babea y frena. ---
    "lickitung": ("tanque", 40, sig("lengua_larga", "Lengua Larga", "body_trait_mechanic.gd", (0.95, 0.6, 0.7),
                  "Sus lengüetazos babean (ralentizan). Golpe pega ×1,4 a lo ralentizado.",
                  {"bonus_vs_status": "ralentizado", "bonus_move_prefix": "golpe", "bonus_mult": 1.4}, max=0), [
        mv("lenguetazo_lickitung", "Lengüetazo", "fantasma", "WHIP", "fis", 30, 1.0, 60, whip_length=95, whip_width=8,
           on_hit=["ralentizado"], status="paralizado", chance=0.2),
        melee("pisoton_lickitung", "Pisotón", "normal", 65, 1.6, 1, final_knockback=200),
        mv("rizo_defensa_lickitung", "Rizo Defensa", "normal", "SELF_BUFF", "est", 0, 10.0, 0, self="rizo"),
        melee("golpe_lickitung", "Golpe", "normal", 80, 4.5, 1, final_knockback=300, recovery=0.3, melee_range=15,
              swing_radius=14),
    ]),
    # --- Farfetch'd: el puerro afilado; castiga al que deja la guardia baja. ---
    "farfetchd": ("asesino", 30, sig("puerro", "Puerro", "body_trait_mechanic.gd", (0.55, 0.75, 0.35),
                  "Con el puerro, Cuchillada pega ×1,6 a un rival Expuesto (Malicioso lo deja así).",
                  {"bonus_vs_status": "expuesto", "bonus_move_prefix": "cuchillada", "bonus_mult": 1.6}, max=0), [
        melee("picotazo_farfetchd", "Picotazo", "volador", 35, 0.8, 2),
        mv("malicioso_farfetchd", "Malicioso", "normal", "PROJECTILE", "est", 0, 6.0, 0, speed=220, size=6,
           lifetime=0.7, on_hit=["expuesto"]),
        mv("danza_espada_farfetchd", "Danza Espada", "normal", "SELF_BUFF", "est", 0, 10.0, 0, self="potenciado"),
        melee("cuchillada_farfetchd", "Cuchillada", "normal", 70, 3.5, 1, final_knockback=240, melee_range=16,
              swing_radius=14, recovery=0.15),
    ]),
    # --- Electabuzz: boxeador eléctrico que se carga moviéndose. ---
    "electabuzz": ("bruiser", 40, sig("electromotor", "Electromotor", "static_mechanic.gd", (1.0, 0.85, 0.3),
                   "Moverse y esquivar lo cargan (5 marcas); quieto se descarga. Con la barra llena el próximo golpe es una Descarga que paraliza fuerte.",
                   {"idle_loss": 25.0, "discharge_mult": 1.35}, gains={"moved": 0.25, "dodged": 20.0}) | FIVE, [
        melee("puno_trueno_electabuzz", "Puño Trueno", "electrico", 75, 1.4, 2, status="paralizado", chance=0.15),
        mv("impactrueno_electabuzz", "Impactrueno", "electrico", "PROJECTILE", "esp", 40, 1.2, 70, speed=320, size=4,
           lifetime=0.7, status="paralizado", chance=0.1),
        melee("patada_baja_electabuzz", "Patada Baja", "lucha", 50, 3.0, 1, final_knockback=150, on_hit=["ralentizado"]),
        mv("trueno_electabuzz", "Trueno", "electrico", "ZONE", "esp", 110, 9.0, 180, cast_time=0.35, zone_radius=24,
           placement_range=150, zone_traps=False, zone_strike=True, strike_delay=0.7, strike_count=1,
           status="paralizado", chance=0.3, recovery=0.3),
    ]),
    # --- Krabby: la pinza gigante. ---
    "krabby": ("bruiser", 30, sig("pinza", "Pinza", "body_trait_mechanic.gd", (0.95, 0.45, 0.3),
               "El caparazón lo cubre de frente (−20%). Martillazo pega ×1,5 a lo ralentizado (Agarre lo deja así).",
               {"front_mult": 0.8, "bonus_vs_status": "ralentizado", "bonus_move_prefix": "martillazo",
                "bonus_mult": 1.5}, max=0), [
        melee("agarre_krabby", "Agarre", "normal", 55, 1.0, 2, on_hit=["ralentizado"]),
        mv("burbuja_krabby", "Burbuja", "agua", "PROJECTILE", "esp", 20, 1.6, 40, speed=200, size=4, lifetime=0.8,
           projectile_count=3, spread_deg=20),
        mv("fortaleza_krabby", "Fortaleza", "normal", "SELF_BUFF", "est", 0, 10.0, 0, self="fortaleza"),
        melee("martillazo_krabby", "Martillazo", "agua", 90, 4.5, 1, final_knockback=280, cast_time=0.2,
              recovery=0.35, melee_range=16, swing_radius=14),
    ]),
    # --- Dratini: dragón que muda la piel. ---
    "dratini": ("control", 50, sig("muda", "Muda", "body_trait_mechanic.gd", (0.55, 0.65, 1.0),
                "Cada 6 s muda la piel: se saca de encima los problemas de estado (quemado, veneno, parálisis, sueño...).",
                {"shed_every": 6.0, "shed_text": "¡Muda!"}, max=0), [
        mv("atadura_dratini", "Atadura", "normal", "WHIP", "fis", 20, 1.2, -120, whip_length=80, whip_width=8,
           on_hit=["ralentizado"]),
        mv("onda_trueno_dratini", "Onda Trueno", "electrico", "PROJECTILE", "est", 0, 8.0, 0, speed=220, size=5,
           lifetime=0.8, status="paralizado", chance=1.0),
        mv("agilidad_dratini", "Agilidad", "psiquico", "SELF_BUFF", "est", 0, 10.0, 0, self="agilidad"),
        mv("furia_dragon_dratini", "Furia Dragón", "dragon", "PROJECTILE", "esp", 60, 4.0, 150, cast_time=0.2,
           speed=260, size=7, lifetime=0.9),
    ]),
    # --- Aerodactyl: predador prehistórico del aire. ---
    "aerodactyl": ("asesino", 40, sig("vuelo_prehistorico", "Vuelo Prehistórico", "flight_mechanic.gd", (0.7, 0.65, 0.8),
                   "Al esquivar con Aliento se eleva: en el aire no lo alcanzan los golpes cortos. El primer ataque desde el aire es un Picado (+50%).",
                   {"lift_cost": 30.0, "max_air_time": 1.8, "drain_per_second": 35.0, "regen_per_second": 30.0,
                    "height": 14.0, "dive_damage_mult": 1.5}) | {"thresholds": [30.0]}, [
        melee("mordisco_aerodactyl", "Mordisco", "siniestro", 60, 1.0, 2, status="intimidado", chance=0.2),
        mv("ataque_ala_aerodactyl", "Ataque Ala", "volador", "LUNGE", "fis", 60, 3.0, 150, lunge_range=130,
           lunge_speed=560, followup_delay=0.12, followup_power_mult=0.5, followup_knockback=200, recovery=0.15),
        mv("supersonico_aerodactyl", "Supersónico", "normal", "CHANNEL", "est", 0, 7.0, 0, channel_time=0.4,
           cone_angle_deg=40, cone_length=60, tick_interval=0.2, on_hit=["desorientado"]),
        mv("avalancha_aerodactyl", "Avalancha", "roca", "ZONE", "fis", 75, 8.0, 180, cast_time=0.3, zone_radius=22,
           placement_range=140, zone_traps=False, zone_strike=True, strike_delay=0.6, strike_count=3,
           strike_spread=36, on_hit=["ralentizado"], recovery=0.3),
    ]),
    # --- Jynx: canta, besa y congela. ---
    "jynx": ("control", 60, sig("cancion_de_cuna", "Canción de Cuna", "stack_mechanic.gd", (0.9, 0.5, 0.75),
             "Sus ataques de hielo y psíquicos suman Somnolencia; con 4, el rival se duerme.",
             {"element_marks": {"hielo": "somnolencia", "psiquico": "somnolencia"}, "stack_status": "somnolencia",
              "stacks": 4, "trigger_status": "dormido", "text": "¡Zzz...!"}, max=0), [
        melee("doble_bofeton_jynx", "Doble Bofetón", "normal", 15, 1.0, 3, step_cd=0.15),
        mv("polvo_nieve_jynx", "Polvo Nieve", "hielo", "PROJECTILE", "esp", 40, 1.4, 50, speed=230, size=4,
           lifetime=0.7, projectile_count=3, spread_deg=28),
        mv("beso_amoroso_jynx", "Beso Amoroso", "normal", "PROJECTILE", "est", 0, 10.0, 0, speed=150, size=7,
           lifetime=0.7, status="dormido", chance=1.0),
        mv("ventisca_jynx", "Ventisca", "hielo", "AREA", "esp", 110, 8.0, 220, radius=60, cast_time=0.5,
           on_hit=["escarcha"], recovery=0.3),
    ]),
    # --- Snorlax: la montaña dormida que bloquea las rutas. ---
    "snorlax": ("tanque", 30, sig("panza", "Panza", "colossus_mechanic.gd", (0.4, 0.55, 0.65),
                "Cuerpo enorme: casi no lo empujan y recibe 20% menos de los golpes físicos. Pega ×1,3 a lo ralentizado.",
                {"physical_mult": 0.8, "stagger_bonus": 1.3, "knockback_mult": 0.25, "scale": 1.35, "phase_at": 0.0}), [
        melee("golpe_cuerpo_snorlax", "Golpe Cuerpo", "normal", 85, 1.6, 1, final_knockback=260, status="paralizado",
              chance=0.25, melee_range=16, swing_radius=15),
        mv("bostezo_snorlax", "Bostezo", "normal", "PROJECTILE", "est", 0, 9.0, 0, speed=150, size=7, lifetime=1.2,
           on_hit=["bostezo", "ralentizado"]),
        mv("descanso_snorlax", "Descanso", "psiquico", "SELF_BUFF", "est", 0, 16.0, 0, self="descansando"),
        mv("hiperrayo_snorlax", "Hiperrayo", "normal", "PROJECTILE", "esp", 150, 12.0, 300, cast_time=0.6, speed=380,
           size=10, lifetime=0.8, recovery=1.0),
    ]),
    # --- Articuno: legendario de las Islas Espuma (jefe). ---
    "articuno": ("control", 70, sig("ave_helada", "Ave Helada", "colossus_mechanic.gd", (0.6, 0.85, 1.0),
                 "Legendario: cuerpo grande, casi no lo empujan. A mitad de vida bate las alas una vez (Ventisca alrededor que ralentiza) y queda enfurecido.",
                 {"physical_mult": 0.9, "stagger_bonus": 1.0, "knockback_mult": 0.3, "scale": 1.3, "phase_at": 0.5,
                  "phase_status": "enfurecido", "roar_move": "res://data/kits/articuno/aleteo_helado.tres"}), [
        mv("rayo_hielo_articuno", "Rayo Hielo", "hielo", "PROJECTILE", "esp", 90, 1.8, 110, speed=290, size=5,
           lifetime=0.9, projectile_count=3, spread_deg=24, on_hit=["ralentizado"]),
        mv("ataque_ala_articuno", "Ataque Ala", "volador", "LUNGE", "fis", 60, 3.5, 160, lunge_range=120,
           lunge_speed=520, followup_delay=0.12, followup_power_mult=0.5, followup_knockback=200, recovery=0.2),
        mv("neblina_articuno", "Neblina", "hielo", "ZONE", "est", 0, 9.0, 0, zone_radius=34, zone_duration=5,
           placement_range=120, zone_traps=False, zone_tick=0.5, zone_max_count=2, on_hit=["ralentizado"]),
        mv("ventisca_articuno", "Ventisca", "hielo", "ZONE", "esp", 110, 8.0, 200, cast_time=0.4, zone_radius=28,
           placement_range=150, zone_traps=False, zone_strike=True, strike_delay=0.8, strike_count=3,
           strike_spread=44, status="congelado", chance=0.15, recovery=0.4),
    ], [boss_roar("aleteo_helado", "Aleteo Helado", "hielo", 60, 80, "ralentizado")]),
    # --- Zapdos: legendario de la Central Eléctrica (jefe). ---
    "zapdos": ("bruiser", 60, sig("ave_trueno", "Ave Trueno", "colossus_mechanic.gd", (1.0, 0.9, 0.3),
               "Legendario: cuerpo grande, casi no lo empujan. A mitad de vida suelta una descarga alrededor que paraliza y queda enfurecido.",
               {"physical_mult": 0.9, "stagger_bonus": 1.0, "knockback_mult": 0.3, "scale": 1.3, "phase_at": 0.5,
                "phase_status": "enfurecido", "roar_move": "res://data/kits/zapdos/descarga_zapdos.tres"}), [
        mv("impactrueno_zapdos", "Impactrueno", "electrico", "PROJECTILE", "esp", 40, 1.2, 90, speed=330, size=5,
           lifetime=0.8, projectile_count=3, spread_deg=26, status="paralizado", chance=0.15),
        mv("pico_taladro_zapdos", "Pico Taladro", "volador", "DASH", "fis", 80, 4.0, 260, cast_time=0.25,
           dash_time=0.4, recovery=0.4),
        mv("onda_trueno_zapdos", "Onda Trueno", "electrico", "PROJECTILE", "est", 0, 8.0, 0, speed=230, size=6,
           lifetime=0.9, status="paralizado", chance=1.0),
        mv("trueno_zapdos", "Trueno", "electrico", "ZONE", "esp", 110, 8.0, 200, cast_time=0.35, zone_radius=24,
           placement_range=160, zone_traps=False, zone_strike=True, strike_delay=0.7, strike_count=3,
           strike_spread=44, status="paralizado", chance=0.5, recovery=0.3),
    ], [boss_roar("descarga_zapdos", "Descarga", "electrico", 60, 85, "paralizado")]),
    # --- Eeveelutions: las de piedra (Eevee está en la Mansión de Azulona). ---
    "vaporeon": ("tanque", 50, sig("absorbe_agua", "Absorbe Agua", "body_trait_mechanic.gd", (0.35, 0.6, 1.0),
                 "Sobre agua o suelo mojado (o empapado) se cura un 3% por segundo y se mueve más rápido; en seco va un poco más lento.",
                 {"wet_heal": 0.03, "wet_speed": 1.25, "dry_speed": 0.92}, max=0), [
        mv("pistola_agua_vaporeon", "Pistola Agua", "agua", "PROJECTILE", "esp", 40, 1.0, 70, speed=300, size=4,
           lifetime=0.8),
        mv("rayo_aurora_vaporeon", "Rayo Aurora", "hielo", "PROJECTILE", "esp", 65, 2.2, 100, speed=270, size=5,
           lifetime=0.9, on_hit=["ralentizado"]),
        mv("danza_lluvia_vaporeon", "Danza Lluvia", "agua", "AREA", "est", 0, 10.0, 0, radius=60, on_hit=["empapado"]),
        mv("hidrobomba_vaporeon", "Hidrobomba", "agua", "PROJECTILE", "esp", 120, 7.0, 260, cast_time=0.45,
           speed=320, size=9, lifetime=0.9, recovery=0.3),
    ]),
    "jolteon": ("velocista", 55, sig("absorbe_electricidad", "Absorbe Electricidad", "static_mechanic.gd", (1.0, 0.9, 0.35),
                "Moverse y esquivar lo cargan (5 marcas); quieto se descarga. Rayo gasta las cargas. Llena: el próximo golpe es una Descarga.",
                {"idle_loss": 30.0, "discharge_mult": 1.35}, gains={"moved": 0.3, "dodged": 20.0}) | FIVE, [
        mv("impactrueno_jolteon", "Impactrueno", "electrico", "PROJECTILE", "esp", 40, 0.9, 70, speed=340, size=4,
           lifetime=0.7, status="paralizado", chance=0.1),
        mv("doble_patada_jolteon", "Doble Patada", "lucha", "LUNGE", "fis", 30, 2.5, 120, lunge_range=100,
           lunge_speed=560, followup_delay=0.1, followup_power_mult=1.0, followup_knockback=180, recovery=0.1),
        mv("pin_misil_jolteon", "Pin Misil", "bicho", "PROJECTILE", "fis", 14, 2.0, 30, speed=360, size=3,
           lifetime=0.6, projectile_count=5, spread_deg=30),
        mv("rayo_jolteon", "Rayo", "electrico", "PROJECTILE", "esp", 90, 5.0, 160, cast_time=0.2, speed=360, size=6,
           lifetime=0.8, status="paralizado", chance=0.3, resource_cost=-1, resource_scaling=0.6),
    ]),
    "flareon": ("bruiser", 35, sig("absorbe_fuego", "Absorbe Fuego", "embers_mechanic.gd", (1.0, 0.5, 0.25),
                "Sus golpes contra quemados pegan +35% y renuevan la quemadura: el fuego no se apaga mientras lo siga castigando.",
                {"burned_damage_mult": 1.35}, max=0), [
        melee("mordisco_flareon", "Mordisco", "siniestro", 60, 1.0, 2),
        mv("ascuas_flareon", "Ascuas", "fuego", "PROJECTILE", "esp", 40, 1.0, 70, speed=300, size=4, lifetime=0.7,
           status="quemado", chance=0.3),
        mv("giro_fuego_flareon", "Giro Fuego", "fuego", "ZONE", "esp", 20, 6.0, 0, zone_radius=24, zone_duration=3,
           placement_range=100, zone_traps=True, zone_tick=0.5, status="quemado", chance=0.4),
        mv("lanzallamas_flareon", "Lanzallamas", "fuego", "CHANNEL", "esp", 90, 7.0, 60, channel_time=1.0,
           cone_angle_deg=40, cone_length=80, tick_interval=0.2, status="quemado", chance=0.3),
    ]),
    # --- Fósiles del Mt. Moon. ---
    "omanyte": ("control", 50, sig("espiral", "Espiral", "body_trait_mechanic.gd", (0.45, 0.65, 0.95),
                "El caparazón en espiral lo cubre de espaldas (−40%). Mojado se mueve más rápido; en seco más lento.",
                {"back_mult": 0.6, "front_mult": 1.0, "wet_speed": 1.2, "dry_speed": 0.9}, max=0), [
        mv("constriccion_omanyte", "Constricción", "normal", "WHIP", "fis", 15, 1.0, 40, whip_length=60, whip_width=9,
           on_hit=["ralentizado"]),
        mv("pistola_agua_omanyte", "Pistola Agua", "agua", "PROJECTILE", "esp", 40, 1.2, 70, speed=290, size=4,
           lifetime=0.8),
        mv("refugio_omanyte", "Refugio", "agua", "SELF_BUFF", "est", 0, 9.0, 0, self="refugio"),
        mv("hidrobomba_omanyte", "Hidrobomba", "agua", "PROJECTILE", "esp", 120, 8.0, 260, cast_time=0.45, speed=320,
           size=9, lifetime=0.9, recovery=0.35),
    ]),
    "kabuto": ("hostigador", 30, sig("caparazon_fosil", "Caparazón Fósil", "cocoon_mechanic.gd", (0.7, 0.55, 0.35),
               "Quieto se endurece: recibe hasta 35% menos. Moverse lo ablanda rápido.",
               {"harden_per_s": 60.0, "max_reduction": 0.35, "soften_per_s": 110.0, "poison_contact": 0.0}), [
        melee("aranazo_kabuto", "Arañazo", "normal", 40, 0.8, 2),
        melee("absorber_kabuto", "Absorber", "planta", 30, 1.4, 1, drain=0.6),
        mv("fortaleza_kabuto", "Fortaleza", "normal", "SELF_BUFF", "est", 0, 10.0, 0, self="fortaleza"),
        mv("cuchillada_kabuto", "Cuchillada", "normal", "LUNGE", "fis", 70, 4.0, 180, lunge_range=90, lunge_speed=500,
           followup_delay=0.12, followup_power_mult=0.4, followup_knockback=220, recovery=0.25),
    ]),
    # --- Porygon: el del Casino; se reconvierte al tipo que le pega. ---
    "porygon": ("control", 60, sig("conversion", "Conversión", "adapt_mechanic.gd", (0.95, 0.5, 0.6),
                "Se reconvierte: durante 8 s recibe 35% menos del último tipo que le pegó.",
                {"duration": 8.0, "resist_mult": 0.65}, max=0), [
        mv("placaje_porygon", "Placaje", "normal", "DASH", "fis", 40, 1.2, 160, dash_time=0.2, recovery=0.1),
        mv("psicorrayo_porygon", "Psicorrayo", "psiquico", "PROJECTILE", "esp", 65, 1.6, 90, speed=270, size=5,
           lifetime=0.8, status="desorientado", chance=0.2),
        mv("agilidad_porygon", "Agilidad", "psiquico", "SELF_BUFF", "est", 0, 10.0, 0, self="agilidad"),
        mv("triataque_porygon", "Triataque", "normal", "PROJECTILE", "esp", 80, 4.0, 140, speed=290, size=5,
           lifetime=0.8, projectile_count=3, spread_deg=18, on_hit=["quemado"], cast_time=0.2),
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
