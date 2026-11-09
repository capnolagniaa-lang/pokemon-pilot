class_name PlayerModel
extends RefCounted
## Modelo del jugador de la IA nueva (Fase 4 de docs/IA_AUDITORIA.md): lo que el entrenador fue aprendiendo de **cómo
## jugás**, solo con lo que vio (tus ataques al salir, tus esquives, tus pasos al costado, tus cambios). No es aprendizaje de
## máquina: cuenta lo que hacés en cada situación, con **memoria que se desvanece** (cada cosa pesa la mitad pasada la vida
## media del `AIProfile`), y predice con una **confianza** que crece con los casos vistos (más rápido cuanto más difícil).
##
## Qué cuenta:
##  · **secuencias** de tus acciones (n-gramas de 2 y 3: "después de Pistola Agua y un esquive, tirás Mordisco");
##  · **cómo respondés** a cada clase de ataque suyo ("al aviso esquivás a la derecha", "a un disparo das un paso");
##  · **dónde atacás**: qué usás a cada distancia;
##  · **cambios**: si cambiás enseguida cuando él cambia (contracambio).
## Vive en `FoeMemory.model`, así lo comparte todo el equipo del entrenador en una pelea.

## Tus acciones recientes (fichas: "atk:<id del ataque>", "esq", "cambio").
const MAX_STREAM := 12
## Qué se considera contracambio: cambiás dentro de este tiempo después de que él cambia.
const COUNTER_WINDOW := 4.0
## Respuestas posibles a un ataque suyo.
const RESPONSES := ["esq_izq", "esq_der", "esq_atras", "paso_izq", "paso_der", "pega", "nada"]

var stream: Array[String] = []
## tabla -> contexto -> {"t": cuándo se actualizó, "w": {resultado: peso}}
var _tables := {}
var _ai_switch_at := -100.0


## Reloj común a todo el equipo (cada criatura tiene el suyo, y el modelo se comparte): cuadros de física / ritmo.
static func clock() -> float:
	return float(Engine.get_physics_frames()) / float(Engine.physics_ticks_per_second)


func clear() -> void:
	stream.clear()
	_tables.clear()
	_ai_switch_at = -100.0


# --- Contar (con decaimiento) ---

func _bucket(table: String, ctx: String, now: float, half_life: float) -> Dictionary:
	if not _tables.has(table):
		_tables[table] = {}
	var tb: Dictionary = _tables[table]
	if not tb.has(ctx):
		tb[ctx] = {"t": now, "w": {}}
	var b: Dictionary = tb[ctx]
	var dt := now - float(b.t)
	if dt > 0.0:
		var k := pow(0.5, dt / maxf(0.1, half_life))
		for o in b.w:
			b.w[o] = float(b.w[o]) * k
		b.t = now
	return b


func add(table: String, ctx: String, outcome: String, now: float, half_life: float, weight: float = 1.0) -> void:
	var b := _bucket(table, ctx, now, half_life)
	b.w[outcome] = float(b.w.get(outcome, 0.0)) + weight


## Lo que cree que va a pasar en ese contexto: {"outcome", "p" (parte del más común), "n" (casos, con decaimiento),
## "conf" (n / (n + k)), "dist" (todas las partes)}. {} si no vio nada.
func predict(table: String, ctx: String, now: float, half_life: float, k: float) -> Dictionary:
	if not _tables.has(table) or not _tables[table].has(ctx):
		return {}
	var b := _bucket(table, ctx, now, half_life)
	var n := 0.0
	var best := ""
	var best_w := 0.0
	for o in b.w:
		n += float(b.w[o])
		if float(b.w[o]) > best_w:
			best_w = float(b.w[o])
			best = o
	if n <= 0.01:
		return {}
	var dist := {}
	for o in b.w:
		dist[o] = float(b.w[o]) / n
	return {"outcome": best, "p": best_w / n, "n": n, "conf": n / (n + maxf(0.1, k)), "dist": dist}


# --- Lo que hacés ---

## Una acción tuya (ficha) entra en las secuencias: bigrama (la anterior → esta), trigrama (las dos anteriores → esta) y
## la frecuencia sola.
func note_action(token: String, now: float, half_life: float) -> void:
	add("uni", "_", token, now, half_life)
	if stream.size() >= 1:
		add("bi", stream[-1], token, now, half_life)
	if stream.size() >= 2:
		add("tri", stream[-2] + ">" + stream[-1], token, now, half_life)
	stream.append(token)
	if stream.size() > MAX_STREAM:
		stream.pop_front()


## Qué vas a hacer ahora: el trigrama si ya vio ese par varias veces, si no el bigrama, si no lo que más hacés.
func predict_next(now: float, half_life: float, k: float) -> Dictionary:
	if stream.size() >= 2:
		var tri := predict("tri", stream[-2] + ">" + stream[-1], now, half_life, k)
		if not tri.is_empty() and float(tri.n) >= 2.0:
			tri["from"] = "trigrama"
			return tri
	if stream.size() >= 1:
		var bi := predict("bi", stream[-1], now, half_life, k)
		if not bi.is_empty() and float(bi.n) >= 1.5:
			bi["from"] = "bigrama"
			return bi
	var uni := predict("uni", "_", now, half_life, k)
	if not uni.is_empty():
		uni["from"] = "frecuencia"
		uni["conf"] = float(uni.conf) * 0.5  # (lo que más hacés no dice cuándo)
	return uni


## Cómo respondiste a un ataque suyo de esta clase ("aviso", "carga", "disparo", "cuerpo", "zona").
func note_response(ctx: String, outcome: String, now: float, half_life: float) -> void:
	add("resp", ctx, outcome, now, half_life)


func predict_response(ctx: String, now: float, half_life: float, k: float) -> Dictionary:
	return predict("resp", ctx, now, half_life, k)


## Qué tan seguido esquivás (rodando o con un paso) cuando él hace eso: la suma de esas respuestas.
func evade_share(ctx: String, now: float, half_life: float, k: float) -> Array:
	var pr := predict_response(ctx, now, half_life, k)
	if pr.is_empty():
		return [0.0, 0.0]
	var s := 0.0
	for o in pr.dist:
		if str(o).begins_with("esq") or str(o).begins_with("paso"):
			s += float(pr.dist[o])
	return [s, float(pr.conf)]


## Atacaste a esta distancia ("cerca", "media", "lejos") con este ataque.
func note_attack_at(band: String, move_id: String, now: float, half_life: float) -> void:
	add("banda", band, move_id, now, half_life)
	add("banda_uso", "_", band, now, half_life)


## A qué distancia atacás más: {"outcome" = banda, "p", "conf"}.
func favorite_band(now: float, half_life: float, k: float) -> Dictionary:
	return predict("banda_uso", "_", now, half_life, k)


# --- Cambios ---

func note_ai_switch(now: float) -> void:
	_ai_switch_at = now


## Cambiaste vos: si fue enseguida después de un cambio suyo, es un contracambio.
func note_switch(now: float, half_life: float) -> void:
	if now - _ai_switch_at <= COUNTER_WINDOW:
		add("contra", "_", "si", now, half_life)
		_ai_switch_at = -100.0


## Él cambió y no le respondiste a tiempo (lo llama quien cambió, pasado COUNTER_WINDOW).
func note_no_counter(now: float, half_life: float) -> void:
	add("contra", "_", "no", now, half_life)


## Probabilidad de que contracambies si él cambia, y su confianza.
func counter_switch(now: float, half_life: float, k: float) -> Array:
	var pr := predict("contra", "_", now, half_life, k)
	if pr.is_empty():
		return [0.0, 0.0]
	return [float(pr.dist.get("si", 0.0)), float(pr.conf)]


func ai_switched_recently(now: float) -> bool:
	return now - _ai_switch_at <= COUNTER_WINDOW


## Lado de un movimiento respecto de la línea de él hacia vos: "izq" / "der" / "atras" / "adelante".
static func side_of(move: Vector2, line: Vector2) -> String:
	if move.length() < 0.1 or line.length() < 0.1:
		return "nada"
	var m := move.normalized()
	var l := line.normalized()
	var along := m.dot(l)
	var across := m.dot(l.orthogonal())
	if absf(across) >= absf(along) * 0.8:
		return "der" if across > 0.0 else "izq"
	return "atras" if along > 0.0 else "adelante"


## Hacia dónde queda un lado ("izq"/"der") en el mundo, visto desde la línea de él hacia vos.
static func side_dir(side: String, line: Vector2) -> Vector2:
	var o := line.normalized().orthogonal()
	return o if side.ends_with("der") else -o
