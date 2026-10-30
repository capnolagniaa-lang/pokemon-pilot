class_name TrainerStyle
extends Resource
## Cómo pelea una clase de entrenador (docs/PLAN_IA.md, IA-4): perillas que lee la mente de sus Pokémon (TacticalMind)
## y la pelea de arena (TrainerBattle). Datos en data/ai/trainer_styles/*.tres; cada uno dice qué clases (el título del
## entrenador: "Cazabichos", "Montañero"...) pelean así. Una clase que no está en ninguno pelea con los valores por
## defecto de acá.

@export var id: String = ""
@export var display_name: String = ""
## Títulos de entrenador que pelean así.
@export var classes: PackedStringArray = []
## Multiplica cuánto piensa al elegir ataque (AiDifficulty.smarts; el resultado se limita a 1).
@export var smarts_mult: float = 1.0
## Multiplica el tiempo entre ataques (menos = ataca más seguido).
@export var pace: float = 1.0
## Aguanta y contragolpea: ataca menos seguido, salvo cuando estás expuesto o con tus ataques fuertes en recarga.
@export var counter: bool = false
## Probabilidad de cambiar de Pokémon cuando el cruce de tipos le es malo y tiene uno mejor.
@export_range(0.0, 1.0) var switch_types: float = 0.0
## Probabilidad de retirar a uno muy golpeado si tiene otro sano.
@export_range(0.0, 1.0) var retreat: float = 0.35
## Al caer uno, saca el que mejor le va contra el tuyo (si no, el siguiente de la lista).
@export var smart_next: bool = false
## Superpociones que usa en la pelea (una por Pokémon como mucho, con poca vida).
@export var potions: int = 0
## Qué hace con poca vida (como Temperament.low_hp).
@export var low_hp: Temperament.LowHp = Temperament.LowHp.CAREFUL
