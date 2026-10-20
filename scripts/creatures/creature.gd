class_name Creature
extends CharacterBody2D
## Una criatura en el mundo. Los comportamientos viven en los estados de su StateMachine.

## Datos de la criatura (especie, nivel, vida). Se asigna antes de agregarla al árbol.
var instance: CreatureInstance
## Entrenador al que sigue (null si es salvaje).
var leader: Trainer
var facing := Vector2.DOWN

@onready var sprite: CreatureSprite = $Sprite
@onready var machine: StateMachine = $StateMachine


func _ready() -> void:
	sprite.species = instance.species


func move(dir: Vector2, speed: float) -> void:
	velocity = dir * speed
	move_and_slide()
	if velocity.length() > 1.0:
		facing = velocity.normalized()
