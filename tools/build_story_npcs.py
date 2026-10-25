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
            "Te quiero agradecer: tomá esta MO. Es Corte: con ella tus Pokémon cortan los árboles finos que tapan el camino.",
            "Para usarla fuera de combate necesitás la Medalla Cascada."]),
        dict(lines=["¡Gracias de nuevo! Con Corte, frente a un árbol fino apretá E."])]),
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
