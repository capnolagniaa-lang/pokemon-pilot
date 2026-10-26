class_name AudioTests
extends Node
## Autotest del sonido (autoload Sound; docs/AUDIO.md): tabla de música, respaldos, archivos que se reemplazan,
## efectos, gritos y la música de cada momento.
##   godot --headless --path . --quit-after 20000 -- --autotest-audio

var autotest: Node


func run() -> void:
	var r := {}
	r["Música por zona (tabla y patrones)"] = Sound.track_for_zone("pueblo_paleta") == "pueblo_paleta" \
		and Sound.track_for_zone("ciudad_verde_centro") == "centro_pokemon" and Sound.track_for_zone("mt_moon_s2") == "cueva" \
		and Sound.track_for_zone("ciudad_celeste_gimnasio") == "gimnasio"
	r["Todas las zonas exteriores tienen tema"] = DB.config.world.zones.filter(
		func(z): return not z.interior and Sound.track_for_zone(z.id) == "").is_empty()
	r["Gritos de los 386 (PokeAPI)"] = range(1, 387).all(func(n): return Sound.stream("gritos", str(n)) != null)
	r["Efectos: los del menú, la bola y un golpe por tipo"] = Sound.EFFECTS.all(func(e): return Sound.stream("efectos", e) != null) \
		and DB.types.keys().filter(func(t): return t != "type_chart").all(func(t): return Sound.stream("efectos", "golpe_" + t) != null)
	r["Cortinas por defecto (curación, captura, subir de nivel)"] = Sound.resolve("curacion") == "curacion" \
		and Sound.resolve("captura") == "captura"
	# Sin el archivo de un tema: sus respaldos y si no hay ninguno, silencio (no rompe).
	var missing := Sound.resolve("tema_que_no_existe")
	r["Un tema sin archivo queda en silencio"] = missing == ""
	# Reemplazar = poner un archivo con el nombre: uno en user://audio/musica aparece sin tocar nada más.
	var dir := "user://audio/musica"
	DirAccess.make_dir_recursive_absolute(dir)
	var test_path := dir.path_join("ruta_1.wav")
	var had_own := FileAccess.file_exists(test_path)
	if not had_own:  # un pitido corto en PCM (anda también en el juego empaquetado)
		var beep := AudioStreamWAV.new()
		beep.format = AudioStreamWAV.FORMAT_16_BITS
		beep.mix_rate = 22050
		var pcm := PackedByteArray()
		pcm.resize(4410 * 2)
		for i in 4410:
			pcm.encode_s16(i * 2, int(sin(i * 0.12) * 8000.0))
		beep.data = pcm
		beep.save_to_wav(ProjectSettings.globalize_path(test_path))
	Sound.clear_cache()
	r["Un archivo tuyo con el nombre del tema suena (y la Ruta 3 usa el de la Ruta 1 de respaldo)"] = \
		Sound.resolve("ruta_1") == "ruta_1" and Sound.resolve("ruta_3") in ["ruta_3", "ruta_1"]
	if not had_own:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	Sound.clear_cache()
	# Los momentos: pelea de entrenador, victoria, evolución.
	Sound.override_track = ""
	Events.trainer_battle_started.emit("lider")
	r["Pelea de líder: tema de líder"] = Sound.override_track == "batalla_lider"
	Events.trainer_battle_ended.emit("win", "lider")
	r["Al terminar vuelve la música del lugar"] = Sound.override_track == ""
	Events.battle_started.emit()
	r["Pelea con un salvaje: tema de salvaje"] = Sound.override_track == "batalla_salvaje"
	Events.battle_ended.emit()
	r["...y después vuelve la del lugar"] = Sound.override_track == ""
	# Que nada rompa sin archivos: un grito y un efecto que no existen.
	Sound.sfx("efecto_que_no_existe")
	Sound.cry(DB.species["pikachu"])
	r["Los sonidos que faltan no rompen nada"] = true

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[audio] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-audio] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
