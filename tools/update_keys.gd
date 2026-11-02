extends SceneTree
## Claves y firma de las actualizaciones automáticas (docs/PLAN_ACTUALIZACIONES.md).
##   godot --headless --path . --script res://tools/update_keys.gd -- --init
##       Crea la clave privada (una sola vez) en %USERPROFILE%/.pokemon_pilot/update_private.key y escribe la pública
##       (PEM) en la salida: va en GameUpdater.PUBLIC_KEY (scripts/autoload/updater.gd). Si ya existe, solo la muestra.
##   godot --headless --path . --script res://tools/update_keys.gd -- --sign <update.json> <update.sig>
##       Firma el archivo (RSA + SHA-256) con la clave privada y deja la firma en base64.
## La clave privada no va al repo ni al zip: sin ella nadie puede publicar una actualización que el juego acepte.


static func key_path() -> String:
	var home := OS.get_environment("USERPROFILE")
	if home == "":
		home = OS.get_environment("HOME")
	return home.path_join(".pokemon_pilot").path_join("update_private.key")


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var crypto := Crypto.new()
	if "--init" in args:
		var key := CryptoKey.new()
		if FileAccess.file_exists(key_path()):
			key.load(key_path())
		else:
			DirAccess.make_dir_recursive_absolute(key_path().get_base_dir())
			key = crypto.generate_rsa(2048)
			key.save(key_path())
			print("Clave privada nueva: ", key_path())
		print(key.save_to_string(true))
	elif "--sign" in args:
		var i := args.find("--sign")
		var key := CryptoKey.new()
		if key.load(key_path()) != OK:
			printerr("No está la clave privada (%s): correr --init primero." % key_path())
			quit(1)
			return
		var data := FileAccess.get_file_as_bytes(args[i + 1])
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_SHA256)
		ctx.update(data)
		var sig := crypto.sign(HashingContext.HASH_SHA256, ctx.finish(), key)
		var f := FileAccess.open(args[i + 2], FileAccess.WRITE)
		f.store_string(Marshalls.raw_to_base64(sig))
		f.close()
		print("Firmado: ", args[i + 2])
	else:
		printerr("Uso: --init | --sign <archivo> <firma>")
		quit(1)
		return
	quit(0)
