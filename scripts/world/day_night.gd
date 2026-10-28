class_name DayNight
extends Node
## Día y noche (docs/PLAN_DIA_NOCHE.md, parte A; referencias en docs/referencias/iluminacion/).
## Hace correr la hora del juego (GameState.time_of_day, 1 hora = SECONDS_PER_HOUR segundos reales; el ajuste
## "time_lock" la deja fija) y, según la hora, pinta el mundo: color del CanvasModulate "Daylight", gradación y luz
## de esquina con rayos del post-procesado, sombras de nubes. Interiores y arenas: luz pareja, sin hora.
## Para los demás (sombras de la parte B, luces de ataques de la D): `darkness`, `shadow_direction`,
## `shadow_length`, `shadow_alpha` y la señal Events.time_changed(hour, phase).

const SECONDS_PER_HOUR := 60.0  # decisión del usuario: un día = 24 min reales
## Cada cuántas horas del juego se avisa por Events.time_changed (además de al cambiar de fase).
const EMIT_STEP := 0.1
const PHASES := [[5.0, "amanecer"], [7.0, "dia"], [17.5, "atardecer"], [20.0, "noche"]]

## Cómo se ve cada hora (se interpola entre filas; la de las 24 = la de las 0). sun = dónde está la luz en la
## pantalla (0-1, puede caer afuera); las sombras van para el lado contrario.
## [hora, color del Daylight, tinte, saturación, contraste, viñeta, sol (posición), color del sol, fuerza, rayos,
##  largo de sombra, opacidad de sombra, nubes]
const KEYS := [
	[0.0, Color(0.58, 0.64, 0.80), Vector3(0.97, 1.00, 1.04), 0.72, 1.06, 0.44, Vector2(0.85, -0.15), Color(0.85, 0.90, 1.0), 0.30, 0.18, 1.4, 0.45, 0.0],
	[4.5, Color(0.58, 0.63, 0.79), Vector3(0.97, 1.00, 1.03), 0.74, 1.06, 0.44, Vector2(1.00, 0.05), Color(0.85, 0.90, 1.0), 0.26, 0.14, 1.6, 0.40, 0.0],
	[6.0, Color(0.86, 0.80, 0.84), Vector3(1.03, 0.98, 0.98), 1.05, 1.05, 0.40, Vector2(1.15, 0.25), Color(1.0, 0.72, 0.58), 0.34, 0.35, 3.0, 0.55, 0.4],
	[7.5, Color(0.99, 0.95, 0.89), Vector3(1.04, 1.00, 0.94), 1.20, 1.06, 0.34, Vector2(1.00, -0.05), Color(1.0, 0.86, 0.62), 0.36, 0.45, 1.8, 0.75, 0.9],
	[12.0, Color(1.00, 0.98, 0.95), Vector3(1.04, 1.01, 0.93), 1.28, 1.06, 0.32, Vector2(0.10, -0.20), Color(1.0, 0.90, 0.66), 0.38, 0.40, 1.0, 0.80, 1.0],
	[16.5, Color(1.00, 0.96, 0.89), Vector3(1.05, 1.00, 0.92), 1.25, 1.06, 0.34, Vector2(-0.10, 0.05), Color(1.0, 0.82, 0.55), 0.40, 0.45, 1.8, 0.80, 1.0],
	[18.5, Color(1.00, 0.88, 0.80), Vector3(1.05, 0.97, 0.94), 1.12, 1.07, 0.40, Vector2(-0.15, 0.25), Color(1.0, 0.66, 0.38), 0.50, 0.60, 3.2, 0.70, 0.6],
	[20.0, Color(0.70, 0.64, 0.80), Vector3(0.99, 0.97, 1.03), 0.85, 1.07, 0.44, Vector2(-0.20, 0.40), Color(0.90, 0.60, 0.68), 0.16, 0.10, 3.6, 0.35, 0.1],
	[21.5, Color(0.58, 0.64, 0.80), Vector3(0.97, 1.00, 1.04), 0.72, 1.06, 0.44, Vector2(0.75, -0.20), Color(0.85, 0.90, 1.0), 0.30, 0.18, 1.3, 0.45, 0.0],
	[24.0, Color(0.58, 0.64, 0.80), Vector3(0.97, 1.00, 1.04), 0.72, 1.06, 0.44, Vector2(0.85, -0.15), Color(0.85, 0.90, 1.0), 0.30, 0.18, 1.4, 0.45, 0.0],
]
## La luz pareja de los interiores y las arenas (la de siempre, sin sol).
const INDOOR := [12.0, Color(1.00, 0.98, 0.95), Vector3(1.04, 1.01, 0.93), 1.28, 1.06, 0.32, Vector2(0.15, -0.25), Color(1.0, 0.90, 0.65), 0.0, 0.0, 1.0, 0.80, 0.0]
## Las cuevas (bioma "cueva"): oscuras y frías (pedido del usuario 2026-10-28); alumbran las antorchas y los cristales
## (CaveLights) y una luz chica alrededor del entrenador (CAVE_PLAYER_LIGHT).
const CAVE := [0.0, Color(0.30, 0.36, 0.50), Vector3(0.94, 1.00, 1.10), 0.88, 1.10, 0.62, Vector2(0.5, -0.5), Color(0.6, 0.7, 1.0), 0.0, 0.0, 1.0, 0.0, 0.0]
const CAVE_PLAYER_LIGHT := Color(0.80, 0.88, 1.0)
const CAVE_PLAYER_ENERGY := 0.38
const CAVE_PLAYER_RADIUS := 64.0
## Lo que se ve afuera del mapa (el vacío): en las cuevas, casi negro.
const CAVE_CLEAR := Color(0.02, 0.02, 0.04)
## Daylight más claro que el de la noche (para medir la oscuridad). La noche es luz de luna plateada (pedido del
## usuario 2026-10-28: "demasiado azulado oscuro"), con un brillo suave desde arriba a la derecha.
const NIGHT_LUMA := 0.63
const DAY_LUMA := 0.98

## 0 = pleno día, 1 = noche cerrada (0 en interiores y arenas).
var darkness := 0.0
## Hay sombras largas (afuera, fuera de las arenas): ZoneShadows y SunShadow.
var casts_shadows := false
## Color de las sombras (azul violáceo, como en las referencias; el Daylight lo oscurece de noche).
var shadow_color := Color(0.16, 0.13, 0.32)
## Hacia dónde caen las sombras (unitario, en pantalla/mundo) y cuánto se estiran (1 = mediodía).
var shadow_direction := Vector2(0.6, 0.8)
var shadow_length := 1.0
var shadow_alpha := 0.8
## Interior, cueva o arena: sin hora.
var indoor := false
## Cueva (bioma "cueva"): oscura aunque sea de día.
var in_cave := false
var phase := ""

var _world: Node
var _last_emit := -1.0
var _player_light: PointLight2D


func _ready() -> void:
	_world = get_parent()
	Events.zone_entered.connect(_enter)
	var here: ZoneEntry = _world.streamer.current if _world.get("streamer") else null
	if here != null:
		_enter(here)
	phase = phase_of(hour())
	apply()


func _process(delta: float) -> void:
	var lock := float(GameState.setting("time_lock"))
	if lock >= 0.0:
		GameState.time_of_day = fposmod(lock, 24.0)
	else:
		GameState.time_of_day = fposmod(GameState.time_of_day + delta / SECONDS_PER_HOUR, 24.0)
	apply()


func _enter(z: ZoneEntry) -> void:
	indoor = z.interior
	in_cave = z.biome == "cueva"


func hour() -> float:
	return GameState.time_of_day


static func phase_of(h: float) -> String:
	var name: String = PHASES[-1][1]
	for p in PHASES:
		if h >= p[0]:
			name = p[1]
	return name


## La fila de KEYS interpolada para esa hora.
static func look_at(h: float) -> Array:
	h = fposmod(h, 24.0)
	for i in range(KEYS.size() - 1):
		var a: Array = KEYS[i]
		var b: Array = KEYS[i + 1]
		if h <= b[0]:
			var t := smoothstep(0.0, 1.0, (h - a[0]) / (b[0] - a[0]))
			var out := []
			for k in a.size():
				out.append(lerp(a[k], b[k], t))
			return out
	return KEYS[0]


## Pinta el mundo según la hora (o la luz pareja) y avisa si corresponde.
func apply() -> void:
	var h := hour()
	var arena_on: bool = _world.get("arena") != null and _world.arena.active
	casts_shadows = not indoor and not arena_on
	var cave := in_cave and not arena_on
	var lk: Array = CAVE if cave else (INDOOR if not casts_shadows else look_at(h))
	_update_player_light(cave)
	RenderingServer.set_default_clear_color(CAVE_CLEAR if cave
		else ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color"))
	var daylight := _world.get_node_or_null("Daylight") as CanvasModulate
	if daylight:
		daylight.color = lk[1]
	var screen := _world.get_node_or_null("PostProcess/Screen") as ColorRect
	if screen and screen.material is ShaderMaterial:
		var m: ShaderMaterial = screen.material
		m.set_shader_parameter("tint", lk[2])
		m.set_shader_parameter("saturation", lk[3])
		m.set_shader_parameter("contrast", lk[4])
		m.set_shader_parameter("vignette", lk[5])
		m.set_shader_parameter("sun_pos", lk[6])
		m.set_shader_parameter("sun_color", Vector3(lk[7].r, lk[7].g, lk[7].b))
		m.set_shader_parameter("sun_strength", lk[8])
		m.set_shader_parameter("rays", lk[9])
	var clouds := _world.get_node_or_null("CloudShadows") as CanvasItem
	if clouds:
		clouds.modulate.a = lk[12]
	var luma: float = lk[1].get_luminance()
	darkness = clampf((DAY_LUMA - luma) / (DAY_LUMA - NIGHT_LUMA), 0.0, 1.0)  # en las cuevas, 1
	shadow_direction = (Vector2(0.5, 0.5) - lk[6]).normalized()
	shadow_length = lk[10]
	shadow_alpha = lk[11]
	var now := phase_of(h)
	var stepped := absf(h - _last_emit) >= EMIT_STEP and absf(h - _last_emit) < 24.0 - EMIT_STEP
	if now != phase or stepped or _last_emit < 0.0:
		phase = now
		_last_emit = h
		Events.time_changed.emit(h, now)


## Luz chica y fría alrededor del entrenador en las cuevas (si no, no se ve el camino entre antorcha y antorcha).
func _update_player_light(on: bool) -> void:
	var trainer: Node2D = _world.get("trainer")
	if trainer == null:
		return
	if _player_light == null or not is_instance_valid(_player_light):
		_player_light = PointLight2D.new()
		_player_light.name = "CaveLight"
		_player_light.texture = CaveLights.light_texture()
		_player_light.texture_scale = CAVE_PLAYER_RADIUS * 2.0 / _player_light.texture.get_width()
		_player_light.color = CAVE_PLAYER_LIGHT
		_player_light.energy = CAVE_PLAYER_ENERGY
		_player_light.position = Vector2(0, -10)
		trainer.add_child(_player_light)
	_player_light.visible = on
