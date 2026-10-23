extends SceneTree
## Asigna el temperamento de los salvajes (SpeciesData.temperament) a las 386 especies: primero los ajustes a
## mano (OVERRIDES), y si no hay, una heurística por stats oficiales:
##  · legendarios/singulares (captura ≤ 5) → territorial;
##  · chicos (total < 330): rápidos → tímido; muy ofensivos (ataque ≥ 1,6× defensa) → agresivo; si no, curioso;
##  · grandes: muy ofensivos (≥ 1,5×) → agresivo; rápidos → tímido; si no, territorial.
## Reparto actual: ~170 territoriales, ~90 tímidos, ~80 agresivos, ~45 curiosos (los agresivos, a propósito,
## son minoría: un mapa lleno de bichos que te atacan apenas te ven cansa).
## Uso: godot --headless --path . --quit-after 3000 --script res://tools/assign_temperaments.gd

const OVERRIDES := {
	# Los 4 de prueba y los que ya tienen kit (que se sientan como su estilo).
	"rattata": "agresivo", "pidgey": "timido", "bellsprout": "territorial", "vulpix": "curioso",
	"charmander": "agresivo", "bulbasaur": "territorial", "squirtle": "territorial", "pikachu": "curioso",
	"oddish": "timido", "psyduck": "curioso", "growlithe": "territorial", "poliwag": "timido", "seel": "curioso",
	"eevee": "curioso",
	# Clásicos conocidos.
	"caterpie": "timido", "metapod": "timido", "weedle": "timido", "kakuna": "territorial", "beedrill": "agresivo",
	"spearow": "agresivo", "fearow": "agresivo", "zubat": "agresivo", "mankey": "agresivo", "primeape": "agresivo",
	"abra": "timido", "magikarp": "timido", "gyarados": "agresivo", "ditto": "curioso", "jigglypuff": "curioso",
	"clefairy": "timido", "chansey": "timido", "snorlax": "territorial", "onix": "territorial", "tauros": "agresivo",
	"geodude": "territorial", "slowpoke": "curioso", "togepi": "curioso", "sneasel": "agresivo",
	"houndour": "agresivo", "poochyena": "agresivo", "zigzagoon": "curioso", "wurmple": "timido",
	"seviper": "agresivo", "zangoose": "agresivo", "absol": "territorial",
}


func _init() -> void:
	var counts := {}
	for f in DirAccess.get_files_at("res://data/species"):
		if not f.ends_with(".tres"):
			continue
		var path := "res://data/species/" + f
		var sp: SpeciesData = load(path)
		var id: String = OVERRIDES.get(sp.id, _guess(sp))
		sp.temperament = load("res://data/ai/temperaments/%s.tres" % id)
		counts[id] = counts.get(id, 0) + 1
		if ResourceSaver.save(sp, path) != OK:
			print("ERROR al guardar ", sp.id)
	print("Temperamentos: ", counts)
	quit()


func _guess(sp: SpeciesData) -> String:
	var total := sp.base_hp + sp.base_attack + sp.base_defense + sp.base_sp_attack + sp.base_sp_defense + sp.base_speed
	var offense := maxi(sp.base_attack, sp.base_sp_attack)
	var defense := (sp.base_defense + sp.base_sp_defense) / 2.0
	if sp.capture_rate <= 5:
		return "territorial"
	if total < 330:
		if sp.base_speed >= offense:
			return "timido"
		if offense >= 1.6 * defense:
			return "agresivo"
		return "curioso"
	if offense >= 1.5 * defense:
		return "agresivo"
	if sp.base_speed >= offense * 1.1:
		return "timido"
	return "territorial"
