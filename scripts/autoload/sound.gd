extends Node
## Sonido del juego (autoload `Sound`; pedido del usuario 2026-10-26): música por lugar y por momento (peleas,
## victorias, evolución, Centro...), efectos y gritos de los Pokémon. **Todo sale de archivos con nombre**, así se
## reemplaza poniendo otro archivo con el mismo nombre (ver docs/AUDIO.md):
##   audio/musica/<tema>.ogg|.mp3|.wav    qué tema va dónde: data/audio/musica.json
##   audio/efectos/<efecto>.ogg|.mp3|.wav (golpe_<tipo>, menu_aceptar, bola_lanzar... ver EFFECTS)
##   audio/gritos/<n.º de Pokédex>.ogg     (tools/fetch_cries.py)
## Se busca primero en la carpeta `audio` al lado del .exe (versión portable: ahí cada uno pone su música), después
## en la del proyecto y después en user://audio. Si no hay archivo, no suena nada (nunca rompe).
## Escucha Events (los sistemas no lo llaman, salvo la pantalla de título y las de menú).

const EXTENSIONS := ["ogg", "mp3", "wav"]
const MUSIC_MAP := "res://data/audio/musica.json"
const SETTINGS_PATH := "user://audio.cfg"
const FADE := 0.6
## Efectos que existen (los genera tools/make_sfx.py; se pueden reemplazar).
const EFFECTS := ["menu_mover", "menu_aceptar", "menu_volver", "golpe", "golpe_fuerte", "esquive", "debilitado",
	"bola_lanzar", "bola_sacudir", "bola_captura", "bola_escapa", "puerta", "saltar", "subir_nivel", "dinero",
	"mensaje", "firma", "curacion", "cambio"]

var music_volume := 0.7
var sfx_volume := 0.8
var cry_volume := 0.8
## Tema que está sonando ("" = silencio) y el del lugar (al que se vuelve después de una pelea o una cortina).
var current_track := ""
var place_track := ""
## Momento especial que manda sobre el lugar ("batalla_salvaje", "evolucion"...); "" = la música del lugar.
var override_track := ""

var _map: Dictionary = {}
var _music: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _jingle: AudioStreamPlayer
var _sfx: Array[AudioStreamPlayer] = []
var _cache: Dictionary = {}  # "carpeta/nombre" -> AudioStream (o null si no hay archivo)
var _tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # el menú pausa el árbol: la música y los menús siguen sonando
	_map = JSON.parse_string(FileAccess.get_file_as_string(MUSIC_MAP)) if FileAccess.file_exists(MUSIC_MAP) else {}
	if not (_map is Dictionary):
		_map = {}
	_load_settings()
	_music = _player("Música")
	_music_b = _player("Música")
	_jingle = _player("Música")
	_jingle.finished.connect(_on_jingle_finished)
	for i in 8:
		_sfx.append(_player("Efectos"))
	_connect_events()
	get_tree().node_added.connect(_on_node_added)


func _player(bus_name: String) -> AudioStreamPlayer:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	var p := AudioStreamPlayer.new()
	p.bus = bus_name
	add_child(p)
	return p


# --- Archivos ----------------------------------------------------------------------------

## Las carpetas donde se buscan los archivos, en orden.
func folders(kind: String) -> PackedStringArray:
	var out := PackedStringArray()
	out.append(OS.get_executable_path().get_base_dir().path_join("audio").path_join(kind))
	out.append("res://audio/" + kind)
	out.append("user://audio/" + kind)
	return out


## El audio `name` de la carpeta `kind` (musica, efectos, gritos), o null si no hay archivo.
func stream(kind: String, name: String) -> AudioStream:
	var key := kind + "/" + name
	if _cache.has(key):
		return _cache[key]
	var found: AudioStream = null
	for dir in folders(kind):
		for ext in EXTENSIONS:
			var path := dir.path_join("%s.%s" % [name, ext])
			found = _load(path)
			if found != null:
				break
		if found != null:
			break
	_cache[key] = found
	return found


func _load(path: String) -> AudioStream:
	if path.begins_with("res://"):
		return load(path) if ResourceLoader.exists(path) else null
	if not FileAccess.file_exists(path):
		return null
	match path.get_extension().to_lower():
		"ogg":
			return AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			var mp3 := AudioStreamMP3.new()
			mp3.data = FileAccess.get_file_as_bytes(path)
			return mp3
		"wav":
			return AudioStreamWAV.load_from_file(path)
	return null


## Olvida lo cargado (para ver un archivo nuevo sin reiniciar).
func clear_cache() -> void:
	_cache.clear()


# --- Música ------------------------------------------------------------------------------

## Tema de una zona: el de la tabla, si no el del primer patrón que aparezca en su id.
func track_for_zone(zone_id: String) -> String:
	var zones: Dictionary = _map.get("zonas", {})
	if zones.has(zone_id):
		return zones[zone_id]
	for row in _map.get("patrones", []):
		if zone_id.contains(str(row[0])):
			return str(row[1])
	return ""


## Tema de un momento ("batalla_salvaje", "victoria_lider"...).
func track_for_event(event: String) -> String:
	return _map.get("eventos", {}).get(event, event)


## El tema que de verdad suena: el pedido si tiene archivo; si no, sus respaldos.
func resolve(track: String) -> String:
	var seen := {}
	while track != "" and not seen.has(track):
		seen[track] = true
		if stream("musica", track) != null:
			return track
		track = str(_map.get("respaldos", {}).get(track, ""))
	return ""


func is_jingle(track: String) -> bool:
	return track in _map.get("cortinas", [])


## Pone un tema (con fundido). "" = silencio.
func play_music(track: String) -> void:
	var real := resolve(track)
	if real == current_track:
		return
	current_track = real
	var s := stream("musica", real) if real != "" else null
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var old := _music
	_music = _music_b
	_music_b = old
	_tween = create_tween().set_parallel()
	if old.playing:
		_tween.tween_property(old, "volume_db", -40.0, FADE)
		_tween.chain().tween_callback(old.stop)
	if s != null:
		_set_loop(s, true)
		_music.stream = s
		_music.volume_db = -40.0
		_music.play()
		create_tween().tween_property(_music, "volume_db", 0.0, FADE)


## Una cortina corta (victoria, captura, curación): baja la música, suena una vez y después sigue lo que había.
func play_jingle(track: String) -> void:
	var real := resolve(track)
	var s := stream("musica", real) if real != "" else null
	if s == null:
		return
	_set_loop(s, false)
	_jingle.stream = s
	_jingle.play()
	_music.stream_paused = true


func _on_jingle_finished() -> void:
	_music.stream_paused = false


func _set_loop(s: AudioStream, on: bool) -> void:
	if s is AudioStreamOggVorbis or s is AudioStreamMP3:
		s.loop = on
	elif s is AudioStreamWAV:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD if on else AudioStreamWAV.LOOP_DISABLED
		if on and s.loop_end <= 0:
			s.loop_end = int(s.get_length() * s.mix_rate)


## Vuelve a la música del lugar (o del momento especial si hay uno).
func refresh_music() -> void:
	play_music(override_track if override_track != "" else place_track)


func set_place(track: String) -> void:
	place_track = track
	refresh_music()


func set_override(track: String) -> void:
	override_track = track
	refresh_music()


# --- Efectos y gritos ----------------------------------------------------------------------

## Un efecto (por nombre; ver EFFECTS). `pitch` varía el tono (para que no suene siempre igual).
func sfx(name: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var s := stream("efectos", name)
	if s == null:
		return
	var p := _free_player()
	p.stream = s
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()


## El grito de una especie (por su n.º de Pokédex). `pitch` < 1 = más grave (al debilitarse).
func cry(species: SpeciesData, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if species == null:
		return
	var s := stream("gritos", str(species.dex))
	if s == null:
		return
	var p := _free_player()
	p.stream = s
	p.pitch_scale = pitch
	p.volume_db = volume_db + linear_to_db(maxf(0.001, cry_volume / maxf(0.001, sfx_volume)))
	p.play()


func _free_player() -> AudioStreamPlayer:
	for p in _sfx:
		if not p.playing:
			return p
	return _sfx[0]


# --- Volumen (global, no por partida) -------------------------------------------------------------

func set_volumes(music: float, effects: float, cries: float) -> void:
	music_volume = clampf(music, 0.0, 1.0)
	sfx_volume = clampf(effects, 0.0, 1.0)
	cry_volume = clampf(cries, 0.0, 1.0)
	_apply_volumes()
	var cfg := ConfigFile.new()
	cfg.set_value("volumen", "musica", music_volume)
	cfg.set_value("volumen", "efectos", sfx_volume)
	cfg.set_value("volumen", "gritos", cry_volume)
	cfg.save(SETTINGS_PATH)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		music_volume = cfg.get_value("volumen", "musica", music_volume)
		sfx_volume = cfg.get_value("volumen", "efectos", sfx_volume)
		cry_volume = cfg.get_value("volumen", "gritos", cry_volume)
	call_deferred("_apply_volumes")


func _apply_volumes() -> void:
	for pair in [["Música", music_volume], ["Efectos", sfx_volume]]:
		var i := AudioServer.get_bus_index(pair[0])
		if i != -1:
			AudioServer.set_bus_volume_db(i, linear_to_db(maxf(0.0001, pair[1])))
			AudioServer.set_bus_mute(i, pair[1] <= 0.001)


# --- Eventos del juego ---------------------------------------------------------------------

func _connect_events() -> void:
	Events.zone_entered.connect(func(z: ZoneEntry): set_place(track_for_zone(z.id)))
	Events.battle_started.connect(_on_battle_started)
	Events.battle_ended.connect(_on_battle_ended)
	Events.trainer_battle_started.connect(func(kind: String): set_override(track_for_event("batalla_" + kind)))
	Events.trainer_battle_ended.connect(_on_trainer_battle_ended)
	Events.evolution_ready.connect(func(_i, _t, _c): set_override(track_for_event("evolucion")))
	Events.evolved.connect(func(_i, _f, _t):
		override_track = ""
		refresh_music()
		play_jingle(track_for_event("evolucion_fin")))
	Events.party_healed.connect(func(): play_jingle(track_for_event("curacion")))
	Events.pokemon_caught.connect(func(_i, _w):
		sfx("bola_captura")
		play_jingle(track_for_event("captura")))
	Events.level_up.connect(func(_i): play_jingle(track_for_event("subir_nivel")))
	Events.creature_damaged.connect(_on_damaged)
	Events.creature_fainted.connect(_on_fainted)
	Events.wild_aggro.connect(_on_aggro)
	Events.warped.connect(func(_a, _b): sfx("puerta"))
	Events.ledge_jumped.connect(func(): sfx("saltar"))
	Events.ball_thrown.connect(func(): sfx("bola_lanzar"))
	Events.ball_shook.connect(func(): sfx("bola_sacudir"))
	Events.capture_escaped.connect(func(): sfx("bola_escapa"))
	Events.money_changed.connect(func(_m): sfx("dinero", -6.0))
	Events.signature_triggered.connect(func(_c, _t, _col): sfx("firma", -8.0))
	Events.companion_out.connect(_on_companion_out)


func _on_fainted(c) -> void:
	if c is Creature and c.instance != null:
		cry(c.instance.species, 0.75)
		sfx("debilitado")


func _on_aggro(w, _target) -> void:
	if w is Creature and w.instance != null:
		cry(w.instance.species, 1.0, -4.0)


func _on_companion_out(inst) -> void:
	if inst != null:
		cry(inst.species)


func _on_battle_started() -> void:
	# Las peleas de entrenador ponen su propia música (trainer_battle_started); esta es la de los salvajes.
	if override_track == "":
		set_override(track_for_event("batalla_salvaje"))


func _on_battle_ended() -> void:
	if override_track == track_for_event("batalla_salvaje"):
		override_track = ""
		refresh_music()


func _on_trainer_battle_ended(result: String, kind: String) -> void:
	override_track = ""
	refresh_music()
	if result == "win":
		play_jingle(track_for_event("victoria_lider" if kind in ["lider", "torneo"] else "victoria_entrenador"))


func _on_damaged(c, amount: float, hit: HitInfo) -> void:
	if hit == null or hit.move == null or amount <= 0.0:
		return
	var el: String = hit.move.element.id if hit.move.element != null else ""
	var strong: bool = c is Creature and c.instance != null and amount > c.instance.max_hp() * 0.2
	var name := "golpe_" + el
	if stream("efectos", name) == null:
		name = "golpe_fuerte" if strong else "golpe"
	sfx(name, -2.0 if strong else -5.0, randf_range(0.95, 1.05))


## Sonido de los menús: todo botón suena al apretarlo, y moverse con el teclado entre botones también.
func _on_node_added(n: Node) -> void:
	if n is BaseButton:
		n.pressed.connect(func(): sfx("menu_aceptar", -6.0))
		n.focus_entered.connect(func(): if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): sfx("menu_mover", -12.0))
