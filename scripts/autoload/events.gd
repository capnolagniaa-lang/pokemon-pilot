extends Node
## Bus de eventos global. Los sistemas emiten y escuchan acá en lugar de llamarse entre sí.

@warning_ignore_start("unused_signal")

# Mundo
signal zone_entered(zone: ZoneEntry)
signal zone_loaded(zone: ZoneEntry, node: Node)
signal zone_unloaded(zone: ZoneEntry)

# Partida
signal game_started()
signal party_changed()

# Combate
## Un salvaje detectó a un objetivo (normalmente tu Pokémon o el entrenador).
signal wild_aggro(wild: Node, target: Node)
signal battle_started()
signal battle_ended()
signal move_used(user: Node, move: MoveData)
signal creature_damaged(creature: Node, amount: float, hit: HitInfo)
signal creature_fainted(creature: Node)
signal status_applied(creature: Node, status: StatusEffect)
signal status_removed(creature: Node, status: StatusEffect)
## Se disparó una interacción elemento × estado (agua apaga quemado, eléctrico sobre empapado...).
signal interaction_triggered(creature: Node, interaction: StatusInteraction)
## Un elemento impactó el mundo en una posición (lo usa el entorno reactivo en la Etapa 3).
signal element_impact(element: ElementType, position: Vector2, radius: float)

# Feedback
signal camera_shake(strength: float)
signal hitstop(duration: float)

# Interfaz
signal message_requested(text: String)

@warning_ignore_restore("unused_signal")
