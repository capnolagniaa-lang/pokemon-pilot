class_name FieldMoves
extends Node
## Habilidades fuera de combate (MO y objetos clave; docs/PLAN_CAPITULO_3.md y docs/PLAN_RESTO_KANTO.md). Las MO van
## como en los juegos nuevos (Let's Go): la historia las desbloquea (la MO + su medalla) y después no ocupan ataque ni
## preguntan nada: **caminando contra** el árbol, el agua o la roca tu Pokémon lo hace solo (`_auto_use`). La E frente
## al obstáculo también sirve, y si todavía no se puede, dice qué falta (StoryDirector.register_interaction):
##  · Corte (MO01 + Medalla Cascada): corta un árbol fino (EnvObject "cortable"); vuelve a crecer al recargar la zona.
##  · Surf (MO03 + Medalla Alma): frente al agua, el entrenador navega sobre su Pokémon (el agua deja de frenarlo);
##    al pisar tierra se baja solo.
##  · Fuerza (MO04 + Medalla Arcoíris): caminando contra una roca grande ("pesado") la empuja una celda si del otro
##    lado hay lugar. Las rocas vuelven a su lugar al recargar la zona (como en los juegos).
##  · Pelea en el agua (decisión del usuario 2026-10-28): los de tipo Agua nadan, los Voladores, Fantasma y los que
##    levitan (FLOATERS) flotan, y el resto, si estás navegando, pelea montado sobre tu Pokémon de Surf (más lento, y
##    el entrenador va con él). Los salvajes del agua salen solo mientras navegás (WildSpawner).
##  · Poké Flauta: despierta a los Snorlax de las Rutas 12 y 16 (acciones "snorlax_<ruta>" de su conversación).
## En el modo libre (sin historia) alcanza con tener la MO. Nodo del mundo (world.field_moves).

const CUT_ITEM := "mo01"
const SURF_ITEM := "mo03"
const STRENGTH_ITEM := "mo04"
## Medalla que hace falta para usar cada MO fuera de combate (como en FireRed).
const BADGES := {"mo01": "medalla_cascada", "mo03": "medalla_alma", "mo04": "medalla_arcoiris"}
const BADGE_NAMES := {"medalla_cascada": "la Medalla Cascada", "medalla_alma": "la Medalla Alma",
	"medalla_arcoiris": "la Medalla Arcoíris"}
## Cuánto hay que caminar contra el obstáculo para que se use la MO (para no activarla rozando).
const AUTO_PUSH := 0.18
## Distancia máxima entre el objeto y el punto de adelante del entrenador.
const REACH := 14.0
const CELL := 16.0
## Snorlax que duermen en el camino: acción → [bandera al despertarlo, nivel].
const SNORLAX := {"snorlax_ruta12": ["snorlax_ruta12_despierto", 30], "snorlax_ruta16": ["snorlax_ruta16_despierto", 30]}
## Legendarios quietos en su lugar: acción → [especie, bandera, nivel, id de la persona]. Al hablarles pelean (salvajes).
const LEGENDS := {"legendario_articuno": ["articuno", "articuno_visto", 50, "islas_espuma_s4_articuno"],
	"legendario_zapdos": ["zapdos", "zapdos_visto", 50, "central_electrica_zapdos"]}

## Los que levitan sin ser Voladores ni Fantasma (Levitación en la 3ª gen, y los imanes de Magnemite).
const FLOATERS := ["koffing", "weezing", "magnemite", "magneton", "unown", "vibrava", "flygon", "lunatone", "solrock",
	"baltoy", "claydol", "chimecho", "latias", "latios"]
## Velocidad del que pelea montado sobre el Pokémon de Surf.
const MOUNTED_SPEED := 0.75
## Si no tenés ningún Pokémon de agua en el equipo, te lleva este (como la Poké Montura de los juegos nuevos).
const DEFAULT_MOUNT := "lapras"

var world: Node
## Navegando sobre el agua (Surf).
var surfing := false
## Fuerza activada a mano (los tests); con la MO04 y la medalla está siempre activa (`strength_on`).
var strength := false
var _push_time := 0.0
var _pushing := false
var _mount: Sprite2D
## La fila de la hoja (dirección) y el cuadro de la montura, que mira hacia donde vas.
var mount_row := 0
var _mount_dir := Vector2.DOWN
var _mount_time := 0.0
var _mount_from := Vector2.ZERO
var _sprite_y := 0.0
## Cómo pelea en el agua el Pokémon que está afuera ("" = fuera de combate).
var water_mode := ""
## Por cuadro: menos que esto es estar quieto, y más, un salto (una puerta, un fundido), no un paso.
const MOUNT_MOVING := 0.2
const MOUNT_JUMP := 40.0
## Al subir al agua, un ratito sin chequear si pisó tierra (todavía está saliendo de la orilla).
var _surf_grace := 0.0
var _water_check := 0.0


func _ready() -> void:
	world = get_parent()
	world.story.register_interaction(_try_cut)
	world.story.register_interaction(_try_strength)
	world.story.register_interaction(_try_surf)
	Events.battle_started.connect(_update_water_battle)
	Events.battle_ended.connect(_update_water_battle)
	Events.companion_out.connect(func(_i): _update_water_battle.call_deferred())
	for action in SNORLAX:
		world.story.register_action(action, _wake_snorlax.bind(action))
	for action in LEGENDS:
		world.story.register_action(action, _legend.bind(action))


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
	if can_use(CUT_ITEM):
		tree.cut()
		return
	var story: StoryDirector = world.story
	story.lock()
	await story._say("", PackedStringArray(["Este árbol se ve fino... se podría cortar.", _why_not(CUT_ITEM, "Corte")]))
	story.unlock()


# --- Fuerza ---------------------------------------------------------------------------------------------------

func _try_strength(zone_id: String, _cell: Vector2i, front: Vector2) -> bool:
	if object_near(front, "pesado") == null:
		return false
	_strength_dialog()
	return true


func _strength_dialog() -> void:
	var story: StoryDirector = world.story
	story.lock()
	if strength_on():
		await story._say("", PackedStringArray(["Caminá contra la roca y %s la empuja." % _mon_name()]))
	else:
		await story._say("", PackedStringArray(["Es una roca enorme. Hace falta mucha fuerza para moverla.", _why_not(STRENGTH_ITEM, "Fuerza")]))
	story.unlock()


func activate_strength(_zone_id: String = "") -> void:
	strength = true


func strength_on() -> bool:
	return strength or can_use(STRENGTH_ITEM)


## Empuja la roca una celda en `dir` si del otro lado hay lugar (lo usa el entrenador al caminar contra ella y el test).
func push(boulder: EnvObject, dir: Vector2) -> bool:
	if _pushing or not strength_on():
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
	if can_use(SURF_ITEM):
		start_surf(front)
		return
	var story: StoryDirector = world.story
	story.lock()
	await story._say("", PackedStringArray(["El agua está tranquila y es profunda.", _why_not(SURF_ITEM, "Surf")]))
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
		_mount_dir = t.facing
		_mount_from = t.global_position
		_mount_time = 0.0
		_mount.position = Vector2(0, -6)
		_animate_mount(0.0)
		_sprite_y = t.sprite.position.y
		t.sprite.position.y = _sprite_y - 8.0
	else:
		t.sprite.position.y = _sprite_y


## Mira hacia donde se mueve el entrenador (en 8 direcciones) o hacia donde se dio vuelta, y nada mientras avanza.
func _animate_mount(delta: float) -> void:
	var t: Trainer = world.trainer
	var moved: Vector2 = t.global_position - _mount_from
	_mount_from = t.global_position
	var moving: bool = moved.length() > MOUNT_MOVING and moved.length() < MOUNT_JUMP
	if moving:
		_mount_dir = moved.normalized()
	elif _mount_dir.dot(t.facing) <= 0.0:
		_mount_dir = t.facing
	_mount_time += delta
	var anims: Dictionary = DB.anims_of(mount_species())
	var anim: Dictionary = anims.get("Walk" if moving else "Idle", anims.get("Idle", {}))
	if anim.is_empty():
		_mount.texture = DB.idle_frame_of(mount_species())
		return
	var sheet: Texture2D = DB.texture(anim["file"])
	var w: float = anim["w"]
	var h: float = anim["h"]
	var single: bool = sheet.get_height() < h * 8.0  # (una sola fila: mira a la izquierda y se espeja)
	mount_row = 0 if single else CreatureSprite.row_for(_mount_dir)
	_mount.flip_h = single and _mount_dir.x > 0.3
	if not _mount.texture is AtlasTexture:
		_mount.texture = AtlasTexture.new()
	var at: AtlasTexture = _mount.texture
	at.atlas = sheet
	at.region = Rect2(CreatureSprite.frame_at(anim["durations"], _mount_time, true) * w, mount_row * h, w, h)


## El que te lleva por el agua: el primero de agua del equipo (o la montura de siempre).
static func mount_species() -> SpeciesData:
	for inst in GameState.party:
		if inst.species.types.any(func(e): return e.id == "agua"):
			return inst.species
	return DB.species.get(DEFAULT_MOUNT)


# --- Pelea en el agua -----------------------------------------------------------------------------------------

## Cómo se mueve una especie en el agua: "nada" (tipo Agua), "flota" (Volador, Fantasma o levita) o "montado" (el
## resto: solo navegando, sobre tu Pokémon de Surf).
static func water_mode_of(sp: SpeciesData) -> String:
	var types: Array = sp.types.map(func(e): return e.id)
	if types.has("agua"):
		return "nada"
	if types.has("volador") or types.has("fantasma") or sp.id in FLOATERS:
		return "flota"
	return "montado"


## Al empezar o terminar una pelea (o al cambiar de Pokémon): quién puede entrar al agua y cómo.
func _update_water_battle() -> void:
	var c: Creature = world.companion
	if not is_instance_valid(c):
		return
	var fighting: bool = world.combat.in_battle
	var in_arena: bool = world.get("arena") != null and world.arena.active
	var mode := water_mode_of(c.instance.species) if fighting and not in_arena else ""  # (las arenas tienen sus reglas)
	if mode == "montado" and not surfing:
		mode = ""  # en tierra pelea como siempre
	water_mode = mode
	var t: Trainer = world.trainer
	if mode == "" and c.swims and not surfing and world.tags_at(c.global_position).has("agua"):
		c.global_position = t.global_position + Vector2(0, -12)  # terminó adentro del agua: vuelve a la orilla
	c.swims = mode != ""
	c.swim_mult = MOUNTED_SPEED if mode == "montado" else 1.0
	if not surfing or _in_arena():
		return
	c.visible = fighting
	# Montado: el entrenador (con la montura abajo) va pegado a tu Pokémon, que se para adelante sobre ella.
	if mode == "montado":
		t.follow_target = null
	elif fighting and not world.combat.arena_lock:
		t.follow_target = c


func _physics_process(delta: float) -> void:
	if world == null or not is_instance_valid(world.trainer):
		return
	var t: Trainer = world.trainer
	if surfing:
		_mount_for_arena()
		if is_instance_valid(_mount) and _mount.visible:
			_animate_mount(delta)
	if surfing and not _in_arena():
		_surf_grace -= delta
		if water_mode == "montado" and is_instance_valid(world.companion):
			t.global_position = world.companion.global_position + Vector2(0, -3)  # va arriba de la montura con él
		elif not world.combat.in_battle and is_instance_valid(world.companion):
			world.companion.global_position = t.global_position  # viaja "adentro" (no choca con el agua)
			world.companion.visible = false
		if _surf_grace <= 0.0 and not world.tags_at(t.global_position).has("agua") and not t.locked:
			stop_surf()  # pisó tierra: se baja
	_water_check -= delta
	if _water_check <= 0.0:
		_water_check = 0.5
		_resume_if_in_water()
	_auto_use(delta)
	if strength_on() and not _pushing:
		for i in t.get_slide_collision_count():
			var obj = t.get_slide_collision(i).get_collider()
			if obj is EnvObject and obj.has_tag("pesado") and t.velocity.length() > 1.0:
				push(obj, t.velocity)
				break


## Adentro del agua sin navegar no hay forma de moverse (partida guardada navegando, o trabada por versiones viejas): vuelve a Surf.
func _resume_if_in_water() -> void:
	var t: Trainer = world.trainer
	if surfing or t.locked or world.story.busy or _in_arena() or (world.warps != null and world.warps.busy) 			or not world.tags_at(t.global_position).has("agua"):
		return
	var q := PhysicsPointQueryParameters2D.new()
	q.position = t.global_position
	q.collision_mask = 2  # capa de agua
	if not t.get_world_2d().direct_space_state.intersect_point(q, 1).is_empty():
		start_surf(t.global_position)


## Parado en una arena: sigue navegando (al terminar vuelve al agua), pero sin la montura a la vista.
func _in_arena() -> bool:
	return world.get("arena") != null and world.arena.arena != null


func _mount_for_arena() -> void:
	var on := not _in_arena()
	if not on and is_instance_valid(world.companion):
		world.companion.visible = true  # navegando viaja "adentro": en la arena tiene que salir a pelear
	if is_instance_valid(_mount) and _mount.visible != on:
		_mount.visible = on
		world.trainer.sprite.position.y = _sprite_y - 8.0 if on else _sprite_y


## Caminando contra un árbol fino, el agua o una roca (con la habilidad desbloqueada) se usa sola, sin preguntar.
## (Fuerza no pasa por acá: con `strength_on` el choque contra la roca ya la empuja.)
func _auto_use(delta: float) -> void:
	var t: Trainer = world.trainer
	var input := t.input_dir()
	var story: StoryDirector = world.story
	if input == Vector2.ZERO or surfing or t.locked or world.combat.in_battle or story.busy or story.dialog.active \
			or (world.warps != null and world.warps.busy):
		_push_time = 0.0
		return
	var d := Vector2(WarpSystem._four(input))
	var front := t.global_position + d * 12.0
	var tree := cuttable_near(front) if can_use(CUT_ITEM) else null
	var water: bool = tree == null and can_use(SURF_ITEM) and world.tags_at(front).has("agua") \
		and not world.tags_at(t.global_position).has("agua")
	if tree == null and not water:
		_push_time = 0.0
		return
	_push_time += delta
	if _push_time < AUTO_PUSH:
		return
	_push_time = 0.0
	t.facing = d
	if tree != null:
		tree.cut()
	else:
		start_surf(t.global_position + d * 16.0)


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
