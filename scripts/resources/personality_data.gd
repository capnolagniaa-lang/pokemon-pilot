class_name PersonalityData
extends Resource
## Personalidad de un entrenador vivo (docs/PLAN_ENTRENADORES.md, sección 3): cómo aprende de vos y cómo
## reacciona a ganar o perder. Los números son guía para el planificador (fases E-3/E-4).

## Encuentros que necesita para creerse algo de tu forma de pelear (menos = aprende rápido).
@export_range(1, 10) var encounters_to_learn: int = 2
## Hasta dónde llega: 1 solo recuerda · 2 adapta tácticas · 3 planifica equipo y estrategia.
@export_range(1, 3) var max_intelligence: int = 2
## Cuánto se resiste a cambiar de equipo aunque pierda (0 cambia fácil · 1 nunca).
@export_range(0.0, 1.0) var pride: float = 0.5
## Agresión base de su IA de combate (0 cauto · 1 temerario).
@export_range(0.0, 1.0) var aggression: float = 0.5
## Cuánto captura y prueba especies nuevas (0 nunca · 1 siempre).
@export_range(0.0, 1.0) var curiosity: float = 0.3
## Probabilidad de malinterpretar lo que vio (ajusta la perilla equivocada).
@export_range(0.0, 1.0) var misread_chance: float = 0.2
