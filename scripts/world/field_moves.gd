class_name FieldMoves
extends Node
## Habilidades fuera de combate (MO y objetos clave; docs/PLAN_CAPITULO_3.md y docs/PLAN_RESTO_KANTO.md). Todas con la E
## frente a algo (StoryDirector.register_interaction):
##  · Corte (MO01 + Medalla Cascada): corta un árbol fino (EnvObject "cortable"); vuelve a crecer al recargar la zona.
##  · Surf (MO03 + Medalla Alma): frente al agua, el entrenador navega sobre su Pokémon (el agua deja de frenarlo);
##    al pisar tierra se baja solo.
##  · Fuerza (MO04 + Medalla Arcoíris): frente a una roca grande ("pesado") la activa; caminando contra la roca la empuja
##    una celda si del otro lado hay lugar. Las rocas vuelven a su lugar al recargar la zona (como en los juegos).
##  · Poké Flauta: despierta a los Snorlax de las Rutas 12 y 16 (acciones "snorlax_<ruta>" de su conversación).
## En el modo libre (sin historia) alcanza con tener la MO. Nodo del mundo (world.field_moves).

const CUT_ITEM := "mo01"
const SURF_ITEM := "mo03"
const STRENGTH_ITEM := "mo04"
## Medalla que hace falta para usar cada MO fuera de combate (como en FireRed).
const BADGES := {"mo01": "medalla_cascada", "mo03": "medalla_alma", "mo04": "medalla_arcoiris"}
const BADGE_NAMES := {"medalla_cascada": "la Medalla Cascada", "medalla_alma": "la Medalla Alma",
	"medalla_arcoiris": "la Medalla Arcoíris"}
## Distancia máxima entre el objeto y el punto de adelante del entrenador.
const REACH := 14.0
const CELL := 16.0
## Snorlax que duermen en el camino: acción → [bandera al despertarlo, nivel].
const SNORLAX := {"snorlax_ruta12": ["snorlax_ruta12_despierto", 30], "snorlax_ruta16": ["snorlax_ruta16_despierto", 30]}
## Legendarios quietos en su lugar: acción → [especie, bandera, nivel, id de la persona]. Al hablarles pelean (salvajes).
const LEGENDS := {"legendario_articuno": ["articuno", "articuno_visto", 50, "islas_espuma_s4_articuno"],
	"legendario_zapdos": ["zapdos", "zapdos_visto", 50, "central_electrica_zapdos"]}

var world: Node
## Navegando sobre el agua (Surf).
var surfing := false
## Fuerza activada (hasta cambiar de zona).
var strength := false
var _strength_zone := ""
var _pushing := false
var _mount: Sprite2D
var _sprite_y := 0.0
## Al subir al agua, un ratito sin chequear si pisó tierra (todavía está saliendo de la orilla).
var _surf_grace := 0.0


func _ready() -> void:
	world = get_parent()
	world.story.register_interaction(_try_cut)
	world.story.register_interaction(_try_strength)
	world.story.register_interaction(_try_surf)
	for action in SNORLAX:
		world.story.register_action(action, _wake_snorlax.bind(action))
	for action in LEGENDS:
		world.story.register_action(action, _legend.bind(action))
	Events.zone_entered.connect(func(z: ZoneEntry): if z.id != _strength_zone: strength = false)


## Si puede usar una MO fuera de combate: la tiene y, en la historia, tiene la medalla.
static func can_use(item: String) -> bool:
	if GameState.item_count(item) <= 0:
		return false
	return GameState.has_flag(BADGES.get(item, "")) or not GameState.has_flag("historia")


static func can_cut() -> bool:
	return can_use(CUT_ITEM)


## Por qué no se puede (para el mensaje).
static func _why_not(item: String, move_name: String) -> String:
	if GameState.item_count(item) <= 0:
		return "Necesitás la MO de %s." % move_name
	return "Te falta %s para usarlo fuera de combate." % BADGE_NAMES.get(BADGES.get(item, ""), "una medalla")


func _mon_name() -> String:
	var mon: CreatureInstance = GameState.active()
	return mon.display_name() if mon != null else "Tu Pokémon"


## El objeto con ese tag más cercano a un punto (o null).
func object_near(pos: Vector2, tag: String) -> EnvObject:
	var best: EnvObject = null
	var best_d := REACH
	for o in get_tree().get_nodes_in_group("env_objects"):
		if o is EnvObject and o.has_tag(tag) and not o._gone:
			var d: float = o.global_position.distance_to(pos)
			if d < best_d:
				best_d = d
				best = o
	return best


func cuttable_near(pos: Vector2) -> EnvObject:
	return object_near(pos, "cortable")


# --- Corte ----------------------------------------------------------------------------------------------------

func _try_cut(_zone_id: String, _cell: Vector2i, front: Vector2) -> bool:
	var tree := cuttable_near(front)
	if tree == null:
		return false
	_cut_dialog(tree)
	return true


func _cut_dialog(tree: EnvObject) -> void:
	var story: StoryDirector = world.story
	story.lock()
	if not can_use(CUT_ITEM):
		await story._say("", PackedStringArray(["Este árbol se ve fino... se podría cortar.", _why_not(CUT_ITEM, "Corte")]))
	elif await story.dialog.ask("", "Este árbol se puede cortar. ¿Usás Corte?", PackedStringArray(["Sí", "No"])) == 0:
		await story._say("", PackedStringArray(["¡%s usó Corte!" % _mon_name()]))
		tree.cut()
	story.unlock()


# --- Fuerza ---------------------------------------------------------------------------------------------------

func _try_strength(zone_id: String, _cell: Vector2i, front: Vector2) -> bool:
	if object_near(front, "pesado") == null:
		return false
	_strength_dialog(zone_id)
	return true


func _strength_dialog(zone_id: String) -> void:
	var story: StoryDirector = world.story
	story.lock()
	if strength:
		await story._say("", PackedStringArray(["La Fuerza está activa: caminá contra la roca para empujarla."]))
	elif not can_use(STRENGTH_ITEM):
		await story._say("", PackedStringArray(["Es una roca enorme. Hace falta mucha fuerza para moverla.", _why_not(STRENGTH_ITEM, "Fuerza")]))
	elif await story.dialog.ask("", "Es una roca enorme. ¿Usás Fuerza?", PackedStringArray(["Sí", "No"])) == 0:
		activate_strength(zone_id)
		await story._say("", PackedStringArray(["¡%s usó Fuerza! Ahora puede empujar las rocas." % _mon_name()]))
	story.unlock()


func activate_strength(zone_id: String) -> void:
	strength = true
	_strength_zone = zone_id


## Empuja la roca una celda en `dir` si del otro lado hay lugar (lo usa el entrenador al caminar contra ella y el test).
func push(boulder: EnvObject, dir: Vector2) -> bool:
	if _pushing or not strength:
		return false
	var d := Vector2(signf(dir.x), 0.0) if absf(dir.x) > absf(dir.y) else Vector2(0.0, signf(dir.y))
	var entry: ZoneEntry = world.streamer.world_data.zone_at(boulder.global_position)
	var zone: Zone = world.streamer.zone_node(entry.id) if entry != null else null
	if zone == null:
		return false
	var target := boulder.global_position + d * CELL
	var cell := zone.cell_at(target)
	if not MapRules.is_walkable(zone, cell) or zone.get_tags(cell).has("agua"):
		return false
	_pushing = true
	var tw := boulder.create_tween()
	tw.tween_property(boulder, "global_position", target, 0.25)
	await tw.finished
	Events.camera_shake.emit(1.5)
	_pushing = false
	return true


# --- Surf -----------------------------------------------------------------------------------------------------

func _try_surf(_zone_id: String, _cell: Vector2i, front: Vector2) -> bool:
	if surfing or not world.tags_at(front).has("agua") or world.tags_at(world.trainer.global_position).has("agua"):
		return false
	_surf_dialog(front)
	return true


func _surf_dialog(front: Vector2) -> void:
	var story: StoryDirector = world.story
	story.lock()
	if not can_use(SURF_ITEM):
		await story._say("", PackedStringArray(["El agua está tranquila y es profunda.", _why_not(SURF_ITEM, "Surf")]))
	elif await story.dialog.ask("", "El agua está tranquila. ¿Usás Surf?", PackedStringArray(["Sí", "No"])) == 0:
		await story._say("", PackedStringArray(["¡%s usó Surf!" % _mon_name()]))
		start_surf(front)
	story.unlock()


## Sube al agua: el entrenador ya no choca con el agua (capa 2) y avanza al punto `onto`.
func start_surf(onto: Vector2) -> void:
	var t: Trainer = world.trainer
	surfing = true
	_surf_grace = 0.4
	t.set_collision_mask_value(2, false)
	_show_mount(true)
	var tw := t.create_tween()
	tw.tween_property(t, "global_position", onto, 0.25)
	if is_instance_valid(world.companion):
		world.companion.visible = false


func stop_surf() -> void:
	var t: Trainer = world.trainer
	surfing = false
	t.set_collision_mask_value(2, true)
	_show_mount(false)
	if is_instance_valid(world.companion):
		world.companion.global_position = t.global_position
		world.companion.visible = true


## Debajo del entrenador, el Pokémon que lo lleva (el primero de agua del equipo, o el activo).
func _show_mount(on: bool) -> void:
	var t: Trainer = world.trainer
	if _mount == null or not is_instance_valid(_mount):
		_mount = Sprite2D.new()
		_mount.name = "SurfMount"
		_mount.z_index = -1
		_mount.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		t.add_child(_mount)
	_mount.visible = on
	if on:
		var mon: CreatureInstance = GameState.active()
		for inst in GameState.party:
			if inst.species.types.any(func(e): return e.id == "agua"):
				mon = inst
				break
		_mount.texture = DB.idle_frame_of(mon.species) if mon != null else null
		_mount.position = Vector2(0, -6)
		_sprite_y = t.sprite.position.y
		t.sprite.position.y = _sprite_y - 8.0
	else:
		t.sprite.position.y = _sprite_y


func _physics_process(delta: float) -> void:
	if world == null or not is_instance_valid(world.trainer):
		return
	var t: Trainer = world.trainer
	if surfing:
		_surf_grace -= delta
		if is_instance_valid(world.companion):
			world.companion.global_position = t.global_position  # viaja "adentro" (no choca con el agua)
		if _surf_grace <= 0.0 and not world.tags_at(t.global_position).has("agua") and not t.locked:
			stop_surf()  # pisó tierra: se baja
	if strength and not _pushing:
		for i in t.get_slide_collision_count():
			var obj = t.get_slide_collision(i).get_collider()
			if obj is EnvObject and obj.has_tag("pesado") and t.velocity.length() > 1.0:
				push(obj, t.velocity)
				break


# --- Poké Flauta ----------------------------------------------------------------------------------------------

## Conversación del Snorlax dormido: con la Poké Flauta se despierta y te ataca (salvaje, se puede atrapar).
func _wake_snorlax(action: String) -> void:
	var story: StoryDirector = world.story
	var flag: String = SNORLAX[action][0]
	if GameState.item_count("poke_flauta") <= 0:
		await story._say("", PackedStringArray(["Ronca tan fuerte que no se va a despertar solo..."]))
		return
	if await story.dialog.ask("", "¿Tocás la Poké Flauta?", PackedStringArray(["Sí", "No"])) != 0:
		return
	await story._say("", PackedStringArray(["♪ ♫ ♪ ...", "¡Snorlax se despertó! ¡Y está de muy mal humor!"]))
	var npc: StoryNPC = story.npcs.get("%s_snorlax" % action.trim_prefix("snorlax_"))
	var at: Vector2 = npc.global_position if npc != null else world.trainer.global_position + world.trainer.facing * 32.0
	GameState.set_flag(flag)  # la persona-Snorlax se va (hide_if) y queda el salvaje
	story.refresh()
	var wild: Creature = world.spawner.spawn(DB.species["snorlax"], SNORLAX[action][1], at)
	if is_instance_valid(wild) and is_instance_valid(world.companion):
		wild.target = world.companion


## Un legendario: si aceptás, pelea como salvaje (se puede atrapar; si huís o lo debilitás, ya no vuelve).
func _legend(action: String) -> void:
	var story: StoryDirector = world.story
	var spec: Array = LEGENDS[action]
	var sp: SpeciesData = DB.species[spec[0]]
	if await story.dialog.ask("", "¿Te acercás a %s?" % sp.display_name, PackedStringArray(["Sí", "No"])) != 0:
		return
	await story._say("", PackedStringArray(["¡%s te ataca!" % sp.display_name]))
	var npc: StoryNPC = story.npcs.get(spec[3])
	var at: Vector2 = npc.global_position if npc != null else world.trainer.global_position + world.trainer.facing * 32.0
	GameState.set_flag(spec[1])
	story.refresh()
	var wild: Creature = world.spawner.spawn(sp, spec[2], at)
	if is_instance_valid(wild) and is_instance_valid(world.companion):
		wild.target = world.companion
