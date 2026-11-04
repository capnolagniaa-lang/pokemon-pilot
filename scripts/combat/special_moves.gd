class_name SpecialMoves
extends RefCounted
## Ataques con un efecto propio que no se arma solo con números (`MoveData.special`): los que llaman a otro ataque, copian,
## cambian el tipo, se debilitan... adaptados al tiempo real. `run` los hace al soltarse (Creature.release_move),
## `ai_value` dice cuánto le conviene a la IA (TacticalMind: 0 = ni lo intenta) y `TEXT` es la explicación de la ficha.
## Los cambios duran hasta que se cambia de Pokémon o termina la pelea (Creature.reset_fight_changes).

const EXCLUDED := ["autodestruccion", "explosion"]
const RANGE := 200.0
const CAST_COLOR := Color(0.85, 0.8, 1.0)
const TEXT := {
	"metronomo": "Lanza un ataque de daño al azar de todos los del juego.",
	"espejo": "Repite el último ataque que usó el rival.",
	"ayuda": "Lanza un ataque al azar de otro Pokémon de tu equipo.",
	"adaptacion": "Lanza un ataque según el lugar: Surf en el agua, Hoja Afilada en el pasto, Lanzarrocas en una cueva y Rapidez en el resto.",
	"mimetico": "Copia el último ataque del rival en esta ranura hasta el final de la pelea.",
	"esquema": "Aprende para siempre el último ataque del rival, en lugar de Esquema.",
	"imitacion": "Copia la habilidad del rival hasta el final de la pelea.",
	"intercambio": "Te cambia la habilidad con la del rival hasta el final de la pelea.",
	"transformacion": "Te convertís en el rival hasta el final de la pelea: su aspecto, tipos, stats, ataques y habilidad (la vida sigue siendo la tuya).",
	"conversion": "Tu tipo pasa a ser el de tu primer ataque hasta el final de la pelea.",
	"conversion_2": "Tu tipo pasa a ser uno que resiste el último ataque que te pegaron.",
	"camuflaje": "Tu tipo pasa a ser el del lugar: Agua, Planta, Roca o Normal.",
	"autosugestion": "Copia las mejoras que tenga el rival.",
	"niebla": "Borra todos los estados y mejoras de los que estén cerca, los tuyos también.",
	"truco": "Le pasás tus problemas de estado al rival y te quedás con los suyos.",
	"senuelo": "Los salvajes cercanos dejan lo que hacían y van por vos.",
	"canto_mortal": "Todos los que estén cerca, vos también, se debilitan en 15 s si no se cambian antes.",
	"legado": "Te debilitás y el rival queda Muy intimidado.",
	"maldicion": "Si sos tipo Fantasma: perdés media vida y el rival pierde un 5 % por segundo durante 10 s. Si no: pegás y aguantás más por 15 s, pero vas más lento.",
	"relevo": "Sale otro de tu equipo y hereda tus mejoras.",
	"reciclaje": "Te devuelve el último objeto que usaste en esta pelea (una vez por objeto).",
	"sustituto": "Gastás un cuarto de tu vida en un muñeco que recibe los golpes y frena los ataques de estado hasta romperse.",
	"sonambulo": "Solo funciona dormido: tenerlo equipado hace que, mientras dormís, tires solo otro de tus ataques a distancia cada 1,2 s.",
}

## Relevo: lo que hereda el próximo que salga de ese equipo.
static var baton_team := -1
static var baton_statuses: Array[StatusEffect] = []
static var _metronome_pool: Array[MoveData] = []


static func run(m: MoveData, user: Creature) -> void:
	var foe: Creature = _foe_of(user)
	match m.special:
		"metronomo":
			var pick: MoveData = metronome_pool().pick_random()
			_call(user, pick, "¡Metrónomo: %s!" % pick.display_name)
		"espejo":
			if foe == null or foe.last_move == null or foe.last_move.special != "":
				_fail(user)
			else:
				_call(user, foe.last_move, "¡Espejo: %s!" % foe.last_move.display_name)
		"ayuda":
			var pool := _team_moves(user)
			if pool.is_empty():
				_fail(user)
			else:
				var pick: MoveData = pool.pick_random()
				_call(user, pick, "¡Ayuda: %s!" % pick.display_name)
		"adaptacion":
			var pick: MoveData = DB.moves[_terrain(user)["move"]]
			_call(user, pick, "¡Adaptación: %s!" % pick.display_name)
		"mimetico", "esquema":
			_copy_move(m, user, foe)
		"imitacion":
			if foe == null or not _same_kind(user, foe):
				_fail(user)
			else:
				user.save_ability()
				user.signature.data = foe.signature.data
				_say(user, "¡Copió %s!" % foe.signature.data.display_name)
		"intercambio":
			if foe == null or not _same_kind(user, foe):
				_fail(user)
			else:
				user.save_ability()
				foe.save_ability()
				var mine: SignatureData = user.signature.data
				user.signature.data = foe.signature.data
				foe.signature.data = mine
				_say(user, "¡Cambiaron de habilidad!")
		"transformacion":
			_transform(user, foe)
		"conversion":
			var first: MoveData = null
			for s: MoveData in user.moves.slots:
				if s != null and s.power > 0.0:
					first = s
					break
			if first == null:
				_fail(user)
			else:
				_set_type(user, first.element)
		"conversion_2":
			var by := user.last_hit_by as Creature
			if not is_instance_valid(by) or by.last_move == null:
				_fail(user)
			else:
				var options: Array = DB.types.values().filter(func(t: ElementType):
					var one: Array[ElementType] = [t]
					return DB.type_chart.get_multiplier(by.last_move.element, one) < 1.0)
				if options.is_empty():
					_fail(user)
				else:
					_set_type(user, options.pick_random())
		"camuflaje":
			_set_type(user, DB.types[_terrain(user)["type"]])
		"autosugestion":
			var good := _good_statuses(foe) if foe != null else []
			if good.is_empty():
				_fail(user)
			else:
				for s: StatusEffect in good:
					user.statuses.apply(s)
				_say(user, "¡Copió sus mejoras!")
		"niebla":
			for c in _near(user):
				c.statuses.clear()
			_say(user, "¡La niebla borró todo!")
		"truco":
			if foe == null:
				_fail(user)
			else:
				var mine := _bad_statuses(user)
				var theirs := _bad_statuses(foe)
				for s: StatusEffect in mine:
					user.statuses.cure(s)
					foe.statuses.apply(s)
				for s: StatusEffect in theirs:
					foe.statuses.cure(s)
					user.statuses.apply(s)
				_say(user, "¡Truco!")
		"senuelo":
			for c in _near(user):
				if c.team == Creature.Team.WILD and user.team != Creature.Team.WILD:
					c.target = user
					c.emote("!", 0.8)
					if c.machine.current_name() in ["wander", "watch", "flee", "idle"]:
						c.machine.transition_to("chase")
			_say(user, "¡Vengan por mí!")
		"canto_mortal":
			for c in _near(user):
				c.statuses.apply(DB.statuses["condenado"])
			_say(user, "¡Canto Mortal!")
		"legado":
			if foe != null:
				foe.statuses.apply(DB.statuses["muy_intimidado"])
			user.take_status_damage(user.health.max_hp())
		"maldicion":
			if _is_ghost(user):
				if foe == null:
					_fail(user)
				else:
					user.take_status_damage(user.health.max_hp() * 0.5)
					foe.statuses.apply(DB.statuses["maldito"])
			else:
				user.statuses.apply(DB.statuses["maldicion_cuerpo"])
		"relevo":
			_baton_pass.call_deferred(user)
		"reciclaje":
			var last: String = GameState.last_item_used
			if user.team != Creature.Team.ALLY or last == "" or not DB.items.has(last):
				_fail(user)
			else:
				GameState.last_item_used = ""
				GameState.add_item(last)
				_say(user, "¡Recuperó %s!" % DB.items[last].display_name)
		"sustituto":
			if user.instance.hp <= user.health.max_hp() * 0.25 or user.statuses.has_status("sustituto"):
				_fail(user)
			else:
				user.take_status_damage(user.health.max_hp() * 0.25)
				user.sub_hp = user.health.max_hp() * 0.25
				user.statuses.apply(DB.statuses["sustituto"])
		"sonambulo":
			_say(user, "Está despierto...")


## Cuánto le conviene a la IA (multiplica el valor de un ataque de estado; 0 = ni lo intenta).
static func ai_value(m: MoveData, actor: Creature, t: Creature) -> float:
	var hp: float = actor.health.ratio()
	var has_foe := is_instance_valid(t)
	match m.special:
		"metronomo", "ayuda", "adaptacion":
			return 1.2
		"espejo", "mimetico", "esquema":
			return 1.2 if has_foe and t.last_move != null and t.last_move.special == "" else 0.0
		"imitacion", "intercambio":
			return 1.0 if has_foe and not actor.ability_saved() and _same_kind(actor, t) else 0.0
		"transformacion":
			return 3.0 if has_foe and actor.instance.fight_stats == null else 0.0
		"conversion", "conversion_2", "camuflaje":
			return 0.8 if actor.instance.fight_types.is_empty() else 0.0
		"autosugestion":
			return 1.5 if has_foe and not _good_statuses(t).is_empty() else 0.0
		"niebla":
			return 1.5 if not _bad_statuses(actor).is_empty() or (has_foe and not _good_statuses(t).is_empty()) else 0.0
		"truco":
			return 1.5 if not _bad_statuses(actor).is_empty() and has_foe else 0.0
		"canto_mortal":
			return 2.0 if hp < 0.35 else 0.0
		"legado":
			return 2.0 if hp < 0.25 else 0.0
		"maldicion":
			return (1.0 if hp > 0.6 else 0.0) if _is_ghost(actor) else (0.0 if actor.statuses.has_status("maldicion_cuerpo") else 1.2)
		"relevo":
			return 1.2 if not _good_statuses(actor).is_empty() and _can_baton(actor) else 0.0
		"sustituto":
			return 1.5 if hp > 0.5 and not actor.statuses.has_status("sustituto") else 0.0
		"mismo_destino":
			return 2.0 if hp < 0.3 and not actor.statuses.flag("destiny") else 0.0
		"rabia":
			return 1.5 if hp < 0.4 and not actor.statuses.flag("grudge") else 0.0
		"robo":
			if has_foe:
				for s: MoveData in t.moves.slots:
					if s != null and s.self_status != null:
						return 1.0
			return 0.0
		"chapoteo":
			if has_foe:
				for s: MoveData in t.moves.slots:
					if s != null and s.power > 0.0 and s.element != null and s.element.id == "electrico":
						return 1.0
			return 0.0
	return 0.0  # (Señuelo, Reciclaje, Sonámbulo: la IA no los usa)


static func metronome_pool() -> Array[MoveData]:
	if _metronome_pool.is_empty():
		for m: MoveData in DB.moves.values():
			if m.power > 0.0 and m.cooldown > 0.0 and m.special == "" and m.id not in EXCLUDED \
					and m.kind not in [MoveData.Kind.SELF_BUFF, MoveData.Kind.SHIELD]:
				_metronome_pool.append(m)
	return _metronome_pool


## Mientras duerme, si tiene Sonámbulo, tira otro de sus ataques a distancia (lo llama Creature cada `Creature.SLEEP_TALK_EVERY` s).
static func sleep_talk(user: Creature) -> void:
	var pool: Array[MoveData] = []
	for s: MoveData in user.moves.slots:
		if s != null and s.power > 0.0 and s.kind in [MoveData.Kind.PROJECTILE, MoveData.Kind.AREA]:
			pool.append(s)
	if pool.is_empty():
		return
	var foe := _foe_of(user)
	if foe == null or user.napping:
		return  # (sin nadie cerca, o un salvaje en su siesta: sigue durmiendo tranquilo)
	var pick: MoveData = pool.pick_random()
	var aim: Vector2 = (foe.global_position - user.global_position).normalized()
	_say(user, "¡Sonámbulo: %s!" % pick.display_name)
	user.release_move({"move": pick, "aim": aim, "step": 0, "no_recovery": true})


## Relevo: el que sale de ese equipo hereda las mejoras (lo llama Creature._ready).
static func receive_baton(c: Creature) -> void:
	if baton_team != c.team or baton_statuses.is_empty():
		return
	for s: StatusEffect in baton_statuses:
		c.statuses.apply(s)
	baton_statuses = []
	baton_team = -1


static func is_good(s: StatusEffect) -> bool:
	return s.attack_mult > 1.0 or s.damage_taken_mult < 1.0 or s.speed_mult > 1.0 or s.heal_per_second > 0.0


# ---------------------------------------------------------------------------------------------------------------------

static func _foe_of(user: Creature) -> Creature:
	if is_instance_valid(user.target) and not user.target.is_down():
		return user.target
	var best: Creature = null
	var best_d := RANGE
	for c in user.get_tree().get_nodes_in_group("creatures"):
		if c != user and c.team != user.team and not c.is_down():
			var d: float = c.global_position.distance_to(user.global_position)
			if d < best_d:
				best_d = d
				best = c
	return best


static func _near(user: Creature) -> Array[Creature]:
	var out: Array[Creature] = []
	for c in user.get_tree().get_nodes_in_group("creatures"):
		if not c.is_down() and c.global_position.distance_to(user.global_position) <= RANGE:
			out.append(c)
	return out


static func _call(user: Creature, m: MoveData, text: String) -> void:
	_say(user, text)
	user.cast_other.call_deferred(m)


static func _say(user: Creature, text: String) -> void:
	Events.signature_triggered.emit(user, text, CAST_COLOR)


static func _fail(user: Creature) -> void:
	_say(user, "¡Pero falló!")


static func _is_ghost(c: Creature) -> bool:
	return c.instance.types().any(func(t: ElementType): return t != null and t.id == "fantasma")


## Dos firmas de la misma clase (las habilidades, no el kit de un jefe): se pueden pasar los datos.
static func _same_kind(a: Creature, b: Creature) -> bool:
	return a.signature != null and b.signature != null and a.signature.get_script() == b.signature.get_script() \
		and a.signature.data != b.signature.data


static func _good_statuses(c: Creature) -> Array:
	var out := []
	for id in c.statuses.active:
		if is_good(c.statuses.active[id]["status"]):
			out.append(c.statuses.active[id]["status"])
	return out


static func _bad_statuses(c: Creature) -> Array:
	var out := []
	for id in c.statuses.active:
		var s: StatusEffect = c.statuses.active[id]["status"]
		if not is_good(s) and s.id != "sustituto":
			out.append(s)
	return out


static func _team_moves(user: Creature) -> Array[MoveData]:
	var out: Array[MoveData] = []
	if user.team == Creature.Team.ALLY:
		for inst: CreatureInstance in GameState.party:
			if inst != user.instance:
				for s: MoveData in inst.equipped_moves:
					if s != null and s.power > 0.0 and s.special == "":
						out.append(s)
	else:  # (un salvaje o un rival: de lo que sabe su especie)
		for e in user.instance.species.learnset_entries():
			if e.move != null and e.move.power > 0.0 and e.move.special == "" and e.level <= user.instance.level:
				out.append(e.move)
	return out


## Lugar donde está parado: qué ataque saca Adaptación y qué tipo da Camuflaje.
static func _terrain(user: Creature) -> Dictionary:
	var world: Node = user.get_tree().get_first_node_in_group("world")
	if world != null and world.has_method("tags_at"):
		var tags: PackedStringArray = world.tags_at(user.global_position)
		if tags.has("agua"):
			return {"move": "surf", "type": "agua"}
		if tags.has("pasto_alto"):
			return {"move": "hoja_afilada", "type": "planta"}
		var dn = world.get("day_night")
		if dn != null and dn.get("in_cave"):
			return {"move": "lanzarrocas", "type": "roca"}
	return {"move": "rapidez", "type": "normal"}


static func _set_type(user: Creature, t: ElementType) -> void:
	var one: Array[ElementType] = [t]
	user.instance.fight_types = one
	_say(user, "¡Ahora es tipo %s!" % t.display_name)


static func _copy_move(m: MoveData, user: Creature, foe: Creature) -> void:
	if foe == null or foe.last_move == null or foe.last_move.special != "" or user.moves.slots.has(foe.last_move):
		_fail(user)
		return
	var slot: int = user.moves.slots.find(m)
	if slot < 0:
		return
	var copy: MoveData = foe.last_move
	if m.special == "esquema":  # para siempre
		var eq: int = user.instance.equipped_moves.find(m)
		if eq >= 0:
			user.instance.equipped_moves[eq] = copy
		if not user.instance.taught_moves.has(copy):
			user.instance.taught_moves.append(copy)
	user.moves.slots[slot] = copy
	user.moves.cooldowns[slot] = 0.0
	user.fight_moves_changed = true
	_say(user, "¡Aprendió %s!" % copy.display_name)


static func _transform(user: Creature, foe: Creature) -> void:
	if foe == null or user.instance.fight_stats != null:
		_fail(user)
		return
	user.instance.fight_stats = foe.instance
	user.instance.fight_types = foe.instance.types().duplicate()
	for i in MoveUser.SLOT_COUNT:
		var copy: MoveData = foe.moves.slots[i] if i < foe.moves.slots.size() else null
		user.moves.slots[i] = copy
		user.moves.cooldowns[i] = 0.0
	user.fight_moves_changed = true
	if _same_kind(user, foe):
		user.save_ability()
		user.signature.data = foe.signature.data
	user.sprite.species = foe.instance.species
	_say(user, "¡Se transformó en %s!" % foe.instance.species.display_name)


static func _can_baton(user: Creature) -> bool:
	var world: Node = user.get_tree().get_first_node_in_group("world")
	if world == null or user.statuses.flag("traps"):
		return false
	if user.team == Creature.Team.ALLY:
		return user == world.companion and GameState.party.any(func(i): return i != user.instance and i.hp > 0.0)
	var arena = world.get("arena")
	return arena != null and arena.active and arena.foe == user \
		and arena.foe_team.any(func(i): return i != user.instance and i.hp > 0.0)


static func _baton_pass(user: Creature) -> void:
	if not is_instance_valid(user) or user.is_down() or not _can_baton(user):
		if is_instance_valid(user):
			_fail(user)
		return
	var world: Node = user.get_tree().get_first_node_in_group("world")
	baton_team = user.team
	baton_statuses.assign(_good_statuses(user))
	if user.team == Creature.Team.ALLY:
		for i in GameState.party.size():
			if GameState.party[i] != user.instance and GameState.party[i].hp > 0.0:
				world.combat.force_switch(i)
				return
	else:
		world.arena.baton_out()
