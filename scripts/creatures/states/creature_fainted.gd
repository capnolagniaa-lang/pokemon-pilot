extends State
## Debilitado: deja de colisionar y se desvanece. Los salvajes se borran; tu Pokémon queda oculto
## hasta que se recupera (lo maneja el CombatDirector).


func enter(_msg: Dictionary = {}) -> void:
	actor.velocity = Vector2.ZERO
	actor.hurtbox.set_deferred("monitorable", false)
	actor.set_deferred("collision_layer", 0)
	actor.sprite.play_once("Hurt", 0.6)
	var tw: Tween = actor.create_tween()
	tw.tween_interval(0.35)
	tw.tween_property(actor, "modulate:a", 0.0, 0.5)
	if actor.team == Creature.Team.WILD:
		tw.tween_callback(actor.queue_free)
