class_name KitsV9Tests
extends KitsV6Tests
## Autotest de los kits v9 (pedido del usuario 2026-10-28: kit para todos los Pokémon que aparecen en el juego):
## 34 especies nuevas, sus herederas y las mecánicas nuevas (Transformación de Ditto, la cría de Kangaskhan, la
## curación de Chansey, la Muda de Dratini).
##   godot --headless --path . --quit-after 400000 -- --autotest-kits-v9 [--only <especie>]


func _species() -> Dictionary:
	return {"gastly": "hostigador", "cubone": "bruiser", "doduo": "velocista", "rhyhorn": "tanque",
		"venonat": "control", "exeggcute": "control", "ditto": "caotico", "tangela": "control", "mr_mime": "control",
		"kangaskhan": "bruiser", "chansey": "tanque", "tauros": "bruiser", "hitmonlee": "asesino",
		"hitmonchan": "bruiser", "scyther": "asesino", "diglett": "hostigador", "charizard": "bruiser",
		"lapras": "tanque", "lickitung": "tanque", "farfetchd": "asesino", "electabuzz": "bruiser", "krabby": "bruiser",
		"dratini": "control", "aerodactyl": "asesino", "jynx": "control", "snorlax": "tanque", "articuno": "control",
		"zapdos": "bruiser", "vaporeon": "tanque", "jolteon": "velocista", "flareon": "bruiser", "omanyte": "control",
		"kabuto": "hostigador", "porygon": "control"}


func _heirs() -> Dictionary:
	return {"haunter": "gastly", "gengar": "gastly", "marowak": "cubone", "dodrio": "doduo", "rhydon": "rhyhorn",
		"venomoth": "venonat", "exeggutor": "exeggcute", "kingler": "krabby", "dragonair": "dratini",
		"dragonite": "dratini", "dugtrio": "diglett", "omastar": "omanyte", "kabutops": "kabuto", "alakazam": "kadabra"}


func _tag() -> String:
	return "kits-v9"


func run() -> void:
	var r := {}
	# Todo lo que aparece en el juego (salvajes y entrenadores) tiene kit.
	var missing := []
	for f in DirAccess.get_files_at("res://data/world/encounters"):
		if f.ends_with(".tres"):
			var t: EncounterTable = load("res://data/world/encounters/" + f)
			for e in t.entries:
				if DB.species.has(e.species_id) and DB.species[e.species_id].kit == null and not e.species_id in missing:
					missing.append(e.species_id)
	var trainers: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/trainers_frlg.json"))
	for zone in trainers.values():
		for t in zone.values():
			for row in t["team"]:
				if DB.species.has(row[0]) and DB.species[row[0]].kit == null and not row[0] in missing:
					missing.append(row[0])
	print("[kits-v9] sin kit: ", missing)
	_extra["Todo Pokémon que aparece en el juego tiene kit %s" % str(missing)] = missing.is_empty()
	await super.run()


var _extra := {}


func _finish(r: Dictionary) -> void:
	r.merge(_extra)
	super._finish(r)


func _ditto(r: Dictionary) -> void:
	await _setup("ditto")
	r["Ditto: en la vuelta de sus ataques ya se había transformado"] = me.signature.get("_left") > 0.0
	me.signature.call("_revert")  # (para probar desde cero)
	var foe := _dummy("charmander", Vector2(40, 0))
	await get_tree().physics_frame
	me.target = foe
	me.move_released.emit(DB.species["ditto"].kit.moves[3])
	r["Ditto: Transformación copia los ataques del rival"] = me.moves.slots[0] == foe.moves.slots[0] \
		and me.moves.slots[3] == foe.moves.slots[3]
	me.signature.call("_revert")
	r["...y después vuelve a sus ataques"] = me.moves.slots[3] == DB.species["ditto"].kit.moves[3]
	me.target = null


func _kangaskhan(r: Dictionary) -> void:
	await _setup("kangaskhan")
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	var hp0 := foe.instance.hp
	me.hit_dealt.emit(foe, HitInfo.from(me, me.moves.slots[0]), 10.0)
	await get_tree().create_timer(0.3).timeout
	r["Kangaskhan: la cría repite el golpe (%.1f de daño extra)" % (hp0 - foe.instance.hp)] = hp0 - foe.instance.hp >= 3.0


func _chansey(r: Dictionary) -> void:
	await _setup("chansey")
	me.instance.hp = me.instance.max_hp() * 0.5
	var hp0 := me.instance.hp
	await get_tree().create_timer(3.5).timeout
	r["Chansey: sin que le peguen se cura sola"] = me.instance.hp > hp0


func _dratini(r: Dictionary) -> void:
	await _setup("dratini")
	me.statuses.apply(DB.statuses["envenenado"])
	await get_tree().create_timer(6.5).timeout
	r["Dratini: la Muda le saca el veneno"] = not me.statuses.has_status("envenenado")
