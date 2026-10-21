class_name Kit
extends Resource
## Kit de un Pokémon (plan de identidad): estilo de pelea, mecánica de firma opcional y 4 ataques.
## Controles: Clic izq. = ataque 1 · Clic der. = ataque 2 · Q = ataque 3 · R = ataque 4 (el de más recarga).
## Espacio es el esquive (igual para todos). Sin energía: todo funciona con recargas.
## Cada .tres en data/kits/<pokémon>/kit.tres; la especie lo referencia en SpeciesData.kit.

const SLOT_COUNT := 4

## Estilo de pelea: bruiser, control, tanque, velocista, hostigador, desgaste, espaciador, asesino.
@export var archetype: String = ""
## Rango en el que quiere pelear (lo usa la IA).
@export var preferred_range: float = 50.0
## Mecánica de firma (opcional), ej. el Calor de Charmander.
@export var signature: SignatureData
## Los 4 ataques, en el orden de las teclas (Clic izq., Clic der., Q, R).
@export var moves: Array[MoveData] = []
