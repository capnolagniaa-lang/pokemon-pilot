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
signal game_saved()
signal game_loaded()
## Un Pokémon del equipo aprendió un movimiento al subir de nivel.
signal move_learned(creature: CreatureInstance, move: MoveData)
## Atrapaste un Pokémon ("equipo" o "caja").
signal pokemon_caught(creature: CreatureInstance, where: String)
## Cambió la Caja.
signal box_changed()
## Cambió la mochila (se sumó, gastó o recogió un objeto).
signal bag_changed()
## Se usó un objeto sobre un Pokémon.
signal item_used(item: ItemData, creature: CreatureInstance)
## Se prendieron o apagaron los entrenadores vivos (Opciones).
signal living_trainers_changed(on: bool)
## Una especie se registró por primera vez en la Pokédex (la viste).
signal pokedex_registered(species: SpeciesData)
## Cambiaron los movimientos equipados de un Pokémon (ficha): el mundo re-saca al activo.
signal equipment_changed(creature: CreatureInstance)

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
## Una mecánica de firma hizo algo destacable (Mar Llamas, Descarga...): texto flotante.
signal signature_triggered(creature: Node, text: String, color: Color)
## Se disparó una interacción elemento × estado (agua apaga quemado, eléctrico sobre empapado...).
signal interaction_triggered(creature: Node, interaction: StatusInteraction)
## Un elemento impactó el mundo en una posición (lo usa el entorno reactivo en la Etapa 3).
signal element_impact(element: ElementType, position: Vector2, radius: float)
## Una embestida chocó contra un objeto del entorno (las rocas frágiles se rompen si `power` alcanza).
signal env_object_struck(object: Node, power: float)
## El entorno reaccionó en una posición (vapor, puente de hielo...): texto flotante.
signal env_reaction(position: Vector2, text: String)

# Feedback
signal camera_shake(strength: float)
signal hitstop(duration: float)

# Interfaz
signal message_requested(text: String)

@warning_ignore_restore("unused_signal")
