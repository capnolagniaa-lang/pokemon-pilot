class_name NpcProp
extends Node2D
## Algo que una persona tiene en la mano (`NpcData.prop`; pedido del usuario 2026-11-08: el empleado de la Tienda en la
## Ruta 1 fumándose un porro). Dibujado por código, chiquito como los sprites de FireRed, y sigue hacia dónde mira la
## persona (StoryNPC.facing). Tipos: "porro" (papel, brasa que titila, humo que sube y cada tanto una pitada: la brasa se
## aviva y sale una nube de la boca).

const PUFF_MIN := 3.5
const PUFF_MAX := 7.0
## Desde que se aviva la brasa hasta que larga el humo por la boca.
const EXHALE_DELAY := 0.7
const SMOKE := Color(0.82, 0.84, 0.86)
const PAPER := Color(0.96, 0.94, 0.88)
const EMBER := Color(1.0, 0.42, 0.12)
const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")
## (Para el test de la sacudida de cabeza de StoryNPC: un poco menos que StoryNPC.SHAKE.)
const SHAKE_TEST := 0.08

var kind := "porro"
var npc: Node2D
var _puff_in := 0.0
var _exhale_in := -1.0
var _glow := 0.0
var _time := 0.0
var _smoke: CPUParticles2D
var _cloud: CPUParticles2D
var _light: PointLight2D
## Cuántas pitadas dio (lo lee el test).
var puffs := 0


func setup(p_kind: String, p_npc: Node2D) -> void:
	kind = p_kind
	npc = p_npc


func _ready() -> void:
	_puff_in = randf_range(1.0, PUFF_MAX)
	_smoke = _particles(12, 2.6, 2.5, 4.0)  # el hilito de la brasa (tamaño en px)
	_smoke.direction = Vector2(0.15, -1.0)
	_smoke.spread = 12.0
	_smoke.initial_velocity_min = 4.0
	_smoke.initial_velocity_max = 7.0
	_cloud = _particles(16, 2.0, 6.0, 10.0)  # la nube de la pitada
	_cloud.emitting = false
	_cloud.one_shot = true
	_cloud.explosiveness = 0.85
	_cloud.direction = Vector2(0.4, -1.0)
	_cloud.spread = 40.0
	_cloud.initial_velocity_min = 6.0
	_cloud.initial_velocity_max = 14.0
	_light = PointLight2D.new()  # (de noche la brasa se ve; energía baja: las luces saturan el suelo claro)
	_light.texture = LIGHT_TEX
	_light.texture_scale = 0.1
	_light.color = EMBER
	_light.energy = 0.2
	add_child(_light)


## `size_min`/`size_max` = diámetro de cada bocanada en px (la textura suave es de 64 px).
func _particles(amount: int, life: float, size_min: float, size_max: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = LIGHT_TEX
	p.amount = amount
	p.lifetime = life
	p.local_coords = false  # el humo queda en el aire aunque se dé vuelta
	p.gravity = Vector2(2.0, -5.0)  # sube y se va un poco con el viento
	p.scale_amount_min = size_min / 64.0
	p.scale_amount_max = size_max / 64.0
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.6))
	grow.add_point(Vector2(1.0, 2.2))
	p.scale_amount_curve = grow
	var ramp := Gradient.new()
	ramp.set_color(0, Color(SMOKE, 0.0))
	ramp.add_point(0.12, Color(SMOKE, 0.7))
	ramp.add_point(0.6, Color(SMOKE, 0.35))
	ramp.set_color(1, Color(SMOKE, 0.0))
	p.color_ramp = ramp
	p.z_index = 2
	add_child(p)
	return p


func _process(delta: float) -> void:
	_time += delta
	_puff_in -= delta
	if _puff_in <= 0.0:
		_puff_in = randf_range(PUFF_MIN, PUFF_MAX)
		_glow = 1.0
		_exhale_in = EXHALE_DELAY
		puffs += 1
	if _exhale_in >= 0.0:
		_exhale_in -= delta
		if _exhale_in < 0.0:
			_cloud.global_position = global_position + _mouth()
			_cloud.restart()
	_glow = maxf(0.0, _glow - delta * 0.8)
	var tip := _tip()
	_smoke.position = tip
	_light.position = tip
	_light.energy = 0.15 + 0.25 * _glow + 0.04 * sin(_time * 9.0)
	queue_redraw()


## Hacia dónde mira la persona (abajo por defecto).
func _facing() -> Vector2i:
	return npc.facing if npc != null and "facing" in npc else Vector2i.DOWN


## La mano (relativa a los pies): a un costado del cuerpo; mirando de perfil, adelante.
func _hand() -> Vector2:
	var f := _facing()
	if f.x != 0:
		return Vector2(6.0 * f.x, -12.0)
	return Vector2(6.0, -11.0) if f.y >= 0 else Vector2(-6.0, -12.0)


func _tip() -> Vector2:
	var f := _facing()
	return _hand() + Vector2(3.0 * (f.x if f.x != 0 else 1), -1.0)


func _mouth() -> Vector2:
	var f := _facing()
	return Vector2(3.0 * f.x, -21.0) if f.x != 0 else Vector2(0.0, -21.0 if f.y >= 0 else -23.0)


func _draw() -> void:
	if kind != "porro":
		return
	var f := _facing()
	if f.y < 0 and f.x == 0:
		return  # de espaldas: el porro queda adelante del cuerpo, no se ve (el humo sí)
	var hand := _hand()
	var tip := _tip()
	draw_line(hand, tip, PAPER, 1.5)  # el porro (un poquito en punta: más fino atrás)
	draw_line(hand, hand + (tip - hand) * 0.35, Color(0.85, 0.8, 0.66), 1.0)
	var ember := EMBER.lerp(Color(1.0, 0.85, 0.4), _glow)
	ember.a = 0.75 + 0.25 * sin(_time * 11.0) * 0.5 + 0.25 * _glow
	draw_rect(Rect2(tip - Vector2(0.5, 1.0), Vector2(1.5, 1.5)), ember)
