extends CharacterBody2D
## Base de toda criatura en combate (la del jugador y las salvajes).

signal fainted(creature)

const MAX_ENERGY := 100.0
const ENERGY_REGEN := 22.0
const DASH_SPEED := 720.0
const DODGE_COST := 18.0

var arena: Node2D
var team := 0  # 0 = jugador, 1 = salvaje
var data: Dictionary = {}
var species: Dictionary = {}
var species_name := ""
var level := 1
var max_hp := 1.0
var hp := 1.0
var atk := 10.0
var move_speed := 180.0
var energy := MAX_ENERGY
var moves: Array = []
var cooldowns: Dictionary = {}
var facing := Vector2.RIGHT
var radius := 18.0

var invulnerable_time := 0.0
var shield_time := 0.0
var hurt_flash := 0.0
var dodge_cooldown := 0.0
var dash_time := 0.0
var dash_dir := Vector2.ZERO
var dash_move: Dictionary = {}
var dash_hit: Array = []
var knockback := Vector2.ZERO
var bob := 0.0

const SPRITE_SCALE := 2.0
var anims: Dictionary = {}
var anim_name := "Idle"
var anim_time := 0.0
var attack_anim := 0.0
var hurt_anim := 0.0


func setup(entry: Dictionary, p_team: int) -> void:
	data = entry
	team = p_team
	species_name = entry["species"]
	species = Game.SPECIES[species_name]
	moves = species["moves"]
	for m in moves:
		cooldowns[m] = 0.0
	radius = 16.0 + species["hp"] / 20.0
	refresh_stats()
	hp = clampf(entry.get("hp", max_hp), 0.0, max_hp)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	add_to_group("creatures")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	anims = Game.anims_of(species_name)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Recalcula stats según el nivel (al crear y al subir de nivel).
func refresh_stats() -> void:
	level = data["level"]
	var old_max := max_hp
	max_hp = Game.max_hp_of(data)
	atk = species["atk"] * Game.stat_mult(level)
	move_speed = species["speed"]
	if hp > 0.0 and old_max > 1.0:
		hp = minf(max_hp, hp + (max_hp - old_max))


func _physics_process(delta: float) -> void:
	if hp <= 0.0:
		return
	for k in cooldowns:
		cooldowns[k] = maxf(0.0, cooldowns[k] - delta)
	energy = minf(MAX_ENERGY, energy + ENERGY_REGEN * delta)
	invulnerable_time = maxf(0.0, invulnerable_time - delta)
	shield_time = maxf(0.0, shield_time - delta)
	hurt_flash = maxf(0.0, hurt_flash - delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)

	var dir: Vector2 = _control(delta)
	if dash_time > 0.0:
		dash_time -= delta
		velocity = dash_dir * DASH_SPEED
		if not dash_move.is_empty():
			_check_dash_hits()
	else:
		velocity = dir.limit_length(1.0) * move_speed
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 1600.0 * delta)
	move_and_slide()
	if velocity.length() > 10.0:
		bob += delta * 14.0
	data["hp"] = hp
	_update_anim(delta)
	queue_redraw()


func _update_anim(delta: float) -> void:
	anim_time += delta
	attack_anim = maxf(0.0, attack_anim - delta)
	hurt_anim = maxf(0.0, hurt_anim - delta)
	var want := "Idle"
	if hurt_anim > 0.0:
		want = "Hurt"
	elif attack_anim > 0.0:
		want = "Attack"
	elif velocity.length() > 20.0:
		want = "Walk"
	if want != anim_name and anims.has(want):
		anim_name = want
		anim_time = 0.0


func _play_attack_anim() -> void:
	if not anims.has("Attack"):
		return
	var total := 0
	for d in anims["Attack"]["durations"]:
		total += d
	attack_anim = minf(total / 60.0, 0.45)
	anim_name = "Attack"
	anim_time = 0.0


## Lo implementan las subclases: decide acciones y devuelve la dirección de movimiento.
func _control(_delta: float) -> Vector2:
	return Vector2.ZERO


func can_use(i: int) -> bool:
	if i < 0 or i >= moves.size():
		return false
	var m: Dictionary = Game.MOVES[moves[i]]
	return cooldowns[moves[i]] <= 0.0 and energy >= m["energy"] and dash_time <= 0.0


func use_move(i: int, aim: Vector2) -> bool:
	if hp <= 0.0 or not can_use(i):
		return false
	var id: String = moves[i]
	var m: Dictionary = Game.MOVES[id]
	energy -= m["energy"]
	cooldowns[id] = m["cooldown"]
	if aim.length() > 0.01:
		facing = aim.normalized()
	if m["kind"] != "shield":
		_play_attack_anim()
	match m["kind"]:
		"projectile":
			arena.spawn_projectile(self, m, facing)
		"dash":
			dash_time = m.get("dash_time", 0.22)
			dash_dir = facing
			dash_move = m
			dash_hit.clear()
		"area":
			arena.spawn_area(self, m)
		"shield":
			shield_time = m["duration"]
	return true


## Esquive rápido con un instante de invulnerabilidad.
func dodge(dir: Vector2) -> bool:
	if hp <= 0.0 or dodge_cooldown > 0.0 or dash_time > 0.0 or energy < DODGE_COST:
		return false
	energy -= DODGE_COST
	dodge_cooldown = 0.7
	invulnerable_time = 0.32
	dash_time = 0.16
	dash_dir = dir.normalized() if dir.length() > 0.01 else facing
	dash_move = {}
	return true


## Snapshot del ataque para que el daño no dependa de que el atacante siga vivo.
func make_attack(m: Dictionary) -> Dictionary:
	return {"power": m["power"], "type": m["type"], "atk": atk, "user_type": species["type"]}


func _check_dash_hits() -> void:
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team == team or c.hp <= 0.0 or c in dash_hit:
			continue
		if global_position.distance_to(c.global_position) < radius + c.radius + 10.0:
			dash_hit.append(c)
			c.take_hit(make_attack(dash_move), global_position)
			dash_time = minf(dash_time, 0.05)


func take_hit(attack: Dictionary, from: Vector2) -> void:
	if hp <= 0.0 or invulnerable_time > 0.0:
		return
	var result: Array = Game.calc_damage(attack, species["type"])
	var dmg: float = result[0]
	if shield_time > 0.0:
		dmg *= 0.2
	hp = maxf(0.0, hp - dmg)
	data["hp"] = hp
	hurt_flash = 0.12
	hurt_anim = 0.22
	knockback = (global_position - from).normalized() * 320.0
	arena.on_creature_hit(self, dmg, result[1])
	if hp <= 0.0:
		fainted.emit(self)


## Fila del sprite según hacia dónde mira (PMD: abajo, abajo-der, der, arriba-der, arriba, ...).
func _dir_row() -> int:
	return posmod(int(round((PI / 2.0 - facing.angle()) / (PI / 4.0))), 8)


func _anim_frame(durations: Array, loop: bool) -> int:
	var total := 0
	for d in durations:
		total += d
	var t := int(anim_time * 60.0)
	t = t % total if loop else mini(t, total - 1)
	var acc := 0
	for i in durations.size():
		acc += durations[i]
		if t < acc:
			return i
	return durations.size() - 1


func _draw() -> void:
	var a := 0.45 if invulnerable_time > 0.0 else 1.0
	var tint := Color(1, 0.55, 0.55, a) if hurt_flash > 0.0 else Color(1, 1, 1, a)
	var feet := Vector2(0, 8.0 * SPRITE_SCALE)

	# Sombra y marcador de equipo (azul = tuyo, rojo = salvaje) bajo los pies
	draw_set_transform(feet, 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.25))
	draw_arc(Vector2.ZERO, radius + 2.0, 0.0, TAU, 32, Color(0.3, 0.6, 1.0, 0.9) if team == 0 else Color(1.0, 0.35, 0.3, 0.9), 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var top := -radius - 14.0
	if anims.has(anim_name):
		var anim: Dictionary = anims[anim_name]
		var tex := Game.texture(anim["file"])
		var fw: float = anim["w"]
		var fh: float = anim["h"]
		var frame := _anim_frame(anim["durations"], anim_name == "Idle" or anim_name == "Walk")
		var src := Rect2(frame * fw, _dir_row() * fh, fw, fh)
		var dst := Rect2(-fw * SPRITE_SCALE / 2.0, -fh * SPRITE_SCALE / 2.0, fw * SPRITE_SCALE, fh * SPRITE_SCALE)
		draw_texture_rect_region(tex, dst, src, tint)
		top = -float(anims["Idle"]["h"]) * SPRITE_SCALE / 2.0 if anims.has("Idle") else top
	else:
		draw_circle(Vector2.ZERO, radius, Color(Game.TYPE_COLORS[species["type"]], a))

	if shield_time > 0.0:
		draw_circle(Vector2.ZERO, radius + 14.0, Color(0.55, 0.85, 1.0, 0.25))
		draw_arc(Vector2.ZERO, radius + 14.0, 0.0, TAU, 40, Color(0.6, 0.9, 1.0, 0.9), 2.5)
	if team == 1:
		var w := 48.0
		var r := Rect2(Vector2(-w / 2.0, top - 4.0), Vector2(w, 5))
		draw_rect(r, Color(0, 0, 0, 0.6))
		draw_rect(Rect2(r.position, Vector2(w * hp / max_hp, 5)), Color(0.9, 0.25, 0.2))

