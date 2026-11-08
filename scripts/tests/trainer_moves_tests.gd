class_name TrainerMovesTests
extends Node
## Ataques de los Pokémon de los entrenadores (TrainerMovesets, decisión del usuario 2026-11-08): los equipos que FireRed
## arma a mano salen con sus ataques "mejorados" (MT incluidas, sin relleno) y los comunes con lo mejor que saben, con MT
## desde el Nv. 30. Con `--out <md>` escribe la tabla de los líderes, el Alto Mando y el rival (FireRed → acá).
##   godot --headless --path . --quit-after 30000 -- --autotest-trainer-moves [--out docs/ENTRENADORES_ATAQUES.md]

var autotest: Node
var r := {}


func run() -> void:
	var args := OS.get_cmdline_user_args()
	var parties := TrainerMovesets.parties()
	r["Los equipos de FireRed con ataques propios se cargan (%d)" % parties.size()] = parties.size() >= 100

	# --- Brock: el Onix lleva la Tumba Rocas de FireRed; el Geodude (2 ataques en FireRed) llega a 4 ---
	var brock := _team([["geodude", 12], ["onix", 14]])
	r["Brock se reconoce como el de FireRed"] = TrainerMovesets.equip_team(brock) == "LeaderBrock"
	r["El Onix de Brock tiene la Tumba Rocas de FireRed (%s)" % str(_ids(brock[1]))] = _ids(brock[1]).has("tumba_rocas")
	r["El Geodude de Brock suma ataques de su nivel, sin Rizo Defensa (%s)" % str(_ids(brock[0]))] = _ids(brock[0]).size() >= 3 \
		and not _ids(brock[0]).has("rizo_defensa")
	var learned_any := brock.all(func(i: CreatureInstance):
		var fr: Array = TrainerMovesets.parties().filter(func(p): return p.party == "LeaderBrock")[0].mons.filter(func(m): return m[0] == i.species.id)[0][2]
		return i.equipped_moves.all(func(m): return m == null or fr.has(m.id) or i.learned_moves().has(m)))
	r["Brock no recibe MT que FireRed no le da (nada de Terremoto a Nv. 12-14)"] = learned_any and not brock.any(func(i): return _ids(i).has("terremoto"))

	# --- Giovanni: Terremoto en todos (MT26 en FireRed) ---
	var gio := _team([["rhyhorn", 45], ["dugtrio", 42], ["nidoqueen", 44], ["nidoking", 45], ["rhyhorn", 50]])
	r["Giovanni se reconoce"] = TrainerMovesets.equip_team(gio) == "LeaderGiovanni"
	r["Todos los de Giovanni tienen Terremoto"] = gio.all(func(i): return _ids(i).has("terremoto"))

	# --- Lorelei: Surf y Rayo Hielo (MT) se quedan; nada de relleno ---
	var lorelei := _team([["dewgong", 52], ["cloyster", 51], ["slowbro", 52], ["jynx", 54], ["lapras", 54]])
	TrainerMovesets.equip_team(lorelei)
	r["El Dewgong y el Lapras de Lorelei tienen Surf y Rayo Hielo"] = [lorelei[0], lorelei[4]].all(func(i): return _ids(i).has("surf") and _ids(i).has("rayo_hielo"))

	# --- Rival en Celeste (Squirtle): el Abra con solo Teletransporte en FireRed pasa a pelear de verdad ---
	GameState.new_game(DB.species["charmander"])
	var rival := _team([["pidgeotto", 17], ["abra", 16], ["rattata", 15], ["squirtle", 18]])
	r["El rival de Celeste se reconoce"] = TrainerMovesets.equip_team(rival) == "RivalCeruleanSquirtle"
	var abra: CreatureInstance = rival[1]
	r["El Abra del rival ya no es solo Teletransporte (%s)" % str(_ids(abra))] = not _ids(abra).has("teletransporte") \
		and abra.equipped_moves.any(func(m): return m != null and m.power > 0.0)

	# --- Un ataque de daño flojo se cambia por otro de daño, no por uno de estado (antes: Atracción en vez de Doble Patada) ---
	var bad_swaps := []
	for p in parties:
		var team := _team(p.mons.map(func(m): return [m[0], m[1]]))
		TrainerMovesets.equip_team(team, p.party)
		for k in team.size():
			var fr: Array = p.mons[k][2]
			var fr_damage := fr.filter(func(id): return DB.moves.has(id) and DB.moves[id].power * DB.moves[id].power_mult > 0.0).size()
			var now_damage := team[k].equipped_moves.filter(func(m): return m != null and m.power * m.power_mult > 0.0).size()
			if now_damage < fr_damage:
				bad_swaps.append("%s %s" % [p.party, p.mons[k][0]])
	r["Ningún Pokémon termina con menos ataques de daño que en FireRed (%s)" % str(bad_swaps.slice(0, 3))] = bad_swaps.is_empty()

	# --- Nunca más de MAX_SWAPS cambios sobre lo de FireRed (identidad), y sin relleno donde se pudo cambiar ---
	var too_many := []
	var filler_left := 0
	for p in parties:
		var team := _team(p.mons.map(func(m): return [m[0], m[1]]))
		TrainerMovesets.equip_team(team, p.party)
		for k in team.size():
			var fr: Array = p.mons[k][2]
			var now := _ids(team[k])
			var kept := fr.filter(func(id): return now.has(id)).size()
			if fr.size() - kept > TrainerMovesets.MAX_SWAPS:
				too_many.append("%s %s" % [p.party, p.mons[k][0]])
			filler_left += now.filter(func(id): return TrainerMovesets.FILLER.has(id)).size()
	r["Ningún Pokémon de FireRed pierde más de %d de sus ataques (%s)" % [TrainerMovesets.MAX_SWAPS, str(too_many.slice(0, 3))]] = too_many.is_empty()
	print("[trainer-moves] relleno que quedó (más de %d por Pokémon para cambiar): %d" % [TrainerMovesets.MAX_SWAPS, filler_left])

	# --- Comunes: debajo del Nv. 30 como hoy (sin MT); desde el 30, también MT ---
	var low := _team([["rattata", 12], ["pidgey", 13]])
	TrainerMovesets.equip_team(low)
	r["Un entrenador común de nivel bajo sale como antes (sin MT)"] = low.all(func(i): return _ids(i) == _id_list(i.best_equipment()))
	var with_tm := 0
	var high := _team([["nidoking", 40], ["machamp", 40], ["gengar", 40], ["rhydon", 40], ["starmie", 40], ["arcanine", 40]])
	TrainerMovesets.equip_team(high)
	for i: CreatureInstance in high:
		var learned := i.learned_moves()
		if i.equipped_moves.any(func(m): return m != null and not learned.has(m) and i.species.tm_moves.has(m)):
			with_tm += 1
	r["Desde el Nv. 30 los comunes eligen también MT (%d de %d usan alguna)" % [with_tm, high.size()]] = with_tm >= 4

	# --- En la historia: la pelea de Brock arma su equipo con estos ataques ---
	var npc: NpcData = DB.npcs.get("ciudad_plateada_gimnasio_brock")
	var story_team: Array[CreatureInstance] = []
	if npc != null and npc.trainer != null:
		for m in npc.trainer.starting_team:
			story_team.append(CreatureInstance.create_rival(m.species, m.level))
		TrainerMovesets.equip_team(story_team)
	var src := FileAccess.get_file_as_string("res://scripts/world/story_director.gd")
	r["La pelea de la historia equipa con TrainerMovesets (Brock de verdad: %s)" % str(_ids(story_team[1]) if story_team.size() > 1 else [])] = \
		"TrainerMovesets.equip_team(team, td.display_name)" in src and story_team.size() == 2 and _ids(story_team[1]).has("tumba_rocas")
	# Equipos iguales: el nombre desempata (cuatro pintoras con un Smeargle Nv. 50 cada una).
	var sm := _team([["smeargle", 50]])
	r["Equipos iguales: el nombre del entrenador elige el de FireRed correcto"] = TrainerMovesets.equip_team(sm, "Edna") == "PainterEdna" \
		and _ids(sm[0]).has("velocidad_extrema")

	if "--out" in args:
		_write_table(args[args.find("--out") + 1], parties)
	_results()


func _team(mons: Array) -> Array[CreatureInstance]:
	var out: Array[CreatureInstance] = []
	for m in mons:
		out.append(CreatureInstance.create_rival(DB.species[m[0]], int(m[1])))
	return out


func _ids(i: CreatureInstance) -> Array:
	return _id_list(i.equipped_moves)


func _id_list(moves: Array) -> Array:
	return moves.filter(func(m): return m != null).map(func(m): return m.id)


## Tabla para revisar: líderes, Alto Mando, Campeón y rival (FireRed → acá; en negrita lo que cambió).
func _write_table(path: String, parties: Array) -> void:
	var lines := PackedStringArray([
		"# Ataques de líderes, Alto Mando y rival",
		"",
		"Generado por `--autotest-trainer-moves --out %s` (no editar a mano). Criterio \"FireRed mejorado\" (decisión del " % path
			+ "usuario 2026-11-08, `TrainerMovesets`): los ataques de FireRed, cambiando a lo sumo %d por Pokémon " % TrainerMovesets.MAX_SWAPS
			+ "(primero el relleno, después los de daño muy flojos) y llenando los huecos con lo mejor que puede aprender "
			+ "(nivel + MT). En **negrita**, lo que no es de FireRed. Los Pokémon con kit de jefe (Onix, Starmie y Raichu de "
			+ "los líderes) pelean con su kit.",
		"",
	])
	var names := func(ids: Array) -> String: return ", ".join(ids.map(func(id): return DB.moves[id].display_name if DB.moves.has(id) else id))
	for p in parties:
		if not RegEx.create_from_string("Leader|EliteFour|Champion|Rival").search(p.party):
			continue
		lines.append("## %s" % p.party)
		lines.append("")
		lines.append("| Pokémon | Nv. | FireRed | Acá |")
		lines.append("|---|---|---|---|")
		var team := _team(p.mons.map(func(m): return [m[0], m[1]]))
		TrainerMovesets.equip_team(team, p.party)
		for k in team.size():
			var fr: Array = p.mons[k][2]
			var now := _ids(team[k]).map(func(id): return ("**%s**" if not fr.has(id) else "%s") % (DB.moves[id].display_name if DB.moves.has(id) else id))
			lines.append("| %s | %d | %s | %s |" % [team[k].species.display_name, team[k].level, names.call(fr), ", ".join(now)])
		lines.append("")
	var f := FileAccess.open(ProjectSettings.globalize_path("res://" + path) if not path.begins_with("res://") else path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(lines) + "\n")
		f.close()
		print("[trainer-moves] tabla en %s" % path)


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[trainer-moves] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-trainer-moves] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
