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


func animate(moving: bool, running: bool, delta: float) -> void:
	var row := 0  # abajo
	if facing == Vector2.LEFT:
		row = 1
	elif facing == Vector2.RIGHT:
		row = 2
	elif facing == Vector2.UP:
		row = 3
	var col := 0
	if moving:
		_anim_time += delta * (12.0 if running else 8.0)
		col = [1, 0, 2, 0][int(_anim_time) % 4]
	else:
		_anim_time = 0.0
	sprite.frame = row * 3 + col


func _four_dir(dir: Vector2) -> Vector2:
	if absf(dir.x) > absf(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	return Vector2.DOWN if dir.y > 0 else Vector2.UP
