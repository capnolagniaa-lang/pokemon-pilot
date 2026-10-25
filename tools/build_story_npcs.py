"""Arma las personas que hablan (data/story/npcs/<id>.tres, NpcData) desde los NPC reales de FireRed que exporta
tools/import_frlg_maps.py en data/world/frlg_maps.json ("npcs": celda ya agrandada, gráfico, script, movimiento).
Historia: docs/PLAN_HISTORIA.md (H-0: vecinos, enfermeras, mamá, empleados). Los textos son propios (en
rioplatense), cuentan lo mismo que FireRed sin copiar sus diálogos.

Uso: python -I -B tools/build_story_npcs.py <carpeta del proyecto>
Solo arma los NPC que están en TALKS (los entrenadores, Oak, el rival, el viejo del tutorial... llegan en sus
fases). Correrlo de nuevo PISA data/story/npcs/ (los .tres de otras fases que no estén acá no se tocan).
"""
import json
import os
import sys

FACING = {"UP": (0, -1), "DOWN": (0, 1), "LEFT": (-1, 0), "RIGHT": (1, 0)}

NURSE = dict(name="Enfermera", talks=[dict(heal=True, lines=[
    "¡Hola! Bienvenido al Centro Pokémon.",
    "Dame tus Pokémon un ratito que los dejo como nuevos.",
    "...",
    "¡Listo! Tus Pokémon están en plena forma. ¡Volvé cuando quieras!"])])

# (zona, script de FireRed) -> nombre y conversaciones. Conversación: lines, y opcionales requires/forbids/
# set_flags/give/heal/speaker. Se usa la primera que se cumple.
TALKS = {
    # --- Pueblo Paleta ---
    ("pueblo_paleta", "SignLady"): dict(name="Vecina", talks=[dict(lines=[
        "Los carteles te dicen dónde estás y adónde va cada camino.",
        "Si te perdés, ¡leé los carteles!"])]),
    ("pueblo_paleta", "FatMan"): dict(name="Vecino", talks=[dict(lines=[
        "La tecnología está increíble: ahora los Pokémon viajan en la PC.",
        "¡Podés guardar los que no te entran en el equipo y sacarlos en cualquier Centro!"])]),
    ("casa_jugador", "Mom"): dict(name="Mamá", talks=[dict(heal=True, lines=[
        "¡Hola! Te veo cansado. Sentate un ratito.",
        "Tus Pokémon también se merecen un descanso.",
        "...¡Listo! Ahora sí, a seguir con tu aventura. ¡Cuidate!"])]),
    ("casa_rival", "Daisy"): dict(name="Dalia", talks=[dict(lines=[
        "¿Buscás a mi hermano? Salió temprano.",
        "Dice que va a ser el mejor entrenador del mundo. ¡Siempre tan modesto!"])]),
    ("laboratorio_oak", "Aide1"): dict(name="Ayudante", talks=[dict(lines=[
        "Soy ayudante del Profesor Oak.",
        "El profe estudia a los Pokémon día y noche. ¡No para nunca!"])]),
    ("laboratorio_oak", "Aide2"): dict(name="Ayudante", talks=[dict(lines=[
        "Estamos investigando cómo pelean los Pokémon cuando están en libertad.",
        "Cada uno tiene su propio estilo, ¿sabías?"])]),
    ("laboratorio_oak", "Aide3"): dict(name="Ayudante", talks=[dict(lines=[
        "El Profesor Oak es una eminencia. Medio despistado, pero una eminencia."])]),
    # --- Ruta 1 ---
    ("ruta1", "MartClerk"): dict(name="Empleado de la Tienda", talks=[
        dict(forbids=["muestra_pocion"], set_flags=["muestra_pocion"], give={"pocion": 1}, lines=[
            "¡Hola! Trabajo en la Tienda Pokémon de Ciudad Verde.",
            "Estoy repartiendo muestras gratis. ¡Tomá, llevate una!"]),
        dict(lines=["Pasate por la Tienda de Ciudad Verde cuando quieras. ¡Tenemos de todo!"])]),
    ("ruta1", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "Si te metés en el pasto alto salen Pokémon salvajes.",
        "Si querés atrapar uno, primero debilitalo un poco."])]),
    # --- Ciudad Verde ---
    ("ciudad_verde", "DreamEaterTutor"): dict(name="Señor", talks=[dict(lines=["Zzz... Zzz...", "(Está durmiendo la siesta.)"])]),
    ("ciudad_verde", "OldMan"): dict(name="Abuelo", talks=[dict(lines=[
        "Hace años que vivo en Ciudad Verde.",
        "Siempre fue un lugar tranquilo... salvo por ese gimnasio cerrado."])]),
    ("ciudad_verde", "Woman"): dict(name="Señora", talks=[dict(lines=[
        "Más al norte está el Bosque Verde.",
        "Es fácil perderse ahí adentro. ¡Llevá Antídotos!"])]),
    ("ciudad_verde", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "¿Viste el gimnasio? Siempre está cerrado.",
        "Nadie sabe quién es el líder. Dicen que es alguien muy importante..."])]),
    ("ciudad_verde", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "Si tus Pokémon están cansados, llevalos al Centro Pokémon.",
        "La enfermera los cura gratis. ¡Es lo más!"])]),
    ("ciudad_verde_centro", "Nurse"): NURSE,
    ("ciudad_verde_centro", "Gentleman"): dict(name="Señor", talks=[dict(lines=[
        "En la PC de los Centros se guardan los Pokémon que no entran en tu equipo."])]),
    ("ciudad_verde_centro", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "Hay un Centro Pokémon en cada ciudad. ¡Te van a salvar más de una vez!"])]),
    ("ciudad_verde_centro", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Dicen que en el Bosque Verde hay Pikachu. ¡Yo nunca vi ninguno!"])]),
    ("ciudad_verde_tienda", "Clerk"): dict(name="Vendedor", talks=[dict(lines=[
        "¡Bienvenido a la Tienda Pokémon!",
        "Estamos acomodando el depósito. Volvé en un rato."])]),
    ("ciudad_verde_tienda", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Las Poké Balls sirven para atrapar Pokémon salvajes.",
        "¡Cuanto más débil esté, más fácil entra!"])]),
    ("ciudad_verde_tienda", "Woman"): dict(name="Señora", talks=[dict(lines=[
        "Un Antídoto cura el veneno. Yo siempre llevo uno encima."])]),
    ("ciudad_verde_gimnasio", "GymGuy"): dict(name="Guía del gimnasio", talks=[dict(lines=[
        "¡Ey! El líder de este gimnasio anda de viaje.",
        "Volvé cuando tengas más medallas."])]),
    ("ciudad_verde_escuela", "Woman"): dict(name="Maestra", talks=[dict(lines=[
        "Bienvenido a la escuela de entrenadores.",
        "Hoy estudiamos los estados: quemado, envenenado, paralizado, dormido...",
        "¡Saber qué hace cada uno gana peleas!"])]),
    ("ciudad_verde_escuela", "Lass"): dict(name="Alumna", talks=[dict(lines=[
        "Estoy anotando todo lo que dice la maestra.",
        "¡Los tipos son re importantes! El agua le gana al fuego, el fuego a la planta..."])]),
    ("ciudad_verde_casa", "BaldingMan"): dict(name="Papá", talks=[dict(lines=[
        "Mi hija tiene un Spearow. Le puso Speary.",
        "Lo cuida como si fuera de la familia. Bueno, es de la familia."])]),
    ("ciudad_verde_casa", "LittleGirl"): dict(name="Nena", talks=[dict(lines=[
        "¡Speary es mi mejor amigo! Le encanta picotear todo."])]),
    ("ciudad_verde_casa", "Speary"): dict(name="Speary", talks=[dict(lines=["¡Spiiir! ¡Spir!"])]),
    # --- Ruta 22 y Ruta 2 ---
    ("ruta22_garita", "BoulderBadgeGuard"): dict(name="Guardia", talks=[dict(lines=[
        "Por acá se va a la Liga Pokémon.",
        "Solo pueden pasar los entrenadores que tengan medallas de gimnasio."])]),
    ("ruta2_garita_sur", "Woman1"): dict(name="Señora", talks=[dict(lines=[
        "El Bosque Verde está acá nomás. Está lleno de Pokémon bicho."])]),
    ("ruta2_garita_sur", "Woman2"): dict(name="Chica", talks=[dict(lines=[
        "Los Cazabichos del bosque te desafían apenas te ven.",
        "¡Tené tus Pokémon listos!"])]),
    ("ruta2_garita_norte", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "¡Saliste del bosque! Ciudad Plateada está al norte."])]),
    ("ruta2_garita_norte", "OldMan"): dict(name="Abuelo", talks=[dict(lines=[
        "Yo cruzaba ese bosque de chico. Antes había menos árboles... ¿o yo era más alto?"])]),
    ("ruta2_garita_norte", "CooltrainerF"): dict(name="Entrenadora", talks=[dict(lines=[
        "Brock, el líder de Plateada, usa Pokémon de roca.",
        "El agua y la planta les hacen muchísimo daño."])]),
    ("ruta2_casa", "Scientist"): dict(name="Científico", talks=[dict(lines=[
        "Estudio los intercambios de Pokémon. ¡Algunos evolucionan al cambiar de entrenador!"])]),
    ("ruta2_edificio", "Aide"): dict(name="Ayudante de Oak", talks=[dict(lines=[
        "Soy ayudante del Profesor Oak.",
        "Cuando tengas más Pokémon registrados en la Pokédex, pasá que te voy a dar algo."])]),
    ("ruta2_edificio", "Rocker"): dict(name="Rockero", talks=[dict(lines=[
        "¡Mi Pokémon evolucionó en plena pelea! Fue lo más."])]),
    # --- Bosque Verde ---
    ("bosque_verde", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Me perdí... Este bosque es un laberinto.",
        "Me dijeron que la salida está para el norte."])]),
    ("bosque_verde", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "Si un Weedle te envenena, usá un Antídoto.",
        "¡Los bichos de acá pican fuerte!"])]),
    # --- Ciudad Plateada ---
    ("ciudad_plateada", "Lass"): dict(name="Chica", talks=[dict(lines=[
        "Brock, el líder del gimnasio, usa Pokémon de tipo roca.",
        "¡Son durísimos! Su Onix es enorme."])]),
    ("ciudad_plateada", "MuseumGuide"): dict(name="Señor", talks=[dict(lines=[
        "¿Fuiste al Museo de la Ciencia?",
        "Tienen fósiles de Pokémon que vivieron hace millones de años."])]),
    ("ciudad_plateada", "FatMan"): dict(name="Vecino", talks=[dict(lines=[
        "Ciudad Plateada es gris como la piedra. Por eso el nombre, ¿viste?"])]),
    ("ciudad_plateada", "BugCatcher"): dict(name="Cazabichos", talks=[dict(lines=[
        "¡Mis Pokémon bicho se hicieron fuertes en el Bosque Verde!"])]),
    ("ciudad_plateada", "GymGuide"): dict(name="Chico", talks=[dict(lines=[
        "¡Ey! ¿Sos entrenador?",
        "Brock te está esperando en el gimnasio. ¡Andá a desafiarlo!"])]),
    ("ciudad_plateada_centro", "Nurse"): NURSE,
    ("ciudad_plateada_centro", "Jigglypuff"): dict(name="Jigglypuff", talks=[dict(lines=["¡Jiggly, jigglypuuuff! ♪"])]),
    ("ciudad_plateada_centro", "Gentleman"): dict(name="Señor", talks=[dict(lines=[
        "¿Sabés qué le gana a los Pokémon de roca? ¡El agua y la planta!"])]),
    ("ciudad_plateada_centro", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Ese Jigglypuff canta y a todos les da sueño... ¡Zzz!"])]),
    ("ciudad_plateada_centro", "Woman"): dict(name="Señora", talks=[dict(lines=[
        "Viajar con tus Pokémon es lo mejor que hay."])]),
    ("ciudad_plateada_tienda", "Clerk"): dict(name="Vendedor", talks=[dict(lines=[
        "¡Bienvenido a la Tienda Pokémon!"], action="tienda_ciudad_plateada")]),
    ("ciudad_plateada_tienda", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Comprá Antídotos antes de cruzar el bosque. ¡Los Weedle envenenan!"])]),
    ("ciudad_plateada_tienda", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "La Cuerda Huida te saca de una cueva en un segundo."])]),
    ("ciudad_plateada_gimnasio", "GymGuy"): dict(name="Guía del gimnasio", talks=[dict(lines=[
        "¡Hola, futuro campeón!",
        "Brock usa Pokémon de roca: el agua y la planta son tu mejor opción.",
        "Su Onix es durísimo. Cuando se enoja... ¡cuidado!"])]),
    ("ciudad_plateada_casa1", "BaldingMan"): dict(name="Papá", talks=[dict(lines=[
        "Mi hijo quiere que su Nidoran pelee contra Brock... ¡Todavía le falta!"])]),
    ("ciudad_plateada_casa1", "LittleBoy"): dict(name="Nene", talks=[dict(lines=["¡Nidoran, vamos a ganarle a Brock!"])]),
    ("ciudad_plateada_casa1", "Nidoran"): dict(name="Nidoran", talks=[dict(lines=["¡Nido, nido!"])]),
    ("ciudad_plateada_casa2", "OldMan"): dict(name="Abuelo", talks=[dict(lines=[
        "Los Pokémon que evolucionan se vuelven más fuertes.",
        "Pero a veces también cambia su forma de pelear."])]),
    ("ciudad_plateada_casa2", "LittleBoy"): dict(name="Nene", talks=[dict(lines=["Mi abuelo sabe todo sobre Pokémon."])]),
    ("museo", "Scientist1"): dict(name="Encargado", talks=[dict(lines=[
        "¡Bienvenido al Museo de la Ciencia de Plateada! Hoy la entrada es gratis."])]),
    ("museo", "OldMan"): dict(name="Abuelo", talks=[dict(lines=["Ese esqueleto es de un Kabutops. ¡Mirá el tamaño!"])]),
    ("museo", "OldAmberScientist"): dict(name="Científico", talks=[dict(lines=[
        "Estamos estudiando un ámbar muy antiguo... parece que tiene algo adentro."])]),
    ("museo", "Scientist2"): dict(name="Científico", talks=[dict(lines=[
        "Los fósiles son restos de Pokémon que vivieron hace millones de años."])]),
    ("museo", "SeismicTossTutor"): dict(name="Científico", talks=[dict(lines=[
        "Algún día te voy a enseñar un movimiento especial. Hoy no, estoy ocupado."])]),
    ("museo_2p", "Scientist"): dict(name="Científico", talks=[dict(lines=[
        "Este piso es sobre el espacio. ¡Mirá ese transbordador!"])]),
    ("museo_2p", "Man"): dict(name="Señor", talks=[dict(lines=[
        "Dicen que en el Monte Moon cayó una piedra del espacio."])]),
    ("museo_2p", "OldMan"): dict(name="Abuelo", talks=[dict(lines=["Vengo todas las semanas a ver el transbordador."])]),
    ("museo_2p", "LittleGirl"): dict(name="Nena", talks=[dict(lines=["¡Cuando sea grande quiero ser astronauta!"])]),
    ("museo_2p", "BaldingMan"): dict(name="Papá", talks=[dict(lines=["Mi nena quiere ir a la luna. Primero que termine la tarea."])]),
}


# Entrenadores de la historia (E-1): equipos de FireRed (pret: src/data/trainer_parties.h). Frases propias; "|"
# separa globos. arena: data/arenas/<id>.tres. sight: celdas que ven (0 = solo si le hablás).
BUG = "Cazabichos"
TRAINERS = {
    ("bosque_verde", "Rick"): dict(name="Ricardo", title=BUG, team=[("weedle", 6), ("caterpie", 6)], lines={
        "desafio": "¡Ey! ¿Entraste al bosque? ¡Mis bichos te van a dar la bienvenida!",
        "pierde": "¡Nooo! Mis bichitos...",
        "despues": "Los Caterpie crecen rápido. ¡La próxima te gano!"}),
    ("bosque_verde", "Doug"): dict(name="Diego", title=BUG, team=[("weedle", 7), ("kakuna", 7), ("weedle", 7)], lines={
        "desafio": "¡Shh! Estoy cazando bichos... ¡pero vos servís para practicar!",
        "pierde": "¡Uf! Sos bueno, eh.",
        "despues": "Los Kakuna no se mueven, pero son durísimos."}),
    ("bosque_verde", "Sammy"): dict(name="Samuel", title=BUG, team=[("weedle", 9)], lines={
        "desafio": "¡Mi Weedle es el más fuerte de todo el bosque!",
        "pierde": "¡¿Cómo?! ¡Perdí con mi mejor Weedle!",
        "despues": "Cuidado con el veneno de los Weedle: pica fuerte."}),
    ("bosque_verde", "Anthony"): dict(name="Antonio", title=BUG, team=[("caterpie", 7), ("caterpie", 8)], lines={
        "desafio": "¡Mirá cuántos Caterpie atrapé! ¡A ver si les ganás!",
        "pierde": "Tendría que haber atrapado un Pikachu...",
        "despues": "Algún día mis Caterpie van a ser Butterfree."}),
    ("bosque_verde", "Charlie"): dict(name="Carlos", title=BUG, team=[("metapod", 7), ("caterpie", 7), ("metapod", 7)], lines={
        "desafio": "¡Mis Metapod no se mueven, pero no los vas a poder romper!",
        "pierde": "Bueno... se rompieron.",
        "despues": "Un Metapod endurecido aguanta casi todo. Casi."}),
    ("ciudad_plateada_gimnasio", "Liam"): dict(name="Liam", title="Campista", team=[("geodude", 10), ("sandshrew", 11)],
        arena="arena_gimnasio_roca", sight=3, lines={
        "desafio": "¡Alto ahí! Para llegar a Brock primero tenés que pasar por mí.",
        "pierde": "¡Qué bestia! Pero Brock es otra cosa, eh.",
        "despues": "Si querés ganarle a Brock, usá agua o planta."}),
    ("ciudad_plateada_gimnasio", "Brock"): dict(name="Brock", title="Líder", team=[("geodude", 12), ("onix", 14)],
        arena="arena_gimnasio_roca", sight=0, leader=True, reward_flags=["medalla_roca"],
        reward="¡Recibiste la MEDALLA ROCA de Brock!", reward_items={"mt39": 1}, lines={
        "desafio": "Soy Brock, el líder del Gimnasio de Ciudad Plateada.|Mis Pokémon de roca son duros como la piedra... "
                   "y mi Onix no conoce la derrota.|¡Mostrame lo que tenés!",
        "pierde": "Te subestimé... ¡Ganaste limpio!|Tomá, la Medalla Roca. Es la prueba de que me venciste.|"
                  "Y llevate esta MT: Tumba Rocas. Tirás rocas que frenan al rival. ¡Usala bien!",
        "despues": "Hay muchos entrenadores fuertes en Kanto. ¡Seguí entrenando!"}),
}


def gd_str(s):
    return '"%s"' % s.replace("\\", "\\\\").replace('"', '\\"')


def psa(items):
    return "PackedStringArray(%s)" % ", ".join(gd_str(x) for x in items)

# --- H-1: Pueblo Paleta y el laboratorio (docs/PLAN_HISTORIA.md) ---------------------------------------------
# Banderas: historia (partida de historia), oak_te_freno, tiene_inicial, inicial_<especie>, rival_<especie>
# (la Poké Ball que se llevó el rival), rival_lab_peleado.
OAK = "Prof. Oak"
RIVAL = "Azul"
COUNTER = {"bulbasaur": "charmander", "charmander": "squirtle", "squirtle": "bulbasaur"}
STARTER_TEXT = {
    "bulbasaur": ["¡Es Bulbasaur, el Pokémon tipo planta!",
                  "Su estilo es el control: domina la cancha con látigos, polvos y esporas."],
    "charmander": ["¡Es Charmander, el Pokémon tipo fuego!",
                   "Su estilo es el de un bruiser: entra, aguanta y se calienta cuanto más pelea."],
    "squirtle": ["¡Es Squirtle, el Pokémon tipo agua!",
                 "Su estilo es el de un tanque: se mete en el caparazón y castiga los errores."],
}


def starter_ball(sp):
    other = COUNTER[sp]
    return dict(name="Poké Ball", gfx="item_ball", show_if=["oak_te_freno"],
                hide_if=["inicial_" + sp, "rival_" + sp], talks=[
        dict(requires=["tiene_inicial"], lines=["Mejor no. Ya tenés a tu compañero."]),
        dict(lines=STARTER_TEXT[sp], confirm="¿Querés a %s?" % sp.capitalize(), give_pokemon=sp,
             set_flags=["tiene_inicial", "inicial_" + sp, "rival_" + other],
             after_speaker=RIVAL, after_lines=["¡Entonces yo me quedo con este!",
                                               "(Azul agarró la Poké Ball de %s.)" % other.capitalize()]),
    ])


TALKS.update({
    ("casa_jugador", "Mom"): dict(name="Mamá", talks=[
        dict(forbids=["tiene_inicial"], requires=["historia"], lines=[
            "¡Buen día! Hoy es un gran día, ¿no?",
            "El Profesor Oak, el vecino, te andaba buscando. ¡Pasá por su laboratorio!"]),
        TALKS[("casa_jugador", "Mom")]["talks"][-1],
    ]),
    ("laboratorio_oak", "ProfOak"): dict(name=OAK, show_if=["oak_te_freno"], talks=[
        dict(forbids=["tiene_inicial"], lines=[
            "Ahí en la mesa hay tres Poké Balls. Adentro de cada una hay un Pokémon.",
            "Elegí el que más te guste. ¡Va a ser tu primer compañero!"]),
        dict(forbids=["rival_lab_peleado"], lines=["¡Ese Pokémon ya es tuyo! Cuidalo mucho."]),
        dict(lines=["El mundo está lleno de Pokémon. ¡Salí a conocerlos!"]),
    ]),
    ("laboratorio_oak", "BulbasaurBall"): starter_ball("bulbasaur"),
    ("laboratorio_oak", "SquirtleBall"): starter_ball("squirtle"),
    ("laboratorio_oak", "CharmanderBall"): starter_ball("charmander"),
    ("laboratorio_oak", "Rival"): dict(name=RIVAL, show_if=["oak_te_freno"], hide_if=["rival_lab_peleado"], talks=[
        dict(forbids=["tiene_inicial"], lines=[
            "¡Abuelo! ¡Me aburro de esperar!",
            "¿Eh? ¿Vos también vas a elegir? Dale, elegí primero. Yo soy re generoso."]),
        dict(lines=["Mi Pokémon es mucho mejor que el tuyo. Ya vas a ver."]),
    ]),
})

TRAINERS.update({
    ("laboratorio_oak", "Rival"): dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False, team=[
        ("charmander", 5, "rival_charmander"), ("squirtle", 5, "rival_squirtle"), ("bulbasaur", 5, "rival_bulbasaur")],
        lines={"desafio": "¡Esperá! ¡Veamos qué tan buenos son nuestros Pokémon!",
               "pierde": "¿¡Qué!? ¡Elegí mal mi Pokémon!",
               "gana": "¡Ja! ¡Gané! Sabía que el mío era mejor.",
               "despues": "La próxima no te salvás."}),
})

TRIGGERS = {
    # Al querer salir de Pueblo Paleta hacia el pasto alto de la Ruta 1 sin Pokémon, Oak te frena.
    "oak_te_frena": dict(zone="pueblo_paleta", rect=(54, 0, 6, 3), once=False, talk=dict(
        requires=["historia"], forbids=["tiene_inicial"], speaker=OAK, lines=[
            "¡Esperá! ¡No sigas!",
            "En el pasto alto hay Pokémon salvajes. ¡Es peligroso salir sin un Pokémon propio!",
            "Vení conmigo al laboratorio."],
        set_flags=["oak_te_freno"], warp=("laboratorio_oak", (6, 6)))),
    # Sin Pokémon no te deja irte del laboratorio.
    "oak_llevate_uno": dict(zone="laboratorio_oak", rect=(4, 11, 5, 2), once=False, push_back=True, talk=dict(
        requires=["oak_te_freno"], forbids=["tiene_inicial"], speaker=OAK, lines=[
            "¡Eh! ¡Antes de irte elegí uno de los Pokémon de la mesa!"])),
    # Con tu inicial, el rival te desafía cuando querés salir (1ª pelea; si perdés, la historia sigue).
    "rival_laboratorio": dict(zone="laboratorio_oak", rect=(3, 9, 7, 2), talk=dict(
        requires=["tiene_inicial"], forbids=["rival_lab_peleado"], speaker=RIVAL, lines=["¡Eh, esperá!"],
        battle_npc="laboratorio_oak_rival", no_blackout=True, heal=True, set_flags=["rival_lab_peleado"],
        after_speaker=RIVAL, after_lines=["¡Me voy a entrenar a mis Pokémon! ¡Chau, abuelo!"])),
}


# --- H-2: el Correo de Oak, la Pokédex, Dalia y el viejo de Ciudad Verde --------------------------------------
# Banderas: tiene_paquete, paquete_entregado, tiene_pokedex (habilita la Pokédex), tiene_mapa, tutorial_captura.
_clerk_default = TALKS[("ciudad_verde_tienda", "Clerk")]["talks"]
TALKS[("ciudad_verde_tienda", "Clerk")] = dict(name="Vendedor", talks=[
    dict(requires=["historia", "tiene_inicial"], forbids=["tiene_paquete"], give={"paquete_oak": 1},
         set_flags=["tiene_paquete"], lines=[
            "¡Eh! Vos venís de Pueblo Paleta, ¿no?",
            "Llegó un correo para el Profesor Oak. ¿Se lo podés llevar? ¡Gracias!"]),
    dict(requires=["tiene_paquete"], forbids=["paquete_entregado"], lines=[
        "¿Ya le llevaste el correo al Profesor Oak? Está en Pueblo Paleta, al sur."]),
    # El mercado (scripts/world/mart.gd): vende después de entregar el correo, como en FireRed; sin historia, siempre.
    dict(requires=["paquete_entregado"], lines=["¡Bienvenido a la Tienda Pokémon!"], action="tienda_ciudad_verde"),
    dict(forbids=["historia"], lines=["¡Bienvenido a la Tienda Pokémon!"], action="tienda_ciudad_verde"),
] + _clerk_default)
_oak = TALKS[("laboratorio_oak", "ProfOak")]["talks"]
TALKS[("laboratorio_oak", "ProfOak")]["talks"] = _oak[:2] + [
    dict(requires=["tiene_paquete"], forbids=["paquete_entregado"], take={"paquete_oak": 1}, give={"poke_ball": 5},
         set_flags=["paquete_entregado", "tiene_pokedex"], lines=[
            "¡Ah, mi correo! Muchas gracias.",
            "Te tengo un regalo: ¡la Pokédex! Registra cada Pokémon que ves y con el que peleás.",
            "Y llevate estas Poké Balls. Debilitá al Pokémon y lanzala con E.",
            "Completar la Pokédex es mi sueño de toda la vida. ¿Me ayudás?"],
         after_lines=["¡Recibiste la Pokédex! (Esc → Pokédex)"]),
    dict(requires=["paquete_entregado"], lines=[
        "¿Cómo va esa Pokédex? Cada Pokémon nuevo que veas queda registrado.",
        "Al norte de Ciudad Verde está el Bosque Verde. ¡Hay muchos Pokémon bicho!"]),
    dict(lines=["¿Pasaste por Ciudad Verde? Está al norte, cruzando la Ruta 1."]),
]
_daisy = TALKS[("casa_rival", "Daisy")]["talks"]
TALKS[("casa_rival", "Daisy")]["talks"] = [
    dict(requires=["paquete_entregado"], forbids=["tiene_mapa"], give={"mapa": 1}, set_flags=["tiene_mapa"], lines=[
        "¿Así que el abuelo te dio una Pokédex? ¡Qué emoción!",
        "Tomá, un mapa de la región. Te va a servir para no perderte."]),
] + _daisy
_granddaughter = TALKS[("ciudad_verde", "Woman")]["talks"]
TALKS[("ciudad_verde", "Woman")]["talks"] = [
    dict(requires=["historia"], forbids=["paquete_entregado"], lines=[
        "¡Perdón! Mi abuelo no tomó su café y se tiró en el medio del camino.",
        "No deja pasar a nadie hasta que se le pase... Volvé en un rato."]),
] + _granddaughter
# El viejo dormido tapa la salida al norte (Ruta 2) hasta que le entregás el correo a Oak.
TALKS[("ciudad_verde", "TutorialOldMan")] = dict(name="Señor", gfx="old_man_lying_down", cell=(49, 5),
    show_if=["historia"], hide_if=["paquete_entregado"], talks=[dict(lines=[
        "Zzz... ¡Por acá no pasa nadie! Zzz...",
        "(Un señor está tirado en el medio del camino.)"])])
# Ya despierto, te enseña a atrapar Pokémon.
TALKS[("ciudad_verde", "OldManAwake")] = dict(name="Abuelo", show_if=["paquete_entregado"], talks=[
    dict(forbids=["tutorial_captura"], set_flags=["tutorial_captura"], lines=[
        "¡Ah, ya tomé mi café! Ahora sí estoy despierto. Perdón por lo de recién.",
        "¿Sabés atrapar Pokémon? Te explico.",
        "Primero peleá con el salvaje y bajale la vida, pero sin dejarlo fuera de combate.",
        "Después apretá E: la Poké Ball sale hacia donde apuntás con el mouse.",
        "Cuanta menos vida le quede, más fácil entra. ¡Y si está dormido o paralizado, mejor todavía!"]),
    dict(lines=["¡Que tengas suerte atrapando Pokémon!"]),
])
EXTRA_NPCS = {("ciudad_verde", "OldManAwake"): ((47, 7), "old_man_1")}
TRIGGERS["viejo_bloquea"] = dict(zone="ciudad_verde", rect=(44, 6, 13, 2), once=False, push_back=True, talk=dict(
    requires=["historia"], forbids=["paquete_entregado"], lines=[
        "(Un señor está tirado en el medio del camino. No se puede pasar.)"]))


# --- H-3: el rival en la Ruta 22 (2ª pelea) ----------------------------------------------------------------------
# Aparece después de que Oak te da la Pokédex. Te frena al cruzar la Ruta 22 (cualquiera de los dos caminos, x = 50).
# Si perdés, volvés al último Centro y te vuelve a desafiar; si ganás, se va a Ciudad Plateada.
TALKS[("ruta22", "0x0")] = dict(name=RIVAL, show_if=["paquete_entregado"], hide_if=["rival_ruta22_peleado"], talks=[
    dict(lines=["¡Eh! ¿Vos también vas para la Liga? ¡Ni lo sueñes!"])])
TRAINERS[("ruta22", "0x0")] = dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False,
    reward_flags=["rival_ruta22_peleado"], team=[
        ("pidgey", 9), ("charmander", 9, "rival_charmander"), ("squirtle", 9, "rival_squirtle"), ("bulbasaur", 9, "rival_bulbasaur")],
    lines={"desafio": "¡Eh, vos! ¿Vas a la Liga Pokémon? ¡Sin medallas no te dejan ni entrar!|"
                      "Yo estuve atrapando Pokémon. ¡Mirá cómo quedó mi equipo!",
           "pierde": "¿¡Perdí de nuevo!? ...Bueno, igual sin medallas no sirve de nada ir a la Liga.|"
                     "Me voy a Ciudad Plateada a ganarle a Brock. ¡Nos vemos!",
           "gana": "¡Ja! ¿Viste? Mi equipo es mucho mejor.",
           "despues": "¡Nos vemos en Ciudad Plateada!"})
TRIGGERS["rival_ruta22"] = dict(zone="ruta22", rect=(50, 28, 1, 33), once=False, talk=dict(
    requires=["paquete_entregado", "tiene_inicial"], forbids=["rival_ruta22_peleado"], speaker=RIVAL,
    lines=["¡Eh, esperá!"], battle_npc="ruta22_0x0"))


# --- H-4 / H-5: objetos fijos del camino y el chico que tapa la Ruta 3 ------------------------------------------
# Objetos tirados en sus lugares de FireRed: se agarran con E una sola vez (bandera objeto_<id>). (El Éter de la
# Ruta 2 no está porque todavía no hay PP.)
ITEM_BALLS = {
    ("ciudad_verde", "ItemPotion"): "pocion",
    ("bosque_verde", "ItemPokeBall"): "poke_ball",
    ("bosque_verde", "ItemAntidote"): "antidoto",
    ("bosque_verde", "ItemPotion"): "pocion",
    ("bosque_verde", "ItemPotion2"): "pocion",
    ("ruta2", "ItemParalyzeHeal"): "antiparalizador",
}
for (_zone, _script), _item in ITEM_BALLS.items():
    _flag = "objeto_%s_%s" % (_zone, _script.lower())
    TALKS[(_zone, _script)] = dict(name="Objeto", gfx="item_ball", hide_if=[_flag], talks=[
        dict(give={_item: 1}, set_flags=[_flag], lines=[])])
# El chico de Plateada no te deja ir a la Ruta 3 sin la Medalla Roca y te lleva al gimnasio (como en FireRed).
TALKS[("ciudad_plateada", "GymGuide")] = dict(name="Chico", talks=[
    dict(forbids=["medalla_roca"], lines=[
        "¡Ey! ¿Sos entrenador?",
        "Brock te está esperando en el gimnasio. ¡Andá a desafiarlo!"]),
    dict(lines=["¡Le ganaste a Brock! ¡Sos un crack!",
                "La Ruta 3 sigue por acá... pero todavía está en obras. ¡Pronto!"]),
])
TRIGGERS["chico_ruta3"] = dict(zone="ciudad_plateada", rect=(72, 35, 2, 5), once=False, push_back=True, talk=dict(
    requires=["historia"], forbids=["medalla_roca"], speaker="Chico", lines=[
        "¡Eh, esperá! ¿Vas para la Ruta 3?",
        "Primero tenés que ganarle a Brock, el líder del gimnasio. ¡Vení que te llevo!"],
    warp=("ciudad_plateada", (29, 32))))


# --- Torneo de Ciudad Plateada (docs/PLAN_TORNEO.md) -------------------------------------------------------------
TALKS[("ciudad_plateada_torneo", "Recepcionista")] = dict(name="Recepcionista", talks=[
    dict(lines=["¡Bienvenido al Torneo de Ciudad Plateada!",
                "Ocho entrenadores, eliminación directa: cuartos, semifinal y final en el estadio."], action="torneo")])
TALKS[("ciudad_plateada_torneo", "Fanatico")] = dict(name="Fanático", talks=[dict(lines=[
    "Para anotarte, tus Pokémon no pueden pasar el nivel de la copa... ¡pero peleás con tu equipo de siempre!",
    "Y no te curan entre ronda y ronda. Las Pociones valen oro."])])
TALKS[("ciudad_plateada_torneo", "Chusma")] = dict(name="Pibe", talks=[dict(lines=[
    "Dicen que Brock a veces se anota en el torneo...",
    "¡Y que cada vez trae más Pokémon de roca!"])])
EXTRA_NPCS[("ciudad_plateada_torneo", "Recepcionista")] = ((7, 2), "cable_club_receptionist")
EXTRA_NPCS[("ciudad_plateada_torneo", "Fanatico")] = ((12, 5), "gentleman")
EXTRA_NPCS[("ciudad_plateada_torneo", "Chusma")] = ((3, 6), "youngster")


class Ext:
    """ext_resource que necesita un .tres (scripts y recursos), con ids estables."""

    def __init__(self, scripts):
        self.items = list(scripts)  # [(tipo, path, id)]

    def ref(self, path, kind="Resource"):
        for t, p, i in self.items:
            if p == path:
                return i
        i = "r_%d" % len(self.items)
        self.items.append((kind, path, i))
        return i

    def lines(self):
        return ['[ext_resource type="%s" path="%s" id="%s"]' % it for it in self.items]


def species_ref(ext, sp):
    return 'ExtResource("%s")' % ext.ref("res://data/species/%s.tres" % sp)


def talk_body(sid, t, ext):
    """Cuerpo de un NpcTalk (conversación) como sub-recurso."""
    body = ['[sub_resource type="Resource" id="%s"]' % sid, 'script = ExtResource("%s")' % ext.ref(
        "res://scripts/resources/npc_talk.gd", "Script")]
    for key in ("requires", "forbids", "set_flags"):
        if t.get(key):
            body.append("%s = %s" % (key, psa(t[key])))
    if t.get("speaker"):
        body.append("speaker = " + gd_str(t["speaker"]))
    body.append("lines = " + psa(t.get("lines", [])))
    if t.get("give"):
        body.append("give_items = {%s}" % ", ".join("%s: %d" % (gd_str(k), v) for k, v in t["give"].items()))
    if t.get("take"):
        body.append("take_items = {%s}" % ", ".join("%s: %d" % (gd_str(k), v) for k, v in t["take"].items()))
    if t.get("heal"):
        body.append("heal = true")
    if t.get("confirm"):
        body.append("confirm = " + gd_str(t["confirm"]))
    if t.get("give_pokemon"):
        body.append("give_pokemon = " + species_ref(ext, t["give_pokemon"]))
    if t.get("battle_npc"):
        body.append("battle_npc = " + gd_str(t["battle_npc"]))
    if t.get("no_blackout"):
        body.append("battle_no_blackout = true")
    if t.get("after_lines"):
        body.append("after_speaker = " + gd_str(t.get("after_speaker", "")))
        body.append("after_lines = " + psa(t["after_lines"]))
    if t.get("action"):
        body.append("action = " + gd_str(t["action"]))
    if t.get("warp"):
        body.append("warp_zone = " + gd_str(t["warp"][0]))
        body.append("warp_cell = Vector2i(%d, %d)" % tuple(t["warp"][1]))
    return "\n".join(body)


def trainer_subs(spec, ext):
    """Sub-recursos de un TrainerData (con sus TrainerMon). Un Pokémon del equipo puede pedir una bandera:
    (especie, nivel, bandera)."""
    subs, mons = [], []
    mon_script = ext.ref("res://scripts/resources/trainer_mon.gd", "Script")
    for i, m in enumerate(spec["team"]):
        body = ['[sub_resource type="Resource" id="Mon_%d"]' % i, 'script = ExtResource("%s")' % mon_script,
                "species = " + species_ref(ext, m[0]), "level = %d" % m[1]]
        if len(m) > 2:
            body.append("requires_flag = " + gd_str(m[2]))
        subs.append("\n".join(body))
        mons.append('SubResource("Mon_%d")' % i)
    lines = ", ".join("%s: %s" % (gd_str(k), gd_str(v)) for k, v in spec["lines"].items())
    body = ['[sub_resource type="Resource" id="Trainer"]',
            'script = ExtResource("%s")' % ext.ref("res://scripts/resources/trainer_data.gd", "Script"),
            "id = " + gd_str(spec["name"].lower()), "display_name = " + gd_str(spec["name"]), "title = " + gd_str(spec["title"]),
            'starting_team = Array[ExtResource("%s")]([%s])' % (mon_script, ", ".join(mons)), "lines = {%s}" % lines,
            "arena_id = " + gd_str(spec.get("arena", "arena_campo"))]
    if spec.get("leader"):
        body.append("leader = true")
    if spec.get("reward_flags"):
        body.append("reward_flags = " + psa(spec["reward_flags"]))
    if spec.get("reward"):
        body.append("reward_text = " + gd_str(spec["reward"]))
    if spec.get("reward_items"):
        body.append("reward_items = {%s}" % ", ".join("%s: %d" % (gd_str(k), v) for k, v in spec["reward_items"].items()))
    subs.append("\n".join(body))
    return subs


def npc_tres(npc_id, zone, n, spec):
    gfx = spec.get("gfx") or n["gfx"][len("OBJ_EVENT_GFX_"):].lower()
    move = n["movement"].replace("MOVEMENT_TYPE_", "")
    face = (0, 1)
    for k, v in FACING.items():
        if move.startswith("FACE_" + k):
            face = v
    look = move.startswith("LOOK_AROUND") or move.startswith("WANDER")
    ext = Ext([("Script", "res://scripts/resources/npc_data.gd", "1_n"),
               ("Script", "res://scripts/resources/npc_talk.gd", "2_t")])
    subs, ids = [], []
    for i, t in enumerate(spec["talks"]):
        ids.append('SubResource("Talk_%d")' % i)
        subs.append(talk_body("Talk_%d" % i, t, ext))
    extra = []
    if spec.get("trainer"):
        subs += trainer_subs(spec["trainer"], ext)
        extra = ['trainer = SubResource("Trainer")', "sight = %d" % spec["trainer"].get("sight", 4)]
        if spec["trainer"].get("talk_challenge") is False:
            extra.append("challenge_on_talk = false")
    for key in ("show_if", "hide_if"):
        if spec.get(key):
            extra.append("%s = %s" % (key, psa(spec[key])))
    head = ['[gd_resource type="Resource" script_class="NpcData" format=3]', ""] + ext.lines()
    return "\n".join(head + ["",
        "\n\n".join(subs), "",
        "[resource]", 'script = ExtResource("1_n")', "id = " + gd_str(npc_id),
        "display_name = " + gd_str(spec["name"]), "zone_id = " + gd_str(zone),
        "cell = Vector2i(%d, %d)" % tuple(spec.get("cell", n["cell"])), "gfx = " + gd_str(gfx),
        "facing = Vector2i(%d, %d)" % face, "look_around = " + ("true" if look else "false"),
        'talks = Array[ExtResource("2_t")]([%s])' % ", ".join(ids)] + extra + [""])


def trigger_tres(tid, spec):
    ext = Ext([("Script", "res://scripts/resources/story_trigger.gd", "1_g"),
               ("Script", "res://scripts/resources/npc_talk.gd", "2_t")])
    body = talk_body("Talk", spec["talk"], ext)
    r = spec["rect"]
    return "\n".join(['[gd_resource type="Resource" script_class="StoryTrigger" format=3]', ""] + ext.lines() + [
        "", body, "", "[resource]", 'script = ExtResource("1_g")', "id = " + gd_str(tid),
        "zone_id = " + gd_str(spec["zone"]), "rect = Rect2i(%d, %d, %d, %d)" % tuple(r), 'talk = SubResource("Talk")',
        "once = " + ("true" if spec.get("once", True) else "false"),
        "push_back = " + ("true" if spec.get("push_back") else "false"), ""])


def main():
    root = sys.argv[1]
    data = json.load(open(os.path.join(root, "data", "world", "frlg_maps.json"), encoding="utf-8"))
    sprites = json.load(open(os.path.join(root, "art", "pret", "characters", "npcs.json"), encoding="utf-8"))
    out = os.path.join(root, "data", "story", "npcs")
    os.makedirs(out, exist_ok=True)
    made = set()
    for z in data["zones"]:
        for n in z.get("npcs", []):
            script = n["script"].split("EventScript_")[-1]
            spec = TALKS.get((z["id"], script))
            t = TRAINERS.get((z["id"], script))
            if t is not None:
                spec = dict(spec or {}, name=t["name"], trainer=t)
                spec.setdefault("talks", [dict(lines=[t["lines"]["despues"]])])
            if spec is None:
                continue
            gfx = spec.get("gfx") or n["gfx"][len("OBJ_EVENT_GFX_"):].lower()
            if gfx not in sprites:
                print("sin sprite:", z["id"], script, gfx)
                continue
            npc_id = "%s_%s" % (z["id"], script.lower())
            with open(os.path.join(out, npc_id + ".tres"), "w", encoding="utf-8", newline="\n") as f:
                f.write(npc_tres(npc_id, z["id"], n, spec))
            made.add((z["id"], script))
    # Personas que no están en los mapas de FireRed (ej. el viejo de Ciudad Verde ya despierto).
    for (zone, script), (cell, gfx) in EXTRA_NPCS.items():
        n = {"cell": list(cell), "gfx": "OBJ_EVENT_GFX_" + gfx.upper(), "movement": "MOVEMENT_TYPE_FACE_DOWN"}
        npc_id = "%s_%s" % (zone, script.lower())
        with open(os.path.join(out, npc_id + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write(npc_tres(npc_id, zone, n, TALKS[(zone, script)]))
        made.add((zone, script))
    for key in list(TALKS) + list(TRAINERS):
        if key not in made:
            print("no está en el mapa:", key)
    print("personas:", len(made))
    tout = os.path.join(root, "data", "story", "triggers")
    os.makedirs(tout, exist_ok=True)
    for tid, spec in TRIGGERS.items():
        with open(os.path.join(tout, tid + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write(trigger_tres(tid, spec))
    print("disparadores:", len(TRIGGERS))


if __name__ == "__main__":
    main()
