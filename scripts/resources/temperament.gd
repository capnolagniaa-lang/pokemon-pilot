class_name Temperament
extends Resource
## Temperamento de un Pokémon salvaje (mente de salvaje = instinto, sin memoria; ver docs/PLAN_ENTRENADORES.md,
## sección 1b). Decide qué hace cuando te ve, hasta dónde te persigue y cuándo huye. Datos en
## data/ai/temperaments/*.tres; cada especie tiene el suyo (SpeciesData.temperament, lo asigna
## tools/assign_temperaments.gd).

## ATTACK te ataca apenas te ve · TERRITORY solo si entrás a su territorio · FLEE huye (pelea si lo acorralás
## o le pegás) · APPROACH se acerca a mirarte (si te le venís encima, se pone nervioso).
enum OnNotice { ATTACK, TERRITORY, FLEE, APPROACH }

@export var id: String = ""
@export var display_name: String = ""
@export var on_notice: OnNotice = OnNotice.ATTACK
## Distancia a la que nota a tu Pokémon (al entrenador, un poco menos).
@export var detect_radius: float = 90.0
## Hasta qué distancia de su lugar te persigue (después vuelve).
@export var leash: float = 300.0
## Territorial: radio alrededor de su lugar que defiende.
@export var territory_radius: float = 70.0
## Curioso: a qué distancia se queda mirando.
@export var approach_distance: float = 55.0
## Curioso: si te acercás más que esto se pone nervioso; con esta probabilidad ataca (si no, huye).
@export var nervous_distance: float = 26.0
@export_range(0.0, 1.0) var nervous_attack_chance: float = 0.4
## En combate, con menos de esta fracción de vida intenta huir.
@export_range(0.0, 1.0) var flee_below: float = 0.2
## Probabilidad de espantarse (retroceder un momento) cuando recibe un golpe fuerte.
@export_range(0.0, 1.0) var spook_chance: float = 0.0
## Aviso que muestra al notarte ("!" agresivo, "?" curioso, gota tímido...).
@export var notice_emote: String = "!"
## Reservado para "en grupo" (si atacás a uno vienen los demás): todavía no se usa.
@export var calls_group: bool = false
