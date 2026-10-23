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
        "¡Bienvenido! Estamos acomodando la mercadería. Volvé en un rato."])]),
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
        reward="¡Recibiste la MEDALLA ROCA de Brock!", lines={
        "desafio": "Soy Brock, el líder del Gimnasio de Ciudad Plateada.|Mis Pokémon de roca son duros como la piedra... "
                   "y mi Onix no conoce la derrota.|¡Mostrame lo que tenés!",
        "pierde": "Te subestimé... ¡Ganaste limpio!|Tomá, la Medalla Roca. Es la prueba de que me venciste.",
        "despues": "Hay muchos entrenadores fuertes en Kanto. ¡Seguí entrenando!"}),
}


def gd_str(s):
    return '"%s"' % s.replace("\\", "\\\\").replace('"', '\\"')


def psa(items):
    return "PackedStringArray(%s)" % ", ".join(gd_str(x) for x in items)


def trainer_subs(spec, ext):
    """Sub-recursos de un TrainerData (con sus TrainerMon). `ext` junta los ext_resource de especies."""
    subs, mons = [], []
    for i, (sp, lvl) in enumerate(spec["team"]):
        key = "res://data/species/%s.tres" % sp
        if key not in ext:
            ext[key] = "sp_%d" % len(ext)
        subs.append('[sub_resource type="Resource" id="Mon_%d"]\nscript = ExtResource("4_m")\nspecies = ExtResource("%s")\nlevel = %d'
                    % (i, ext[key], lvl))
        mons.append('SubResource("Mon_%d")' % i)
    lines = ", ".join("%s: %s" % (gd_str(k), gd_str(v)) for k, v in spec["lines"].items())
    body = ['[sub_resource type="Resource" id="Trainer"]', 'script = ExtResource("3_d")',
            "id = " + gd_str(spec["name"].lower()), "display_name = " + gd_str(spec["name"]), "title = " + gd_str(spec["title"]),
            'starting_team = Array[ExtResource("4_m")]([%s])' % ", ".join(mons), "lines = {%s}" % lines,
            "arena_id = " + gd_str(spec.get("arena", "arena_campo"))]
    if spec.get("leader"):
        body.append("leader = true")
    if spec.get("reward_flags"):
        body.append("reward_flags = " + psa(spec["reward_flags"]))
    if spec.get("reward"):
        body.append("reward_text = " + gd_str(spec["reward"]))
    subs.append("\n".join(body))
    return subs


def npc_tres(npc_id, zone, n, spec):
    gfx = n["gfx"][len("OBJ_EVENT_GFX_"):].lower()
    move = n["movement"].replace("MOVEMENT_TYPE_", "")
    face = (0, 1)
    for k, v in FACING.items():
        if move.startswith("FACE_" + k):
            face = v
    look = move.startswith("LOOK_AROUND") or move.startswith("WANDER")
    subs, ids = [], []
    for i, t in enumerate(spec["talks"]):
        sid = "Talk_%d" % i
        ids.append('SubResource("%s")' % sid)
        body = ['[sub_resource type="Resource" id="%s"]' % sid, 'script = ExtResource("2_t")']
        if t.get("requires"):
            body.append("requires = " + psa(t["requires"]))
        if t.get("forbids"):
            body.append("forbids = " + psa(t["forbids"]))
        if t.get("speaker"):
            body.append("speaker = " + gd_str(t["speaker"]))
        body.append("lines = " + psa(t["lines"]))
        if t.get("set_flags"):
            body.append("set_flags = " + psa(t["set_flags"]))
        if t.get("give"):
            body.append("give_items = {%s}" % ", ".join("%s: %d" % (gd_str(k), v) for k, v in t["give"].items()))
        if t.get("heal"):
            body.append("heal = true")
        subs.append("\n".join(body))
    ext = {}
    extra = []
    if spec.get("trainer"):
        subs += trainer_subs(spec["trainer"], ext)
        extra = ['trainer = SubResource("Trainer")', "sight = %d" % spec["trainer"].get("sight", 4)]
    head = ['[gd_resource type="Resource" script_class="NpcData" format=3]', "",
            '[ext_resource type="Script" path="res://scripts/resources/npc_data.gd" id="1_n"]',
            '[ext_resource type="Script" path="res://scripts/resources/npc_talk.gd" id="2_t"]']
    if spec.get("trainer"):
        head += ['[ext_resource type="Script" path="res://scripts/resources/trainer_data.gd" id="3_d"]',
                 '[ext_resource type="Script" path="res://scripts/resources/trainer_mon.gd" id="4_m"]']
        head += ['[ext_resource type="Resource" path="%s" id="%s"]' % (k, v) for k, v in ext.items()]
    return "\n".join(head + ["",
        "\n\n".join(subs), "",
        "[resource]", 'script = ExtResource("1_n")', "id = " + gd_str(npc_id),
        "display_name = " + gd_str(spec["name"]), "zone_id = " + gd_str(zone),
        "cell = Vector2i(%d, %d)" % tuple(n["cell"]), "gfx = " + gd_str(gfx),
        "facing = Vector2i(%d, %d)" % face, "look_around = " + ("true" if look else "false"),
        'talks = Array[ExtResource("2_t")]([%s])' % ", ".join(ids)] + extra + [""])


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
                spec = dict(name=t["name"], trainer=t, talks=[dict(lines=[t["lines"]["despues"]])])
            if spec is None:
                continue
            gfx = n["gfx"][len("OBJ_EVENT_GFX_"):].lower()
            if gfx not in sprites:
                print("sin sprite:", z["id"], script, gfx)
                continue
            npc_id = "%s_%s" % (z["id"], script.lower())
            with open(os.path.join(out, npc_id + ".tres"), "w", encoding="utf-8", newline="\n") as f:
                f.write(npc_tres(npc_id, z["id"], n, spec))
            made.add((z["id"], script))
    for key in list(TALKS) + list(TRAINERS):
        if key not in made:
            print("no está en el mapa:", key)
    print("personas:", len(made))


if __name__ == "__main__":
    main()
