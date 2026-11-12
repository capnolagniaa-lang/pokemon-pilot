class_name RogueKits
extends RefCounted
## Kits de 5 teclas del Modo Desafío (pedido del usuario 2026-11-12, con el combate de Pokémon Arena 2D como referencia):
## básico, dos habilidades, movilidad en Espacio y definitiva con barra. Uno por línea evolutiva, en
## `data/desafio_kits/<especie base>/kit.tres` (los arma `tools/build_desafio_kits.py`); la evolución usa el de su
## preevolución. Solo en el modo: la historia sigue con los ataques que elegís.

const DIR := "res://data/desafio_kits/%s/kit.tres"


## El kit de esa especie o el de su preevolución más cercana que tenga uno (null si su línea no tiene).
static func of(sp: SpeciesData) -> Kit:
	var guard := 0
	while sp != null and guard < 4:
		var path := DIR % sp.id
		if ResourceLoader.exists(path):
			return load(path) as Kit
		sp = DB.species.get(str(sp.evolves_from))
		guard += 1
	return null


## Le pone el kit a un Pokémon de la partida (si su línea tiene): sus 4 ataques pasan a ser los del kit.
static func apply(inst: CreatureInstance) -> bool:
	var kit := of(inst.species)
	if kit == null:
		return false
	inst.rogue_kit = kit
	inst.ult = 0.0
	inst.equipped_moves = kit.moves.duplicate()
	return true
