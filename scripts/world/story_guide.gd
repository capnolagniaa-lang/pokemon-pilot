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
	["surge_puerta_abierta", "Los basureros de Surge", "Con Corte (caminá contra el árbol fino) entrá al gimnasio de Ciudad Carmín. Buscá los dos interruptores en los basureros: el segundo está al lado del primero."],
	["medalla_trueno", "La Medalla Trueno", "Ganale a Lt. Surge (tipo eléctrico: los de tierra no sienten la electricidad)."],
	# Capítulos 4 a 8 (docs/PLAN_RESTO_KANTO.md)
	["giovanni_escondite_vencido", "El Escondite Rocket", "Desde Ciudad Celeste, la Ruta 9 y el Túnel Roca llevan a Pueblo Lavanda; la Ruta 8 y la Vía Subterránea, a Ciudad Azulona. El Team Rocket se esconde debajo del Casino: bajá hasta el fondo y ganale a su jefe."],
	["medalla_arcoiris", "La Medalla Arcoíris", "Ganale a Erika en el gimnasio de Ciudad Azulona (tipo planta: el fuego, el hielo y los voladores le pegan fuerte). Cortá el árbol de la entrada."],
	["fuji_rescatado", "La Torre Pokémon", "Con el Scope Silph volvé a la Torre Pokémon de Pueblo Lavanda: subí hasta arriba de todo y rescatá al Sr. Fuji del Team Rocket."],
	["medalla_alma", "La Medalla Alma", "Con la Poké Flauta despertá al Snorlax de la Ruta 12 (o el de la 16) y seguí hasta Ciudad Fucsia. Ganale a Koga (tipo veneno). En la Zona Safari hay una MO escondida."],
	["silph_liberada", "Silph S.A.", "Con el Té de la Mansión Azulona los guardias te dejan entrar a Ciudad Azafrán. El Team Rocket tomó Silph S.A.: subí hasta el último piso y echá a Giovanni."],
	["medalla_pantano", "La Medalla Pantano", "Ganale a Sabrina en el gimnasio de Ciudad Azafrán (tipo psíquico: los bichos y los fantasmas le pegan fuerte)."],
	["medalla_volcan", "La Medalla Volcán", "Con Surf, bajá desde Ciudad Fucsia por las Rutas 19 y 20 hasta Isla Canela. La llave del gimnasio está en la Mansión Pokémon. Después, ganale a Blaine (tipo fuego)."],
	["medalla_tierra", "La Medalla Tierra", "Con siete medallas se abre el gimnasio de Ciudad Verde. Su líder es... Giovanni (tipo tierra: el agua y la planta le pegan fuerte)."],
	["rival_ruta22_final_peleado", "La última pelea con el rival", "Andá al oeste de Ciudad Verde: tu rival te espera en la Ruta 22, antes de la Liga."],
	["campeon", "La Liga Pokémon", "Con las 8 medallas pasá la garita de la Ruta 22, la Ruta 23 y la Calle Victoria (con Fuerza). En la Meseta Añil te esperan el Alto Mando... y el Campeón."],
]
## Adónde ir en cada paso (bandera del paso -> zona): la estrella del Mapa (Esc → Mapa). Un paso sin fila no marca nada.
const GOALS := {
	"oak_te_freno": "ruta1", "tiene_inicial": "laboratorio_oak", "rival_lab_peleado": "laboratorio_oak",
	"tiene_paquete": "ciudad_verde_tienda", "paquete_entregado": "laboratorio_oak", "medalla_roca": "ciudad_plateada_gimnasio",
	"fosil_elegido": "mt_moon", "rival_celeste_peleado": "ciudad_celeste", "medalla_cascada": "ciudad_celeste_gimnasio",
	"rival_ss_anne_peleado": "ss_anne_muelle", "tiene_corte": "ss_anne_muelle", "surge_puerta_abierta": "ciudad_carmin_gimnasio",
	"medalla_trueno": "ciudad_carmin_gimnasio", "giovanni_escondite_vencido": "ciudad_azulona_casino",
	"medalla_arcoiris": "ciudad_azulona_gimnasio", "fuji_rescatado": "torre_pokemon_1p", "medalla_alma": "ciudad_fucsia_gimnasio",
	"silph_liberada": "silph_1p", "medalla_pantano": "ciudad_azafran_gimnasio", "medalla_volcan": "isla_canela_gimnasio",
	"medalla_tierra": "ciudad_verde_gimnasio", "rival_ruta22_final_peleado": "ruta22", "campeon": "meseta_anil",
}
## Cosas que se pueden hacer además: [bandera que la completa, banderas que hacen falta, texto]
const OPTIONAL := [
	["tutorial_captura", ["paquete_entregado"], "En Ciudad Verde, el abuelo que tapaba el camino te enseña a atrapar Pokémon."],
	["tiene_mapa", ["paquete_entregado"], "Dalia, la hermana de tu rival (casa de al lado de la tuya), tiene un regalo para vos."],
	["rival_ruta22_peleado", ["paquete_entregado"], "Tu rival te espera en la Ruta 22, al oeste de Ciudad Verde."],
	["campeon_nv15_3", ["medalla_roca"], "Probá el Torneo de Ciudad Plateada (la puerta del anexo rosa del museo)."],
	["magikarp_comprado", ["medalla_roca"], "En el Centro Pokémon de la Ruta 4 (al pie del Mt. Moon) un señor vende un Magikarp."],
	["rocket_puente_peleado", ["rival_celeste_peleado"], "Al norte de Ciudad Celeste, el Puente Pepita: cinco entrenadores al hilo y un premio."],
	["rocket_celeste_peleado", ["medalla_cascada"], "El ladrón de la casa robada de Ciudad Celeste anda por atrás de la casa: tiene la MT28 Excavar."],
	["rival_torre_peleado", ["medalla_trueno"], "Tu rival anda por la Torre Pokémon de Pueblo Lavanda."],
	["te_recibido", ["medalla_trueno"], "En la Mansión Azulona una abuela muy amable convida té..."],
	["eevee_recibido", ["medalla_trueno"], "En la terraza de la Mansión Azulona hay un regalo esperando a quien lo encuentre."],
	["mo04_recibido", ["medalla_arcoiris"], "Al guarda de la Zona Safari (Ciudad Fucsia) se le cayeron los dientes de oro en la Zona Safari."],
	["lapras_recibido", ["fuji_rescatado"], "En el 7º piso de Silph S.A. un empleado esconde un Pokémon."],
	["hitmon_elegido", ["fuji_rescatado"], "El Dojo Karate de Ciudad Azafrán regala un Pokémon de lucha al que le gane al maestro."],
	["articuno_visto", ["medalla_alma"], "Dicen que en lo más hondo de las Islas Espuma vive un pájaro de hielo legendario."],
	["zapdos_visto", ["medalla_alma"], "Dicen que en la Central Eléctrica (Ruta 10, con Surf) vive un pájaro eléctrico legendario."],
	["ticket_barco_recibido", ["rival_celeste_peleado"], "Pasando el Puente Pepita y la Ruta 25 vive Bill, el de la PC. Dicen que le pasó algo raro..."],
]
## Cazabichos del Bosque Verde (para contar cuántos te faltan).
const FOREST_TRAINERS := ["bosque_verde_rick", "bosque_verde_doug", "bosque_verde_sammy", "bosque_verde_anthony",
	"bosque_verde_charlie"]


## El paso actual: {index, total, title, text, goal (zona adonde ir o "")}; con todo hecho, index == total. En el
## modo libre (sin historia), {}.
static func current() -> Dictionary:
	if not GameState.has_flag("historia"):
		return {}
	for i in STEPS.size():
		if not GameState.has_flag(STEPS[i][0]):
			return {"index": i, "total": STEPS.size(), "title": STEPS[i][1], "text": STEPS[i][2],
				"goal": GOALS.get(STEPS[i][0], "")}
	return {"index": STEPS.size(), "total": STEPS.size(), "goal": "", "title": "¡Sos el Campeón de Kanto!",
		"text": "Le ganaste al Alto Mando y a tu rival. ¡Felicitaciones! Ahora podés completar la Pokédex, buscar a los legendarios o probar el Torneo de Ciudad Plateada."}


## Primer paso de cada capítulo (índice en STEPS) y su nombre.
const CHAPTERS := [[0, "Capítulo 1: de Pueblo Paleta a la Medalla Roca"], [6, "Capítulo 2: del Mt. Moon a la Medalla Cascada"],
	[9, "Capítulo 3: del S.S. Anne a la Medalla Trueno"], [13, "Capítulo 4: del Túnel Roca a la Medalla Arcoíris"],
	[15, "Capítulo 5: de la Torre Pokémon a la Medalla Alma"], [17, "Capítulo 6: Silph S.A. y la Medalla Pantano"],
	[19, "Capítulo 7: Isla Canela y la Medalla Volcán"], [20, "Capítulo 8: la Medalla Tierra y la Liga Pokémon"]]


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
