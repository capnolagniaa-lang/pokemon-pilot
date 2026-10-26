extends Node
## Bus de eventos global. Los sistemas emiten y escuchan acá en lugar de llamarse entre sí.

@warning_ignore_start("unused_signal")

# Mundo
signal zone_entered(zone: ZoneEntry)
signal zone_loaded(zone: ZoneEntry, node: Node)
signal zone_unloaded(zone: ZoneEntry)
## El entrenador usó una puerta (de una zona a otra: casa, Centro, garita...).
signal warped(from: ZoneEntry, to: ZoneEntry)

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
## Pelea contra un entrenador en su arena (TrainerBattle): `kind` = "entrenador", "lider", "rival" o "torneo" (la
## música de esa pelea). Al terminar, el resultado ("win"/"lose") y el mismo kind.
signal trainer_battle_started(kind: String)
signal trainer_battle_ended(result: String, kind: String)
## Sale un Pokémon tuyo a pelear (empieza un combate o lo cambiás): su grito.
signal companion_out(inst: Resource)
## Sonidos sueltos (Sound): curar en el Centro / con mamá, saltar un saliente, lanzar la bola, cada sacudida, se
## escapó de la bola, subió de nivel.
signal party_healed()
signal ledge_jumped()
signal ball_thrown()
signal ball_shook()
signal capture_escaped()
signal level_up(inst: Resource)
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

# Historia (docs/PLAN_HISTORIA.md)
## Se puso o se sacó una bandera de la historia.
signal story_flag_changed(flag: String, on: bool)
## Empieza / termina una conversación (la caja de diálogo está abierta).
signal dialog_started
signal dialog_finished
## Un golpe fuerte contra el suelo (MoveData.crater_radius): el terreno se deforma (cráter).
## `source` = quién y con qué ("<id del Pokémon>:<id del ataque>") y `max_count` = cuántos cráteres de esa fuente
## pueden quedar a la vez (MoveData.crater_max): al pasarse se borra el más viejo.
signal ground_impact(position: Vector2, radius: float, source: String, max_count: int)
## Combo con nombre o cadena de golpes (para el feedback): quién lo hizo, nombre ("" = solo la cadena) y largo.
signal combo_landed(attacker: Node, combo_name: String, chain: int)
## Cambió el dinero (docs/PLAN_TORNEO.md).
signal money_changed(money: int)
## Evoluciones (EvolutionDirector): una criatura del equipo puede evolucionar (al subir de nivel o con una piedra;
## cancelable = se puede frenar con Esc, como en los juegos) y cuando ya evolucionó.
signal evolution_ready(inst: Resource, to: Resource, cancelable: bool)
signal evolved(inst: Resource, from: Resource, to: Resource)

@warning_ignore_restore("unused_signal")
