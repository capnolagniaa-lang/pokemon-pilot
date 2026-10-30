class_name WildLife
extends Resource
## Reglas de los salvajes vivos (docs/PLAN_IA.md, IA-5): quiénes duermen de día o de noche, cuándo huyen de un Pokémon
## mucho más fuerte, manadas y presas/depredadores. Un solo archivo de datos: data/ai/wild_life.tres (DB.wild_life).
## La lógica está en WildSociety.

@export_group("Día y noche")
## Tipos y especies nocturnos (de día duermen) y diurnos (de noche duermen). En las cuevas siempre es de noche.
@export var nocturnal_types: PackedStringArray = []
@export var nocturnal_species: PackedStringArray = []
@export var diurnal_species: PackedStringArray = []
## Probabilidad de que uno que aparece en su hora de dormir esté durmiendo.
@export_range(0.0, 1.0) var sleep_chance: float = 0.75
## A qué distancia lo despertás pasando al lado, y con qué probabilidad por segundo.
@export var wake_radius: float = 22.0
@export_range(0.0, 1.0) var wake_chance: float = 0.6

@export_group("Respeto")
## Si tu Pokémon le lleva esta cantidad de niveles (o más), no te ataca: se va (salvo que le pegues).
@export var outclass_gap: int = 10

@export_group("Manadas")
## Los de la misma familia a esta distancia se suman a la pelea (si su temperamento tiene calls_group).
@export var pack_radius: float = 110.0
## Si el que se suma le lleva esta cantidad de niveles al atacado, es su cría: viene enfurecido.
@export var young_gap: int = 5

@export_group("Presas y depredadores")
## Depredador (id de especie o de tipo) -> lo que caza (ids de especie o de tipo). Solo lo persigue: no se pegan.
@export var predators: Dictionary = {}
## A qué distancia el cazador ve a la presa, y con qué probabilidad sale a cazar (cada vez que la ve).
@export var hunt_radius: float = 90.0
@export_range(0.0, 1.0) var hunt_chance: float = 0.35
## A qué distancia la presa nota al cazador y huye.
@export var prey_alert: float = 60.0

@export_group("Curiosidad")
## Los curiosos se acercan a mirar una Pokébola tirada o un objeto del piso a esta distancia.
@export var curious_radius: float = 80.0
