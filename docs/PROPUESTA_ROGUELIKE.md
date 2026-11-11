# Propuesta: un roguelike estilo Hades con las mecánicas de Pokémon Pilot

> Análisis de ideas (2026-11-11). **No es un plan aprobado**: es para discutir. Al final están las decisiones que hay
> que tomar antes de empezar y un plan por fases si se decide hacerlo.

---

## 1. La idea en una frase

Elegís un Pokémon, bajás por una serie de **salas** de Kanto peleando contra salvajes, entrenadores y líderes; después
de cada sala elegís **una recompensa entre tres**; cuando te debilitan volvés al **Laboratorio de Oak** con lo que
juntaste para desbloquear cosas permanentes, y probás de nuevo.

## 2. Por qué el proyecto ya está muy cerca

Hades funciona porque tiene tres cosas: **un combate que se siente bien sala tras sala**, **una forma de cambiar ese
combate a mitad de la partida** (las bendiciones) y **una razón para volver después de morir** (el progreso
permanente y la historia). Las dos primeras ya están casi hechas en Pokémon Pilot:

| Lo que necesita Hades | Lo que ya tienen | Dónde está |
|---|---|---|
| Combate rápido, legible, con esquive | 4 ataques + esquive invulnerable, stagger, telegrafiado, paso adelante en los golpes | `MoveUser`, `Creature`, `CombatDirector` |
| Armas distintas que se juegan distinto | **~150 kits con estilo y firma** (Calor, Estática, Vuelo, Instinto, Núcleo...) + habilidades de 3ª gen | `data/kits/`, `scripts/combat/signatures/`, `data/abilities/` |
| Estados que se combinan | Empapado + Eléctrico = cortocircuito, esporas inflamables, escarcha, veneno acumulable, Expuesto... | `StatusEffects`, `status_interaction.gd`, `ReactionSystem` |
| Salas con peligros | Entorno reactivo: lagunas, pasto que se prende, rocas frágiles, cráteres, charcos eléctricos, climas | `ReactionSystem`, `CombatWeather`, `build_arenas.gd` |
| Enemigos que leen al jugador | `TacticalMind` con memoria (lee tu esquive, castiga tus recargas, fintas) | `scripts/creatures/ai/` |
| Jefes con fases | Onix, Starmie, Raichu, Articuno, Zapdos con fase a mitad de vida; líderes con guion | `phase_at`, `LeaderScript`/`LeaderMoment` |
| Un "Pacto de Castigo" (Heat) | `AiDifficulty`: ritmo, puntería, reacción, esquive, fintas, daño | `data/config/difficulty/` |
| Un modo con equipo temporal que no pisa la partida | **El Torneo**: guarda tu equipo y Mochila, usás otro, no se cura entre rondas | `scripts/world/tournament.gd` |
| Herramienta para armar salas | El editor de mapas + el constructor de arenas | `scenes/tools/map_editor.tscn`, `tools/build_arenas.gd` |

Lo que **no** tienen todavía (y es la parte nueva): la estructura de salas en cadena, el sistema de recompensas a
elegir, el progreso entre partidas y, sobre todo, **combate contra muchos a la vez** (ver la sección 6: es el
riesgo técnico más grande).

---

## 3. Cómo se traduce cada pieza de Hades

### 3.1 El "arma": tu Pokémon

En Hades elegís un arma y su aspecto. Acá el arma es **el Pokémon con su kit, su habilidad y sus 4 ataques**. Las
ranuras encajan casi perfecto:

| Hades | Pokémon Pilot |
|---|---|
| Ataque (spam) | Clic izq. (ataque 1) |
| Especial | Clic der. (ataque 2) |
| Cast (el disparo que se recoge) | Q (ataque 3) |
| Dash | Espacio (esquive) |
| Call (el poder del dios, se carga) | R (ataque 4) **o** la mecánica de firma |

**Ajuste necesario**: en Hades el ataque básico se aprieta sin parar. Acá el ataque 1 tiene recarga de 0,9-1,4 s.
Para el modo roguelike convendría que el **ataque 1 tenga recarga muy baja** (0,3-0,5 s) y poco daño, y que los
otros tres sean los "fuertes". Se puede hacer con un multiplicador de recarga por ranura solo en este modo, sin
tocar los datos de los ataques.

**Aspectos de arma = formas del mismo Pokémon.** Charmander con Mar Llamas vs. Charmander con otra habilidad, o
Eevee como Eevee / Vaporeon / Jolteon / Flareon. Pero hay algo mejor que Hades no tiene: **la Pokédex como
colección de armas** (ver 3.6).

### 3.2 Las bendiciones de los dioses → bendiciones de los legendarios (o de los tipos)

Es la pieza central. Después de una sala aparece un orbe; lo tocás y te ofrecen **3 bendiciones a elegir** de un
"patrón". Dos opciones de quién las da:

- **A. Legendarios** (más épico, más Hades): Articuno (Hielo), Zapdos (Eléctrico), Moltres (Fuego), Mew (Psíquico),
  Lugia, Ho-Oh, Suicune, Entei, Raikou, Groudon, Kyogre, Rayquaza... Cada uno con su personalidad y diálogo al
  ofrecerte algo. Ya tienen 386 especies con datos y sprites, así que la lista sobra.
- **B. Tipos** (más simple de diseñar): "Bendición del Fuego", "del Agua", etc. Menos carisma.

Recomiendo **A**, con un legendario por tipo principal (unos 8-10 para empezar).

**Qué hace una bendición**: se engancha a una ranura y le suma un efecto **del tipo del legendario**, usando los
estados que ya existen:

| Legendario | Ataque 1 | Ataque 2 | Esquive | Pasiva |
|---|---|---|---|---|
| Zapdos | los golpes suman Estática; 3 = Paralizado | rayo extra del cielo donde impacta | deja un charco electrificado | +daño a lo Paralizado |
| Articuno | suma Escarcha (5 = Congelado) | el impacto deja hielo que frena | deja un rastro de escarcha | lo congelado recibe ×1,5 |
| Moltres | Quemado al pegar | el impacto prende el pasto | estela de fuego (la de Embestida Ígnea) | los quemados explotan al debilitarse |
| Kyogre | Empapado al pegar | ola que empuja | moja el piso | +velocidad sobre mojado |
| Mew | desorienta | el proyectil rebota | teletransporte corto (el de Kadabra) | copia una bendición al azar |

Casi todo eso **ya existe como pieza**: `element_marks` de las firmas (un golpe de tal tipo pone tal estado), las
estelas de fuego, los charcos electrificados de Raichu, el teletransporte, el desvío de proyectiles. Una bendición
puede ser un `Resource` nuevo (`BoonData`) que agrega un `SignatureMechanic` extra a la criatura o modifica un
`MoveData` duplicado (son `.tres`: `duplicate()` y se cambian campos como `strike_count`, `drain`, `crater_radius`).

**Bendiciones dobles (los "Duo Boons")**: esto es donde el proyecto brilla, porque **las combinaciones ya están en
el motor**. Si tenés una de Zapdos y una de Kyogre, aparece "Tormenta": el cortocircuito de Empapado + Eléctrico
encadena a los cercanos. Moltres + Celebi (Planta): las esporas inflamables explotan en cadena. Articuno + Kyogre:
todo lo mojado se congela al instante. Salen casi solas de `status_interaction.gd` y del `ReactionSystem`.

**Rareza**: común / rara / épica / legendaria, multiplicando los números del efecto (como en Hades).

### 3.3 Las demás recompensas de sala

| Hades | Versión Pokémon | Qué hace |
|---|---|---|
| Granada de Poder (Pom) | **Caramelo Raro** | +1 nivel a una bendición (o +nivel al Pokémon, ver 3.5) |
| Martillo de Dédalo | **MT** | Cambia un ataque por otro de su learnset/MT, o **muta** un ataque (Ascuas de 3 a 5 brasas, Látigo Cepa que atrae a dos) |
| Centauro (vida máx.) | **Proteína / Más PS** | +vida máxima |
| Oro de Caronte | **Dinero** (`GameState.money` ya existe) | Para la tienda |
| Tienda de Caronte | **Tienda Pokémon** (`ShopData` ya existe) | Pociones, objetos, bendiciones al azar |
| Fuente | **Centro Pokémon** | Sala de descanso: cura un porcentaje |
| Recuerdos (Keepsakes) | **Objetos equipados de 3ª gen** | Restos, Cinta Elegida, Garra Rápida, Carbón, Agua Mística, Banda Focus, Hierba Blanca... |
| Compañeros | **Pokémon capturados** | Ver 3.4 |
| Caos | **Missingno.** (o Equipo Rocket) | Pacto: una maldición por 3 salas a cambio de una bendición fuerte |
| Puertas de Érebo | **Pasto oscuro / Zona Safari** | Sala más difícil con mejor premio |
| Cofre infernal | **Shiny** | Un salvaje shiny que escapa: si lo debilitás a tiempo, premio grande |

Los objetos equipados son un buen agregado aunque no se haga el roguelike: son datos simples y están en el espíritu
de la 3ª gen.

### 3.4 La captura: lo que Hades no tiene

Esto es lo que puede hacer al juego **propio** en vez de una copia de Hades. Ideas, de la más simple a la más ambiciosa:

1. **Captura = desbloqueo.** En la partida podés tirar una Poké Ball a un salvaje debilitado (la mecánica de
   captura ya está). Si lo atrapás, **queda desbloqueado para siempre como Pokémon inicial** de próximas partidas.
   La Pokédex se vuelve la colección de armas. Con ~150 kits hay contenido para muchísimas horas.
2. **Captura = compañero.** Lo atrapado viene con vos como asistente: se invoca con R (como el Call de Hades), sale,
   tira su ataque más fuerte y vuelve a la bola. Usa la `TacticalMind` y el cambio de Pokémon que ya existe.
3. **Captura = cambio de arma a mitad de partida.** Podés cambiar tu Pokémon por el que atrapaste, manteniendo las
   bendiciones (que se reacomodan a sus ranuras). Muy roguelike, pero difícil de balancear.

Recomiendo **1 + 2** para empezar; la 3 después si gusta.

### 3.5 La evolución como pico de poder

En Hades no hay nada como esto: **evolucionar a mitad de la partida**. Opciones:

- Subís de nivel con la EXP de cada sala (el sistema de EXP y las curvas ya existen) y evolucionás al nivel real.
- O, más controlado, la evolución es **una recompensa de sala** que aparece después del primer jefe ("Piedra Fuego",
  "Piedra Lunar", "Cable Link" según la especie). Al evolucionar cambian los stats y, si la evolución tiene kit
  propio (Butterfree, Beedrill, Kadabra, Gyarados), cambia la forma de pelear.
- **Piedra Eterna** como alternativa: no evoluciona pero gana algo fuerte. Es una decisión interesante de partida.

Recomiendo que la partida **empiece en un nivel fijo** (por ejemplo 10) y que se suba de nivel adentro, para que las
partidas no dependan de lo que tengas en el modo historia.

### 3.6 Morir y volver: el progreso permanente

| Hades | Versión Pokémon |
|---|---|
| Casa de Hades (hub) | **Laboratorio de Oak** (o Pueblo Paleta entero: ya es un mapa real) |
| Oscuridad → Espejo de la Noche | **Datos de investigación** → mejoras del Prof. Oak: +1 Revivir, más vida, +1 opción de bendición, reroll, esquive doble... |
| Desafío a la Muerte (revivir) | **Revivir** (perfecto: es un objeto real) |
| Llaves → armas nuevas | **La Pokédex**: lo que capturaste queda como inicial |
| Néctar → relaciones con NPCs | **Bayas** de regalo para Brock, Misty, Azul, Mamá... cada uno te da un objeto equipado |
| Gemas → decoración | Fichas del Casino → decorar tu cuarto |
| Lista del Destino (profecías) | **Desafíos de la Pokédex** ("ganá una partida con un Pokémon de cada tipo") |
| Pacto de Castigo (Heat) | **Medallas de Desafío**: cada una sube algo de `AiDifficulty` o suma una regla |

Ideas de Medallas de Desafío (casi todas son perillas que ya existen):
- Reflejos: reacción de la IA más rápida (`reaction`).
- Fintas: más fintas (`feint_chance`).
- Puntería: menos error (`aim_error_deg`), más anticipación (`lead`).
- Manada: más enemigos por sala.
- Habilidades ocultas: los salvajes vienen con su mejor habilidad.
- Sin Centro: no hay salas de descanso.
- Jefe Furioso: los jefes entran en fase a 75 % en vez de 50 %.
- Clima hostil: cada piso arranca con un clima en contra (`CombatWeather`).

### 3.7 Los pisos (biomas)

Hades tiene 4 regiones con un jefe al final de cada una. Kanto da para eso con lugares reales que ya están
importados de FireRed:

| Piso | Lugar | Enemigos | Jefe | Peligros |
|---|---|---|---|---|
| 1 | **Bosque Verde** | bichos, Pidgey, Pikachu | **Brock** (Onix, ya es jefe) | pasto alto que se prende, esporas |
| 2 | **Monte Moon** | Zubat, Geodude, Paras, Clefairy, Equipo Rocket | **Misty** (Starmie, ya es jefa) o Giovanni | oscuridad, rocas, cráteres |
| 3 | **Torre Pokémon / Mansión Canela** | Gastly, Grimer, Koffing | **Lt. Surge** (Raichu, ya es jefe) o Sabrina | gas inflamable, charcos |
| 4 | **Calle Victoria** | de todo, evolucionados | **Alto Mando / Azul** | todo junto |
| Final | **Cueva Celeste** | — | **Mewtwo** (habría que hacerle kit de jefe) | — |

La historia de fondo puede ser como la de Hades (escapar), dada vuelta: **Mewtwo escapó** y el Prof. Oak te manda
a buscarlo; cada vez que perdés volvés al laboratorio y se desbloquea más charla. Azul puede ser la Megara: aparece
en distintos pisos, a veces como rival, a veces como aliado.

### 3.8 Las salas

En Hades las salas están **hechas a mano** y se eligen al azar. Recomiendo lo mismo:
- Cada sala es una zona chica armada con el **editor de mapas** (ya tiene pinceles, objetos, validaciones y botón de
  probar). 8-12 salas por piso alcanzan para que no se repita mucho.
- Cada sala declara: piso, tamaño, dónde aparecen los enemigos y por dónde salen las puertas.
- Las **puertas** muestran el ícono de la recompensa (como en Hades) y elegís cuál tomar. `WarpSystem` ya hace el
  fundido entre zonas.
- Tipos de sala: oleadas de salvajes, entrenador (1 contra 1 con cambios: `TrainerBattle`), élite (un Pokémon grande
  con `body_scale`), mini-jefe (un Snorlax que bloquea el camino), tienda, Centro, historia.

---

## 4. Tres formas de encararlo

| | Qué es | Ventaja | Contra |
|---|---|---|---|
| **1. Edificio dentro de la historia** | Como el Torneo: un lugar (Cueva Celeste, una "Torre de Batalla") donde entrás con un Pokémon de tu equipo | Reusa casi todo, no compite con la historia | No hay hub propio ni progreso fuerte; se siente "minijuego" |
| **2. Modo aparte desde el título** ⭐ | "Modo Desafío" en la pantalla de título, con su propio guardado y su hub (el laboratorio) | Libertad de diseño total, mismo motor, no rompe la historia | Hay que hacer el hub y el progreso |
| **3. Cambiar el juego entero** | Que el juego pase a ser el roguelike | Foco total | Se tira mucho del trabajo del mundo abierto y la historia |

Recomiendo la **2**. Ya hay un antecedente: "Probar el torneo" en el título (`tournament_test_setup.gd`) arma un
equipo temporal sin tocar la partida. El roguelike sería lo mismo pero con su propio archivo de progreso
(`user://roguelike.json`).

---

## 5. Lo que hay que construir (piezas nuevas)

1. **`RunState`** (autoload o nodo): Pokémon elegido, bendiciones, objetos, dinero, sala actual, semilla. Se guarda
   solo al salir de una sala (como Hades).
2. **`RoomDirector`**: elige la próxima sala, hace aparecer las oleadas, detecta "sala limpia", muestra la
   recompensa y abre las puertas.
3. **`BoonData` + `BoonPool`**: datos de bendiciones (ranura, legendario, rareza, efecto, requisitos para las dobles)
   y el sorteo de 3 con pesos.
4. **Pantalla de elección** (3 cartas con el legendario y el efecto): con `UiStyle` y `MenuNav`, así funciona con
   joystick.
5. **Hub**: el laboratorio con Oak (mejoras permanentes), la Pokédex (elegir inicial) y NPCs de regalo.
6. **`MetaState`**: moneda permanente, mejoras compradas, desbloqueos, Medallas de Desafío, mejor partida.
7. **Objetos equipados** (`ItemData` con un efecto pasivo).
8. **Enemigos "de oleada"** (ver la sección siguiente).

---

## 6. Riesgos y cosas a cambiar del combate

**El combate está pensado para 1 contra 1.** Todo el balance, la IA (`TacticalMind`, el sparring), la vida
(`HP_SCALE = 3`) y el stagger se pensaron para duelos. Hades es 1 contra 5-10. Lo que habría que hacer:

- **Dos categorías de enemigo**: *esbirros* (poca vida, `HP_SCALE` 1, 1-2 ataques simples, mueren en 2-4 golpes) y
  *élites/jefes* (la IA completa, como hoy). Un Rattata de oleada no necesita leer tu esquive; un Raichu jefe sí.
- **Fichas de ataque**: solo 2-3 enemigos pueden estar atacando a la vez; los demás rodean. Es lo que hacen casi
  todos los juegos de acción para que no sea injusto, y respeta la "regla de justicia" de `PLAN_IA.md`.
- **Golpes que pegan a varios**: los abanicos y las zonas ya lo hacen; los cuerpo a cuerpo hoy apuntan a uno. En
  oleadas, los golpes deberían barrer un arco.
- **Stagger y respiro**: la regla de "0,35 s sin stagger nuevo" está para que no te encadenen en un duelo. Con 6
  enemigos puede quedar raro; probarlo antes de tocarlo.
- **Rendimiento**: muchas criaturas con `TacticalMind`, `Perception` y `CombatBody` a la vez. Los esbirros deberían
  usar una mente más barata (el `Temperament` de salvaje solo, sin la táctica).
- **Ritmo de recargas**: hoy el ataque 4 tarda hasta 12 s. En Hades el ritmo es más rápido; sumar un multiplicador
  de recargas del modo (0,6-0,7) y dejar que las bendiciones lo bajen más.
- **Balance de builds**: con bendiciones apiladas aparecen combinaciones rotas. Eso en un roguelike está bien
  (es parte de la gracia), pero conviene usar la batería de balance IA contra IA que ya tienen para detectar las
  que hacen que la partida se gane sola.

**Lo que se puede reusar sin cambios**: tipos y efectividad, daño oficial, estados, habilidades, firmas, entorno
reactivo, climas, captura, EXP y evolución, jefes con fase, líderes con guion, música por zona, joystick, editor
de mapas.

---

## 7. Plan por fases (si se decide hacerlo)

Mismo estilo que los otros planes: cada fase deja el juego ejecutable y tiene su autotest.

| Fase | Qué | Cómo se prueba |
|---|---|---|
| **R-0** | **Rebanada vertical**: botón "Modo Desafío" en el título → elegís entre 3 Pokémon → 3 salas del Bosque Verde con oleadas → Brock. Sin bendiciones ni hub: solo la cadena de salas, puertas y "sala limpia" | `--autotest-rogue-rooms` (un bot completa las 3 salas) |
| R-1 | **Esbirros y fichas de ataque**: enemigos de oleada con poca vida y mente barata; máximo 3 atacando | `--autotest-rogue-waves` + jugarlo |
| R-2 | **Bendiciones**: `BoonData`, 3 legendarios (Zapdos, Articuno, Moltres) con 5-6 bendiciones cada uno, pantalla de elección, rarezas | `--autotest-boons` (cada bendición hace lo que dice) |
| R-3 | **Recompensas de sala**: Caramelo Raro, MT, Proteína, dinero, tienda, Centro; puertas con ícono | autotest + jugarlo |
| R-4 | **Morir y volver**: hub en el laboratorio, `MetaState`, mejoras de Oak, Revivir, desbloqueo por captura | `--autotest-rogue-meta` |
| R-5 | **Pisos 2-4** con sus salas (editor de mapas), jefes y peligros; bendiciones dobles | jugarlo entero |
| R-6 | **Medallas de Desafío**, objetos equipados, historia entre partidas (Oak, Azul, Mewtwo), desafíos de Pokédex | jugarlo |

R-0 y R-1 son las importantes: si pelear contra oleadas no se siente bien, lo demás no importa. Conviene decidir si
seguir después de jugar R-1.

---

## 8. Decisiones a tomar

1. **¿Dónde vive?** Modo aparte desde el título (recomendado) / edificio en la historia / el juego entero.
2. **¿Uno o varios Pokémon por partida?** Uno principal + capturados como asistentes (recomendado) / equipo de 3 con
   cambio / uno solo sin nada más.
3. **¿Quién da las bendiciones?** Legendarios con personalidad (recomendado) / tipos sin personaje.
4. **¿Nivel?** Empieza en un nivel fijo y sube adentro (recomendado) / usa el nivel de tu partida de la historia.
5. **¿Evolución?** Por nivel adentro de la partida / como recompensa de sala con opción de Piedra Eterna (recomendado).
6. **¿Salas?** Hechas a mano con el editor y elegidas al azar (recomendado) / generadas por código.
7. **¿Qué desbloquea capturar?** El Pokémon como inicial para siempre (recomendado) / solo un compañero en esa partida.
8. **¿Multijugador?** El online ya existe: un modo cooperativo de 2 sería posible más adelante, pero no para empezar.

---

## 9. Decisiones tomadas (usuario, 2026-11-11) y estado

1. **Dónde vive**: modo aparte desde el título ("Modo Desafío").
2. **Pokémon por partida**: uno principal; los capturados serán asistentes, **máximo 2 por ahora**. En R-0, uno solo: si cae, se termina.
3. **Bendiciones**: legendarios con personalidad.
4. **Nivel**: fijo (10) y sube adentro.
5. **Evolución**: recompensa de sala, con Piedra Eterna como alternativa.
6. **Salas**: hechas a mano y elegidas al azar; **no tienen que ser iguales a FireRed**: pintadas con ComfyUI/Qwen en el
   estilo de las arenas pintadas.
7. **Captura**: el Pokémon queda como inicial para siempre (y asistente en esa partida).
8. **Multijugador**: no por ahora.

**Hecho: R-0** (ver `docs/PROGRESO.md` y CLAUDE.md, "Modo Desafío"). Frenado hasta que el usuario lo juegue.
Después de R-0 (mismo día, pedido del usuario): salas más grandes (64×48), **encadenadas** (se pasa caminando por un
portón, sin fundido) y con obstáculos pintados cuya colisión sale sola de la pintura.

**Después de jugarlo hasta Brock (usuario, 2026-11-11)**, en tres etapas:
1. **Hecho — run más larga y captura**: 5 salas antes de Brock; desbloqueo permanente (de entrada solo Charmander,
   Squirtle y Bulbasaur; te ofrecen 3 de lo desbloqueado, al azar si hay más); **capturar solo desbloquea esa especie
   como inicial** para las próximas partidas (reemplaza por ahora al "asistente" de la decisión 7: en esa partida seguís
   con tu único Pokémon); 2 Pokébolas por partida = 2 tiros con la fórmula normal (la errada se pierde). Progreso en
   `user://desafio.json` (`RogueProgress`). Decidido sin preguntar: se desbloquea la especie tal cual se atrapó (un
   Beedrill desbloquea a Beedrill, no a Weedle) y atrapar a uno que ya tenías igual lo saca de la sala.
2. **Hecho — biomas**: 6 biomas × 3 salas pintadas (Bosque Verde, Volcán, Costa, Cueva, Gruta Helada, Cementerio); cada
   sala de la partida sale de un bioma al azar con Pokémon característicos y niveles según la posición
   (`data/rogue/desafio.json`, `RogueRun.plan_rooms`). Decidido sin preguntar: dos salas seguidas nunca son del mismo
   bioma; las dos últimas salas cierran con una oleada de evoluciones del bioma; el jefe sigue siendo Brock sea cual sea
   el camino. Para más adelante: central eléctrica, pradera, pantano; pisos con más detalle (los nuevos son lisos);
   peligros propios del bioma (lava que quema, hielo que resbala).
3. **Hecho — castillo de Mew**: Mewtwo corrompió el mundo (salvajes y entrenadores); aparecés en un castillo pintado
   donde Mew te cuenta la historia, elegís el inicial (de los desbloqueados) y el portal del fondo arranca la partida.
   **Reemplaza al hub del laboratorio de Oak** de este documento (sección del hub): lo que ahí iba en el laboratorio
   (mejoras permanentes, Pokédex del modo, legendarios que visitan) va a ir en el castillo. Decidido sin preguntar: la
   historia entera sale sola solo la primera vez (después Mew ofrece elegir o contarla de nuevo); atrapar = "rescatar"
   (Mew cuida al Pokémon en el castillo, por eso queda como inicial); vencer a un entrenador lo "despierta" (Brock lo
   dice al perder); al terminar una partida se vuelve al castillo sin Pokémon; se puede cambiar de Pokémon antes de
   cruzar. Para más adelante: que los Pokémon rescatados se vean paseando por el castillo, y Mewtwo como jefe final.

4. **Hecho — repintado y castillo nuevo** (usuario, mismo día, al ver las pinturas): las 18 salas más pintorescas (más
   elementos por bioma, bordes decorados, luz); el castillo con más estructuras, **el portal abajo** (tarima redonda con
   runas) y **una escalera a la planta alta bloqueada hasta avanzar en la historia** (bandera `planta_alta` del progreso
   del modo; todavía sin planta alta). Decidido sin preguntar: la barrera es una cortina de luz y el aviso lo da Mew;
   qué abre la escalera (¿ganarle a Brock?, ¿N entrenadores despertados?) queda para definir con el usuario.

**Hecho: R-1** (2026-11-11): esbirros con 45 % de vida y 2 ataques de daño, élites en la oleada fuerte, oleadas más
grandes y 3 fichas de ataque que rotan. Decidido sin preguntar: la "mente barata" quedó en recortarles los ataques (la
`TacticalMind` de salvaje se mantiene: con 5-7 enemigos no hubo problema de rendimiento); los golpes cuerpo a cuerpo ya
pegaban a todos los que toca el arco, y el stagger no se tocó (verlo jugando).

**Hecho: R-2** (2026-11-11): bendiciones de Zapdos, Articuno y Moltres (6 cada uno), 4 rarezas, pantalla de elección.
Decidido sin preguntar: por ahora **cada sala limpia da una bendición** (R-3 la vuelve una de varias recompensas); las
bendiciones no modifican los `MoveData` ni usan las firmas viejas: se enganchan a las señales de tu Pokémon (golpe,
esquive, daño recibido, enemigo caído) y aplican los estados que ya existen, así no tocan el combate central; el daño
de más de una bendición no dispara otras (sin cadenas infinitas); repetida = sube de nivel (+35 % a sus números); las
frases de los legendarios tienen personalidad (Zapdos soberbio, Articuno sereno, Moltres eufórico). **Para el usuario al
jugarlo**: qué bendiciones se sienten y cuáles no, y si conviene que el esquive con bendición sea tan fuerte. Las dobles
(Zapdos + Articuno...) y más dadores (Mew, Kyogre...) quedan para R-5.

**Hecho: R-3** (2026-11-11): recompensas de sala (Bendición, Caramelo Raro, MT, Más PS, Dinero, Tienda, Centro) y dos
puertas con ícono para elegir la de la sala siguiente. Decidido sin preguntar: como las salas van encadenadas (un solo
paso arriba), **las puertas son dos arcos que aparecen frente al paso** y eligen la recompensa, no el camino; **Tienda y
Centro son recompensas**, no salas aparte; la MT no ofrece ataques de más de 100 de potencia; el ataque reemplazado se
pierde por esa partida; la evolución y la Piedra Eterna como recompensa (decisión 5) quedan para más adelante, junto con
los objetos equipados y el pacto de Missingno. **Frenado acá** (el usuario pidió seguir hasta R-3): hay que jugar R-1,
R-2 y R-3 juntas antes de R-4 (mejoras permanentes en el castillo de Mew, Revivir, qué abre la escalera).

**Hecho — salas en juego y 18 más** (usuario, 2026-11-11, al ver capturas del juego): textura de suelo pintada por
bioma mezclada sobre el piso de cada sala (el piso liso era de la pintura, no del juego), 6 salas por bioma (36) con
composiciones distintas, y cámara abierta en el castillo. Decidido sin preguntar: el zoom de las salas de pelea no se
tocó (es el del jugador, con la rueda); si igual se ven "de cerca", la opción es abrirlo solo en el modo.

**Después de jugar R-1 a R-3 (usuario, 2026-11-11)**: "hay que arreglar que el pokemon no evoluciona en el medio de la
run. La dificultad es bastante sencilla, deberían darme menos experiencia los pokemon. Los objetos que agarro no aparecen
en la mochila ni puedo equiparlos en los pokemon. Y se siente relativamente fácil y mucho más con las mejoras." Eligió
además "Esbirros más duros" y "Mejoras enemigas ya" (no subir niveles de las oleadas ni recortar la curación). En etapas:

- **Hecho — evolución en la partida**: evoluciona al llegar al nivel, con la sala limpia (después de la recompensa, antes
  de las puertas), conservando bendiciones, Más PS, ataques y la vida en proporción; ahí mismo sale el cartel de ataque
  nuevo si tenía las 4 ranuras llenas. **Cambia la decisión 5** (evolución como recompensa de sala con Piedra Eterna):
  por ahora es automática por nivel y Esc la frena. Decidido sin preguntar: la evolución **no** se desbloquea como
  inicial (solo lo atrapado: si no, cada inicial regalaría toda su línea).

- **Hecho — menos EXP y más dificultad** (paso O-d de la sección 11 incluido): EXP ×0,8 (antes ×3), esbirros con 50 %
  de vida y 4 fichas de ataque, mejoras enemigas visibles (Furioso, Blindado, Ardiente, Eléctrico, Regenerador) en
  campeones, élites y los Pokémon de Brock, y bendiciones ~30 % más flojas. Números de antes y después y cómo le fue al
  bot: `docs/PROGRESO.md`. Decidido sin preguntar (dudas 6 de 11.5): las mejoras arrancan en la sala 4 (donde aparecen
  los élite) y **Brock también las lleva**; además de los élite, un esbirro "campeón" por oleada lleva una (si no, en
  las salas 4-5 solo se veían en la última oleada); Blindado es más vida (no reducción de daño) y Furioso suma daño
  aparte (no toca la fórmula central); los íconos son pixel art hecho por código (16×16), no pintados.

- **Hecho — objetos equipables** (paso O-b de la sección 11): recompensa "Objeto" (puerta, Tienda), 28 objetos reales
  con el motor de las bendiciones, 3 ranuras con reemplazo, repetido = nivel, y todo visible (Mochila "De la partida",
  pestaña "Partida" de la ficha, HUD). Dudas de 11.5 resueltas con los defaults: (1) tope de nivel 3, también para las
  bendiciones (el Caramelo Raro ya no ofrece las que están al máximo); (2) el reemplazado da plata (`item_sell` 20 ×
  rareza × nivel) y además se puede guardar sin equipar o vender desde la Mochila; (7) objetos con contra, después;
  (8) "garantizado tras el jefe" espera a que haya un segundo piso. Distinto de la tabla de 11.3: la Cinta Focus da
  invulnerabilidad breve bajo 25 % (no "1 PS"), y los de stat usan un único gancho (`Creature.speed_bonus`) más ajustes
  de la partida (EXP, plata), en vez de `run_mods`.
- **Hecho — pesos por necesidad, reroll y suerte** (pasos O-a y O-c): `weight_of`, tipo "Poké Ball", reroll pagado en
  bendiciones y objetos, y suerte por Pokédex del modo. Decidido sin preguntar (dudas 3, 4 y 5 de 11.5): la suerte
  cuenta solo los atrapados (1 punto cada 3, tope 6) y +2 con inicial shiny, 4 % por punto de subir un escalón; el
  shiny sale como siempre (1 de 1024), sin desbloqueo aparte; reroll base $30, +25 % por sala limpiada, y la Tienda no
  lo tiene. Además, con menos de 40 % de vida una puerta es siempre el Centro (el plan decía "sale seguro").
  **Con esto la sección 11 quedó entera** (O-a, O-b, O-c y O-d). Lo que sigue para definir con el usuario al jugarlo:
  si la dificultad quedó en su punto (perillas en `desafio.json`: `exp_mult`, `minion_hp`, `attackers`, `champions`,
  `mods`), objetos con contra (Vidasfera), y R-4.

### Correcciones a este documento (revisado contra el código el 2026-11-11)
- Los **kits están apagados** desde el 2026-10-28: el "arma" es especie + habilidad de 3ª gen + los 4 ataques elegidos.
  Las evoluciones ya no cambian la forma de pelear, y solo Onix, Starmie y Raichu tienen kit de jefe (Articuno, Zapdos y
  Mewtwo habría que hacerlos). Las firmas (`element_marks`, charcos, teletransporte) siguen en el código pero solo las
  usan esos 3: cada bendición que las reuse hay que reengancharla y probarla.
- `status_interaction.gd` no existe: las combinaciones están en `StatusEffects` y `ReactionSystem`.
- **Salas**: ni `WarpSystem` ni el editor de mapas sirven tal cual (trabajan sobre la región); van como arenas pintadas
  cargadas aparte (así quedó en R-0).
- **Esbirros con poca vida**: `hp_scale` es un ajuste global, no por criatura: hay que agregar un multiplicador por
  Pokémon (R-1). `TrainerBattle` maneja un solo rival: las oleadas tienen su director (`RogueRun`).
- **Más barato de lo que decía**: ya existen `slot_roles` (básico rápido en Clic izq., definitiva en R) y
  `cooldown_mult`, apagados; el modo los puede prender desde `settings` del piso. Pelear contra varios ya andaba
  (`CombatDirector.enemies`, manadas) y los golpes cuerpo a cuerpo ya pegan a todos los que toca el arco.
- **No estaba**: el PP como maná. Medido con el bot en R-0: contra 3 a la vez la barra normal deja la mitad de la pelea
  sin poder atacar; el modo la llena al doble (`pp_regen` 2). Es la perilla a mirar primero al jugarlo.

---

## 10. Etapa aparte: "Salas por piezas" (plan, sin implementar; acordado con el usuario el 2026-11-11)

**Por qué.** Hoy cada sala es **una pintura entera** de Qwen (1600×1200 para 1024×768 px de juego) y la colisión sale de
esa pintura por color (`auto_color`). Dio 36 salas rápido, pero tiene techo: el suelo sale liso o granulado, con el zoom
del juego se ve pixelado, los objetos son parte del fondo (tu Pokémon nunca pasa *por detrás* de una palmera), no
reaccionan (no se queman ni se rompen) y cada sala nueva es otra pintura a revisar. La prueba de alta resolución con
Costa 1 mejora mucho la nitidez, pero no cambia nada de lo demás. La alternativa es armar las salas como Hades: **un
fondo + objetos sueltos**.

### 10.1 Cómo es una sala por piezas
- **Piso**: una textura de fondo por bioma en alta resolución (grande, sin repetición visible, o 2-3 variantes), pintada
  una sola vez y revisada con el zoom del juego. Encima, **manchas de decorado sin colisión** (conchas, flores, grietas,
  charcos secos, huesitos) para que dos salas del mismo bioma no tengan el mismo suelo.
- **Obstáculos = piezas**: cada una es un sprite pintado con Qwen en alta resolución, **con fondo transparente y el origen
  en los pies** (como todas las entidades del juego), dentro del y-sort del mundo: lo que está más abajo tapa a lo que
  está más arriba, así se pasa por detrás de una palmera o una columna. Colisión con **la forma de su base** (no el
  rectángulo de toda la imagen) y, si corresponde, tags de entorno como cualquier `EnvObject`: `inflamable` (árbol, tronco,
  carpa), `fragil` (roca que se rompe con una embestida, cajas), `pesado`, `conductor`.
- **Zonas de líquido**: agua, lava y hielo roto no son piezas sólidas sino **zonas** (forma + borde pintado): el agua es
  agua de verdad (moja, frena, conduce: lo que ya hace la capa `Water`), la lava quema al pisarla y el agua helada frena.
  Así aparecen los peligros propios de cada bioma que quedaron pendientes.
- **Paredes**: el borde de la sala también por bioma: tramos rectos, esquinas y el tramo con el paso (arriba y abajo),
  para que el encadenado de hoy siga igual (mismo ancho, paso en el medio).
- **La grilla sigue debajo**: las celdas de la zona se marcan desde las piezas colocadas (sólido, agua, tags), así
  `ReactionSystem`, `MapRules`, los caminos de la IA (`find_path`), los puntos de aparición y `door_cells` no cambian.

### 10.2 Las piezas del catálogo
`data/rogue/piezas/<bioma>/<id>.tres` (recurso nuevo, p. ej. `RoomPiece`): sprite, tamaño en celdas de su base, forma de
colisión, tags, categoría y cuántas admite una sala. Categorías:

| Categoría | Ejemplos (Costa) | Colisión | Cuántas por sala |
|---|---|---|---|
| Chica | roca chica, caja, barril, coral | 1×1 a 2×1 | 6-10 |
| Mediana | roca con percebes, palmera, tronco, bote | 2×2 a 4×2 | 4-7 |
| Grande / protagonista | naufragio, faro caído, muelle | 6×4 o más | 0-1 |
| Zona | charco de marea, laguna | agua (no sólida) | 1-4 |
| Decorado | conchas, estrellas de mar, algas, huellas | ninguna | 10-25 |
| Pared | recta, esquina, con paso | sólida | las que hagan falta |

Para empezar alcanzan **~12 piezas por bioma** (4 chicas, 4 medianas, 1 grande, 2 zonas, y un juego de decorado que va en
una sola hoja) más las paredes. Con 6 biomas son unas 70-80 piezas más 6 pisos.

### 10.3 El generador
`RoomBuilder.build(bioma, semilla, tipo)` arma una sala sorteando piezas con reglas:
1. Pone las paredes y deja libres el paso de entrada y el de salida, con un margen delante de cada uno.
2. Elige una **plantilla de composición** (centro libre con cosas en los bordes; una protagonista en el centro con anillo
   libre alrededor; dos mitades con un pasillo; laguna al costado...) para que no todas sean "cosas desparramadas".
3. Coloca la pieza grande (si la plantilla la pide), después zonas, medianas y chicas, respetando distancias mínimas
   entre piezas (que pase un Pokémon grande) y un **área jugable** libre mínima.
4. **Valida**: todo el piso conectado desde la entrada hasta la salida (`MapRules` / el mismo recorrido de celdas de
   `--autotest-room-walk`), lugar para que aparezcan las oleadas y para las dos puertas de recompensa. Si falla, prueba
   con otra semilla.
5. Decorado sin colisión por encima, con densidad por bioma.

Con **semilla** fija la sala es siempre la misma (tests y capturas). Dos opciones de cuándo se genera: **(a) fuera del
juego** (el generador escribe la escena y su `ArenaData`, como hoy `build_arenas.gd`: fácil de revisar y de arreglar a
mano, y se pueden guardar las 30 mejores semillas por bioma) o **(b) al entrar a la partida** (salas infinitas, pero sin
revisar). Recomendado: **(a)** primero; (b) después si se quiere, con el mismo generador.

### 10.4 Qué se reusa y qué se reemplaza
- **Se reusa tal cual**: `RogueRun` (encadenado, portones, oleadas, esbirros y fichas), bendiciones, recompensas y
  puertas, biomas y sus Pokémon (`data/rogue/desafio.json`), el castillo de Mew, los tests del modo.
- **Se reemplaza**: la pintura entera + `auto_color` como fuente de las salas (quedan para el castillo y las arenas de
  gimnasio, que son una sola imagen fija y están bien así). `ArenaDecor._add_painting` pasa a dibujar el piso del bioma.
- **Convivencia**: las 36 salas pintadas siguen funcionando mientras tanto. Cada bioma en `desafio.json` lista sus salas:
  al convertir un bioma, sus salas por piezas se suman a esa lista (o la reemplazan) sin tocar los demás. Se puede comparar
  una pintada contra una por piezas en la misma partida.

### 10.5 Pasos (cada uno con su autotest y el juego ejecutable)
| Paso | Qué | Cómo se prueba |
|---|---|---|
| **P-0** | **Bioma de muestra** (Costa): piso en alta resolución, ~12 piezas con fondo transparente y colisión de base, paredes, y 3 salas armadas a mano con esas piezas para ver el resultado | `--showcase-rogue --biomes costa` + captura; el usuario compara contra las pintadas |
| P-1 | `RoomPiece` + `RoomBuilder` con semilla, plantillas y validación; 10 salas de Costa generadas | `--autotest-rogue-builder` (200 semillas: conectadas, con lugar, sin piezas encimadas) |
| P-2 | Piezas con vida: se pasa por detrás (y-sort), tags de entorno (se queman, se rompen), agua/lava como zonas con efecto | `--autotest-rogue-pieces` + jugarlo |
| P-3 | Los otros 5 biomas (piso + piezas + paredes) | el test de P-1 por bioma + capturas |
| P-4 | Retirar las salas pintadas (o dejarlas como "salas especiales") y, si gusta, generar al entrar | `--autotest-rogue-rooms` completo |

**P-0 es el que decide**: si el bioma de muestra no se ve claramente mejor que las pintadas, no se sigue.

### 10.6 Riesgos
- **Cantidad de arte**: ~80 piezas + 6 pisos + paredes. Qwen las pinta de a una en ~15 s, pero cada una hay que
  recortarla y revisarla. Mitigación: hojas de varias piezas por prompt y un script de recorte (como `prop_from_image.py`).
- **Recorte del fondo**: Qwen no devuelve transparencia; hay que pintar sobre un color plano y recortar. Las piezas con
  bordes finos (palmeras, árboles secos, rejas) son las difíciles; la sombra conviene dibujarla aparte por código
  (`SunShadow` / `blob_shadow`), no pintada.
- **Coherencia de estilo** entre piezas pintadas por separado (luz, escala, grosor de línea): fijar un prompt base por
  bioma y pintar las piezas de una misma categoría juntas.
- **Paredes**: es la parte que más se nota si queda mal (uniones entre tramos). Alternativa barata: una sola pintura de
  "marco" por bioma con el centro vacío.
- **Rendimiento**: 5 salas encadenadas × ~40 nodos por sala = ~200 sprites con colisión; no debería ser problema, pero
  medirlo. Si hace falta, las salas lejanas se cargan al acercarse.
- **Choque con la IA**: hoy los obstáculos son celdas enteras; con formas de base más chicas hay que confirmar que
  `CombatBody.steer` y `find_path` no se traben en las esquinas (el test de recorrido lo cubre).

### 10.8 Decisiones y estado (2026-11-11)
El usuario decidió **no repintar las 36 salas** y pasar a esta etapa. Respuestas: muestra = **Costa**; estilo = **pixel
art cercano al de los sprites** (limpio, a la resolución del juego, sin grano); las pintadas **se retiran bioma por
bioma** a medida que se convierten. Decidido sin preguntar: salas **generadas fuera del juego y revisadas**; en el primer
paso el agua de los charcos ya es agua de verdad (moja, frena, conduce) y la lava/hielo quedan para cuando se conviertan
esos biomas.

**Hecho: P-0** (ver `docs/PROGRESO.md` y CLAUDE.md): Costa con marco en pixel art 1 a 1, 16 piezas y 3 salas armadas a
mano, y-sort, colisión por elipse de base y grilla debajo. Cómo se llegó al pixel art limpio: Qwen pinta "pixel art" con
píxeles falsos de tamaño irregular; se pinta grande (marco 2048×1536, piezas 1024) y **se achica a la resolución del
juego promediando y con paleta chica sin tramado** (`prop_from_image.py` para las piezas, `pixel` para el marco), y se
dibuja 1 a 1 con filtro nearest. Distinto del plan: las paredes van en la misma pintura que el piso (el "marco"), no
como piezas. **Frenado** hasta que el usuario compare. Para ajustar con su opinión: densidad y escala de las piezas, y el
piso (hoy arena lisa con decorado suelto).

**Hecho: P-1 en la Costa, por escenas** (2026-11-11, pedido del usuario: composición con sentido). El generador
(`tools/build_piece_rooms.py`) coloca **escenas** con ancla (orilla / borde / arena) y miembros relativos, en vez de
piezas sueltas; marcos con mar de verdad; decorado repartido con criterio. Cambios respecto del plan de 10.3: las
"plantillas de composición" son el **tema de la sala** (su lista de escenas, la primera protagonista); se genera fuera
del juego y cada sala guarda su semilla. **Para convertir otro bioma** hay que pensar primero sus escenas (qué va con
qué y pegado a qué): volcán = río de lava con puente y rocas incandescentes en sus bordes, fumarolas agrupadas, esqueleto
con huesos alrededor; hielo = lago helado con cristales en la orilla, bosquecito de pinos, cabaña con leña y pozo...
**Frenado** hasta que el usuario apruebe la Costa.

### 10.9 Escenas de los otros biomas (referencias miradas el 2026-11-11; plan, sin implementar)
Pedido del usuario: que los demás biomas también "tengan sentido". Miré mapas top-down de juegos y tilesets de cada tema
(búsquedas de imágenes, solo para composición: no se bajó arte ajeno). Lo que se repite en los buenos mapas y cómo pasarlo
a escenas (ancla → miembros). En todos: **un elemento que ordena la sala** (río, sendero, hilera, vía) y lo demás se
acomoda respecto de él; la vegetación o las rocas en grupos contra las paredes; el centro libre.

| Bioma | Lo que ordena la sala (marco) | Escenas (qué va con qué) | Zonas / peligro |
|---|---|---|---|
| **Volcán** | Un **río de lava** que cruza o bordea (marcos: lava a un costado, río que serpentea con un vado de piedra, lago de lava al fondo) | *Vado*: losas de basalto cruzando la lava + rocas incandescentes en las dos orillas. *Fumarolas*: 3-4 conos juntos con ceniza y azufre amarillo alrededor. *Osario*: esqueleto grande + huesos sueltos + cráneo, lejos de la lava. *Árboles quemados*: troncos carbonizados en grupo con brasas a los pies. *Forja*: horno contra la pared + yunque + carbón + herramientas. *Desprendimiento*: rocas negras de grande a chica cayendo desde la pared. | Lava = zona que quema al pisarla; rocas incandescentes al borde |
| **Bosque** | Un **sendero de tierra** entre la entrada y la salida, y un **arroyo o estanque** (marcos: arroyo a un costado con piedras para cruzar, claro con estanque, claro seco) | *Campamento*: fogata en el centro del grupo + carpa + troncos para sentarse + leña apilada, junto al sendero. *Ruinas*: arco caído + columnas rotas en fila + estatua, con hiedra y hongos alrededor. *Arboleda*: 3-5 árboles juntos contra la pared con raíces, helechos y hongos. *Estanque*: juncos y nenúfares en el borde + rocas musgosas + un tronco caído que entra al agua. *Santuario*: altar contra la pared + dos faroles de piedra a los lados + ofrendas. *Tocones*: tocones + hacha + troncos cortados (un claro talado). | Agua baja (moja); pasto alto que se prende |
| **Cueva** | Una **vía de mina** que entra por un lado y termina en un tope, o un **río subterráneo** (marcos: vía curva, lago oscuro al costado, galería seca con columnas) | *Mina*: vía + vagoneta al final + tope + pila de mineral + farol. *Apuntalado*: vigas contra la pared con faroles + cajas + picos y palas. *Veta de cristales*: cristales de grande a chico pegados a la pared + esquirlas en el piso. *Estalagmitas*: 3-5 juntas de distinto alto + goteras/charquitos. *Excavación*: fósil a medio desenterrar + andamio + cepillos y cajas. *Hongos*: colonia de hongos brillantes junto al agua. | Agua oscura (moja); rocas frágiles |
| **Gruta helada** | Un **lago congelado** o una **grieta de agua** (marcos: lago helado al costado con orilla de nieve, río helado que cruza con un puente de hielo, claro nevado) | *Cabaña*: cabaña en ruinas contra la pared + leña apilada + pozo + trineo. *Pinar*: 3-5 pinos juntos con nieve amontonada a los pies. *Cristales*: púas de hielo de grande a chica junto al lago. *Pesca en el hielo*: agujero en el lago + banquito + balde + caña. *Ruinas heladas*: columnas en fila + estatua dentro de un bloque de hielo + brasero azul. *Ventisquero*: rocas con nieve encima y carámbanos. | Hielo que resbala o agua helada que frena |
| **Cementerio** | Un **sendero de piedra** de la entrada a la salida y las tumbas **en hileras**, no sueltas (marcos: sendero recto con canteros, sendero que rodea un cantero central, sin sendero con niebla) | *Hilera de tumbas*: 4-6 lápidas alineadas, con flores marchitas, una vela y una torcida. *Parcela cercada*: reja en U + 2-3 tumbas adentro + farol en la esquina. *Mausoleo*: mausoleo contra la pared + dos estatuas de ángel a los lados de su puerta + escalones. *Árbol viejo*: árbol seco grande + farolitos colgando + calabazas y hojas a los pies. *Capilla*: ruina con bancos en dos filas mirando al altar + campana caída. *Fosa abierta*: fosa + pala + montículo de tierra + ataúd. | Niebla (visual); nada que frene |

Para cada bioma hace falta: 2-3 marcos, ~20-30 piezas (varias se comparten entre escenas) y sus `SCENES`/`ROOMS`. Cosas
nuevas respecto de la Costa: escenas **en hilera** (tumbas, columnas, bancos: miembros repetidos a paso fijo), escenas
que siguen un **camino** del marco (vía, sendero) y zonas con efecto propio (lava). El agua en movimiento
(`shaders/pixel_water.gdshader`) sirve para la lava (más lenta y con más brillo) y el agua helada.

**Hecho: los otros 5 biomas** (2026-11-11, el usuario aprobó la Costa): Volcán, Bosque, Cueva, Gruta Helada y Cementerio
con las escenas de 10.9. Lo que quedó distinto del plan: las hileras y la vía de mina se armaron con miembros a paso
fijo dentro de la escena (no hizo falta nada nuevo en el generador); el sendero del marco se respeta con `trail`; el
"vado" de losas sobre la lava no se hizo (la lava es pared). **Pendiente**: efecto propio de la lava (quemar) y del
hielo (resbalar), retirar del repo las 36 salas pintadas, y ajustar con el usuario densidad y tamaños al jugarlo.

### 10.7 Preguntas abiertas para el usuario
1. **Bioma de muestra**: ¿Costa (donde se vio el problema) o Bosque?
2. **Generar fuera del juego o al entrar**: ¿salas revisadas a mano (30 por bioma, por ejemplo) o infinitas?
3. **Qué pasa con las 36 pintadas**: ¿se retiran, o quedan como salas especiales (con su versión en alta resolución)?
4. **Peligros**: ¿la lava quema y el agua helada frena desde el primer paso, o primero solo lo visual?
5. **Estilo de las piezas**: ¿pintura "HD-2D" como la prueba de Costa 1 o más cerca del pixel art de los sprites?

---

## 11. Etapa aparte: objetos equipados, suerte, reroll y mejoras enemigas (**hecho el 2026-11-11**: ver sección 9; usuario, 2026-11-11)

Sale de mirar cómo lo hace PokéRogue. **No se implementa hasta que el usuario lo pida**; va después de la prueba de la
Costa y es independiente de "Salas por piezas" (sección 10).

### 11.1 Decisiones ya tomadas por el usuario
- **Objetos equipados**: 3 ranuras por Pokémon. Con las 3 llenas, uno nuevo reemplaza a otro (elegís cuál). Un
  repetido sube de nivel el que ya tenés.
- **Suerte**: sale de la Pokédex del modo: cuantas más especies desbloqueadas por captura, más suerte; un inicial shiny
  suma extra. Mejora la rareza de lo que te ofrecen (bendiciones y objetos): cada opción tiene una chance de subir un
  escalón de rareza, como en PokéRogue.
- **Reroll**: en toda pantalla de "elegí 1 de 3" (bendiciones y objetos), pagado con el dinero de la partida. El costo
  se duplica con cada reroll seguido en la misma pantalla y sube con las salas. En las puertas no hay reroll.

### 11.2 Qué hay hoy (para no romperlo)
- `RogueRewards` (`world.rogue.rewards`): 7 tipos, `options()` sortea 2 con los pesos fijos de `rewards.weights`
  (`data/rogue/desafio.json`) y `available()` ya saca lo que no sirve (Caramelo sin bendiciones, Tienda sin plata, MT sin
  candidatos). `grant()` da la recompensa; las que se eligen usan `RewardScreen` (tarjetas) o `BoonScreen`.
- `RogueBoons`: efectos por señales de tu Pokémon (`hit_dealt`, `dodged`, `damage_received`) y `creature_fainted`, datos
  en `BoonData` (`effect` + `params` + `scaled`), rarezas con peso y multiplicador en `bendiciones.json`, nivel por
  repetida. Estado en `GameState.rogue["boons"]`.
- `RogueProgress` (`user://desafio.json`): especies desbloqueadas y banderas. `CreatureInstance.hp_mult` y
  `Creature.attack_gate` (R-1). El dinero de la partida es `GameState.money`.

### 11.3 Contenido
**1. Pesos por necesidad** (reemplaza los pesos fijos). `RogueRewards.weight_of(tipo)` = peso base × factor según tu
situación al limpiar la sala:

| Tipo | Factor |
|---|---|
| Centro | ×(0,3 a 3) según la vida que te falta (con la vida casi entera, casi no sale; bajo 40 %, sale seguro) |
| Tienda | 0 si no te alcanza para nada; ×1,5 si te alcanza para 2 cosas o más |
| MT | ×1,5 si hay un candidato claramente mejor que tu ataque más flojo (potencia, STAB); 0 sin candidatos |
| Caramelo Raro | 0 sin bendiciones; crece con cuántas tenés |
| Poké Ball (nuevo tipo) | ×2 si te queda 1 o ninguna; ×0,3 con 3 o más |
| Objeto | ×0,3 con las 3 ranuras en nivel máximo; ×1,5 con ranuras vacías |
| Dinero, Más PS, Bendición | base (la Bendición sigue siendo la más común) |

Regla dura: **nunca ofrecer algo inútil** (ya existe con `available`; se extiende a los tipos nuevos).

**2. Recompensa "Objeto"** (puerta con su ícono, artículo de la Tienda y **garantizado después de un jefe**): te ofrecen 3
con rareza (las 4 de las bendiciones) y elegís uno. Son objetos reales de Pokémon adaptados al tiempo real, **solo de la
partida**:

| Objeto | Efecto en tiempo real | Efecto del motor |
|---|---|---|
| Restos | regenera vida cada segundo en combate | `regen` (nuevo, por tiempo) |
| Campana Concha | cura un % del daño que hacés | `lifesteal` (nuevo, en `hit_dealt`) |
| Cinta Focus | sobrevivís un golpe mortal con 1 PS, una vez por sala | `phoenix` con otro umbral / `lethal_guard` |
| Garra Rápida | el esquive recarga antes | `stat` dodge_cooldown (nuevo) |
| Roca del Rey | chance de stagger extra al pegar | `hit_status` con un estado corto ("Azotado") |
| Periscopio | chance de golpe crítico (+50 %) | `crit` (nuevo: daño de más al azar) |
| Carbón, Agua Mística, Imán, Semilla Milagro... | +daño de ese tipo | `bonus_type` (nuevo); **solo se ofrecen los del tipo de tus ataques** |
| Vidasfera | +daño, perdés un poco de vida al pegar | `bonus_all` + costo |
| Casco Dentado | daña al que te pega cuerpo a cuerpo | `thorns` (ya existe) |
| Pañuelo Elegido | +velocidad de movimiento | `stat` speed (nuevo) |
| Baya Zidra | cura al bajar de 50 %, se repone por sala | `phoenix` (ya existe, otros números) |
| Cascabel Alivio / Huevo Suerte | más EXP | `stat` exp (ajuste de la partida) |
| Moneda Amuleto | más dinero por sala | `stat` money |

- **Se reusa el motor de las bendiciones**: mismo `effect` + `params` + `scaled`, con origen "objeto". Lo más simple es que
  `RogueBoons` recorra dos listas (`GameState.rogue["boons"]` y `GameState.rogue["items"]`) y que los datos de objeto sean
  `BoonData` con `giver = "objeto"` y un campo `item_id` (para usar el `ItemData` y el ícono de `sprites/items` cuando
  existan; los que falten, ícono pintado). Así un efecto nuevo sirve para las dos cosas.
- **Efectos nuevos que hacen falta**: por tiempo (`regen`), robo de vida, crítico, bonus por tipo de ataque y los de
  "stat" (velocidad, recarga del esquive, EXP, dinero). Los de stat necesitan ganchos chicos en el combate central
  (hoy `Creature.speed()` y `MoveUser.dodge_cooldown` solo miran la firma): proponer un multiplicador genérico por
  criatura (`Creature.run_mods`, vacío fuera del modo), en vez de un `if` por objeto.
- **3 ranuras**: `GameState.rogue["items"]` = hasta 3 `{id, rarity, level}`. Con las 3 llenas, después de elegir se abre
  la pantalla de tarjetas con tus 3 para elegir cuál se va (o "no cambiar"). Repetido = +1 nivel, sin gastar ranura.
- **Que se vean**: íconos en el HUD de la partida (al lado de las bendiciones, con otro marco) y una sección "Objetos" en
  Equipo del menú de pausa con nombre, nivel y descripción (también para las bendiciones, que hoy solo son íconos).

**3. Suerte y reroll.**
- `RogueProgress.luck()` = puntos por especies desbloqueadas (por ejemplo 1 cada 5, con tope) + extra si el inicial de
  esta partida es shiny. Cada punto da a **cada opción ofrecida** una chance de subir un escalón de rareza
  (`RogueBoons.roll_rarity(suerte)`); la suerte se muestra en el castillo (al elegir) y en la pantalla de elección.
- Reroll: botón en `BoonScreen` y en la pantalla de objetos, con el costo a la vista. Costo = base × 2^(rerolls seguidos
  en esa pantalla) × (1 + salas limpiadas × factor). Sin plata, apagado. No se puede en las puertas ni en Caramelo/MT.
  Los pesos del sorteo no cambian al rerollear (solo se vuelve a tirar).

**4. Mejoras de los enemigos al avanzar** (el "pool enemigo" de PokéRogue): desde cierta sala, los élite (la oleada
fuerte) y el Pokémon del jefe llevan **un modificador visible** (ícono sobre su barra de vida y su nombre en el cartel):
Furioso (+daño), Blindado (aguanta más), Ardiente / Eléctrico (quema o paraliza al golpear), Regenerador (se cura un
poco). Así la dificultad sube con algo más que el nivel. Se arma con el mismo motor, enganchado a la criatura enemiga
(un `RogueBoons` chico por enemigo, o el motor generalizado a "dueño" cualquiera): es la parte que obliga a que el motor
deje de asumir que el dueño es tu Pokémon. Datos en `desafio.json`: desde qué sala, cuántos, y la lista con pesos.

### 11.4 Pasos (cada uno con su autotest, el juego ejecutable y commit propio)
| Paso | Qué | Autotest |
|---|---|---|
| **O-a** | Pesos por necesidad (`weight_of`), tipo "Poké Ball", y reroll en `BoonScreen` (costo, duplicación, tope por plata) | `--autotest-rogue-rewards` ampliado: con la vida baja el Centro sale casi siempre; sin plata no hay reroll; el costo se duplica |
| O-b | Objetos equipables: datos, 6-8 objetos con los efectos que ya existen + los nuevos (`regen`, robo de vida, crítico, bonus por tipo), 3 ranuras con reemplazo, nivel por repetido, puerta/Tienda/tras el jefe, HUD y Equipo | `--autotest-rogue-items` (cada objeto hace lo que dice; ranuras; solo se ofrecen potenciadores de tus tipos) |
| O-c | Suerte (`RogueProgress.luck`, shiny) aplicada a bendiciones y objetos; se muestra en el castillo y en la pantalla | en 5000 tiradas, más suerte = más raras; con 0 de suerte no cambia nada de hoy |
| O-d | Mejoras enemigas: motor con dueño cualquiera, 4-5 modificadores, ícono sobre la barra, desde qué sala | `--autotest-rogue-foes` (el modificador hace lo que dice y se ve; antes de la sala N no hay) |

### 11.5 Dudas de diseño que quedan
1. **Objetos y bendiciones repetidos**: ¿tope de nivel (por ejemplo 3) para que "las 3 ranuras al máximo" exista de verdad?
2. **Reemplazo**: al cambiar un objeto, ¿el que sale se pierde o da algo de plata?
3. **Suerte**: ¿cuenta todas las especies desbloqueadas o solo las atrapadas (sin los 3 iniciales)? ¿Tope?
4. **Shiny**: hoy el inicial sale shiny 1 de cada 1024 como cualquiera; ¿alcanza o hay que poder desbloquear la versión
   shiny (atrapando un shiny en una partida) para elegirla?
5. **Reroll**: costo base (¿$30?) y si la Tienda también lo tiene.
6. **Mejoras enemigas**: ¿desde la sala 3? ¿El jefe (Brock) también, o solo los élite por ahora?
7. **Objetos con costo** (Vidasfera): ¿van, o por ahora solo objetos sin contra?
8. **Tras el jefe**: hoy después de Brock termina la partida; el "objeto garantizado tras el jefe" tiene sentido recién
   cuando haya un segundo piso. ¿Se deja preparado o se espera a los pisos?
