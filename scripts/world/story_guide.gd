class_name StoryGuide
extends RefCounted
## Guía de la historia (Esc → Guía; pedido del usuario 2026-10-24): en qué parte de la historia estás y qué hacer para
## seguir, según las banderas (GameState.story_flags). Los pasos siguen docs/PLAN_HISTORIA.md / docs/HISTORIA.md.
## Agregar un paso nuevo = sumar una fila a STEPS (en orden); el primero cuya bandera falta es el actual.

## [bandera que lo completa, título, qué hacer]
const STEPS := [
	["oak_te_freno", "Un gran día", "Hablá con tu mamá (abajo, en tu casa) y salí de Pueblo Paleta hacia el norte, por el pasto alto de la Ruta 1."],
	["tiene_inicial", "Tu primer Pokémon", "En el laboratorio de Oak, acercate a la mesa y elegí una de las 3 Poké Balls (E para mirarla)."],
	["rival_lab_peleado", "El primer desafío", "Salí del laboratorio: tu rival Azul te va a frenar para pelear."],
	["tiene_paquete", "Rumbo a Ciudad Verde", "Andá al norte por la Ruta 1 hasta Ciudad Verde y entrá a la Tienda Pokémon (techo azul)."],
	["paquete_entregado", "El correo de Oak", "Llevale el Correo-Oak al Profesor Oak, en su laboratorio de Pueblo Paleta (al sur)."],
	["medalla_roca", "La Medalla Roca", "Ahora el camino al norte de Ciudad Verde está libre: Ruta 2, Bosque Verde y Ciudad Plateada. Entrá al gimnasio y ganale a Brock (tipo roca: el agua y la planta le pegan fuerte)."],
	# Capítulo 2 (docs/PLAN_CAPITULO_2.md)
	["fosil_elegido", "El Mt. Moon", "Seguí al este de Ciudad Plateada por la Ruta 3 hasta el Mt. Moon. En lo más hondo de la cueva el Team Rocket busca fósiles: ganale a Miguel y elegí uno."],
	["rival_celeste_peleado", "Ciudad Celeste", "Salí del Mt. Moon y bajá por la Ruta 4 hasta Ciudad Celeste. Tu rival te espera al norte de la ciudad, camino al Puente Pepita."],
	["medalla_cascada", "La Medalla Cascada", "Ganale a Misty en el gimnasio de Ciudad Celeste (tipo agua: los eléctricos y los de planta le pegan fuerte; el agua de las piletas conduce la electricidad)."],
	# Capítulo 3 (docs/PLAN_CAPITULO_3.md)
	["rival_ss_anne_peleado", "Rumbo al S.S. Anne", "Con el Ticket de Bill, andá al sur de Ciudad Celeste: Ruta 5, la Vía Subterránea y la Ruta 6 hasta Ciudad Carmín. Subí al S.S. Anne en el puerto: tu rival anda por el segundo piso."],
	["tiene_corte", "El capitán mareado", "El capitán del S.S. Anne está en su camarote, al fondo del pasillo del segundo piso. Ayudalo."],
	["surge_puerta_abierta", "Los basureros de Surge", "Con Corte (E frente al árbol fino) entrá al gimnasio de Ciudad Carmín. Buscá los dos interruptores en los basureros: el segundo está al lado del primero."],
	["medalla_trueno", "La Medalla Trueno", "Ganale a Lt. Surge (tipo eléctrico: los de tierra no sienten la electricidad)."],
]
## Cosas que se pueden hacer además: [bandera que la completa, banderas que hacen falta, texto]
const OPTIONAL := [
	["tutorial_captura", ["paquete_entregado"], "En Ciudad Verde, el abuelo que tapaba el camino te enseña a atrapar Pokémon."],
	["tiene_mapa", ["paquete_entregado"], "Dalia, la hermana de tu rival (casa de al lado de la tuya), tiene un regalo para vos."],
	["rival_ruta22_peleado", ["paquete_entregado"], "Tu rival te espera en la Ruta 22, al oeste de Ciudad Verde."],
	["campeon_nv15_3", ["medalla_roca"], "Probá el Torneo de Ciudad Plateada (la puerta del anexo rosa del museo)."],
	["magikarp_comprado", ["medalla_roca"], "En el Centro Pokémon de la Ruta 4 (al pie del Mt. Moon) un señor vende un Magikarp."],
	["rocket_puente_peleado", ["rival_celeste_peleado"], "Al norte de Ciudad Celeste, el Puente Pepita: cinco entrenadores al hilo y un premio."],
	["rocket_celeste_peleado", ["medalla_cascada"], "El ladrón de la casa robada de Ciudad Celeste anda por atrás de la casa: tiene la MT28 Excavar."],
	["ticket_barco_recibido", ["rival_celeste_peleado"], "Pasando el Puente Pepita y la Ruta 25 vive Bill, el de la PC. Dicen que le pasó algo raro..."],
]
## Cazabichos del Bosque Verde (para contar cuántos te faltan).
const FOREST_TRAINERS := ["bosque_verde_rick", "bosque_verde_doug", "bosque_verde_sammy", "bosque_verde_anthony",
	"bosque_verde_charlie"]


## El paso actual: {index, total, title, text}; con todo hecho, index == total. En el modo libre (sin historia), {}.
static func current() -> Dictionary:
	if not GameState.has_flag("historia"):
		return {}
	for i in STEPS.size():
		if not GameState.has_flag(STEPS[i][0]):
			return {"index": i, "total": STEPS.size(), "title": STEPS[i][1], "text": STEPS[i][2]}
	return {"index": STEPS.size(), "total": STEPS.size(), "title": "¡Capítulo 3 completo!",
		"text": "Le ganaste a Lt. Surge. Muy pronto: la Cueva Diglett, el Túnel Roca y Pueblo Lavanda. Mientras tanto, entrenate o probá el Torneo de Ciudad Plateada."}


## Primer paso de cada capítulo (índice en STEPS) y su nombre.
const CHAPTERS := [[0, "Capítulo 1: de Pueblo Paleta a la Medalla Roca"], [6, "Capítulo 2: del Mt. Moon a la Medalla Cascada"],
	[9, "Capítulo 3: del S.S. Anne a la Medalla Trueno"]]


static func chapter_name(index: int) -> String:
	var name: String = CHAPTERS[0][1]
	for c in CHAPTERS:
		if index >= c[0]:
			name = c[1]
	return name


## Lo opcional que todavía no hiciste (y que ya está disponible).
static func optional_left() -> PackedStringArray:
	var out := PackedStringArray()
	for o in OPTIONAL:
		if GameState.has_flag(o[0]):
			continue
		if o[1].all(func(f): return GameState.has_flag(f)):
			out.append(o[2])
	if GameState.has_flag("paquete_entregado"):
		var left := FOREST_TRAINERS.filter(func(id): return not GameState.has_flag("vencido_" + id)).size()
		if left > 0:
			out.append("Te faltan %d Cazabichos en el Bosque Verde (te desafían si pasás por delante)." % left)
	return out
