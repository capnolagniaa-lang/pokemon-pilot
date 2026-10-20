extends SceneTree
## Genera el arte provisorio: atlas de tiles (con variantes de estado) y el entrenador.
## Uso: godot --headless --path . --script res://tools/gen_art.gd
## El layout del atlas tiene que coincidir con tools/build_world.gd.

const T := 16

var img: Image
var rng := RandomNumberGenerator.new()


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/tiles"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/characters"))
	_make_tiles().save_png(ProjectSettings.globalize_path("res://art/tiles/tileset.png"))
	_make_trainer().save_png(ProjectSettings.globalize_path("res://art/characters/trainer.png"))
	print("Arte generado.")
	quit()


# --- Tiles -----------------------------------------------------------------

func _make_tiles() -> Image:
	img = Image.create(8 * T, 4 * T, false, Image.FORMAT_RGBA8)
	rng.seed = 1234
	_grass(0, 0)
	_grass(1, 0)
	_flowers(1, 0)
	_tall_grass(2, 0)
	_speckled(3, 0, Color8(214, 186, 128), [Color8(190, 160, 104), Color8(232, 208, 152)], [0.15, 0.08])
	_water(4, 0)
	_rock(5, 0, Color8(150, 150, 160), false)
	_rock(6, 0, Color8(160, 140, 120), true)
	_speckled(7, 0, Color8(232, 216, 160), [Color8(212, 196, 136), Color8(244, 232, 188)], [0.15, 0.08])
	_tree(0, 1)
	_speckled(2, 1, Color8(72, 64, 56), [Color8(96, 88, 80), Color8(50, 44, 40)], [0.2, 0.15])  # quemado
	_wet(3, 1)
	_ice(4, 1)
	_rubble(5, 1)
	_vines(6, 1)
	return img


func _px(cx: int, cy: int, x: int, y: int, c: Color) -> void:
	if x >= 0 and x < T and y >= 0 and y < T:
		img.set_pixel(cx * T + x, cy * T + y, c)


func _speckled(cx: int, cy: int, base: Color, cols: Array, dens: Array) -> void:
	for y in T:
		for x in T:
			var c := base
			for i in cols.size():
				if rng.randf() < dens[i]:
					c = cols[i]
			_px(cx, cy, x, y, c)


func _grass(cx: int, cy: int) -> void:
	_speckled(cx, cy, Color8(104, 176, 72), [Color8(88, 152, 60), Color8(128, 200, 88)], [0.12, 0.05])
	for i in 4:
		var x := rng.randi_range(1, 13)
		var y := rng.randi_range(2, 14)
		_px(cx, cy, x, y, Color8(72, 136, 56))
		_px(cx, cy, x + 2, y, Color8(72, 136, 56))
		_px(cx, cy, x + 1, y + 1, Color8(72, 136, 56))


func _flowers(cx: int, cy: int) -> void:
	var cols := [Color8(232, 72, 72), Color8(248, 216, 64), Color8(248, 248, 248)]
	for p in [Vector2i(3, 3), Vector2i(11, 6), Vector2i(5, 11)]:
		var c: Color = cols[rng.randi() % cols.size()]
		for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			_px(cx, cy, p.x + o.x, p.y + o.y, c)
		_px(cx, cy, p.x, p.y, Color8(248, 232, 120))


func _tall_grass(cx: int, cy: int) -> void:
	_speckled(cx, cy, Color8(64, 136, 52), [Color8(56, 120, 44)], [0.15])
	for row in 4:
		for col in 4:
			var x0 := col * 4 + (row % 2) * 2 - 1
			var y0 := row * 4
			var dark := Color8(40, 96, 40)
			var light := Color8(112, 192, 80)
			_px(cx, cy, x0, y0 + 2, dark)
			_px(cx, cy, x0 + 1, y0 + 1, dark)
			_px(cx, cy, x0 + 2, y0, dark)
			_px(cx, cy, x0 + 3, y0 + 1, dark)
			_px(cx, cy, x0 + 4, y0 + 2, dark)
			_px(cx, cy, x0 + 1, y0 + 2, light)
			_px(cx, cy, x0 + 2, y0 + 1, light)
			_px(cx, cy, x0 + 3, y0 + 2, light)
			_px(cx, cy, x0 + 2, y0 + 2, light)


func _water(cx: int, cy: int) -> void:
	_speckled(cx, cy, Color8(64, 128, 216), [Color8(56, 112, 200)], [0.1])
	for i in 5:
		var x := rng.randi_range(0, 12)
		var y := rng.randi_range(1, 14)
		for k in 4:
			_px(cx, cy, x + k, y - (1 if k in [1, 2] else 0), Color8(136, 184, 240))


func _rock(cx: int, cy: int, base: Color, cracked: bool) -> void:
	var center := Vector2(7.5, 8.5)
	for y in T:
		for x in T:
			var d := Vector2((x - center.x) / 7.2, (y - center.y) / 6.8)
			var r := d.length()
			if r > 1.0:
				continue
			var c := base
			if r > 0.85:
				c = Color8(56, 56, 64)
			elif d.x + d.y < -0.6:
				c = base.lightened(0.25)
			elif d.x + d.y > 0.5:
				c = base.darkened(0.25)
			if rng.randf() < 0.08 and r <= 0.85:
				c = c.darkened(0.12)
			_px(cx, cy, x, y, c)
	if cracked:
		var crack := Color8(48, 36, 32)
		var x := 5
		for y in range(3, 14):
			_px(cx, cy, x, y, crack)
			x += 1 if y % 3 == 0 else (-1 if y % 4 == 0 else 0)
		for k in 4:
			_px(cx, cy, 6 + k, 8 + (k % 2), crack)


func _tree(cx: int, cy: int) -> void:
	# Árbol de 2x2 tiles (32x32) a partir de (cx, cy).
	for y in 32:
		for x in 32:
			var tx := cx + x / T
			var ty := cy + y / T
			var lx := x % T
			var ly := y % T
			var canopy := Vector2((x - 15.5) / 14.5, (y - 12.5) / 12.5)
			var r := canopy.length()
			var c := Color(0, 0, 0, 0)
			if x >= 12 and x <= 19 and y >= 22:
				c = Color8(112, 72, 40) if x > 12 and x < 19 else Color8(64, 40, 24)
			if r <= 1.0:
				c = Color8(40, 112, 56)
				if r > 0.9:
					c = Color8(24, 72, 40)
				elif canopy.x + canopy.y < -0.5:
					c = Color8(72, 156, 76)
				if rng.randf() < 0.12 and r <= 0.9:
					c = Color8(32, 96, 48)
			if c.a > 0.0:
				_px(tx, ty, lx, ly, c)


func _wet(cx: int, cy: int) -> void:
	_speckled(cx, cy, Color8(72, 140, 96), [Color8(60, 120, 88), Color8(120, 170, 200)], [0.12, 0.08])


func _ice(cx: int, cy: int) -> void:
	_speckled(cx, cy, Color8(176, 224, 240), [Color8(150, 200, 228)], [0.1])
	for i in 4:
		var x := rng.randi_range(0, 10)
		var y := rng.randi_range(0, 10)
		for k in 5:
			_px(cx, cy, x + k, y + k, Color8(248, 252, 255))


func _rubble(cx: int, cy: int) -> void:
	for i in 7:
		var p := Vector2i(rng.randi_range(2, 13), rng.randi_range(4, 13))
		var c := Color8(130, 130, 140)
		_px(cx, cy, p.x, p.y, c)
		_px(cx, cy, p.x + 1, p.y, c.darkened(0.3))
		_px(cx, cy, p.x, p.y + 1, c.darkened(0.3))


func _vines(cx: int, cy: int) -> void:
	for y in T:
		for x in T:
			var d := Vector2((x - 7.5) / 7.5, (y - 8.0) / 7.5).length()
			if d <= 1.0 and rng.randf() < 0.85:
				var c := Color8(48, 128, 48) if rng.randf() < 0.6 else Color8(88, 168, 64)
				if d > 0.85:
					c = Color8(24, 72, 32)
				_px(cx, cy, x, y, c)


# --- Entrenador ------------------------------------------------------------
# Hoja de 3 columnas (quieto, paso A, paso B) x 4 filas (abajo, izquierda, derecha, arriba), frames de 16x20.

const PALETTE := {
	"k": Color8(40, 32, 40), "r": Color8(216, 48, 48), "w": Color8(248, 248, 248),
	"s": Color8(248, 200, 160), "h": Color8(88, 56, 40), "b": Color8(64, 104, 200),
	"d": Color8(48, 56, 96), "g": Color8(96, 96, 104),
}

const DOWN_HALF := ["........", ".....kkk", "....krrr", "...krrrw", "...krrrr", "..kkkkkk", "..khssss", "..khskss",
	"..khssss", "...kksss", "..kbbbbw", ".ksbbbbw", ".ksbbbbb", "..kkbbbb", "...kdddd", "...kdddd"]
const UP_HALF := ["........", ".....kkk", "....krrr", "...krrrr", "...krrrr", "..kkkkkk", "..khhhhh", "..khhhhh",
	"..khhhhh", "...kkhhh", "..kbbbbb", ".ksbbbbb", ".ksbbbbb", "..kkbbbb", "...kdddd", "...kdddd"]
const FRONT_LEGS_STAND := ["...kddk..kddk...", "...kddk..kddk...", "...kggk..kggk...", "...kkkk..kkkk..."]
const FRONT_LEGS_STEP := ["...kddk..kddk...", "...kddk..kggk...", "...kggk..kkkk...", "...kkkk........."]
const SIDE_BODY := ["................", "......kkkkk.....", ".....krrrrrk....", "....krrrrwrrk...", "....krrrrrrrkkk.",
	"....kkkkkkkkkkk.", "....khhhssssk...", "....khhssksk....", "....khhsssssk...", ".....khsssk.....",
	".....kbbbbk.....", ".....kbbsbk.....", ".....kbbsbk.....", ".....kbbbbk.....", ".....kddddk.....", ".....kddddk....."]
const SIDE_LEGS_STAND := ["......kddk......", "......kddk......", "......kgggk.....", "......kkkkk....."]
const SIDE_LEGS_A := [".....kdk.kdk....", "....kdk...kdk...", "....kgk...kggk..", "....kkk...kkkk.."]
const SIDE_LEGS_B := ["......kddk......", ".....kddk.......", ".....kgggk......", ".....kkkkk......"]


func _make_trainer() -> Image:
	var sheet := Image.create(16 * 3, 20 * 4, false, Image.FORMAT_RGBA8)
	var down := _mirror_rows(DOWN_HALF)
	var up := _mirror_rows(UP_HALF)
	var front := [FRONT_LEGS_STAND, FRONT_LEGS_STEP, _reverse_rows(FRONT_LEGS_STEP)]
	var side := [SIDE_LEGS_STAND, SIDE_LEGS_A, SIDE_LEGS_B]
	for f in 3:
		_blit(sheet, f, 0, down + front[f], false)
		_blit(sheet, f, 1, SIDE_BODY + side[f], true)
		_blit(sheet, f, 2, SIDE_BODY + side[f], false)
		_blit(sheet, f, 3, up + front[f], false)
	return sheet


func _mirror_rows(half: Array) -> Array:
	var out := []
	for h in half:
		out.append(h + h.reverse())
	return out


func _reverse_rows(rows: Array) -> Array:
	var out := []
	for r in rows:
		out.append(r.reverse())
	return out


func _blit(sheet: Image, col: int, row: int, rows: Array, flip: bool) -> void:
	for y in rows.size():
		var line: String = rows[y]
		for x in 16:
			var ch := line[15 - x] if flip else line[x]
			if PALETTE.has(ch):
				sheet.set_pixel(col * 16 + x, row * 20 + y, PALETTE[ch])
