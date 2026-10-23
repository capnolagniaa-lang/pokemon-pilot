class_name TrainerNPC
extends CharacterBody2D
## Un entrenador vivo en el mundo (docs/PLAN_ENTRENADORES.md). En la fase E-0 está quieto en su lugar: mira al
## jugador cuando se acerca y muestra su nombre. El desafío y el combate llegan en E-1; la rutina, en E-5.
## Lo crea y lo saca TrainerDirector; lo que recuerda vive en su TrainerState (GameState.trainers).

## A qué distancia del entrenador del jugador se da vuelta a mirarlo y muestra su nombre.
const NOTICE_RADIUS := 72.0

var data: TrainerData
var facing := Vector2.DOWN

@onready var sprite: Sprite2D = $Sprite
@onready var name_label: Label = $Name


func _ready() -> void:
	add_to_group("trainer_npcs")
	sprite.texture = data.sprite
	sprite.hframes = maxi(1, data.sprite.get_width() / 16)
	name_label.text = "%s · %s" % [data.display_name, data.title] if data.title != "" else data.display_name
	name_label.visible = false
	_apply_facing()


func state() -> TrainerState:
	return GameState.trainer_state(data)


func _process(_delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("trainer")
	var near := player != null and player.global_position.distance_to(global_position) < NOTICE_RADIUS
	name_label.visible = near
	if near:
		var d: Vector2 = player.global_position - global_position
		var f := Vector2(signf(d.x), 0) if absf(d.x) > absf(d.y) else Vector2(0, signf(d.y))
		if f != facing:
			facing = f
			_apply_facing()


## Hoja de FireRed: frame 0 quieto abajo, 1 arriba, 2 costado (izquierda; la derecha es espejada).
func _apply_facing() -> void:
	if facing.y > 0.0:
		sprite.frame = 0
	elif facing.y < 0.0:
		sprite.frame = 1
	else:
		sprite.frame = 2
	sprite.flip_h = facing.x > 0.0
