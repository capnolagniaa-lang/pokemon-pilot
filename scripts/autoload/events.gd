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

# Interfaz
signal message_requested(text: String)

@warning_ignore_restore("unused_signal")
