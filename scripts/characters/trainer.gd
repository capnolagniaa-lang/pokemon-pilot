class_name Trainer
extends CharacterBody2D
## El entrenador: se mueve por el mundo y deja un rastro que sigue su Pokémon.

@export var walk_speed := 70.0
@export var run_speed := 125.0

const TRAIL_STEP := 3.0
const TRAIL_MAX := 80

var facing := Vector2.DOWN
## Posiciones recientes (la última es la más nueva): el Pokémon las sigue como migas.
var trail: Array[Vector2] = []
## Si no es cero, reemplaza al input (lo usa el autotest).
var autopilot := Vector2.ZERO

var _anim_time := 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var machine: StateMachine = $StateMachine


func _ready() -> void:
	trail.append(global_position)


func input_dir() -> Vector2:
	if autopilot != Vector2.ZERO:
		return autopilot
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func wants_run() -> bool:
	return Input.is_action_pressed("run")


func move(dir: Vector2, speed: float) -> void:
	velocity = dir * speed
	move_and_slide()
	if dir != Vector2.ZERO:
		facing = _four_dir(dir)
	if global_position.distance_to(trail[-1]) >= TRAIL_STEP:
		trail.append(global_position)
		if trail.size() > TRAIL_MAX:
			trail.pop_front()


## Hoja de FireRed (9 frames): quieto abajo/arriba/izq, y dos pasos para cada una.
## La derecha es la izquierda espejada.
const FRAMES := {
	"down": [0, 3, 4],
	"up": [1, 5, 6],
	"side": [2, 7, 8],
}


func animate(moving: bool, running: bool, delta: float) -> void:
	var set_name := "down"
	if facing == Vector2.UP:
		set_name = "up"
	elif facing.x != 0.0:
		set_name = "side"
	sprite.flip_h = facing == Vector2.RIGHT
	var frames: Array = FRAMES[set_name]
	var frame: int = frames[0]
	if moving:
		_anim_time += delta * (10.0 if running else 6.5)
		frame = [frames[1], frames[0], frames[2], frames[0]][int(_anim_time) % 4]
	else:
		_anim_time = 0.0
	sprite.frame = frame


func _four_dir(dir: Vector2) -> Vector2:
	if absf(dir.x) > absf(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	return Vector2.DOWN if dir.y > 0 else Vector2.UP
