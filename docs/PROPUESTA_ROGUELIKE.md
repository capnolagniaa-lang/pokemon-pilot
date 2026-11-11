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
3. **Pendiente — castillo de Mew**: Mewtwo corrompió el mundo; aparecés en un castillo donde Mew te cuenta la historia,
   elegís el inicial y un portal arranca la partida. **Reemplaza al hub del laboratorio de Oak** de la sección de hub.

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
