class_name AiTrace
extends RefCounted
## Registro de decisiones de la IA (Fase 1 de docs/IA_AUDITORIA.md). Los que deciden (estado `attack`, CombatBody,
## TrainerBattle) llaman a `AiTrace.note(actor, qué, datos)` y eso sale por `Events.ai_decided`; lo escuchan el registro a
## archivo, el overlay y las métricas de la pelea (`AiDebug`, nodo del mundo). Nada de esto cambia lo que decide la IA:
## solo cuenta lo que ya decidió (y no gasta números al azar, así una pelea con el registro prendido es igual a una sin él).
##
## Qué se anota (`what`): "modo" (acercarse, rodear...), "ataque", "aviso", "finta", "juntar" (PP), "ve" (vio una
## amenaza y decidió si esquivar), "paso" (paso al costado), "esquive", "lectura" (esquivó lo que repetís), "saca",
## "cambio", "no cambia", "retira", "pocion", "momento" (guion de líder).

## El registro a archivo (consola GM `ia log`).
static var log_on := false
## El overlay (consola GM `ia ver`).
static var overlay_on := false
## Hay una pelea de arena midiéndose (lo prende AiDebug): las decisiones se cuentan aunque no haya registro ni overlay.
static var measuring := false
## (Tests: imprime cada decisión en la consola.)
static var echo := false


## ¿Vale la pena armar los datos de una decisión? (Así, apagado, no cuesta nada.)
static func enabled() -> bool:
	return log_on or overlay_on or measuring or echo


## Anota una decisión de `actor`. `data` tiene que poder pasarse a JSON (textos, números, listas).
static func note(actor: Node, what: String, data: Dictionary = {}) -> void:
	if not enabled() or not is_instance_valid(actor):
		return
	data["what"] = what
	if actor.has_method("now"):
		data["t"] = snappedf(actor.now(), 0.01)
	if echo:
		print("[ia] %s %s %s" % [who(actor), what, describe(data)])
	Events.ai_decided.emit(actor, what, data)


## Nombre corto de una criatura para el registro: "Rattata (Tincho)".
static func who(actor: Node) -> String:
	if actor is Creature and actor.instance != null:
		var c: Creature = actor
		var owner := c.owner_name if c.owner_name != "" else ("salvaje" if c.team == Creature.Team.WILD else "tuyo")
		return "%s (%s)" % [c.instance.display_name(), owner]
	return str(actor.name) if actor != null else "?"


## Los datos de una decisión en una línea (para el registro y el overlay).
static func describe(data: Dictionary) -> String:
	var parts: PackedStringArray = []
	for k in data:
		if k in ["what", "t"]:
			continue
		var v = data[k]
		if v is float:
			v = "%.2f" % v
		elif v is Array:
			v = ", ".join(v.map(func(x): return str(x)))
		parts.append("%s=%s" % [k, str(v)])
	return " · ".join(parts)


## Los 3 mejores puntajes de la última elección de ataque, como textos "Placaje 72".
static func top3(actor: Creature) -> Array:
	var out := []
	if actor == null or actor.mind == null or actor.moves == null:
		return out
	var scores: Array[float] = actor.mind.last_scores
	var order := range(scores.size())
	order.sort_custom(func(a, b): return scores[a] > scores[b])
	for slot in order:
		if out.size() >= 3 or scores[slot] <= 0.0:
			break
		var m: MoveData = actor.moves.slots[slot]
		out.append("%s %d" % [m.display_name if m != null else "?", roundi(scores[slot])])
	return out
