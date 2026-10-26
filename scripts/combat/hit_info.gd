class_name HitInfo
extends RefCounted
## Datos de un golpe: se calcula al lanzar el ataque, así no depende de que el atacante siga vivo.
## La mecánica de firma del atacante puede modificarlo (más daño, estado extra, área mayor).

var move: MoveData
var attacker: Node
var attacker_level: int = 1
## Ataque o At. Esp. del atacante según la categoría del ataque (con la quemadura ya aplicada).
var attack: float = 10.0
var attacker_types: Array[ElementType] = []
var origin: Vector2 = Vector2.ZERO
var team: int = 0
## Multiplicador de daño (mecánicas de firma, escalado por recurso).
var damage_mult: float = 1.0
## Multiplicador del tamaño de áreas y golpes cuerpo a cuerpo (Mar Llamas).
var area_mult: float = 1.0
## Empuje de este golpe (el último golpe de un combo empuja más).
var knockback: float = 0.0
## Estado extra que aplica este golpe (ej: Charmander con Calor ≥ 50 quema).
var extra_status: StatusEffect
var extra_status_chance: float = 0.0
## Lo completa Damage.resolve al aplicarse sobre un objetivo.
var effectiveness: float = 1.0


static func from(user: Node, p_move: MoveData) -> HitInfo:
	var h := HitInfo.new()
	h.move = p_move
	h.attacker = user
	h.attacker_level = user.instance.level
	h.attack = user.attack_stat_for(p_move.category)
	h.attacker_types = user.instance.species.types
	h.origin = user.global_position
	h.team = user.team
	h.knockback = p_move.knockback
	if user.team == 1 and GameState.difficulty != null:  # salvaje: daño según la dificultad
		h.damage_mult *= GameState.difficulty.damage_mult
	# Ajustes del juego: daño que hacés (tu equipo) y que recibís (el de los rivales).
	h.damage_mult *= float(GameState.setting("dealt_mult")) if user.team == 0 else float(GameState.setting("taken_mult"))
	if user.signature != null:
		user.signature.modify_hit(h)
	return h


## Clave de "quién y con qué" de un golpe (para los cráteres de cada ataque): "<id del Pokémon>:<id del ataque>".
static func source_key(h: HitInfo) -> String:
	var who: int = h.attacker.get_instance_id() if is_instance_valid(h.attacker) else 0
	return "%d:%s" % [who, h.move.id if h.move != null else ""]
