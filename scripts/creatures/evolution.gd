class_name Evolution
extends RefCounted
## Reglas de evolución (datos en SpeciesData.evolutions, de tools/apply_evolutions.gd). Solo evolucionan por nivel y
## con piedras: el intercambio y la amistad todavía no existen en el juego.


## La especie a la que evoluciona por nivel ahora (o null). Tyrogue mira ataque y defensa; Wurmple elige al azar
## (en los juegos depende de su personalidad).
static func by_level(inst: CreatureInstance) -> SpeciesData:
	var options: Array[SpeciesData] = []
	for e: EvolutionData in inst.species.evolutions:
		if e.method != "nivel" or inst.level < e.level or not DB.species.has(e.to_id):
			continue
		if e.stats_cond != 99 and signi(inst.stat("attack") - inst.stat("defense")) != e.stats_cond:
			continue
		options.append(DB.species[e.to_id])
	if options.is_empty():
		return null
	return options[0] if options.size() == 1 else options[hash(inst.ivs) % options.size()]


## La especie a la que evoluciona con esta piedra (o null).
static func by_item(inst: CreatureInstance, item_id: String) -> SpeciesData:
	for e: EvolutionData in inst.species.evolutions:
		if e.method == "piedra" and e.item == item_id and DB.species.has(e.to_id):
			return DB.species[e.to_id]
	return null


## Texto corto de una evolución para la ficha: "Charmeleon (Nv. 16)", "Clefable (Piedra Lunar)".
static func describe(e: EvolutionData) -> String:
	var to: SpeciesData = DB.species.get(e.to_id)
	var name := to.display_name if to != null else e.to_id
	match e.method:
		"nivel":
			return "%s (Nv. %d)" % [name, e.level]
		"piedra":
			return "%s (%s)" % [name, DB.items[e.item].display_name if DB.items.has(e.item) else e.item]
		"intercambio":
			return "%s (intercambio: todavía no)" % name
		"amistad":
			return "%s (amistad: todavía no)" % name
	return name
