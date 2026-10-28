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


# =================================================================================================================
# --- Capítulo 2: de Ciudad Plateada al Gimnasio de Ciudad Celeste (docs/PLAN_CAPITULO_2.md) ----------------------
# Equipos de FireRed (pret: trainer_parties.h). Banderas: fosil_elegido, rival_celeste_peleado, rocket_puente_peleado,
# magikarp_comprado, bill_ayudado, ticket_barco_recibido, medalla_cascada. La Chica Crissy de la Ruta 4 (Paras Nv. 31)
# queda afuera. Dos personas con el mismo script en una zona: la segunda usa la clave "<script>_2" (casa de Bill).
LASS, YOUNG, CAMPER, HIKER, NERD, PICNIC, ROCKET = ("Chica", "Joven", "Campista", "Montañero", "Supernecio",
                                                    "Dominguera", "Soldado Rocket")


def _t(name, title, team, desafio, pierde, despues, **kw):
    return dict(name=name, title=title, team=team, lines={"desafio": desafio, "pierde": pierde, "despues": despues}, **kw)


TRAINERS.update({
    # Ruta 3
    ("ruta3", "Robin"): _t("Robina", LASS, [("jigglypuff", 14)], "¡Ay, mirá qué lindo mi Jigglypuff! ¿Peleamos?",
        "¡Ni la canción lo salvó!", "Si Jigglypuff canta, no te duermas."),
    ("ruta3", "James"): _t("Jaime", BUG, [("caterpie", 11), ("metapod", 11)],
        "¡Mis bichos salieron del Bosque Verde para ganarte!", "¡Volvé, Metapod!", "Un Metapod duro aguanta casi todo."),
    ("ruta3", "Sally"): _t("Sandra", LASS, [("rattata", 10), ("nidoran_f", 10)], "¡Eh! ¿Me mirabas? ¡Entonces peleamos!",
        "¡Qué vergüenza!", "Los Nidoran tienen púas venenosas, ojo."),
    ("ruta3", "Greg"): _t("Gregorio", BUG, [("weedle", 9), ("kakuna", 9), ("caterpie", 9), ("metapod", 9)],
        "¡Tengo cuatro bichos! ¡A ver si aguantás!", "¡Cuatro y ninguno sirvió!", "Algún día van a evolucionar todos."),
    ("ruta3", "Calvin"): _t("Calvo", YOUNG, [("spearow", 14)], "¡Mi Spearow pica más fuerte que cualquier Pidgey!",
        "¡Se me desplumó!", "Los Spearow son bravos. Cuidá los ojos."),
    ("ruta3", "Janice"): _t("Jimena", LASS, [("pidgey", 9), ("pidgey", 9)], "¡Mis dos Pidgey vuelan en pareja!",
        "Aterrizaron mal...", "Los Pidgey son tranquilos, pero en pareja molestan."),
    ("ruta3", "Colton"): _t("Colo", BUG, [("caterpie", 10), ("weedle", 10), ("caterpie", 10)],
        "¡Shh! Vas a espantar a los bichos... ¡ahora peleamos!", "¡Me espantaste a todos!", "Por acá hay Nidoran. Son re lindos."),
    ("ruta3", "Ben"): _t("Benja", YOUNG, [("rattata", 11), ("ekans", 11)], "¡Pantalón corto y Pokémon cortitos! ¡Dale!",
        "¡Uh, perdí!", "El Mt. Moon está al final de la ruta. Llevá Antídotos."),
    # Mt. Moon
    ("mt_moon", "Iris"): _t("Iris", LASS, [("clefairy", 14)], "¿Viste un Clefairy? ¡Yo tengo uno!",
        "¡Ay, mi Clefairy!", "Dicen que los Clefairy bailan con la luna llena."),
    ("mt_moon", "Robby"): _t("Robi", BUG, [("caterpie", 10), ("metapod", 10), ("caterpie", 10)],
        "¡Hasta en la cueva hay bichos! ¡Peleá!", "¡Acá abajo no ven nada!", "Los Zubat no tienen ojos, ¿sabías?"),
    ("mt_moon", "Jovan"): _t("Gustavo", NERD, [("magnemite", 11), ("voltorb", 11)], "¡Mis Pokémon eléctricos son puro cálculo!",
        "¡Me fallaron las cuentas!", "Vine a buscar fósiles. ¡Son de hace millones de años!"),
    ("mt_moon", "Miriam"): _t("Mirna", LASS, [("oddish", 11), ("bellsprout", 11)],
        "¡Me perdí en la cueva! Igual... ¡peleemos!", "Ahora estoy perdida y derrotada.", "¿Cuál era la salida? Creo que por abajo..."),
    ("mt_moon", "Kent"): _t("Casimiro", BUG, [("weedle", 11), ("kakuna", 11)], "¡Los bichos de cueva son los más fuertes!",
        "Bueno, no tanto.", "Los Paras tienen hongos en la espalda. ¡Qué asco!"),
    ("mt_moon", "Josh"): _t("José", YOUNG, [("rattata", 10), ("rattata", 10), ("zubat", 10)],
        "¡Hay un montón de Zubat! ¡Y uno es mío!", "¡Volaron todos!", "Si te molestan los Zubat, corré hacia la salida."),
    ("mt_moon", "Marcos"): _t("Marcos", HIKER, [("geodude", 10), ("geodude", 10), ("onix", 10)],
        "¡Las montañas son mi casa! ¡Y mis Pokémon son de piedra!", "¡Se me desmoronó todo!", "Escalar es lindo, pero la cueva es mejor."),
    ("mt_moon_s2", "Grunt1"): _t("Rocket", ROCKET, [("rattata", 13), ("zubat", 13)],
        "¡Somos el Team Rocket! ¡Los fósiles son nuestros!", "¡Pff! ¡Esto no termina acá!", "El jefe se va a enojar..."),
    ("mt_moon_s2", "Grunt2"): _t("Rocket", ROCKET, [("sandshrew", 11), ("rattata", 11), ("zubat", 11)],
        "¿Un nene en la cueva? ¡Andate antes de que te robe los Pokémon!", "¡Ay! ¡Qué nene fuerte!", "Los fósiles valen una fortuna, ¿sabías?"),
    ("mt_moon_s2", "Grunt3"): _t("Rocket", ROCKET, [("zubat", 11), ("ekans", 11)], "¡Alto! ¡Este paso es del Team Rocket!",
        "¡Me ganaste! Pero el Team Rocket nunca se rinde.", "¡Vamos a volver!"),
    ("mt_moon_s2", "Grunt4"): _t("Rocket", ROCKET, [("rattata", 13), ("sandshrew", 13)],
        "¡Vos sos el que anda molestando a mis compañeros!", "¡Pero qué es esto!", "Grrr... ¡el Team Rocket se va a vengar!"),
    ("mt_moon_s2", "Miguel"): _t("Miguel", NERD, [("grimer", 12), ("voltorb", 12), ("koffing", 12)],
        "¡Ey! ¡Estos fósiles los encontré yo! ¡Son míos!",
        "¡Está bien, está bien! Uno para cada uno. No hay que ser avaricioso.", "Agarrá el fósil que quieras. El otro es mío.",
        sight=3),
    # Ciudad Celeste: el rival antes del Puente Pepita
    ("ciudad_celeste", "0x0"): dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False,
        reward_flags=["rival_celeste_peleado"],
        team=[("pidgeotto", 17), ("abra", 16), ("rattata", 15), ("squirtle", 18, "rival_squirtle"),
              ("bulbasaur", 18, "rival_bulbasaur"), ("charmander", 18, "rival_charmander")],
        lines={"desafio": "¡Eh, vos! ¡Seguís vivo! ¿Pasaste por el Mt. Moon?|A ver cuánto mejoraste. ¡Mis Pokémon están re entrenados!",
               "pierde": "¡¿Otra vez?! ...Bueno, ¿sabés qué? Hay un tal Bill pasando el Puente Pepita.|Tiene una colección de "
                         "Pokémon rarísimos. Andá a verlo, si te animás.",
               "gana": "¡Ja! Sigo siendo el mejor.", "despues": "Bill vive al norte, pasando el Puente Pepita."}),
    # Ruta 24: Puente Pepita (cinco al hilo) y el Rocket disfrazado
    ("ruta24", "Cale"): _t("Calixto", BUG, [("caterpie", 10), ("weedle", 10), ("metapod", 10), ("kakuna", 10)],
        "¡Bienvenido al Puente Pepita! ¡Soy el primero de cinco!", "¡Pasaste el primero!", "Si le ganás a los cinco, hay premio."),
    ("ruta24", "Ali"): _t("Alicia", LASS, [("pidgey", 12), ("oddish", 12), ("bellsprout", 12)],
        "¡Soy la segunda! ¡No te va a ser fácil!", "¡Ay! Pasaste a la segunda.", "Faltan tres. ¡Suerte!"),
    ("ruta24", "Timmy"): _t("Tomás", YOUNG, [("sandshrew", 14), ("ekans", 14)],
        "¡El tercero! ¡A partir de acá se pone picante!", "¡Picante para mí!", "Los dos últimos son los más bravos."),
    ("ruta24", "Reli"): _t("Rebeca", LASS, [("nidoran_m", 16), ("nidoran_f", 16)], "¡Soy la cuarta! ¡Mis Nidoran son pareja!",
        "¡Se separaron!", "Te queda uno solo..."),
    ("ruta24", "Ethan"): _t("Ezequiel", CAMPER, [("mankey", 18)], "¡El último del Puente Pepita! ¡Mi Mankey está furioso!",
        "¡Pasaste los cinco! ¡Increíble!", "Andá a buscar tu premio, que te lo ganaste."),
    ("ruta24", "Shane"): _t("Santiago", CAMPER, [("rattata", 14), ("ekans", 14)], "¡Ey! ¡Acá abajo también se pelea!",
        "¡Uh, me ganaste!", "El pasto de acá tiene Abra. ¡Se teletransportan!"),
    ("ruta24", "Rocket"): dict(name="Rocket", title=ROCKET, sight=0, talk_challenge=False, team=[("ekans", 15), ("zubat", 15)],
        reward_flags=["rocket_puente_peleado"], reward_items={"pepita": 1}, lines={
            "desafio": "¿No? ¡Entonces vas a tener que ganártela! ¡Vas a ver lo que es el Team Rocket!",
            "pierde": "¡Argh! ¡Tenés pasta! Está bien... quedate con la Pepita.",
            "gana": "¡Ja! Pensá bien lo del Team Rocket.", "despues": "Ya me voy, ya me voy..."}),
    # Ruta 25
    ("ruta25", "Franklin"): _t("Francisco", HIKER, [("machop", 15), ("geodude", 15)],
        "¡Subiendo montañas se hacen músculos! ¡Mirá!", "¡Me bajaron de la montaña!", "Bill vive al final de la ruta, en la casita del cabo."),
    ("ruta25", "Joey"): _t("Joaquín", YOUNG, [("rattata", 15), ("spearow", 15)], "¡Mi Rattata está entre el 1% de los mejores!",
        "¡Nooo! ¡Mi Rattata!", "Igual mi Rattata es el mejor. Te lo digo yo."),
    ("ruta25", "Wayne"): _t("Wenceslao", HIKER, [("onix", 17)], "¡Encontré este Onix en una cueva! ¡Probalo!",
        "¡Ni la serpiente de roca!", "El agua y la planta parten las rocas."),
    ("ruta25", "Dan"): _t("Dani", YOUNG, [("slowpoke", 17)], "Mi Slowpoke es... re... lento... ¡pero pega!",
        "...¿Ya terminó?", "Mi Slowpoke todavía no se dio cuenta de que perdió."),
    ("ruta25", "Kelsey"): _t("Celeste", PICNIC, [("nidoran_m", 15), ("nidoran_f", 15)], "¡Vine de picnic con mis Nidoran!",
        "¡Se me arruinó el picnic!", "¿Querés un sanguchito? Ah, no, se los comieron los Nidoran."),
    ("ruta25", "Nob"): _t("Norberto", HIKER, [("geodude", 13), ("geodude", 13), ("machop", 13), ("geodude", 13)],
        "¡Cuatro Pokémon de pura fuerza! ¡Aguantá!", "¡Qué aguante el tuyo!", "Los Geodude ruedan barranca abajo."),
    ("ruta25", "Flint"): _t("Facundo", CAMPER, [("rattata", 14), ("ekans", 14)], "¡Acampando y peleando, así vivo!",
        "¡Me desarmaste la carpa!", "¿Ya fuiste a ver a Bill?"),
    ("ruta25", "Chad"): _t("Chacho", YOUNG, [("ekans", 14), ("sandshrew", 14)], "¡Te estaba esperando!",
        "¡No era tan fácil como pensaba!", "Bill es un genio de las computadoras."),
    ("ruta25", "Haley"): _t("Helena", LASS, [("oddish", 13), ("pidgey", 13), ("oddish", 13)], "¡Ay, qué día lindo para pelear!",
        "¡Qué día feo!", "La casa de Bill tiene vista al mar."),
    # Gimnasio de Ciudad Celeste (arena de agua: data/arenas/arena_gimnasio_agua)
    ("ciudad_celeste_gimnasio", "Luis"): _t("Luis", "Nadador", [("horsea", 16), ("shellder", 16)],
        "¡Antes de Misty, tenés que nadar conmigo!", "¡Me ahogué!", "Misty es la sirena del gimnasio. ¡Ojo!",
        arena="arena_gimnasio_agua", sight=1),
    ("ciudad_celeste_gimnasio", "Diana"): _t("Diana", PICNIC, [("goldeen", 19)], "¡Mi Goldeen es la reina del agua!",
        "¡Se me escapó del anzuelo!", "Para Misty: eléctrico o planta. Te lo regalo.", arena="arena_gimnasio_agua", sight=4),
    ("ciudad_celeste_gimnasio", "Misty"): dict(name="Misty", title="Líder", team=[("staryu", 18), ("starmie", 21)],
        arena="arena_gimnasio_agua", sight=0, leader=True, reward_flags=["medalla_cascada"],
        reward="¡Recibiste la MEDALLA CASCADA de Misty!", lines={
        "desafio": "¡Hola! Soy Misty, la líder del Gimnasio de Ciudad Celeste.|Mi política es atacar con Pokémon de tipo "
                   "agua. ¿Te animás a meterte a la pileta?",
        "pierde": "¡Uf! Sos muy bueno... ¡Está bien, te ganaste la Medalla Cascada!",
        "gana": "¡Te hundiste! Volvé cuando sepas nadar.",
        "despues": "Con la Medalla Cascada tus Pokémon te hacen más caso. ¡Seguí así!"}),
})

_FIVE = ["vencido_ruta24_cale", "vencido_ruta24_ali", "vencido_ruta24_timmy", "vencido_ruta24_reli", "vencido_ruta24_ethan"]
TALKS.update({
    # Ruta 3 / Ruta 4
    ("ruta3", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "¿Ves el Mt. Moon allá? Adentro hay Clefairy... ¡y dicen que también anda el Team Rocket!"])]),
    ("ruta4", "Woman"): dict(name="Señora", talks=[dict(lines=[
        "Bajé del Mt. Moon y casi me pierdo. ¡Menos mal que hay un Centro Pokémon acá!"])]),
    ("ruta4", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "Si saltás esos bordes no hay vuelta atrás. ¡Ciudad Celeste está al este!"])]),
    ("ruta4", "MegaPunchTutor"): dict(name="Luchador", talks=[dict(lines=[
        "¡Hah! ¡Megapuño! ...Todavía no te lo puedo enseñar. Volvé más fuerte."])]),
    ("ruta4", "MegaKickTutor"): dict(name="Luchador", talks=[dict(lines=["¡Megapatada! El que patea primero, patea dos veces."])]),
    ("ruta4_centro", "Nurse"): NURSE,
    ("ruta4_centro", "MagikarpSalesman"): dict(name="Vendedor", talks=[
        dict(forbids=["magikarp_comprado"], lines=["¡Ey, pibe! Te tengo una oferta imperdible."], action="vender_magikarp"),
        dict(lines=["Ya te vendí el Magikarp. Sin devoluciones, eh."])]),
    ("ruta4_centro", "Gentleman"): dict(name="Señor", talks=[dict(lines=[
        "El Team Rocket anda robando en Ciudad Celeste. ¡Qué tiempos!"])]),
    ("ruta4_centro", "Boy"): dict(name="Chico", talks=[dict(lines=[
        "En el Mt. Moon encontré una Piedra Lunar. ¡Dicen que hace evolucionar a Clefairy!"])]),
    ("ruta4_centro", "Youngster"): dict(name="Pibe", talks=[dict(lines=["Me compré un Magikarp... ¡y solo sabe salpicar!"])]),
    # Mt. Moon
    ("mt_moon", "BaldingMan"): dict(name="Señor", talks=[dict(lines=[
        "Los Zubat salen de todos lados. ¡Por eso vengo con Repelente!"])]),
    ("mt_moon_s2", "DomeFossil"): dict(name="Fósil Domo", gfx="item_ball", hide_if=["fosil_elegido"], talks=[
        dict(forbids=["vencido_mt_moon_s2_miguel"], lines=["(Un fósil. Miguel no te deja ni acercarte.)"]),
        dict(confirm="¿Te llevás el Fósil Domo?", give={"fosil_domo": 1}, set_flags=["fosil_elegido", "fosil_domo_elegido"],
             lines=["(Es el Fósil Domo: parece el caparazón de un Pokémon antiquísimo.)"], after_speaker="Miguel",
             after_lines=["¡Entonces el Fósil Hélix es mío! Dicen que en Isla Canela los reviven..."])]),
    ("mt_moon_s2", "HelixFossil"): dict(name="Fósil Hélix", gfx="item_ball", hide_if=["fosil_elegido"], talks=[
        dict(forbids=["vencido_mt_moon_s2_miguel"], lines=["(Un fósil. Miguel no te deja ni acercarte.)"]),
        dict(confirm="¿Te llevás el Fósil Hélix?", give={"fosil_helix": 1}, set_flags=["fosil_elegido", "fosil_helix_elegido"],
             lines=["(Es el Fósil Hélix: tiene forma de caracol, como una concha antigua.)"], after_speaker="Miguel",
             after_lines=["¡Entonces el Fósil Domo es mío! Dicen que en Isla Canela los reviven..."])]),
    # Ciudad Celeste
    ("ciudad_celeste", "0x0"): dict(name=RIVAL, show_if=["historia"], hide_if=["rival_celeste_peleado"], talks=[
        dict(lines=["¿Ya fuiste al gimnasio? Yo ya tengo la medalla, obvio."])]),
    ("ciudad_celeste", "Policeman"): dict(name="Policía", talks=[dict(lines=[
        "El Team Rocket entró a robar en esta casa. Se llevaron una MT.", "No se puede pasar: estamos investigando."])]),
    ("ciudad_celeste", "LittleBoy"): dict(name="Nene", talks=[dict(lines=["¡Misty es re linda! Pero pelea re fuerte."])]),
    ("ciudad_celeste", "BaldingMan"): dict(name="Señor", talks=[dict(lines=["La bici de la tienda cuesta un millón. ¡Un millón!"])]),
    ("ciudad_celeste", "Slowbro"): dict(name="Slowbro", talks=[dict(lines=[
        "Slowbro: ...", "(Está mirando la nada. No le importa nada.)"])]),
    ("ciudad_celeste", "Lass"): dict(name="Chica", talks=[dict(lines=["¡Slowbro, hacé Confusión! ...Nunca me hace caso."])]),
    ("ciudad_celeste", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Al norte está el Puente Pepita: cinco entrenadores al hilo."])]),
    ("ciudad_celeste", "Woman"): dict(name="Señora", talks=[dict(lines=[
        "Si te entrenás con Pokémon de planta o eléctricos, Misty no te asusta."])]),
    ("ciudad_celeste_centro", "Nurse"): NURSE,
    ("ciudad_celeste_centro", "Gentleman"): dict(name="Señor", talks=[dict(lines=[
        "Bill es el que inventó el sistema de la PC de Pokémon."])]),
    ("ciudad_celeste_centro", "Rocker"): dict(name="Rockero", talks=[dict(lines=["¡Yeah! ¡Los Pokémon de agua son lo más!"])]),
    ("ciudad_celeste_centro", "Youngster"): dict(name="Pibe", talks=[dict(lines=[
        "Me dijeron que pasando el puente hay Abra. ¡Se escapan al toque!"])]),
    ("ciudad_celeste_centro", "Lass"): dict(name="Chica", talks=[dict(lines=["Misty es la menor de cuatro hermanas. ¡Y la más fuerte!"])]),
    ("ciudad_celeste_tienda", "Clerk"): dict(name="Vendedor", talks=[dict(lines=["¡Bienvenido a la Tienda Pokémon!"],
        action="tienda_ciudad_celeste")]),
    ("ciudad_celeste_tienda", "Woman"): dict(name="Señora", talks=[dict(lines=[
        "Las Superpociones curan un montón. ¡Valen lo que cuestan!"])]),
    ("ciudad_celeste_tienda", "Youngster"): dict(name="Pibe", talks=[dict(lines=["Vendí una Pepita acá y me hice rico. ¡Bueno, casi!"])]),
    ("ciudad_celeste_gimnasio", "GymGuy"): dict(name="Guía", talks=[
        dict(forbids=["medalla_cascada"], lines=["¡Ey, campeón en potencia! Misty usa Pokémon de agua.",
            "Los eléctricos y los de planta son tu mejor apuesta. Y ojo: ¡el agua de las piletas conduce la electricidad!"]),
        dict(lines=["¡Le ganaste a Misty! ¡Qué crack!"])]),
    ("ciudad_celeste_casa_robada", "Hiker"): dict(name="Dueño", talks=[dict(lines=[
        "¡El Team Rocket me hizo un agujero en la pared y se llevó mi MT de Excavar!"])]),
    ("ciudad_celeste_casa_robada", "Lass"): dict(name="Chica", talks=[dict(lines=["¡Qué susto! Entraron por atrás..."])]),
    # Ruta 24: el Rocket del puente (te felicita, te da la Pepita y te quiere reclutar: disparador "rocket_puente")
    ("ruta24", "Rocket"): dict(name="Señor", hide_if=["rocket_puente_peleado"], talks=[
        dict(forbids=_FIVE[-1:], lines=["¿Venís por el Puente Pepita? Ganale a los cinco y te doy un premio."]),
        dict(lines=["Ya me voy, ya me voy..."])]),
    ("ruta25", "Beauty"): dict(name="Chica", talks=[dict(lines=["La casa de Bill está acá nomás. ¡Es un genio, un poco raro!"])]),
    ("ruta25", "Man"): dict(name="Señor", talks=[dict(lines=["Vine a ver los Pokémon raros de Bill. ¡Tiene uno de cada!"])]),
    # Casa de Bill: Bill convertido en Clefairy (la 2ª persona con el script "Bill" es el Clefairy)
    ("casa_bill", "Bill"): dict(name="Bill", show_if=["bill_ayudado"], talks=[
        dict(forbids=["ticket_barco_recibido"], give={"ticket_barco": 1}, set_flags=["ticket_barco_recibido"], lines=[
            "¡Uf, volví a ser yo! ¡Gracias, de verdad!", "Estaba probando el Separador Celular y me mezclé con un Clefairy...",
            "Tomá, te regalo esto: un Ticket para el S.S. Anne, el crucero que está en Ciudad Carmín.",
            "Hay una fiesta a bordo llena de entrenadores. ¡Andá!"]),
        dict(lines=["Si un día querés ver mi colección de Pokémon raros, pasá cuando quieras."])]),
    ("casa_bill", "Bill_2"): dict(name="Clefairy", hide_if=["bill_ayudado"], talks=[
        dict(confirm="¿Activás el Separador Celular de la PC?", set_flags=["bill_ayudado"], lines=[
            "¡Ey! ¡No soy un Pokémon! ¡Soy Bill, el maniático de los Pokémon!",
            "Un experimento me salió mal y quedé mezclado con un Clefairy.",
            "¿Me hacés un favor? Metete en la máquina... ¡no, yo me meto! Vos activá el Separador en la PC."],
            after_lines=["(Activaste el Separador Celular. ¡La máquina hace un ruido raro!)"])]),
})
TRIGGERS["rival_celeste"] = dict(zone="ciudad_celeste", rect=(38, 4, 3, 1), once=False, talk=dict(
    requires=["historia"], forbids=["rival_celeste_peleado"], speaker=RIVAL, lines=["¡Eh, esperá!"],
    battle_npc="ciudad_celeste_0x0"))
TRIGGERS["rocket_puente"] = dict(zone="ruta24", rect=(3, 28, 10, 1), once=False, talk=dict(
    requires=_FIVE, forbids=["rocket_puente_peleado"], speaker="Señor", lines=[
        "¡Felicitaciones! ¡Le ganaste a los cinco del Puente Pepita!", "El premio es una Pepita: vale un montón de plata.",
        "Pero decime... con lo bueno que sos, ¿no te gustaría unirte al Team Rocket?"], battle_npc="ruta24_rocket"))
for (_zone, _script), _item in {
        ("mt_moon", "ItemParalyzeHeal"): "antiparalizador", ("mt_moon", "ItemPotion"): "pocion",
        ("mt_moon", "ItemRareCandy"): "caramelo_raro", ("mt_moon", "ItemMoonStone"): "piedra_lunar",
        ("mt_moon_s2", "ItemStarPiece"): "trozo_estrella", ("mt_moon_s2", "ItemRevive"): "revivir",
        ("mt_moon_s2", "ItemAntidote"): "antidoto"}.items():
    _flag = "objeto_%s_%s" % (_zone, _script.lower())
    TALKS[(_zone, _script)] = dict(name="Objeto", gfx="item_ball", hide_if=[_flag], talks=[
        dict(give={_item: 1}, set_flags=[_flag], lines=[])])
# El chico de Plateada, después de la medalla, te manda a la Ruta 3 (que ahora existe).
TALKS[("ciudad_plateada", "GymGuide")]["talks"][1] = dict(lines=[
    "¡Le ganaste a Brock! ¡Sos un crack!", "La Ruta 3 sigue por acá, hacia el Mt. Moon. ¡Del otro lado está Ciudad Celeste!"])


# =================================================================================================================
# --- Capítulo 3: de Ciudad Celeste al Gimnasio de Ciudad Carmín (docs/PLAN_CAPITULO_3.md) ------------------------
# Equipos de FireRed (pret: trainer_parties.h). Banderas: rocket_celeste_peleado, rival_ss_anne_peleado, tiene_corte,
# surge_puerta_abierta (VermilionGymPuzzle), medalla_trueno. Corte: FieldMoves (MO01 + Medalla Cascada).
SAILOR, GENT, FISHER, ENGINEER = "Marinero", "Caballero", "Pescador", "Mecánico"
ELEC = "arena_gimnasio_electrico"

TRAINERS.update({
    # Ciudad Celeste: el Rocket que robó la MT28 (detrás de la casa robada)
    ("ciudad_celeste", "Grunt"): _t("Rocket", ROCKET, [("machop", 17), ("drowzee", 17)],
        "¡Ey! ¡Nadie me vio salir por el agujero! ...¿Vos me viste? ¡Entonces peleamos!",
        "¡Uf! Está bien, está bien. Tomá la MT, igual ya no me sirve.", "Me voy antes de que llegue la policía...",
        sight=3, reward_items={"mt28": 1}, reward_flags=["rocket_celeste_peleado"]),
    # Ruta 6
    ("ruta6", "Keigo"): _t("Kevin", BUG, [("weedle", 16), ("caterpie", 16), ("weedle", 16)],
        "¡Mis bichos están listos! ¿Y los tuyos?", "¡Bzzz! Se me escaparon.", "Algún día voy a tener un Beedrill."),
    ("ruta6", "Elijah"): _t("Elías", BUG, [("butterfree", 20)], "¡Mi Caterpie ya es un Butterfree! ¡Mirá cómo vuela!",
        "¡Aterrizó de panza!", "Los Butterfree tiran polvos que duermen y paralizan."),
    ("ruta6", "Ricky"): _t("Rodrigo", CAMPER, [("squirtle", 20)], "¡Mi Squirtle y yo somos inseparables!",
        "¡Squirtle, volvé!", "Squirtle se mete en el caparazón cuando le pegan."),
    ("ruta6", "Jeff"): _t("Joel", CAMPER, [("spearow", 16), ("raticate", 16)], "¡Ey, vos! ¡Combate ya!",
        "¡No llegué ni a calentar!", "Ciudad Carmín está al sur. Huele a mar."),
    ("ruta6", "Nancy"): _t("Nancy", PICNIC, [("rattata", 16), ("pikachu", 16)], "¡Pikachu y yo vinimos de picnic!",
        "¡Se me cayó el sánguche!", "Pikachu me sigue a todos lados."),
    ("ruta6", "Isabelle"): _t("Isabel", PICNIC, [("pidgey", 16), ("pidgey", 16), ("pidgey", 16)],
        "¡Tres Pidgey! ¿Te animás?", "¡Volaron los tres!", "Los Pidgey son re fáciles de criar."),
    # S.S. Anne
    ("ss_anne_cubierta", "Trevor"): _t("Toribio", SAILOR, [("machop", 17), ("tentacool", 17)], "¡Ahoy! ¡Los marineros somos fuertes!",
        "¡Me tiraste por la borda!", "El mar está calmo hoy."),
    ("ss_anne_cubierta", "Edmond"): _t("Edmundo", SAILOR, [("machop", 18), ("shellder", 18)], "¡A ver qué tal pelea un pasajero!",
        "¡Hundido!", "El capitán está mareado. ¡Un capitán mareado! Qué papelón."),
    ("ss_anne_1p_camarote2", "Ann"): _t("Ana", LASS, [("pidgey", 18), ("nidoran_f", 18)], "¡Ay, un pasajero nuevo! ¿Peleamos?",
        "¡Uy, perdí!", "La fiesta es en el segundo piso."),
    ("ss_anne_1p_camarote2", "Tyler"): _t("Tadeo", YOUNG, [("nidoran_m", 21)], "¡Mi Nidoran es el más fuerte del barco!",
        "¡Uh! ¡No era tan fuerte!", "Mi papá me trajo al crucero. ¡Está buenísimo!"),
    ("ss_anne_1p_camarote5", "Arthur"): _t("Arturo", GENT, [("nidoran_m", 19), ("nidoran_f", 19)], "Un caballero siempre acepta un desafío.",
        "Excelente combate, joven.", "Viajar en barco es muy elegante, ¿no le parece?"),
    ("ss_anne_1p_camarote7", "Thomas"): _t("Teodoro", GENT, [("growlithe", 18), ("growlithe", 18)], "Mis Growlithe son de pura raza.",
        "Mis cachorros...", "Los Growlithe son muy leales."),
    ("ss_anne_2p_camarote2", "Dale"): _t("Daniel", FISHER, [("goldeen", 17), ("tentacool", 17), ("goldeen", 17)],
        "¡Picó uno! ...Ah, no, sos un entrenador.", "Se me cortó la línea.", "Desde el barco no se puede pescar. ¡Qué bronca!"),
    ("ss_anne_2p_camarote2", "Brooks"): _t("Celio", GENT, [("pikachu", 23)], "Mi Pikachu es mi orgullo. ¿Probamos?",
        "Bravo, bravo.", "Lt. Surge, el líder de Carmín, ama a los Pikachu."),
    ("ss_anne_2p_camarote4", "Lamar"): _t("Lener", GENT, [("growlithe", 17), ("ponyta", 17)], "¡Fuego en alta mar!",
        "Se me apagó la llama.", "Ponyta corre más rápido que cualquier barco."),
    ("ss_anne_2p_camarote4", "Dawn"): _t("Arrate", LASS, [("rattata", 18), ("pikachu", 18)], "¡Mi Pikachu está re cargado!",
        "¡Se le acabó la pila!", "El capitán está arriba de todo."),
    ("ss_anne_s1_camarote1", "Barny"): _t("Beltrán", FISHER, [("tentacool", 17), ("staryu", 17), ("shellder", 17)],
        "Los Pokémon de mar son los mejores. ¡Te lo demuestro!", "¡Se escaparon al agua!", "En el mar hay Tentacool por todos lados."),
    ("ss_anne_s1_camarote1", "Phillip"): _t("Felipe", SAILOR, [("machop", 20)], "¡Mi Machop levanta anclas!",
        "¡Ancla caída!", "Los Machop entrenan todo el día."),
    ("ss_anne_s1_camarote2", "Huey"): _t("Humberto", SAILOR, [("tentacool", 18), ("staryu", 18)], "¡Nadie pasa por mi camarote sin pelear!",
        "¡Uf, me ganaste!", "El agua y la electricidad no se llevan."),
    ("ss_anne_s1_camarote3", "Dylan"): _t("Dan", SAILOR, [("horsea", 17), ("horsea", 17), ("horsea", 17)], "¡Tres Horsea al ataque!",
        "¡Tinta por todos lados!", "Los Horsea tiran tinta para escapar."),
    ("ss_anne_s1_camarote4", "Duncan"): _t("Dato", SAILOR, [("horsea", 17), ("shellder", 17), ("tentacool", 17)],
        "¡Marinero en guardia!", "¡Hombre al agua!", "El sótano del barco es puro camarote de marineros."),
    ("ss_anne_s1_camarote4", "Leonard"): _t("Leonardo", SAILOR, [("shellder", 21)], "¡Mi Shellder no se abre por nada!",
        "¡Se abrió!", "Un Shellder cerrado aguanta mucho."),
    # El rival en el pasillo del 2º piso (te frena antes del camarote del capitán)
    ("ss_anne_2p", "0x0"): dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False, reward_flags=["rival_ss_anne_peleado"],
        team=[("pidgeotto", 19), ("raticate", 16), ("kadabra", 18), ("wartortle", 20, "rival_squirtle"),
              ("ivysaur", 20, "rival_bulbasaur"), ("charmeleon", 20, "rival_charmander")],
        lines={"desafio": "¡Eh! ¿Vos también te colaste a la fiesta?|Seguro que viniste a ver al capitán. ¡Primero tenés que pasar por mí!",
               "pierde": "¡¿Otra vez?! ...Bueno, el capitán te va a dar algo copado. Andá, andá.|Yo me voy: ¡tengo que atrapar más Pokémon!",
               "gana": "¡Ja! Seguís siendo el segundo.", "despues": "¡Nos vemos!"}),
    # Gimnasio de Ciudad Carmín
    ("ciudad_carmin_gimnasio", "Tucker"): _t("Tucker", GENT, [("pikachu", 23)], "El teniente nos entrenó a todos. ¡En guardia!",
        "Impecable.", "Los basureros esconden más de lo que parece.", arena=ELEC, sight=3),
    ("ciudad_carmin_gimnasio", "Dwayne"): _t("Dwayne", SAILOR, [("pikachu", 21), ("pikachu", 21)], "¡Dos Pikachu, doble descarga!",
        "¡Cortocircuito!", "El teniente Surge fue soldado. ¡Es durísimo!", arena=ELEC, sight=3),
    ("ciudad_carmin_gimnasio", "Baily"): _t("Benito", ENGINEER, [("voltorb", 21), ("magnemite", 21)], "¡Yo armé las trampas eléctricas de este gimnasio!",
        "¡Se me quemó un fusible!", "Los interruptores están en los basureros. ¡Pero no te digo cuáles!", arena=ELEC, sight=3),
    ("ciudad_carmin_gimnasio", "LtSurge"): dict(name="Lt. Surge", title="Líder", team=[("voltorb", 21), ("pikachu", 18), ("raichu", 24)],
        arena=ELEC, sight=0, leader=True, reward_flags=["medalla_trueno"], reward="¡Recibiste la MEDALLA TRUENO de Lt. Surge!", lines={
        "desafio": "¡Hey, kid! ¿Llegaste hasta acá? ¡Nice!|Soy Lt. Surge, el líder del Gimnasio de Ciudad Carmín. En la guerra, los Pokémon "
                   "eléctricos me salvaron la vida.|¡Te voy a electrocutar como a todos! ¡Ready!",
        "pierde": "¡Whoa! ¡Sos el real deal, kid! Está bien, te ganaste la Medalla Trueno.",
        "gana": "¡Ha! ¡Volvé cuando aguantes la corriente!",
        "despues": "Con la Medalla Trueno tus Pokémon son más rápidos. ¡Keep it up!"}),
})

TALKS.update({
    # Ciudad Celeste: después de Misty el policía se va de la puerta de la casa robada
    ("ciudad_celeste", "Policeman"): dict(name="Policía", hide_if=["medalla_cascada"], talks=[dict(lines=[
        "El Team Rocket entró a robar en esta casa. Se llevaron una MT.", "No se puede pasar: estamos investigando."])]),
    ("ciudad_celeste_casa_robada", "Hiker"): dict(name="Dueño", talks=[
        dict(forbids=["rocket_celeste_peleado"], lines=["¡El Team Rocket me hizo un agujero en la pared y se llevó mi MT de Excavar!",
            "El ladrón se escapó por atrás. ¡Si lo ves, recuperala!"]),
        dict(lines=["¿Recuperaste la MT? ¡Quedatela, te la ganaste!"])]),
    # Ruta 5 / Vía Subterránea / Ruta 6
    ("ruta5_guarderia", "DaycareMan"): dict(name="Señor", talks=[dict(lines=[
        "Esto va a ser una guardería de Pokémon. Por ahora estamos de mudanza. ¡Volvé más adelante!"])]),
    ("ruta5_garita", "Guard"): dict(name="Guardia", talks=[dict(lines=["¡Uf, qué sed!", "Ciudad Azafrán está cerrada por ahora. Usá la Vía Subterránea."])]),
    ("ruta6_garita", "Guard"): dict(name="Guardia", talks=[dict(lines=["Ciudad Azafrán está cerrada. Para ir a Celeste, la Vía Subterránea."])]),
    ("via_subterranea_norte", "Saige"): dict(name="Nena", talks=[dict(lines=["La Vía Subterránea va derecho hasta Ciudad Carmín. ¡Es larguísima!"])]),
    ("via_subterranea_sur", "Woman"): dict(name="Señora", talks=[dict(lines=["En Ciudad Carmín está el S.S. Anne, un crucero lujosísimo."])]),
    # Ciudad Carmín
    ("ciudad_carmin", "Woman"): dict(name="Señora", talks=[dict(lines=["¡El S.S. Anne viene una vez por año! Hay una fiesta a bordo."])]),
    ("ciudad_carmin", "OldMan1"): dict(name="Abuelo", talks=[dict(lines=["Ese Machop está aplanando el terreno para construir algo."])]),
    ("ciudad_carmin", "OldMan2"): dict(name="Abuelo", talks=[dict(lines=["Hay un árbol fino tapando el gimnasio. Sin Corte, no pasás."])]),
    ("ciudad_carmin", "Machop"): dict(name="Machop", talks=[dict(lines=["Machop: ¡Machooop!", "(Está pisando el suelo con todas sus fuerzas.)"])]),
    ("ciudad_carmin", "Sailor"): dict(name="Marinero", talks=[dict(lines=["El capitán del S.S. Anne se marea. ¡Un capitán que se marea!"])]),
    ("ciudad_carmin", "FerrySailor"): dict(name="Marinero", talks=[
        dict(forbids=["ticket_barco_recibido"], lines=["Para subir al S.S. Anne necesitás un ticket."]),
        dict(lines=["¡Bienvenido! Mostrame tu ticket... ¡Perfecto, adelante!"])]),
    ("ciudad_carmin_centro", "Nurse"): NURSE,
    ("ciudad_carmin_centro", "Man"): dict(name="Señor", talks=[dict(lines=["Lt. Surge es un excombatiente. ¡Sus Pokémon eléctricos son tremendos!"])]),
    ("ciudad_carmin_centro", "Hiker"): dict(name="Montañero", talks=[dict(lines=["Contra lo eléctrico, la tierra. Un Geodude o un Sandshrew no sienten nada."])]),
    ("ciudad_carmin_centro", "Youngster"): dict(name="Pibe", talks=[dict(lines=["¡Mi Pikachu le ganó a un Squirtle! El agua no le gana a la electricidad."])]),
    ("ciudad_carmin_centro", "VSSeekerWoman"): dict(name="Chica", talks=[dict(lines=["Los entrenadores del barco son de todas partes del mundo."])]),
    ("ciudad_carmin_tienda", "Clerk"): dict(name="Vendedor", talks=[dict(lines=["¡Bienvenido a la Tienda Pokémon!"], action="tienda_ciudad_carmin")]),
    ("ciudad_carmin_tienda", "CooltrainerF"): dict(name="Chica", talks=[dict(lines=["El Antihielo no se consigue en todos lados. ¡Acá sí!"])]),
    ("ciudad_carmin_tienda", "BaldingMan"): dict(name="Señor", talks=[dict(lines=["Las Superpociones son lo mejor para un viaje largo."])]),
    ("club_fans", "Chairman"): dict(name="Presidente", talks=[dict(lines=["¡Bienvenido al Club de Fans de los Pokémon!",
        "¿Querés que te cuente de mi Rapidash? ...¡Otro día, que es una historia larga!"])]),
    ("club_fans", "WorkerF"): dict(name="Secretaria", talks=[dict(lines=["El presidente habla horas de su Rapidash. ¡Horas!"])]),
    ("club_fans", "Pikachu"): dict(name="Pikachu", talks=[dict(lines=["Pikachu: ¡Pika pika!"])]),
    ("club_fans", "Seel"): dict(name="Seel", talks=[dict(lines=["Seel: ¡Seeel!"])]),
    ("club_fans", "Woman"): dict(name="Señora", talks=[dict(lines=["Mi Pikachu es el más lindo del club. ¡No discutas!"])]),
    ("club_fans", "FatMan"): dict(name="Señor", talks=[dict(lines=["Mi Seel es campeón de natación. Bueno, de flotar."])]),
    ("ciudad_carmin_gimnasio", "GymGuy"): dict(name="Guía", talks=[
        dict(forbids=["medalla_trueno"], lines=["¡Ey, campeón! Lt. Surge usa Pokémon eléctricos.",
            "Los de tierra no sienten la electricidad. Y para llegar a él, buscá los interruptores en los basureros:",
            "el segundo siempre está al lado del primero. ¡Si le errás, se reinician!"]),
        dict(lines=["¡Le ganaste a Surge! ¡Sos una bestia!"])]),
    ("ciudad_carmin_casa1", "FishingGuru"): dict(name="Pescador", talks=[dict(lines=["¡Pescar es lo mejor de la vida! Cuando tenga una caña de sobra, te la doy."])]),
    ("ciudad_carmin_casa2", "Elyssa"): dict(name="Nena", talks=[dict(lines=["Quiero un Farfetch'd. ¡Tienen un puerro!"])]),
    ("ciudad_carmin_casa3", "Boy"): dict(name="Chico", talks=[dict(lines=["Mi Pidgey lleva cartas a todos lados. ¡Es mi cartero!"])]),
    ("ciudad_carmin_casa3", "Pidgey"): dict(name="Pidgey", talks=[dict(lines=["Pidgey: ¡Pío!"])]),
    ("ciudad_carmin_casa3", "Lass"): dict(name="Chica", talks=[dict(lines=["¡Qué lindo es vivir al lado del puerto!"])]),
    # S.S. Anne
    ("ss_anne_1p", "Sailor"): dict(name="Marinero", talks=[dict(lines=["¡Bienvenido a bordo del S.S. Anne! La fiesta está en todos los pisos."])]),
    ("ss_anne_1p", "WorkerM"): dict(name="Mozo", talks=[dict(lines=["¿Gusta algo de tomar? ...Ah, es un nene. ¡Un jugo, entonces!"])]),
    ("ss_anne_2p", "0x0"): dict(name=RIVAL, show_if=["historia"], hide_if=["rival_ss_anne_peleado"], talks=[
        dict(lines=["El capitán está acá arriba. ¡Pero primero yo!"])]),
    ("ss_anne_2p", "Sailor"): dict(name="Marinero", talks=[dict(lines=["El camarote del capitán está al fondo del pasillo, subiendo."])]),
    ("ss_anne_3p", "Sailor"): dict(name="Marinero", talks=[dict(lines=["Por acá se sube a la cubierta. ¡Ojo con el viento!"])]),
    ("ss_anne_cubierta", "BaldingMan"): dict(name="Señor", talks=[dict(lines=["¡Uf! Me mareé... Vine a tomar aire."])]),
    ("ss_anne_cubierta", "Sailor"): dict(name="Marinero", talks=[dict(lines=["¡Qué lindo día para navegar!"])]),
    ("ss_anne_cubierta", "Youngster"): dict(name="Pibe", talks=[dict(lines=["¡Desde acá se ve todo Ciudad Carmín!"])]),
    ("ss_anne_capitan", "Captain"): dict(name="Capitán", talks=[
        dict(forbids=["tiene_corte"], give={"mo01": 1}, set_flags=["tiene_corte"], lines=[
            "(El capitán está pálido y apoyado en el escritorio.)", "Uuuh... estoy mareado... me quiero morir...",
            "(Le frotás la espalda...)", "¡Uf! ¡Ahora sí! ¡Mucho mejor! ¡Gracias, de verdad!",
            "Te quiero agradecer: tomá esta MO. Es Corte: no hace falta enseñársela a nadie. Caminá contra un árbol fino y tu Pokémon lo corta.",
            "Para usarla fuera de combate necesitás la Medalla Cascada."]),
        dict(lines=["¡Gracias de nuevo! Con Corte, caminá contra un árbol fino y tu Pokémon lo corta solo."])]),
})
for (_zone, _script), _who in {
        ("ss_anne_cocina", "Chef1"): "¡Fuera de la cocina! ...Bueno, mirá nomás.", ("ss_anne_cocina", "Chef2"): "¡Esta noche hay pescado!",
        ("ss_anne_cocina", "Chef3"): "Le estoy preparando el té al capitán. ¡Para el mareo!", ("ss_anne_cocina", "Chef4"): "¡Más sal! ¡Más sal!",
        ("ss_anne_cocina", "Chef5"): "¿Un Pokémon en mi cocina? ¡Afuera!", ("ss_anne_cocina", "Chef6"): "La fiesta de esta noche es enorme.",
        ("ss_anne_cocina", "Chef7"): "¡Uy, se me quemó la salsa!",
        ("ss_anne_1p_camarote1", "Gentleman"): "Los entrenadores del barco son de primer nivel.",
        ("ss_anne_1p_camarote2", "Woman"): "Mis hijos no paran de pelear con los pasajeros.",
        ("ss_anne_1p_camarote3", "LittleGirl"): "¡Mi Wigglytuff es re esponjoso!", ("ss_anne_1p_camarote3", "Wigglytuff"): "Wigglytuff: ¡Wiggly!",
        ("ss_anne_1p_camarote3", "BaldingMan"): "Viajo por el mundo buscando Pokémon raros.",
        ("ss_anne_1p_camarote4", "Woman"): "¡Qué crucero divino!", ("ss_anne_1p_camarote6", "Woman"): "Dicen que el capitán se marea. ¡Qué gracioso!",
        ("ss_anne_2p_camarote1", "Gentleman"): "En otros países hay Pokémon que acá no se ven.",
        ("ss_anne_2p_camarote3", "Gentleman"): "¿Conocés la Zona Safari? Queda en Ciudad Fucsia.",
        ("ss_anne_2p_camarote3", "OldMan"): "De joven fui marinero. ¡Nunca me mareé!",
        ("ss_anne_2p_camarote5", "Gentleman"): "Un Snorlax duerme en una ruta y no deja pasar a nadie. ¡Increíble!",
        ("ss_anne_2p_camarote5", "LittleBoy"): "¡Quiero un Snorlax!", ("ss_anne_2p_camarote6", "Woman2"): "Esta fiesta es lo más.",
        ("ss_anne_2p_camarote6", "Woman1"): "¿Ya fuiste a ver al capitán?",
        ("ss_anne_s1_camarote5", "Boy"): "¡Mi Machoke entrena conmigo todos los días!", ("ss_anne_s1_camarote5", "Machoke"): "Machoke: ¡Machooo!"}.items():
    _name = _who.split(":")[0] if ": " in _who else ("Cocinero" if _script.startswith("Chef") else "Pasajero")
    TALKS[(_zone, _script)] = dict(name=_name, talks=[dict(lines=[_who])])
for (_zone, _script), _item in {("ss_anne_cocina", "ItemGreatBall"): "super_ball",
                                ("ss_anne_s1_camarote5", "ItemSuperPotion"): "superpocion"}.items():
    _flag = "objeto_%s_%s" % (_zone, _script.lower())
    TALKS[(_zone, _script)] = dict(name="Objeto", gfx="item_ball", hide_if=[_flag], talks=[
        dict(give={_item: 1}, set_flags=[_flag], lines=[])])
# Sin el Ticket de Bill no se sube al barco; el rival te frena en el pasillo del 2º piso (antes del capitán).
TRIGGERS["ticket_ss_anne"] = dict(zone="ciudad_carmin", rect=(38, 48, 3, 1), once=False, push_back=True, talk=dict(
    requires=["historia"], forbids=["ticket_barco_recibido"], speaker="Marinero", lines=[
        "¡Alto! Para subir al S.S. Anne necesitás un ticket.", "Dicen que Bill, el de la PC, tiene uno. Vive pasando el Puente Pepita."]))
TRIGGERS["rival_ss_anne"] = dict(zone="ss_anne_2p", rect=(30, 4, 3, 1), once=False, talk=dict(
    requires=["historia"], forbids=["rival_ss_anne_peleado"], speaker=RIVAL, lines=["¡Eh, esperá!"], battle_npc="ss_anne_2p_0x0"))


# =================================================================================================================
# --- Resto de Kanto (docs/PLAN_RESTO_KANTO.md): entrenadores automáticos ------------------------------------------
# Los equipos salen de data/source/trainers_frlg.json (tools/fetch_frlg_trainers.py, de pret). Solo para las zonas que
# todavía no tienen entrenadores a mano (capítulos 1-3 quedan como están). Frases por clase de entrenador; los líderes
# (LEADERS) con frases propias, su medalla y la arena de su gimnasio.
CLASS_TITLES = {
    "BEAUTY": "Belleza", "BIKER": "Motorista", "BIRD_KEEPER": "Ornitólogo", "BLACK_BELT": "Karateka", "BOSS": "Jefe Rocket",
    "BUG_CATCHER": BUG, "BURGLAR": "Ladrón", "CAMPER": "Campista", "CHANNELER": "Médium", "COOLTRAINER": "Entrenador Guay",
    "COOL_COUPLE": "Pareja Guay", "CRUSH_KIN": "Luchadoras", "CUE_BALL": "Calvo", "ENGINEER": "Mecánico",
    "FISHERMAN": "Pescador", "GAMER": "Jugador", "GENTLEMAN": "Caballero", "HIKER": "Montañero", "JUGGLER": "Malabarista",
    "LASS": "Chica", "LEADER": "Líder", "PICNICKER": "Dominguera", "POKEMANIAC": "Pokemaníaco", "PSYCHIC": "Médium Psíquico",
    "ROCKER": "Rockero", "SAILOR": "Marinero", "SCIENTIST": "Científico", "SIS_AND_BRO": "Hermanos", "SUPER_NERD": "Supernecio",
    "SWIMMER_F": "Nadadora", "SWIMMER_M": "Nadador", "TAMER": "Domador", "TEAM_ROCKET": "Soldado Rocket", "TWINS": "Gemelas",
    "YOUNGSTER": "Joven", "YOUNG_COUPLE": "Parejita",
}
# (desafío, pierde, después) por clase; se elige una variante por el nombre del entrenador.
CLASS_LINES = {
    "BUG_CATCHER": [("¡Mis bichos son los más fuertes del mundo!", "¡Bzzz! Se escaparon...", "Los bichos crecen rápido, ¿sabías?"),
                    ("¿Te gustan los bichos? ¡A mí me encantan!", "¡Mis bichitos!", "Voy a seguir buscando bichos raros.")],
    "LASS": [("¡Ey! ¡Me miraste! Ahora peleamos.", "¡Ay, qué vergüenza!", "La próxima te gano, vas a ver."),
             ("¡Mis Pokémon son re lindos y re fuertes!", "¡Uy, perdí!", "Igual mis Pokémon son los más lindos.")],
    "YOUNGSTER": [("¡Pantalón corto todo el año! ¡Peleá!", "¡Uh, perdí!", "¡Tengo que entrenar más!"),
                  ("¡A que no me ganás!", "¡Me ganaste!", "Ya vas a ver la revancha.")],
    "CAMPER": [("¡Acampando y peleando, así es la vida!", "¡Me desarmaste la carpa!", "El aire libre es lo mejor."),
               ("¡Ey, entrenador! ¡Un combate antes de la fogata!", "¡Se me apagó el fuego!", "Hay que entrenar todos los días.")],
    "PICNICKER": [("¡Vine de picnic con mis Pokémon!", "¡Se me arruinó el picnic!", "¿Querés un sanguchito? Ah, no, no queda."),
                  ("¡Qué día lindo para pelear!", "¡Qué día feo!", "Mis Pokémon se merecen un descanso.")],
    "HIKER": [("¡Las montañas me hicieron fuerte! ¡Mirá!", "¡Me bajaste de la montaña!", "Escalar es lo mejor que hay."),
              ("¡Uf! ¡Cuesta arriba se pelea mejor!", "¡Me desmoroné!", "Llevá siempre agua cuando subas.")],
    "SAILOR": [("¡Ahoy! ¡Los marineros somos fuertes!", "¡Hombre al agua!", "El mar te enseña a no rendirte.")],
    "GENTLEMAN": [("Un caballero nunca rechaza un desafío.", "Excelente combate, joven.", "La elegancia también se entrena.")],
    "FISHERMAN": [("¡Picó uno! ...Ah, no, sos un entrenador.", "Se me cortó la línea.", "La paciencia es la clave de la pesca.")],
    "SWIMMER_M": [("¡A nadar se aprende peleando!", "¡Me hundí!", "El agua está buenísima.")],
    "SWIMMER_F": [("¡Las olas me dan fuerza!", "¡Glub, glub!", "Nadar es mi vida.")],
    "BIRD_KEEPER": [("¡Mis pájaros vuelan más alto que los tuyos!", "¡Aterrizaje forzoso!", "Los Pokémon pájaro son muy leales.")],
    "BIKER": [("¡Ey, nene! ¡Esta ruta es nuestra!", "¡Se me pinchó una rueda!", "Andá con cuidado por el Camino de Bicis."),
              ("¡Rrrum! ¡Fuera de mi camino!", "¡Uf, qué piña!", "Sos más rápido de lo que pensaba.")],
    "CUE_BALL": [("¡Pelado y peligroso! ¡En guardia!", "¡Me dejaste más pelado!", "No te metas con los de la Ruta 16."),
                 ("¿Qué mirás? ¡Peleá!", "¡Ay, mi cabeza!", "Bueno, bueno, pasá.")],
    "BLACK_BELT": [("¡Hah! ¡Mis puños son de acero!", "¡Me bloqueaste!", "El entrenamiento duro nunca miente.")],
    "CHANNELER": [("¡Fuera de aquí! ¡Los espíritus están enojados!", "...¿Qué? ¿Dónde estoy?", "Algo me poseyó... qué miedo."),
                  ("Kekeke... ¡Los fantasmas te van a llevar!", "Ahh... recuperé la conciencia.", "La torre está llena de almas tristes.")],
    "PSYCHIC": [("Ya sabía que ibas a venir... ¡Peleemos!", "Esto no lo vi venir.", "La mente puede más que los músculos.")],
    "SCIENTIST": [("¡Mis experimentos te van a sorprender!", "¡Error en el cálculo!", "La ciencia avanza con cada derrota.")],
    "SUPER_NERD": [("¡Te calculé todos los movimientos!", "¡Fallaron mis cuentas!", "Voy a revisar mis notas.")],
    "ENGINEER": [("¡Nada que una buena herramienta no arregle!", "¡Se me quemó un fusible!", "Todo tiene arreglo.")],
    "BURGLAR": [("¡Ey! ¡No viste nada, ¿no?!", "¡Me agarraron!", "Ya me voy, ya me voy...")],
    "GAMER": [("¡Apuesto a que te gano!", "¡Perdí la apuesta!", "La suerte cambia, ya vas a ver.")],
    "JUGGLER": [("¡Mirá cómo hago malabares con mis Pokémon!", "¡Se me cayeron todos!", "La práctica hace al maestro.")],
    "TAMER": [("¡Mis Pokémon salvajes obedecen solo a mí!", "¡Se me rebelaron!", "Domar requiere paciencia.")],
    "ROCKER": [("¡Yeah! ¡Rockeemos este combate!", "¡Se me cortó una cuerda!", "¡Rock and roll para siempre!")],
    "BEAUTY": [("¿Te gusta mi Pokémon? Es tan elegante como yo.", "¡Ay, se me corrió el maquillaje!", "La belleza también pelea.")],
    "POKEMANIAC": [("¡Los Pokémon raros son mi pasión!", "¡Mi colección!", "¿Viste algún Pokémon raro por ahí?")],
    "COOLTRAINER": [("Entreno todos los días. ¿Estás a la altura?", "Sos muy bueno. Respeto.", "Seguí así y vas a llegar lejos."),
                    ("Solo los mejores llegan hasta acá.", "Bien jugado.", "La Liga te espera.")],
    "TEAM_ROCKET": [("¡El Team Rocket no perdona! ¡Peleá!", "¡Grrr! ¡El jefe se va a enojar!", "¡Esto no termina acá!"),
                    ("¿Un nene? ¡Andate antes de que te robe los Pokémon!", "¡Imposible!", "Ya nos vamos a ver las caras.")],
    "TWINS": [("¡Somos dos! ¡Peleamos juntas!", "¡Perdimos las dos!", "¡La próxima ganamos juntas!")],
    "YOUNG_COUPLE": [("¡Nuestro amor nos hace invencibles!", "¡Ay, no!", "Igual nos queremos mucho.")],
    "COOL_COUPLE": [("¡Pareja que pelea unida, gana unida!", "¡Nos separaron!", "Bien jugado.")],
    "SIS_AND_BRO": [("¡Hermanos al ataque!", "¡Mamá!", "La próxima te ganamos.")],
    "CRUSH_KIN": [("¡Entrenamos los músculos y los Pokémon!", "¡Uf!", "¡A seguir entrenando!")],
}
GENERIC_LINES = [("¡Ey! ¡Un combate!", "¡Me ganaste!", "Bien peleado.")]
# Zona del gimnasio → su arena (los entrenadores del gimnasio pelean ahí).
GYM_ARENAS = {"ciudad_azulona_gimnasio": "arena_gimnasio_planta", "ciudad_fucsia_gimnasio": "arena_gimnasio_veneno",
              "ciudad_azafran_gimnasio": "arena_gimnasio_psiquico", "isla_canela_gimnasio": "arena_gimnasio_fuego",
              "ciudad_verde_gimnasio": "arena_gimnasio_tierra"}
# Líderes: nombre en pret → medalla, nombre, frases.
LEADERS = {
    "Erika": dict(name="Erika", flag="medalla_arcoiris", badge="ARCOÍRIS", lines={
        "desafio": "Hola... ¡Ay, perdón, me había quedado dormida! Soy Erika, la líder de este gimnasio.|Me encantan las "
                   "flores y los Pokémon de tipo planta. ¿Querés pelear? Está bien, pero no voy a perder.",
        "pierde": "Oh... Perdí. Sos muy fuerte. Te ganaste la Medalla Arcoíris.",
        "gana": "Las flores siempre vuelven a crecer. Vos también.", "despues": "Con la Medalla Arcoíris podés usar Fuerza."}),
    "Koga": dict(name="Koga", flag="medalla_alma", badge="ALMA", lines={
        "desafio": "¡Fwahahaha! Un niño se atreve a desafiarme. Soy Koga, el maestro ninja.|Mis Pokémon venenosos te van "
                   "a envenenar hasta el alma. ¡Prepárate!",
        "pierde": "¡Hmph! Tu fuerza es auténtica. Tomá la Medalla Alma.",
        "gana": "¡Fwahahaha! El veneno siempre gana.", "despues": "Con la Medalla Alma podés usar Surf."}),
    "Sabrina": dict(name="Sabrina", flag="medalla_pantano", badge="PANTANO", lines={
        "desafio": "Sabía que ibas a venir. Lo vi hace tres años.|Soy Sabrina. Mis poderes psíquicos me dejan ver el "
                   "futuro... y en él, vos perdés.",
        "pierde": "Esto... no lo había previsto. Te ganaste la Medalla Pantano.",
        "gana": "Era tu destino.", "despues": "El futuro cambió por vos. Interesante."}),
    "Blaine": dict(name="Blaine", flag="medalla_volcan", badge="VOLCÁN", lines={
        "desafio": "¡Hah! ¡Soy Blaine, el líder ardiente! ¡Mis Pokémon de fuego van a reducirte a cenizas!|¿Tenés "
                   "suficientes Antiquemar? ¡Más te vale!",
        "pierde": "¡Me quemé! ¡Sos un fuego! Tomá la Medalla Volcán.",
        "gana": "¡Hah! ¡Te faltó fuego!", "despues": "La Mansión Pokémon guarda secretos... fijate en el diario."}),
    "Giovanni": dict(name="Giovanni", flag="medalla_tierra", badge="TIERRA", lines={
        "desafio": "Así que llegaste hasta acá. Este es mi gimnasio, el de Ciudad Verde.|Soy Giovanni, el líder... y el "
                   "jefe del Team Rocket. ¡Te voy a enseñar lo que es la verdadera fuerza!",
        "pierde": "¡Ja! Bien jugado. Te ganaste la Medalla Tierra.|Me voy a retirar a entrenar. El Team Rocket se disuelve.",
        "gana": "Todavía te falta mucho.", "despues": "..."}),
}
SKIP_AUTO = {("ruta4", "Crissy")}
_manual_zones = {z for (z, _s) in TRAINERS}
_trainers_json = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data", "source", "trainers_frlg.json")
AUTO_TRAINERS = json.load(open(_trainers_json, encoding="utf-8")) if os.path.exists(_trainers_json) else {}
for _zone, _list in AUTO_TRAINERS.items():
    if _zone in _manual_zones:
        continue
    for _script, _tr in _list.items():
        if (_zone, _script) in TRAINERS or (_zone, _script) in SKIP_AUTO:
            continue
        _variants = CLASS_LINES.get(_tr["class"], GENERIC_LINES)
        _v = _variants[sum(map(ord, _tr["name"] + _script)) % len(_variants)]
        _spec = dict(name=_tr["name"], title=CLASS_TITLES.get(_tr["class"], _tr["class"].title()),
                     team=[tuple(m) for m in _tr["team"]], sight=max(1, min(int(_tr.get("sight", 2)), 5)),
                     arena=GYM_ARENAS.get(_zone, "arena_campo"),
                     lines={"desafio": _v[0], "pierde": _v[1], "despues": _v[2]})
        _lead = LEADERS.get(_tr["name"]) if _tr["class"] == "LEADER" else None
        if _lead is not None:
            _spec.update(name=_lead["name"], sight=0, leader=True, reward_flags=[_lead["flag"]],
                         reward="¡Recibiste la MEDALLA %s de %s!" % (_lead["badge"], _lead["name"]), lines=_lead["lines"])
        TRAINERS[(_zone, _script)] = _spec


# =================================================================================================================
# --- Capítulos 4 a 8: de Carmín a la Liga Pokémon (docs/PLAN_RESTO_KANTO.md) ---------------------------------------
# Banderas principales: giovanni_escondite_vencido, medalla_arcoiris (cap. 4) · marowak_en_paz, fuji_rescatado,
# medalla_alma (cap. 5) · silph_liberada, medalla_pantano (cap. 6) · medalla_volcan (cap. 7) · medalla_tierra,
# rival_ruta22_final_peleado, alto_mando_*, campeon (cap. 8). Mecánicas: FieldMoves (Surf, Fuerza, Poké Flauta).


def _rival(teams, **kw):
    """El equipo del rival según el inicial que eligió: {"squirtle": [...], "bulbasaur": [...], "charmander": [...]}."""
    out = []
    for starter, team in teams.items():
        out += [(sp, lvl, "rival_" + starter) for sp, lvl in team]
    return out


def _flag_of(zone, script):
    return "objeto_%s_%s" % (zone, script.lower())


ELITE = "Alto Mando"
AUTO_SPECIES = {f[:-5] for f in os.listdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data", "species"))
                if f.endswith(".tres")}
TRAINERS.update({
    # --- Cap. 4: el rival en la Torre Pokémon (2º piso) ---
    ("torre_pokemon_2p", "0x0"): dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False, reward_flags=["rival_torre_peleado"],
        team=_rival({"squirtle": [("pidgeotto", 25), ("growlithe", 23), ("exeggcute", 22), ("kadabra", 20), ("wartortle", 25)],
                     "bulbasaur": [("pidgeotto", 25), ("gyarados", 23), ("growlithe", 22), ("kadabra", 20), ("ivysaur", 25)],
                     "charmander": [("pidgeotto", 25), ("exeggcute", 23), ("gyarados", 22), ("kadabra", 20), ("charmeleon", 25)]}),
        lines={"desafio": "¡Eh! ¿Qué hacés en la Torre Pokémon? ¿Se te murió algún Pokémon?|...Bueno, ya que estás, ¡peleemos!",
               "pierde": "¡¿Qué?! ¡Perdí de nuevo!|Arriba hay fantasmas... dicen que con el Scope Silph se los puede ver.",
               "gana": "¡Ja! Andá a entrenar.", "despues": "Me voy, este lugar me da escalofríos."}),
    # --- Cap. 6: el rival en Silph S.A. (7º piso) y Giovanni (11º piso) ---
    ("silph_7p", "0x0"): dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False, reward_flags=["rival_silph_peleado"],
        team=_rival({"squirtle": [("pidgeot", 37), ("growlithe", 38), ("exeggcute", 35), ("alakazam", 35), ("blastoise", 40)],
                     "bulbasaur": [("pidgeot", 37), ("gyarados", 38), ("growlithe", 35), ("alakazam", 35), ("venusaur", 40)],
                     "charmander": [("pidgeot", 37), ("exeggcute", 38), ("gyarados", 35), ("alakazam", 35), ("charizard", 40)]}),
        lines={"desafio": "¡Llegás tarde! El Team Rocket tomó todo el edificio.|Igual... ¿te animás a una antes de ir por Giovanni?",
               "pierde": "¡Argh! Bueno, andá vos. Giovanni está arriba, en la oficina del presidente.",
               "gana": "¡Ja! Así no le ganás a Giovanni.", "despues": "Dale, apurate."}),
    ("silph_11p", "0x0"): dict(name="Giovanni", title="Jefe Rocket", sight=3, reward_flags=["silph_liberada"],
        team=[("nidorino", 37), ("kangaskhan", 35), ("rhyhorn", 37), ("nidoqueen", 41)],
        lines={"desafio": "¿Otra vez vos? Qué molesto.|Estoy negociando con el presidente de Silph. ¡No me hagas perder el tiempo!",
               "pierde": "¡Argh! ¡Otra vez! ...Está bien. Por ahora, el Team Rocket se retira de Silph S.A.",
               "gana": "Volvé a tu casa, nene.", "despues": "..."}),
    # --- Cap. 8: el rival en la Ruta 22 (antes de la Liga) ---
    ("ruta22", "RivalFinal"): dict(name=RIVAL, title="Rival", sight=0, talk_challenge=False, reward_flags=["rival_ruta22_final_peleado"],
        team=_rival({"squirtle": [("pidgeot", 47), ("rhyhorn", 45), ("growlithe", 45), ("exeggcute", 45), ("alakazam", 47), ("blastoise", 53)],
                     "bulbasaur": [("pidgeot", 47), ("rhyhorn", 45), ("gyarados", 45), ("growlithe", 45), ("alakazam", 47), ("venusaur", 53)],
                     "charmander": [("pidgeot", 47), ("rhyhorn", 45), ("exeggcute", 45), ("gyarados", 45), ("alakazam", 47), ("charizard", 53)]}),
        lines={"desafio": "¡Eh! ¿Vos también tenés las 8 medallas? Yo voy derecho a la Liga Pokémon.|¡Pero primero te gano acá!",
               "pierde": "¡Bah! ¡Igual llego primero a la Liga! ¡Nos vemos en la Meseta Añil!",
               "gana": "¡Ja! Ni ganes la Liga.", "despues": "¡Nos vemos en la Liga!"}),
    # --- Cap. 8: el Alto Mando y el Campeón ---
    ("liga_lorelei", "Lorelei"): dict(name="Lorelei", title=ELITE, sight=4, arena="arena_liga_hielo", leader=True, reward_flags=["alto_mando_lorelei"],
        team=[("dewgong", 52), ("cloyster", 51), ("slowbro", 52), ("jynx", 54), ("lapras", 54)],
        lines={"desafio": "Bienvenido a la Liga Pokémon. Soy Lorelei, del Alto Mando.|Nadie resiste mis Pokémon de hielo. ¡Te vas a congelar!",
               "pierde": "Sos bueno... Muy bueno. Seguí: Bruno te espera.", "gana": "Qué frío te dejé.", "despues": "Seguí adelante."}),
    ("liga_bruno", "Bruno"): dict(name="Bruno", title=ELITE, sight=4, arena="arena_liga_lucha", leader=True, reward_flags=["alto_mando_bruno"],
        team=[("onix", 51), ("hitmonchan", 53), ("hitmonlee", 53), ("onix", 54), ("machamp", 56)],
        lines={"desafio": "¡Soy Bruno, del Alto Mando! Entreno mis músculos y mis Pokémon al límite.|¡Hoo hah! ¡Preparate!",
               "pierde": "¡Imposible! ¡Mis músculos no alcanzaron! Andá, Agatha te espera.", "gana": "¡Hoo hah! ¡Más entrenamiento!",
               "despues": "Seguí."}),
    ("liga_agatha", "Agatha"): dict(name="Agatha", title=ELITE, sight=4, arena="arena_liga_fantasma", leader=True, reward_flags=["alto_mando_agatha"],
        team=[("gengar", 54), ("golbat", 54), ("haunter", 53), ("arbok", 56), ("gengar", 58)],
        lines={"desafio": "Soy Agatha. Oak y yo fuimos rivales hace mucho... ¡ahora es un viejo débil!|Los Pokémon son para pelear. ¡Te lo voy a mostrar!",
               "pierde": "¡Ja! Qué entrenador. Ahora entiendo por qué Oak te tiene fe. Andá, Lance te espera.",
               "gana": "Volvé cuando sepas pelear.", "despues": "Andá."}),
    ("liga_lance", "Lance"): dict(name="Lance", title=ELITE, sight=4, arena="arena_liga_dragon", leader=True, reward_flags=["alto_mando_lance"],
        team=[("gyarados", 56), ("dragonair", 54), ("dragonair", 54), ("aerodactyl", 58), ("dragonite", 60)],
        lines={"desafio": "Te estaba esperando. Soy Lance, el último del Alto Mando.|Los dragones son Pokémon legendarios, casi imposibles de vencer. ¡Vamos!",
               "pierde": "Me ganaste... Sos digno del título. Pero todavía falta uno: el Campeón te espera.",
               "gana": "Los dragones no perdonan.", "despues": "El Campeón está pasando esa puerta."}),
    ("liga_campeon", "0x0"): dict(name=RIVAL, title="Campeón", sight=0, talk_challenge=False, arena="arena_torneo", leader=True,
        reward_flags=["campeon"], reward="¡Le ganaste al Campeón! ¡Sos el nuevo CAMPEÓN de la Liga Pokémon!",
        team=_rival({"squirtle": [("pidgeot", 59), ("alakazam", 57), ("rhydon", 59), ("arcanine", 59), ("exeggutor", 61), ("blastoise", 63)],
                     "bulbasaur": [("pidgeot", 59), ("alakazam", 57), ("rhydon", 59), ("gyarados", 59), ("arcanine", 61), ("venusaur", 63)],
                     "charmander": [("pidgeot", 59), ("alakazam", 57), ("rhydon", 59), ("exeggutor", 59), ("gyarados", 61), ("charizard", 63)]}),
        lines={"desafio": "¡Llegaste! Yo le gané al Alto Mando antes que vos. ¡Soy el Campeón de la Liga Pokémon!|"
                          "Entrené a mis Pokémon con todo para ser el mejor del mundo. ¡Y nadie me va a sacar el título!",
               "pierde": "¡NO! ¡No puede ser! ¡Fui campeón un minuto nada más!|...Está bien. Sos el mejor. Te lo ganaste.",
               "gana": "¡Ja! ¡Sigo siendo el Campeón!", "despues": "..."}),
})
# El hideout: Giovanni (automático, clase BOSS) con frases propias y la bandera que deja el Scope Silph.
if ("escondite_rocket_s4", "Giovanni") in TRAINERS:
    TRAINERS[("escondite_rocket_s4", "Giovanni")].update(name="Giovanni", sight=4, reward_flags=["giovanni_escondite_vencido"], lines={
        "desafio": "Así que encontraste nuestro escondite. Interesante.|Soy Giovanni, el jefe del Team Rocket. ¡Vas a lamentar haber venido!",
        "pierde": "¡¿Qué?! ...Hacía mucho que nadie me ganaba. Me voy, pero esto no termina acá.",
        "gana": "Volvé a jugar a tu casa.", "despues": "..."})
EXTRA_NPCS[("ruta22", "RivalFinal")] = ((45, 30), "blue")

TALKS.update({
    # --- Cap. 4: Azulona, la Torre y el Escondite ---
    ("torre_pokemon_2p", "0x0"): dict(name=RIVAL, show_if=["historia"], hide_if=["rival_torre_peleado"], talks=[dict(lines=["¡Ey, vos!"])]),
    ("ciudad_azulona_mansion_1p", "TeaWoman"): dict(name="Abuela", talks=[
        dict(forbids=["te_recibido"], give={"te": 1}, set_flags=["te_recibido"], lines=[
            "¡Ay, qué chico tan amable! ¿Querés un té? Lo preparo yo misma.", "Llevate uno para el camino. ¡Es buenísimo para la sed!"]),
        dict(lines=["¿Te gustó el té? Dicen que los guardias de Azafrán se mueren de sed."])]),
    ("ciudad_azulona_mansion_cuarto", "EeveeBall"): dict(name="Poké Ball", gfx="item_ball", hide_if=["eevee_recibido"], talks=[
        dict(confirm="Adentro hay un Eevee. ¿Te lo llevás?", give_pokemon="eevee", give_level=25, set_flags=["eevee_recibido"],
             lines=["(Hay una Poké Ball sobre la mesa. Un cartel dice: \"Para quien lo cuide bien\".)"])]),
    ("escondite_rocket_s4", "SilphScope"): dict(name="Objeto", gfx="item_ball", show_if=["giovanni_escondite_vencido"],
        hide_if=["tiene_silph_scope"], talks=[dict(give={"silph_scope": 1}, set_flags=["tiene_silph_scope"], lines=[
            "(Giovanni dejó caer algo al escapar...)"])]),
    ("escondite_rocket_s4", "LiftKey"): dict(name="Objeto", gfx="item_ball", hide_if=["tiene_llave_ascensor"], talks=[
        dict(give={"llave_ascensor": 1}, set_flags=["tiene_llave_ascensor"], lines=[])]),
    # --- Cap. 5: la Torre (Marowak y el Sr. Fuji), los Snorlax y Fucsia ---
    ("torre_pokemon_7p", "MrFuji"): dict(name="Sr. Fuji", hide_if=["fuji_rescatado"], talks=[
        dict(forbids=["vencido_torre_pokemon_7p_grunt1"], lines=["(El Sr. Fuji está rodeado por el Team Rocket. ¡Hay que ayudarlo!)"]),
        dict(forbids=["vencido_torre_pokemon_7p_grunt2"], lines=["(Todavía quedan soldados del Team Rocket...)"]),
        dict(forbids=["vencido_torre_pokemon_7p_grunt3"], lines=["(Todavía queda un soldado del Team Rocket...)"]),
        dict(give={"poke_flauta": 1}, set_flags=["fuji_rescatado"], lines=[
            "Gracias... Gracias por salvarme. Soy Fuji, cuido a los Pokémon que no tienen a nadie.",
            "El Team Rocket mató a la mamá de un Cubone... gracias a vos, su espíritu ya descansa.",
            "Tomá esto: es la Poké Flauta. Su melodía despierta a cualquier Pokémon dormido.",
            "Dicen que hay Snorlax durmiendo en las Rutas 12 y 16. Te va a servir."])]),
    ("casa_voluntarios", "MrFuji"): dict(name="Sr. Fuji", show_if=["fuji_rescatado"], talks=[dict(lines=[
        "Gracias por todo. Los Pokémon de esta casa están felices de que el Team Rocket se haya ido de la Torre."])]),
    ("ruta12", "Snorlax"): dict(name="Snorlax", hide_if=["snorlax_ruta12_despierto"], talks=[dict(lines=["(Un Snorlax enorme duerme en medio del camino.)"], action="snorlax_ruta12")]),
    ("ruta16", "Snorlax"): dict(name="Snorlax", hide_if=["snorlax_ruta16_despierto"], talks=[dict(lines=["(Un Snorlax enorme duerme en medio del camino.)"], action="snorlax_ruta16")]),
    ("zona_safari_casa_secreta", "Attendant"): dict(name="Encargado", talks=[
        dict(forbids=["mo03_recibido"], give={"mo03": 1}, set_flags=["mo03_recibido"], lines=[
            "¡Felicitaciones! ¡Encontraste la Casa Secreta de la Zona Safari!", "Como premio, tomá esta MO: es Surf.",
            "Con la Medalla Alma, tus Pokémon te llevan sobre el agua."]),
        dict(lines=["Con Surf podés llegar a lugares a los que nadie llega a pie: caminá hacia el agua y tu Pokémon te lleva nadando."])]),
    ("casa_guarda", "Warden"): dict(name="Guarda", talks=[
        dict(requires=["objeto_zona_safari_oeste_itemgoldteeth"], forbids=["mo04_recibido"], take={"dientes_oro": 1}, give={"mo04": 1},
             set_flags=["mo04_recibido"], lines=["¡Ehfe! ¡Mif dientef! ¡Lof encontrafte!", "...(Se los pone)... ¡Ahora sí! ¡Gracias!",
                                                 "Tomá, en agradecimiento: la MO04, Fuerza. Caminá contra una roca enorme y tu Pokémon la empuja."]),
        dict(forbids=["mo04_recibido"], lines=["¡Ehfe! Ffe me cayeron lof dientef en la Fona Fafari... ¡Fi los encontráf, avifame!"]),
        dict(lines=["Con Fuerza, caminá contra las rocas de Calle Victoria y se corren. ¡Te va a hacer falta!"])]),
    # --- Cap. 6: Azafrán y Silph ---
    ("silph_7p", "0x0"): dict(name=RIVAL, show_if=["historia"], hide_if=["rival_silph_peleado"], talks=[dict(lines=["¡Ey!"])]),
    ("silph_7p", "LaprasGuy"): dict(name="Empleado", talks=[
        dict(forbids=["lapras_recibido"], give_pokemon="lapras", give_level=25, set_flags=["lapras_recibido"], lines=[
            "¡Viniste a salvarnos! Escondí a este Pokémon para que el Team Rocket no se lo llevara.", "Es un Lapras. Cuidalo, por favor."]),
        dict(lines=["¿Cómo anda el Lapras? Es muy bueno nadando."])]),
    ("silph_11p", "President"): dict(name="Presidente", talks=[
        dict(requires=["silph_liberada"], forbids=["master_ball_recibida"], give={"master_ball": 1}, set_flags=["master_ball_recibida"], lines=[
            "¡Gracias! ¡Salvaste a Silph S.A.!", "Te quiero dar algo especial: la Master Ball. Atrapa cualquier Pokémon, sin fallar.",
            "Es la única que existe. ¡Usala bien!"]),
        dict(requires=["silph_liberada"], lines=["Silph S.A. siempre va a estar en deuda con vos."]),
        dict(lines=["(El presidente está asustado y no habla.)"])]),
    ("dojo_karate", "HitmonleeBall"): dict(name="Poké Ball", gfx="item_ball", hide_if=["hitmon_elegido"], talks=[
        dict(forbids=["vencido_dojo_karate_masterkoichi"], lines=["(Una Poké Ball. El maestro del Dojo no te deja tocarla.)"]),
        dict(confirm="Es un Hitmonlee, el de las patadas. ¿Te lo llevás?", give_pokemon="hitmonlee", give_level=25,
             set_flags=["hitmon_elegido"], lines=["(Una Poké Ball con un Hitmonlee.)"])]),
    ("dojo_karate", "HitmonchanBall"): dict(name="Poké Ball", gfx="item_ball", hide_if=["hitmon_elegido"], talks=[
        dict(forbids=["vencido_dojo_karate_masterkoichi"], lines=["(Una Poké Ball. El maestro del Dojo no te deja tocarla.)"]),
        dict(confirm="Es un Hitmonchan, el de los puñetazos. ¿Te lo llevás?", give_pokemon="hitmonchan", give_level=25,
             set_flags=["hitmon_elegido"], lines=["(Una Poké Ball con un Hitmonchan.)"])]),
    # --- Legendarios (se despiertan y pelean, Nv. 50) ---
    ("islas_espuma_s4", "Articuno"): dict(name="Articuno", hide_if=["articuno_visto"], talks=[dict(lines=["(Un Pokémon de hielo majestuoso te mira desde lo alto.)"], action="legendario_articuno")]),
    ("central_electrica", "Zapdos"): dict(name="Zapdos", hide_if=["zapdos_visto"], talks=[dict(lines=["(Un Pokémon eléctrico enorme chisporrotea entre las máquinas.)"], action="legendario_zapdos")]),
    # --- Cap. 8: Liga ---
    ("ruta22", "RivalFinal"): dict(name=RIVAL, show_if=["medalla_tierra"], hide_if=["rival_ruta22_final_peleado"], talks=[
        dict(lines=["¡Ey!"])]),
    ("ruta22_garita", "BoulderBadgeGuard"): dict(name="Guardia", talks=[
        dict(forbids=["medalla_tierra"], lines=["Solo pasan los que tienen las 8 medallas de Kanto."]),
        dict(lines=["¡Las 8 medallas! Adelante: la Calle Victoria lleva a la Liga Pokémon."])]),
    ("liga_campeon", "0x0"): dict(name=RIVAL, talks=[dict(lines=["..."])]),
    ("liga_campeon", "0x0_2"): dict(name="Prof. Oak", show_if=["campeon"], talks=[dict(lines=[
        "¡Lo lograste! ¡Le ganaste a mi nieto!", "Me olvidé de algo muy importante: él no supo tratar a sus Pokémon con cariño.",
        "Vos sí. Por eso ganaste. ¡Vení, que te llevo al Salón de la Fama!"])]),
    ("liga_hall", "0x0"): dict(name="Prof. Oak", talks=[dict(lines=[
        "¡Felicitaciones! ¡Sos el nuevo Campeón de la Liga Pokémon!", "Tu Pokémon y vos formaron un equipo increíble.",
        "Este es el Salón de la Fama: acá quedan registrados los campeones y sus Pokémon para siempre.",
        "Pero el mundo Pokémon es enorme... ¡Seguí completando la Pokédex!"])]),
})
for _zone, _script in [("ciudad_azafran", "RocketGrunt%d" % i) for i in range(1, 8)] + [("ciudad_azafran", "DoorGuardGrunt")]:
    TALKS[(_zone, _script)] = dict(name="Rocket", hide_if=["silph_liberada"], talks=[dict(lines=[
        "¡Silph S.A. es del Team Rocket ahora! ¡Andate de acá!"])])
for _script in ["Youngster", "WorkerM", "Man", "Boy", "Pidgeot", "Lass"]:
    TALKS[("ciudad_azafran", _script)] = dict(name="Vecino" if _script != "Pidgeot" else "Pidgeot", show_if=["silph_liberada"], talks=[
        dict(lines=["¡Gracias por echar al Team Rocket! Ciudad Azafrán volvió a ser la de antes." if _script != "Pidgeot" else "Pidgeot: ¡Piiii!"])])
# Guardias de las garitas de Azafrán: con el Té te dejan pasar (como en FireRed).
for _gate in ["ruta5_garita", "ruta6_garita", "ruta7_garita", "ruta8_garita"]:
    TALKS[(_gate, "Guard")] = dict(name="Guardia", talks=[
        dict(forbids=["te_recibido"], lines=["¡Uf, qué sed! No puedo dejar pasar a nadie a Ciudad Azafrán... ¿no tendrás algo para tomar?"]),
        dict(lines=["¡Gracias por el té! Pasá nomás. Cuidate en Azafrán: está lleno del Team Rocket."])])
for _gate, _rect in [("ruta5_garita", (3, 5, 3, 1)), ("ruta6_garita", (3, 5, 3, 1)), ("ruta7_garita", (5, 4, 1, 3)),
                     ("ruta8_garita", (5, 4, 1, 3))]:
    TRIGGERS["guardia_" + _gate] = dict(zone=_gate, rect=_rect, once=False, push_back=True, talk=dict(
        forbids=["te_recibido"], speaker="Guardia", lines=["¡Alto! Ciudad Azafrán está cerrada.", "...¡Uf, qué sed tengo! Si tuviera algo para tomar..."]))
    TRIGGERS["te_" + _gate] = dict(zone=_gate, rect=_rect, once=True, talk=dict(
        requires=["te_recibido"], speaker="Guardia", lines=["¿Eso es té? ¿Me convidás? ...¡Ahh, qué rico!", "¡Gracias! Pasá nomás."]))
TRIGGERS["rival_torre"] = dict(zone="torre_pokemon_2p", rect=(8, 7, 4, 1), once=False, talk=dict(
    requires=["historia"], forbids=["rival_torre_peleado"], speaker=RIVAL, lines=["¡Eh, esperá!"], battle_npc="torre_pokemon_2p_0x0"))
TRIGGERS["fantasma_torre"] = dict(zone="torre_pokemon_6p", rect=(11, 15, 2, 1), once=False, push_back=True, talk=dict(
    forbids=["tiene_silph_scope", "marowak_en_paz"], speaker="", lines=[
        "¡Un fantasma te cierra el paso! No se le ve la forma...", "\"Fuera... fuera de aquí...\"", "(Sin algo para ver fantasmas no se puede seguir.)"]))
TRIGGERS["marowak_torre"] = dict(zone="torre_pokemon_6p", rect=(11, 15, 2, 1), once=True, talk=dict(
    requires=["tiene_silph_scope"], forbids=["marowak_en_paz"], set_flags=["marowak_en_paz"], speaker="", lines=[
        "¡Un fantasma te cierra el paso!", "¡El Scope Silph muestra lo que es: el espíritu de una mamá Marowak!",
        "...El espíritu se calma al ver que ya nadie le va a hacer daño a su hijo.", "Marowak descansa en paz."]))
TRIGGERS["rival_silph"] = dict(zone="silph_7p", rect=(2, 7, 4, 3), once=False, talk=dict(
    requires=["historia"], forbids=["rival_silph_peleado"], speaker=RIVAL, lines=["¡Eh, esperá!"], battle_npc="silph_7p_0x0"))
TRIGGERS["canela_cerrada"] = dict(zone="isla_canela", rect=(37, 5, 3, 1), once=False, push_back=True, talk=dict(
    requires=["historia"], forbids=["objeto_mansion_pokemon_s1_itemsecretkey"], speaker="", lines=[
        "La puerta del gimnasio está cerrada con llave.", "Dicen que la llave se perdió en la Mansión Pokémon."]))
TRIGGERS["verde_cerrado"] = dict(zone="ciudad_verde", rect=(79, 21, 3, 1), once=False, push_back=True, talk=dict(
    requires=["historia"], forbids=["medalla_volcan"], speaker="", lines=[
        "La puerta del gimnasio de Ciudad Verde está cerrada.", "Dicen que el líder vuelve cuando alguien junta siete medallas."]))
TRIGGERS["rival_ruta22_final"] = dict(zone="ruta22", rect=(50, 28, 1, 33), once=False, talk=dict(
    requires=["medalla_tierra"], forbids=["rival_ruta22_final_peleado"], speaker=RIVAL, lines=["¡Eh, esperá!"], battle_npc="ruta22_rivalfinal"))
TRIGGERS["garita_8_medallas"] = dict(zone="ruta22_garita", rect=(0, 4, 15, 1), once=False, push_back=True, talk=dict(
    requires=["historia"], forbids=["medalla_tierra"], speaker="Guardia", lines=[
        "¡Alto! Más allá está la Ruta 23 y la Liga Pokémon.", "Solo pasan los que tienen las 8 medallas de Kanto."]))
TRIGGERS["campeon"] = dict(zone="liga_campeon", rect=(4, 10, 5, 1), once=False, talk=dict(
    requires=["alto_mando_lance"], forbids=["campeon"], speaker=RIVAL, lines=["¡Eh! ¡Por fin llegaste!"], battle_npc="liga_campeon_0x0"))
# Tiendas de las otras ciudades (lista de FireRed con los objetos que hay en el juego: data/shops).
SHOP_CLERKS = {("pueblo_lavanda_tienda", "Clerk"): "pueblo_lavanda", ("ciudad_azulona_almacen_2p", "ClerkItems"): "ciudad_azulona",
               ("ciudad_azulona_almacen_4p", "Clerk"): "ciudad_azulona_piedras", ("ciudad_azafran_tienda", "Clerk"): "ciudad_azafran",
               ("ciudad_fucsia_tienda", "Clerk"): "ciudad_fucsia", ("isla_canela_tienda", "Clerk"): "isla_canela",
               ("meseta_anil_centro", "Clerk"): "meseta_anil"}
for (_zone, _script), _shop in SHOP_CLERKS.items():
    TALKS[(_zone, _script)] = dict(name="Vendedor", talks=[dict(lines=["¡Bienvenido! ¿Qué vas a llevar?"], action="tienda_" + _shop)])

# --- Relleno: todas las personas sin conversación propia (las zonas nuevas) -------------------------------------
# Enfermeras curan; objetos tirados se agarran una vez; el resto, una frase según cómo se ve (y el nombre del lugar).
ITEM_MAP = {"Potion": "pocion", "Potion2": "pocion", "SuperPotion": "superpocion", "HyperPotion": "hiperpocion",
            "MaxPotion": "pocion_maxima", "FullRestore": "pocion_maxima", "Revive": "revivir", "MaxRevive": "revivir",
            "FullHeal": "cura_total", "Antidote": "antidoto", "ParalyzeHeal": "antiparalizador", "Awakening": "despertar",
            "BurnHeal": "antiquemar", "IceHeal": "antihielo", "PokeBall": "poke_ball", "GreatBall": "super_ball",
            "UltraBall": "ultra_ball", "RareCandy": "caramelo_raro", "MoonStone": "piedra_lunar", "LeafStone": "piedra_hoja",
            "ThunderStone": "piedra_trueno", "WaterStone": "piedra_agua", "FireStone": "piedra_fuego", "Nugget": "pepita",
            "StarPiece": "trozo_estrella", "GoldTeeth": "dientes_oro", "SecretKey": "llave_secreta", "CardKey": "tarjeta_llave"}
FLAVOR = {
    "kid": ["¡Quiero ser entrenador como vos!", "¡Mi Pokémon favorito es el tuyo!", "¿Ya viste todo {lugar}?"],
    "old": ["Cuando yo era joven, {lugar} era muy distinto...", "Cuidá a tus Pokémon, que ellos te cuidan a vos.",
            "Ya no tengo edad para combates, pero me encanta mirarlos."],
    "adult": ["¡Hola! Bienvenido a {lugar}.", "{lugar} es un lugar tranquilo... casi siempre.", "¿Viste algún Pokémon raro por {lugar}?",
              "Dicen que el Team Rocket anda por todos lados. ¡Cuidate!", "Me encanta pasear por {lugar} con mis Pokémon."],
    "worker": ["¡Uf, cuánto trabajo! No tengo ni un minuto.", "Acá en {lugar} siempre hay algo para hacer."],
    "science": ["Estoy investigando a los Pokémon de {lugar}. ¡Fascinante!", "La ciencia de los Pokémon avanza cada día."],
    "trainer": ["Entreno todos los días. ¡La Liga Pokémon me espera!", "Los combates se ganan con estrategia, no solo con fuerza."],
}
GFX_KIND = {"LITTLE_BOY": "kid", "LITTLE_GIRL": "kid", "BOY": "kid", "YOUNGSTER": "kid", "LASS": "kid", "GBA_KID": "kid",
            "OLD_MAN_1": "old", "OLD_MAN_2": "old", "OLD_WOMAN": "old", "WORKER_M": "worker", "WORKER_F": "worker", "CLERK": "worker",
            "SCIENTIST": "science", "COOLTRAINER_M": "trainer", "COOLTRAINER_F": "trainer", "BLACK_BELT": "trainer"}
_maps_json = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data", "world", "frlg_maps.json")
_sprites_json = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "pret", "characters", "npcs.json")
_with_sprite = set(json.load(open(_sprites_json, encoding="utf-8"))) if os.path.exists(_sprites_json) else set()
if os.path.exists(_maps_json):
    for _z in json.load(open(_maps_json, encoding="utf-8"))["zones"]:
        _seen = set()
        for _n in _z.get("npcs", []):
            _script = _n["script"].split("EventScript_")[-1]
            if _script in _seen:
                continue
            _seen.add(_script)
            _key = (_z["id"], _script)
            if _key in TALKS or _key in TRAINERS or _n["gfx"] in ("OBJ_EVENT_GFX_0", "OBJ_EVENT_GFX_VAR_0", "OBJ_EVENT_GFX_SS_ANNE",
                                                                   "OBJ_EVENT_GFX_SEAGALLOP", "OBJ_EVENT_GFX_CLIPBOARD",
                                                                   "OBJ_EVENT_GFX_POKEDEX", "OBJ_EVENT_GFX_TOWN_MAP"):
                continue
            _gfx = _n["gfx"][len("OBJ_EVENT_GFX_"):]
            if _gfx.lower() not in _with_sprite and not _script.startswith("Item"):
                continue  # sin sprite (diarios, Ámbar, chicos con la GBA): no se puede mostrar
            if _script.startswith("Item"):
                _item = ITEM_MAP.get(_script[4:])
                if _item:
                    _flag = _flag_of(_z["id"], _script)
                    TALKS[_key] = dict(name="Objeto", gfx="item_ball", hide_if=[_flag], talks=[dict(give={_item: 1}, set_flags=[_flag], lines=[])])
                continue
            if _script.startswith("Nurse") or _gfx == "NURSE":
                TALKS[_key] = NURSE
                continue
            if _gfx == "ITEM_BALL" or _gfx == "FOSSIL":
                continue
            _kind = GFX_KIND.get(_gfx)
            if _kind is None and _gfx.replace("_", "").isalpha() and _gfx.lower() in AUTO_SPECIES:
                TALKS[_key] = dict(name=_gfx.title().replace("_", " "), talks=[dict(lines=["%s: ¡%s!" % (_gfx.title().replace("_", " "),
                                                                                                   _gfx.title()[:4] + "...")])])
                continue
            _lines = FLAVOR[_kind or "adult"]
            _line = _lines[sum(map(ord, _z["id"] + _script)) % len(_lines)].format(lugar=_z.get("name", "este lugar"))
            TALKS[_key] = dict(name={"kid": "Pibe", "old": "Abuelo", "worker": "Empleado", "science": "Científico",
                                     "trainer": "Entrenador"}.get(_kind, "Vecino"), talks=[dict(lines=[_line])])


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
    if t.get("give_level"):
        body.append("give_level = %d" % t["give_level"])
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
        seen = set()
        for n in z.get("npcs", []):
            script = n["script"].split("EventScript_")[-1]
            if script in seen and (z["id"], script + "_2") in TALKS:
                script += "_2"  # dos personas con el mismo script (Bill y Bill-Clefairy)
            seen.add(script)
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
        spec = TALKS[(zone, script)]
        t = TRAINERS.get((zone, script))
        if t is not None:  # una persona extra también puede ser entrenador (el rival final de la Ruta 22)
            spec = dict(spec, name=t["name"], trainer=t)
        with open(os.path.join(out, npc_id + ".tres"), "w", encoding="utf-8", newline="\n") as f:
            f.write(npc_tres(npc_id, zone, n, spec))
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
