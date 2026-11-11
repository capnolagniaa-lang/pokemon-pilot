# Progreso del proyecto

Bitácora viva. Se actualiza al cerrar cada etapa (y antes de que se termine el contexto de una sesión).

> **Plan paralelo:** la identidad del combate (arquetipos, mecánica de firma y kit por Pokémon) se sigue en
> [`PLAN_IDENTIDAD_COMBATE.md`](PLAN_IDENTIDAD_COMBATE.md), con su propia tabla de avance.

## 📍 Dónde estamos (actualizado 2026-11-05)
- **Modo Desafío: salas más grandes, encadenadas y con obstáculos (2026-11-11, pedido del usuario después de R-0)**: las 3 salas pasaron de 40×30 a **64×48 celdas** y se cargan **todas juntas, una arriba de la otra**: al limpiar una se abre el portón de troncos de arriba y pasás caminando a la siguiente, sin fundido; al entrar, otro portón se cierra detrás. El fundido queda solo para ir a Brock (la puerta dorada, al final de la escalera de la tercera). El entrenador ahora te sigue. Pinturas nuevas de Qwen (2048×1536) con obstáculos adentro: rocas, árboles y troncos en el claro; pilares, escombros y 3 lagunas de agua de verdad en las ruinas; raíces, troncos viejos y rocas en el corazón del bosque. La colisión de los obstáculos y el agua salen solos de la pintura por color (`tools/paint_arenas.py`, `auto_color`: lo gris y lo oscuro choca, lo celeste es agua). Quedaron sin chocar los tocones y troncos caídos del claro (marrones como la tierra): se pisan. `RogueGate`. Mismo test (`--autotest-rogue-rooms`, con el bot rodeando obstáculos por celdas) y vitrina. Sin jugar a mano.
- **Modo Desafío, R-0 (2026-11-11; roguelike estilo Hades, `docs/PROPUESTA_ROGUELIKE.md`)**: botón **"Modo Desafío"** en el título → elegís uno de 3 Pokémon al azar (Nv. 10, 3 Pociones) → 3 salas del Bosque Verde con oleadas de salvajes (2, 3 y 3 oleadas; al limpiar la sala recuperás 40 % y se abre la puerta de arriba: caminás hasta ella con tu Pokémon) → Líder Brock en su gimnasio, con Onix de jefe. Un solo Pokémon: si cae, se termina. No toca la historia ni guarda nada (`GameState.rogue`, como "Probar el torneo"). Las salas son pinturas de Qwen con el sistema de las arenas pintadas (`sala_bosque_1..3`). En el modo: EXP ×3 (se sube de nivel adentro: 10 → ~15), la barra de PP se llena al doble (con la normal, contra 3 a la vez se pasaba media pelea sin poder atacar: medido con el bot) y no hay botín, evolución ni "reemplazar ataque" (van a ser recompensas de sala). Todo eso sale de `data/rogue/bosque_verde.json`. `RogueRun` (`world.rogue`), `RogueDoor`, `scenes/ui/rogue_select.tscn`. Test `--autotest-rogue-rooms` (un bot que tira ataques de daño al azar limpia las 3 salas; cae más o menos 1 de cada 4 veces, casi siempre en la sala 3, y ahí juega de nuevo, hasta 3 intentos; a Brock lo voltea el test), vitrina `--showcase-rogue`. **Sin bendiciones ni hub.** Decisiones tomadas (las 8 de la propuesta): modo aparte en el título; un Pokémon + hasta 2 asistentes capturados; nivel fijo y sube adentro; salas hechas a mano y pintadas con Qwen (no tienen que parecerse a FireRed); bendiciones de legendarios; evolución como recompensa de sala (o Piedra Eterna); capturar = inicial para siempre; sin multijugador por ahora. **Frenado acá: el usuario lo quiere jugar antes de R-1** (esbirros con poca vida y fichas de ataque).
- **Látigo Cepa con aturdido (2026-11-10, pedido del usuario)**: ahora es un látigo de rango medio (95 px) que pega al primero que alcanza y lo deja "Azotado" ~0,5 s (no actúa ni se mueve; cuenta como control, así que dos seguidos duran menos). Antes era una embestida. Dibujo por código. Test en `--autotest-sky-stream`, vitrina `--showcase-whip`. Falta probarlo jugando.
- **IA de entrenadores nueva, Fase 4: modelo del jugador (2026-11-09)**: `PlayerModel` aprende de lo que ve (tus ataques, esquives, pasos, cambios): secuencias de 2 y 3 acciones, cómo respondés a cada clase de ataque suyo, tu distancia favorita y si contracambiás, con memoria que se desvanece y confianza que crece más rápido cuanto más difícil (`AIProfile.memory_half_life`, `adapt_k`, `read_skill` × `TrainerStyle.reads`). El cerebro nuevo lo usa: corre la puntería hacia donde vas a esquivar, amaga más si esquivás el aviso, se corre antes de tu próximo golpe y cambia menos si contracambiás. Test `--autotest-ai-model` (incluye un bot que siempre esquiva a la derecha: lo aprende y le corre la puntería). Duelo contra la clásica: 172 a 212 (sin el modelo, 153 a 220; la batería tiene mucho ruido con 400 peleas).
- **IA de entrenadores nueva, Fase 3: cerebro de utilidad (2026-11-09)**: ajuste **"IA nueva de entrenadores (en prueba)"** (Opciones → Ajustes del juego → IA de entrenadores, apagado por defecto). Prendido, el Pokémon del entrenador decide con `UtilityBrain` (puntúa atacar con cada ataque, juntar PP, acercarse, alejarse, rodear, mantener la distancia y salir del rincón; resta lo que repitió; elige con softmax; piensa con ritmo variable, ráfagas y respiros; reacciona a lo que ve venir; apunta adonde cree que vas a estar) y el entrenador con `UtilityCoach` (mantener, cambiar, Superpoción). Sin trampas: todo sale de lo que percibe. Perillas por dificultad en `AIProfile` (a ojo). Batería `--brain duelo` (nueva contra clásica): primer duelo de 400 peleas **parejo** (la nueva 183, la clásica 196, 21 empates), y eso que la clásica ve sin retraso y sabe tus recargas. Test `--autotest-ai-utility`. **Falta jugarla** para ajustar los valores.
- **IA de entrenadores nueva, Fase 2: percepción y situación (2026-11-09)**: `AIProfile` por dificultad (`data/ai/profiles/`: retraso de percepción Fácil 0,4 s, Normal 0,25, Difícil 0,15, con variación), `Perception` (ve tu Pokémon como era hace ese tiempo; tus recargas y PP los **estima** con lo que te vio tirar, nunca los mira) y `Situation` (neutral cerca/media/lejos, castigar, le viene un ataque, acorralado, poca vida, rematar; cruce con lo que te vio, el mejor del banco y si conviene cambiar). Se ve en el overlay (`ia ver`); la IA de hoy no lo usa todavía (lo va a usar el cerebro nuevo de la Fase 3). Test `--autotest-ai-perception`.
- **IA de entrenadores nueva, Fase 1: instrumentación (2026-11-09)**: auditoría en `docs/IA_AUDITORIA.md` (Fase 0, plan aprobado: cerebro de utilidad nuevo en paralelo a la IA actual, con el ajuste `ai_brain`, en `main`; sin trampas en la nueva). Hecho: `AiTrace` (cada decisión de la IA sale por `Events.ai_decided`: modo, ataque con su top 3, aviso, finta, juntar PP, ve la amenaza, paso, esquive, saca, cambia o no y por qué, retira, poción, momento del guion), `AiDebug` (`world.ai_debug`): **registro** a `user://ia_log/` (GM `ia log`), **overlay** con situación, amenaza, top 3, lo que te lee y la pelea (GM `ia ver`), y **métricas por pelea** (`AiFightStats`: daño, castigos hechos y perdidos de los dos lados, esquives útiles, pasos, cambios buenos por cruce, repetición de ataques, tiempo en cada modo), que van también al JSON de sparring (versión 2). **S-2**: `tools/sparring_report.py` → `docs/SPARRING_INFORME.md`. No cambia cómo pelea la IA (los tests de IA siguen igual). Test `--autotest-ai-trace`, vitrina `--showcase-ai-overlay`. Próximo: Fase 2 (percepción con retraso y clasificador de situación).
- **Rayo Solar como rayo (2026-11-09, pedido del usuario)**: carga 1,1 s marcando la línea (la luz se junta en la boca) y después sale un rayo instantáneo de 200 px que pega a todos en la línea a la vez, hasta la primera pared (`BeamStrike`, `MoveData.beam_length`). Animaciones de Qwen (sesión ConfyUI). Test en `--autotest-sky-stream`, vitrina `--showcase-solar`. Falta probarlo jugando.
- **Choque de proyectiles (2026-11-09, pedido del usuario)**: dos disparos que se tocan chocan (`Projectile.clash`). Gana el más fuerte (potencia × efectividad × golpes × lo que le queda); parejos (menos de 1,25 veces) revientan los dos; el que gana sigue con el daño que le sobra (mínimo 25 %). Del mismo bando (de dos Pokémon distintos) se destruyen los dos siempre; los del mismo Pokémon no chocan (un abanico se destruiría solo). Efecto: destello en dos colores (`shaders/clash_tint.gdshader`, hojas en grises de Qwen) y, si los dos pegan fuerte (potencia ≥ 60), anillo, sacudida y hitstop. Online: choca en el servidor (vale para el daño) y en cada pantalla por separado (solo visual, puede diferir: ver `docs/ONLINE_INFORME.md`). La IA no dispara para interceptar a propósito. Test `--autotest-clash`, vitrina `--showcase-clash` (`--scenario <nombre>` = un caso). Falta probarlo jugando.
- **Pokédex: "Dónde aparece" (2026-11-08)**: cada especie vista muestra en qué zonas sale como salvaje, cómo (pasto alto, suelo, Surf, pesca con cada caña) y con qué % y niveles, sacado de las mismas tablas que usa el juego (`WildIndex`). Las zonas que todavía no visitaste salen como "???" con su % (decisión del usuario). Test en `--autotest-pokedex`, vitrina `--showcase-pokedex`. Día/noche no se muestra: las tablas todavía no lo distinguen.
- **Online revisado a fondo (2026-11-08)**: `docs/ONLINE_INFORME.md` (mapa de una pelea, bugs, propuestas). Arreglados: quedar trabado en la arena si se cortaba la conexión en plena pelea, toques de un cuadro que se perdían con la red (contadores en el paquete, `PROTOCOL` 7: **hay que publicar versión**), clima compartido entre peleas del servidor (ahora por pelea), arenas que se encimaban, paquetes con basura, habilidades ajenas en el equipo, parpadeo de estados, cargas que no se cortaban en la copia del rival, vida vieja al volver a salir. Suite nueva `--autotest-online-sync` (red con lag y pérdida simulados, 6 peleas a la vez, cada forma de ataque). Después, por decisión del usuario, **reconexión con gracia**: si se te corta la conexión en plena pelea, la pelea se congela para los dos y el servidor te guarda el lugar 15 s (token de sesión); volvés y sigue donde estaba, si no, gana el otro (`PROTOCOL` 8: **hay que publicar versión**).
- **El empleado de la Ruta 1 fuma (2026-11-08, pedido del usuario)**: el que reparte la Poción de muestra está en su descanso fumándose un porro (`NpcData.prop` + `NpcProp`: papel, brasa que titila, humo y una pitada cada tanto; sigue hacia dónde mira) y charla en consecuencia; sigue dando la Poción. Arriba de la cabeza dice "TOY RE LOCO" (`NpcData.head_text`), balanceándose y cambiando de color, y corre de un lado a otro sacudiendo la cabeza (`NpcData.pace_cells`); se frena cuando te acercás para que le puedas hablar. Test `--autotest-npc-prop`, vitrina `--showcase-npc-prop`.
- **Ataques de los entrenadores (2026-11-08)**: los equipos que FireRed arma a mano (8 líderes, Alto Mando, Campeón, rival, Giovanni, Rocket y Entrenadores Guay importantes: 118) ahora pelean con sus ataques de FireRed, MT incluidas (Terremoto de Giovanni, Surf de Lorelei, Llamarada de Blaine), "mejorados" (decisión del usuario: hasta 2 por Pokémon se cambian si son relleno como Doble Equipo, Agitacola o Teletransporte, o un ataque de daño muy flojo, siempre por otro de daño), y los entrenadores comunes eligen también entre las MT de su especie desde el Nv. 30 (antes de eso, como antes). `TrainerMovesets`, `tools/fetch_frlg_movesets.py`, tabla en `docs/ENTRENADORES_ATAQUES.md`, test `--autotest-trainer-moves`.
- **IA, sparring S-0 (2026-11-08)**: `docs/PLAN_SPARRING_IA.md` (plan para entrenar la IA con peleas contra el usuario: medir, grabar, imitar; decisiones tomadas). Hecho S-0: la IA lee la amenaza que viene (disparo en línea, carga apuntada, Rayo marcado, chorro, golpe saliendo), da **pasos al costado** sin gastar el esquive y rueda solo para lo fuerte que viene justo, y si se come dos golpes viniendo de frente **deja de venir de frente** (rodea, espera tu recarga, entra en zigzag). Test `--autotest-ai-threat`. **S-1**: `SparringRecorder` graba las peleas de arena (ajuste "Grabar peleas" o GM `sparring`) en `user://sparring/*.json` (muestras a 10/s, hechos, marcas con F8); test `--autotest-sparring`. Próximo: S-2 (informe con `tools/sparring_report.py`).
- **Surf en la ola (2026-11-06)**: el ataque Surf ahora lleva al Pokémon montado en la ola hasta donde apuntás (120 px como máximo) y golpea recién al llegar. Falta probarlo jugando: alcance y recarga son los valores puestos a ojo.
- **Se puede llegar a Blaine (2026-11-06)**: las 6 puertas con preguntas del Gimnasio de Isla Canela no estaban programadas y a Blaine no se llegaba caminando (los tests saltaban al líder). `CinnabarGymQuiz`; `--autotest-cinnabar-gym` camina de la entrada a Blaine y comprueba que se llegue a los 8 líderes. También: Mansión Pokémon clara y con marca en sus puertas invisibles.
- **Estadio de fútbol en Fucsia (2026-11-06, pedido del usuario)**: el estadio pasó a 31×22 celdas con cancha, y juegan 8 Hitmonlee con camiseta (Celeste y Azul) con pelota, goles y marcador (`SoccerMatch`): el que la lleva esquiva al rival de adelante y pasa al compañero libre, los demás buscan espacios (idea del usuario). La plaza se corrió a la izquierda, con el puesto de panchos adentro; los Pokémon chicos pasean en el pasto de abajo (ya no están en un estadio). Sin jugar a mano.
- **IA que administra los PP (H-1, 2026-11-06)**: la IA puede elegir no atacar: junta PP para un ataque mucho mejor en vez de tirar uno malo, remata con el más barato y cuenta bien los ataques de varios golpes. Graduado por clase, temperamento y dificultad. Batería de 12.000 peleas sin errores, misma duración y empates; algo menos parejo (desvío 18,9 → 20,1). Falta: que el usuario lo pruebe jugando y seguir con H-2 a H-4 del programa "IA humana" (`docs/PLAN_IA.md`).
- **Plaza y mini estadio en Ciudad Fucsia (2026-11-06, pedido del usuario: campo enorme vacío)**: plaza con fuente, 6 bancos y 5 personas caminando, y un mini estadio cerrado con 10 Pokémon chicos paseando + cuidadora, todo como agregado (`tools/build_plaza_fucsia.py`), sin tocar la zona. Falta: la torre de rocas debajo del gimnasio sigue (es la zona). Sin jugar a mano. `--autotest-fucsia-plaza`.
- **IA que te lee (IA-7, 2026-11-05)**: los entrenadores calculan el daño real de cada cruce, cambian de Pokémon como una persona (responden a tu cambio) y notan si repetís un ataque o esquivás siempre igual. Graduado por clase; Alto Mando y Campeón al máximo. Falta (si hace falta): atacar apenas termina tu recarga, recordar entre peleas. Probarlo jugando: si queda muy difícil, bajar `reads`.
- **Pokébola con joystick (2026-11-05)**: un toque al salvaje más cercano (con algo de anticipación); mantener = mira que se mueve con el stick derecho y se pega al salvaje cercano; sale al soltar (`PlayerItems`, `BallAim`). Falta probarlo con el mando en la mano.
- **Opciones recortadas (2026-11-05, pedido del usuario)**: fuera Modo práctica y Salvajes de prueba (las partidas que los tenían los apagan), y de Ajustes: teclas por rol, PP (maná y recarga), ritmo, stagger, combos, reglas de arena en todo el mundo, curación sola, objetos en las rutas y % de shiny (quedan en lo normal; los objetos siguen saliendo). La dificultad dinámica se eliminó del todo.
- **Joystick, parte 1: jugar (2026-11-05, lo pedían los amigos)**: mover, correr, 4 ataques, esquivar, bola, objeto, sacar al Pokémon y cambiarlo con la cruceta. Los ataques salen hacia
  donde mira el Pokémon (decisión del usuario); con teclado y mouse no cambia nada. Test `--autotest-gamepad` (botones simulados): falta probarlo con un joystick en la mano.
  Parte 2 hecha: menús con joystick (`MenuNav`), controles configurables (Esc → Controles, con dibujo del mando) y ataques de zona que se apuntan manteniendo el botón.
  Falta: escribir nombres con joystick (no hay teclado en pantalla) y mover el Mapa con el stick. Falta probarlo a mano.
- **Partidas en el servidor (2026-11-05, pedido del usuario)**: copia de cada partida + historial + panel privado con equipo, Caja, lugar,
  medallas y dinero (`Sync`, `tools/server/partidas_server.py`, `docs/SERVIDOR_ONLINE.md`). Sin aviso en el juego, por decisión del usuario.
  Falta (más adelante): detección de cosas raras e inscripción al torneo con el equipo congelado.
- **Salvajes del agua arreglados (2026-11-05, queja del usuario: "no los veo salir")**: solo salían en 6 de 25 zonas: los de tierra llenaban el cupo y en lagunas chicas nada
  podía aparecer lejos de vos. Ahora tienen cupo aparte, salen cerca tuyo mientras navegás (`WildSpawner._process_water`). El cupo de los de tierra ya no cuenta celdas de agua: hay menos en zonas muy mojadas (Ruta 25: de 9 a 3). `--autotest-water-wilds`: 27 de 27.
- **Rayo y Lanzallamas nuevos (2026-11-05, pedido del usuario)**: Rayo marca una zona donde apuntás (190 px de alcance, radio 28) y a los 0,55 s cae del cielo; Lanzallamas
  es un chorro sostenido como Psicorrayo (0,9 s, 130 px, 6 golpes de 0,2 × 90, recarga 6 s, 5 % de quemar por golpe). Gráficos de Qwen (`rayo_marca`, `rayo_caida`, `lanzallamas_chorro`). Cambian `data/moves`: hay que
  publicar versión para el online. Valores sin probar jugando. `--autotest-sky-stream`, vitrina `--showcase-sky-stream`.
- **Gráficos nuevos de Excavar (2026-11-05, pedido del usuario)**: `DigFx` + 4 hojas hechas con Qwen 2.1 (`sprites/fx/moves/excavar_*`): el pozo se abre y
  el Pokémon se hunde, un montículo viaja dejando tierra removida (se agita en el último segundo) y sale con una erupción de 96 px
  y un saltito; el golpe en el rival es un impacto de tierra. Solo visual: no cambia reglas ni la versión online. Vitrina `--showcase-burrow`.
  Sin jugar a mano: visto en cuadros de la vitrina y con `--autotest-burrow`, `-vfx` y `-online`.
- **Stagger +15 % y Excavar en dos tiempos (2026-11-04, pedido del usuario)**: `HITSTUN_*` de 0,2-0,45 s a 0,23-0,52 s. Excavar: primer
  toque bajo tierra (hasta 4 s, +10 % de velocidad, no te pegan), segundo toque sale golpeando; sale solo al terminar (`Burrow`, ver
  CLAUDE.md). `NetPeer.PROTOCOL` 6: hay que subir la versión al servidor. Sin jugar a mano. `--autotest-arena-rules` falla en "tope de
  cráteres" desde antes de este cambio (da igual sin él).
- **Mansión Pokémon: encerrado al cargar (2026-11-04, queja de un amigo: "trabado en un piso")**: el mapa en sí está bien (se llega
  a todo y no hay lugares sin salida, con el interruptor de las dos maneras). El problema era al cargar una partida guardada
  adentro con el interruptor apretado: el piso ya estaba cargado antes de que existiera `MansionSwitches`, volvía a las
  barreras de fábrica y se podía quedar encerrado (por ejemplo al lado de la Llave Secreta, sin estatua). Ahora se aplican al
  arrancar y, si la partida quedó en un lugar sin puerta ni estatua (`has_way_out`), aparece en la entrada. Mismo arreglo en
  la barrera del gimnasio de Carmín. La primera vez que entrás, un aviso cuenta que las estatuas se usan con la E. Test `--autotest-mansion` (grafo piso/celda/interruptor, guardar y cargar, recorrido a pie).
- **Ataques de estado que no hacían nada (2026-11-03, queja del usuario: "Drenadoras, Agitacola... no hacen nada")**: había
  58 sin daño, sin estado ni mejora (el armado automático no sabía bajar stats, drenar ni clima). Arreglados 12 con estados:
  Agitacola y Dulce Aroma → Expuesto; Chirrido, Llanto Falso y Eco Metálico → Muy expuesto (+45 % de daño); Encanto y Danza
  Pluma → Muy intimidado (−35 % físico); Cosquillas → Intimidado + Expuesto; Cara Susto y Esporagodón → Frenado (−40 %
  velocidad, 5 s); Destello → Desorientado; **Drenadoras** = semilla que deja Drenado (3 % de vida por segundo, 8 s, y esa
  vida cura al que la tiró: `StatusEffect.leech`, `StatusEffects.apply(..., source)`; no prende en tipo Planta). Los 46 que
  quedan (climas, Canto Mortal, Metrónomo, Transformación, Sustituto, Relevo, Mofa, Rencor...) los marca
  `MoveData.does_nothing()`: la IA no los usa (ni repite uno cuyo estado el rival ya tiene), el equipamiento de fábrica los
  deja para el final (`default_equipment`) y la descripción dice "Todavía no hace nada en combate". Las descripciones de
  los estados ahora dicen cuánto (porcentajes, segundos, inmunes). Test `--autotest-status-moves`.
  **Segunda tanda (mismo día)**: mecánicas chicas: Pesadilla (6 %/s solo dormido), Atracción (Enamorado: se traba de a ratos,
  sin géneros), Mofa (sin ataques de estado), Tormento (no repite), Rastreo, Profecía y Telépata (Descubierto: no esquiva), Mal de
  Ojo y Bloqueo (Atrapado: no huye ni se cambia), Rencor (−40 % de la barra de PP), Divide Dolor (promedian la vida). **Climas**
  (`CombatWeather`, `MoveData.weather`, 20 s, se corta al terminar la pelea): lluvia y sol (±50 % a Agua y Fuego; la lluvia empapa),
  granizo y arena (2 %/s salvo inmunes), con efecto en pantalla (`--showcase-weather`). Cuentan para Nado Rápido, Cura Lluvia y
  Clorofila; la IA los usa solo si le convienen. Los ataques de estado ahora ignoran la inmunidad de tipo, como en los juegos
  (salvo los eléctricos).
  **Tercera tanda (mismo día): ya no queda ningún ataque sin efecto.** `SpecialMoves` (`MoveData.special`) + estados con reglas:
  llaman a otro (Metrónomo, Espejo, Ayuda, Adaptación), copian (Mimético, Esquema para siempre, Imitación, Intercambio,
  Transformación, Autosugestión), cambian el tipo (Conversión, Conversión 2, Camuflaje: `CreatureInstance.fight_types`), Sustituto
  (muñeco con un cuarto de la vida), Canto Mortal (15 s), Mismo Destino, Rabia, Legado, Maldición, Relevo, Niebla, Truco (no hay
  objetos equipados: intercambia problemas de estado), Reciclaje (devuelve el último objeto usado en pelea), Señuelo (los
  salvajes cercanos van por vos), Sonámbulo (dormido tira solo, salvo la siesta de un salvaje), Capa Mágica, Robo, Sellar, Otra Vez,
  Púas (zona) y Chapoteo Lodo. Lo cambiado en la pelea se deshace al cambiar de Pokémon o al terminar
  (`Creature.reset_fight_changes`). Test `--autotest-special-moves`. Sin probar jugando ni en una pelea online real.
  **Balance después de esto (2026-11-04, IA Difícil, nivel 40, dos tandas de 2000 peleas, semillas 1 y 2; informe = semilla 1):** entre las dos
  semillas, con el mismo código, una especie varía 14 puntos de media: mirar solo lo que se repite. Empates 8-9 % (antes 10 %). Mejoran Clefairy, Mew y
  Ditto. Problema a decidir: varios quedan con un solo ataque de daño entre los últimos 4 por nivel (Slowbro empata 32 de 46, Hitmonlee, Vulpix)
  y los fantasmas empatan la mitad (causa sin aislar; Comesueños no tiene condición de sueño).
  **Rivales con sus mejores ataques (mismo día, pedido del usuario):** `CreatureInstance.create_rival` (salvajes, entrenadores, torneo): 3 de daño + el mejor de estado
  (`best_equipment`, `move_damage_score`, `utility_rank`); los tuyos siguen con los últimos 4 por nivel. Empates 8 % → 2 %, Slowbro 11 % → 85 %, pero las peleas bajan de 21 a
  17 s por victoria. Quedan abajo: Metapod, Kakuna (no pegan), Chansey, Diglett, Rapidash, Meowth, Lickitung, Jynx; arriba: Dratini, Slowbro, Hypno, Exeggcute, Kadabra. Tipos: Dragón y Psíquico arriba.
  **Trabado después de pelear en el agua (2026-11-04):** al ganar una pelea de arena navegando (nadadores), `end_battle` destrababa al entrenador en la
  arena, `FieldMoves` veía tierra y lo bajaba de Surf, y volvía adentro del agua chocando con ella. Ahora en una arena sigue navegando (sin mostrar la montura) y queda
  trabado hasta el fundido de vuelta. **Partidas ya trabadas**: adentro del agua sin navegar vuelve a Surf solo (`FieldMoves._resume_if_in_water`, cada 0,5 s), y al cargar
  una partida guardada en el agua, con Surf, se queda ahí navegando (`World._safe_spawn`; antes lo mandaba a la orilla). Test en `--autotest-field`. Sin probar jugando.
  Ese arreglo dejó a tu Pokémon invisible en la arena al pelear desde el agua (lo vieron los amigos, mismo día): corregido, con test.
- **Shiny (2026-11-03, pedido del usuario)**: cualquier Pokémon (salvaje, regalo, de entrenador o del torneo) sale shiny
  1 de cada 1024 (ajuste "Shiny: sale 1 de cada"). Sprites shiny oficiales de PMDCollab para los 386 (5075 hojas, ~86 MB,
  `tools/download_shiny_sprites.py`), destello con sonido al aparecer y ★ en el equipo, la Caja, la ficha y el HUD. Se guarda
  con la partida. Test `--autotest-shiny`.
- **Empalme de las Rutas 14 y 15 (2026-11-04, pedido del usuario)**: al agrandar, la Ruta 15 ganó 4 filas de pasto arriba de
  su camino de abajo y la Ruta 14 no, y el camino chocaba contra el cerco y el bosque. `INSERT_ROWS` de `import_frlg_maps.py`
  le agrega esas 4 filas a la Ruta 14 (mismo alto; nadie se mueve); `--autotest-bounds` lo controla. Contra la Ruta 13 quedan
  cercas corridas 2 filas y pasto contra el agua: se pasa igual (moverla desarmaría el empalme con la Ruta 12).
- **Ruleta de Pokémon (2026-11-05, pedido del usuario, como la de armas de Red Dead 2)**: mantener R3 abre el equipo en gajos,
  el stick izquierdo marca y al soltar sale ese (Círculo o no marcar nada = no cambia). En combate y fuera; el tiempo va a ×0,2
  (`CombatFeedback.set_slowdown`), salvo online, donde muestra solo tu equipo de la pelea. Test `--autotest-wheel`. Gráficos elegidos entre ideas de Qwen: ruleta
  Pokébola de 6 gajos fijos y dibujo oscuro con filete dorado del joystick en Controles (`tools/make_wheel_art.py`).
- **Cuevas más claras (2026-11-08, pedido del usuario: "hay MUY poca luz")**: luz de base de la cueva más clara (`DayNight.CAVE` 0,30 → 0,42, viñeta 0,62 → 0,50; Torre Pokémon también un poco), la luz del entrenador alumbra casi el doble (radio 64 → 112 px) y hay más antorchas y cristales (`CaveLights.SPACING` 9 → 6, alcance 5 → 6,5 celdas). Mt. Moon pasó de 14 a 57 de brillo promedio.
- **Montura de Surf (2026-11-06, pedido del usuario)**: el Pokémon que te lleva por el agua mira hacia donde vas (8 direcciones; quieto, hacia donde te diste vuelta) y nada con su animación de caminar mientras avanza; antes era un cuadro fijo mirando abajo.
- **Pesca (2026-11-06, pedido del usuario)**: 21 puntos de pesca (cartel con un pescadito y burbujas: `data/world/pesca_puntos.json`,
  elegidos sobre el mapa, se llega sin Surf). E frente al agua: tirás la línea, pica ("¡!", 0,8 s para apretar) y frenás la aguja en lo
  verde (más chico y rápido con los raros); sale una pelea normal contra un salvaje. Qué se pesca = FireRed por zona y caña
  (`tools/build_fishing.py` → `data/world/pesca.json`). Caña Vieja (Gurú de Carmín), Buena (Fucsia) y Súper (casa de la Ruta 12).
  Test `--autotest-fishing`. Solo en esos puntos, no desde cualquier orilla. Cerca del punto (`Fishing.NEAR`) la E pesca mires para donde mires y guarda a tu Pokémon si no hay pelea; con un salvaje cerca sigue lanzando la bola.
- **Pantalla completa (2026-11-05, pedido del usuario)**: F11 en cualquier momento o Esc → Opciones; se recuerda en esa PC
  (`Controls.set_fullscreen`, `user://interfaz.cfg`). Test `--autotest-fullscreen`.
- **Enseñar a todos (2026-11-04, pedido del usuario)**: al usar una MT en la Mochila hay un botón nuevo que se la enseña a
  todos los que pueden aprenderla, del equipo y de la Caja (`GameState.teach_all`). La MT no se gasta; los del equipo con
  las 4 ranuras llenas preguntan después si reemplazar uno. Test en `--autotest-equip`.
- **Cuadros negros en las escaleras (2026-11-03, pedido del usuario)**: en Silph, el Escondite Rocket, la sala de Lance y
  algunas celdas sueltas (los Centros, la guardería, el laboratorio de Canela, la casa de la imitadora) había tiles sin
  dibujar. FireRed guarda esos metatiles en el tileset primario, pero con gráficos o paletas del secundario, así que al
  importarlos solos salían vacíos o a medias. `pret_import.py` ahora los copia al final de cada secundario
  (`manifest[...]["borrowed"]`, los ids de antes no se mueven); cambiaron 32 zonas, solo esas celdas. Además, al llegar por
  una puerta detrás de una pared (las salas de la Liga, el S.S. Anne, la Zona Safari) quedabas sobre la celda sólida:
  `WarpSystem.arrival` busca la celda libre más cercana. `--autotest-bounds` controla que ninguna celda quede sin gráfico y
  que las 899 puertas lleven a un lugar donde pararse. Quedan algunos píxeles sueltos transparentes en cuevas (hasta 5 por celda).
- **Arenas pintadas con Qwen (2026-11-03, pedido del usuario: "MUY EPICAS")**: se probaron 3 enfoques (repintar el plano,
  libre, Qwen Edit) y el usuario eligió **libre**. Hechas: el **campo** (claro con arroyo y puente) y el **gimnasio de Brock**
  (cañón con cristales de ámbar, braseros, plataforma del líder con escalera). Pintura en `ArenaData.painting` sobre los
  tiles (colisión y entorno), luz neutra (`DayNight.PAINTED`; con la de interiores quedaba saturada), sin líneas ni
  emblema por código. Config `data/arenas/pinturas.json` (prompt, semilla, plano automático por brillo o rectángulos,
  piedras, celdas, `scale`, `water`, `brillo`) → `tools/paint_arenas.py` (plano resuelto en `data/arenas/planos/<id>.json`)
  → `build_arenas.gd`. Verificado con `--autotest-room-walk --arena <id>`. **Segunda tanda (2026-11-03)**: Brock agrandado
  a 56×42 (la cancha había quedado a la mitad), **Misty** (palacio de agua; Qwen con un boceto para que las 4 piletas de
  agua de verdad caigan sobre las pintadas) y **Surge**, y **arenas por lugar** (pedido del usuario: las peleas de la
  Torre, Silph, etc. no en el campo): Silph, Torre, cuevas, Escondite Rocket (+ Casino), S.S. Anne, Mansión, Dojo y playa
  (rutas de mar); `data/arenas/por_lugar.json` + `ArenaData.for_zone` (solo cambia a los que tenían el campo). El Bosque
  Verde sigue en el campo (las versiones salieron oscuras y borrosas). **Tercera tanda (2026-11-03)**: los otros 5
  gimnasios, a 44×33 (`scale` 1,1, como las de antes): **Erika** (invernadero con pasto y canteros de flores; el piso es
  pasto), **Koga** (salón oscuro con piletas tóxicas en las esquinas), **Sabrina** (plataforma de cristal rosa flotando en
  el espacio, con espejos), **Blaine** (cancha de basalto rodeada de lava) y **Giovanni** (arena de tierra con estatuas y
  trono). **Cuarta tanda (2026-11-03)**: el **Alto Mando** (Lorelei: salón de hielo con pilares de cristal; Bruno: ring de
  arena con columnas y braseros; Agatha: salón oscuro de tumbas con la luna; Lance: templo en el cielo con dragones de
  piedra) y el **estadio del torneo** (46×34; ahí también pelea el Campeón): cancha de fútbol con tribunas llenas y dos
  lagunas de agua de verdad (boceto como el de Misty). Las arenas pintadas ya no dibujan público por código (venía
  duplicado con el de la pintura). Ya están pintadas **todas** las arenas. Para probarlas: consola
  de Game Master → `arena <nombre> [nivel]` (entrenador al azar con 3 Pokémon; perder no te manda al Centro).
- **Todas las teclas iguales y el básico gasta PP (2026-11-03, pedido del usuario: "el combate es más rápido de lo que
  quiero" y "Confusión pega más que Psíquico")**: medido con la prueba nueva `--autotest-move-damage` (cada ataque en
  cada tecla contra un muñeco): Confusión pegaba más solo porque el Clic izquierdo le dejaba a Psíquico/Premonición un
  25-30 % del daño (y la R le sumaba ×1,3). Ahora las teclas por rol (`slot_roles`) vienen apagadas: cualquier ataque
  pega y recarga lo mismo en cualquier tecla. El básico ya no es gratis ni devuelve PP al pegar. La recarga de PP en pelea subió de 13 % a 16 % de la barra por segundo (de vacía a llena en ~6,3 s); tabla de costos en `docs/PP_ATAQUES.md`.
- **Evoluciones por intercambio y amistad (2026-11-03, pedido del usuario: "como lo suelen hacer los fangames")**:
  antes no evolucionaban nunca. Ahora Kadabra, Machoke, Graveler y Haunter evolucionan a Nv. 37; Onix, Scyther, Seadra,
  Slowpoke (Slowking), Poliwhirl (Politoed), Porygon y Clamperl con su objeto usado como piedra (6 objetos nuevos, a
  2100 en el 4º piso del Gran Almacén de Azulona); Feebas a Nv. 30; los de amistad por nivel (bebés 15, Crobat y Blissey
  40, Eevee a Nv. 25: Espeon de día, Umbreon de noche). Un Pokémon que ya pasó ese nivel evoluciona al subir el próximo.
- **Diálogos fieles a FireRed (2026-11-03, pedido del usuario: "chequeá todos los diálogos contra los de FireRed")**: se
  cruzaron las 811 personas con los textos de pret (`text.inc` de cada mapa): solo ~90 contaban lo mismo. Ahora 683
  (vecinos, guías de gimnasio, entrenadores de ruta y los que antes tenían una frase de relleno por clase) dicen lo
  mismo que en FireRed, con palabras propias en rioplatense: `tools/dialogos_frlg/*.json`, que `build_story_npcs.py`
  aplica encima de sus tablas. Sin cambiar la lógica (regalos, banderas, peleas); lo que FireRed da y acá no existe
  (bici, cañas, fichas, intercambios, Piedra Eterna...) se cuenta sin el regalo. La pasajera del S.S. Anne, la médium del
  5.º piso de la Torre y la empleada del 9.º de Silph ahora curan, como en FireRed. Sin tocar: líderes y Alto Mando (ya
  coincidían), las peleas del rival, Oak, las enfermeras y las tiendas.
- **Centro de Combate Online rediseñado (2026-11-03, pedido del usuario: "más lindo, con identidad propia, no tan
  FireRed")**: Qwen dio 4 ideas y el usuario eligió la 4 (pantalla de llaves, mostrador, filas de máquinas de link y un
  escenario holográfico). Esa imagen es ahora el cuarto entero (`sprites/props/centro_online_sala.png`, en los 9
  Centros; el cuarto se agrandó a 24×16 celdas y la pintura va a ×3 la resolución del juego, porque a ×1 se
  veía muy pixelada; los interiores quedaron a 30 celdas uno del otro) y los tiles de abajo son solo la colisión (`tools/build_online_interior.py`). Se borró la enfermera pintada y
  quedaron el vendedor, la enfermera y la recepcionista juntos en el mostrador; antes la recepcionista y el vendedor
  estaban parados encima de los floreros y de la PC (la parte de arriba de la PC le tapaba la cabeza). Los nombres
  ahora muestran solo el de la persona más cercana. Camino abierto para hacer lo mismo con otros interiores.
  Test `--autotest-room-walk` (pedido del usuario): el entrenador pisa con las teclas cada celda a la que se llega desde la
  plaza (FALLO si alguna no se alcanza) y deja una imagen de la colisión sobre la pintura (verde/rojo/amarillo/azul).
- **Nerf de PP y curas (2026-11-03, pedido del usuario: "consumen muy poco y podés spamear mucho")**: todos los
  ataques cuestan ×1,5 de PP (`MoveUser.PP_COST_MULT`; la recarga de la barra no se tocó). Las curas (Descanso,
  Recuperación, Síntesis, Luz Lunar, Arraigo...) gastan una parte de la barra según cuánto curan (`HEAL_PP`) y no salen
  sin un rival cerca (`Creature.foe_near`): ya no se cura uno paseando o con la F. Tests en `--autotest-settings`.
- **Regalos con el equipo lleno (2026-11-03)**: un Pokémon regalado (Lapras de Silph, Eevee, etc.) va a la Caja si el
  equipo está lleno (antes se perdía; `StoryDirector` usa `GameState.add_caught`). **Partidas viejas**: al cargar,
  `GameState.restore_lost_gifts` revisa las banderas de los regalos (Lapras, Eevee, Hitmon del Dojo): si te lo dieron y
  no tenés esa especie ni una evolución, va a la Caja (una vez por regalo, bandera `regalo_revisado_<bandera>`; del Dojo va
  Hitmonchan porque no se sabe cuál elegiste) y el mundo avisa con un cartel. Test en `--autotest-story-h4`.
- **Minimapa con Tab (2026-11-03, pedido del usuario)**: `Minimap` (`scripts/ui/minimap.gd`, arriba a la derecha):
  afuera recorta la imagen del Mapa del menú (`TownMap.image`) con vos en el centro, niebla en lo no visitado e íconos;
  en interiores, cuevas y la Torre dibuja ese lugar solo (`TownMap.zone_image`, agrandado si es chico) con puertas y
  escaleras titilando. Como el Mapa del menú, en la historia aparece recién con el objeto Mapa (Dalia; decisión del usuario). Se esconde en las arenas; Tab lo prende/apaga y se recuerda
  (`user://interfaz.cfg`). La acción "switch" (Tab, sin uso) pasó a "minimap". Tests en `--autotest-town-map`, vitrina
  `--showcase-minimap`.
- **Zoom con la rueda (2026-11-01, pedido del usuario: "más zoom out para ver más del mapa")**: `CameraRig` acerca y
  aleja de 3× (el de siempre) a 2× en pasos de 0,25, suave, y lo recuerda en `user://camara.cfg` (los tests y vitrinas
  usan siempre 3×). `ZoneStreamer.load_margin` 14 → 22 (y descarga a 30) para que alejado no se vean bordes sin cargar.
  En el tutorial (Moverte y explorar).
- **Torre Pokémon más amplia y con velas (2026-11-01, pedido del usuario: "más espacio en general", "se ve muy
  oscura")**: `import_frlg_maps.py::widen_corridors` saca lápidas hasta que ninguna deja un pasillo de una sola celda
  (pisos 2-7; el 4.º pasó de 45 a 19). `CaveLights.CANDLES`: velas (`sprites/props/vela.png`) sobre las lápidas, una cada
  3 celdas, luz cálida que titila; `DayNight.CAVE_DIM` = la Torre igual de fría que una cueva pero menos oscura.
  `--showcase-cave` suma el 4.º piso.
- **Escaleras de la Torre Pokémon con lugar (2026-11-01, pedido del usuario: "no puedo avanzar")**: en FireRed cada
  escalera queda en un pasillo de una celda entre lápidas; acá, al llegar aparecías pegado a la escalera y un paso te
  devolvía al piso de antes. `import_frlg_maps.py` → `CLEAR_NEAR_WARPS`: sin lápidas a 3 celdas de cada escalera
  (plantas 2 a 6). `WarpSystem.arrival`: en una escalera de costado (puerta transitable con lo sólido a un lado)
  aparecés del otro lado, no arriba ni abajo.
- **Ritmo del combate, estilo LoL (2026-10-31, pedido del usuario: "muy rápido, spam de mi parte"; se va puliendo
  jugando)**: Clic izq. = ataque básico (seguido, pega menos), Clic der. y Q = habilidades, R = definitiva (recarga larga,
  pega ×1,3). Los rivales ordenan sus ataques solos por rol. Ajustes del juego → Combate: "Teclas por rol", "Ritmo:
  recargas" (×) y "Ritmo: pausa entre un ataque y otro". `MoveUser` (roles, `slot_cooldown`, `role_damage`).
  Balance (400 peleas IA contra IA, misma semilla que antes): las peleas duran ~45% más y los empates por tiempo pasaron
  de 3% a 11%; Paras cayó (83% → 21%: su básico es un ataque de recarga larga) y Clefairy sigue en 0% (ya estaba).
- **Actualizaciones automáticas (2026-11-01, decisión del usuario: el juego se actualiza solo y es obligatorio)**: al abrir la versión portable, el juego le pregunta al servidor (nginx en el VPS) si hay un .pck nuevo; si lo hay lo baja (con barra), comprueba firma y huella y se vuelve a abrir con él (Windows y Mac). Sin internet se juega con lo que hay. Publicar = `build_portable.py` + `subir_servidor.bat`. Plan y detalles: `docs/PLAN_ACTUALIZACIONES.md`; test `--autotest-updater` + prueba de punta a punta con el juego exportado. **Hay que pasarles a mano este zip una última vez.**
- **Online: los ataques del rival se ven siempre (2026-11-02, pedido del usuario: "Tinieblas de Haunter a veces se ve y a veces no")**: el cliente imitaba al rival con sus teclas, y el ataque salía o no según las recargas, los PP y el stagger de su copia (y sus ajustes de partida). Encima, el Pokémon del lado B en el servidor y el del rival en cada pantalla se ordenaban "por rol" como un salvaje, así que una tecla podía ser otro ataque. Ahora el servidor avisa cada ataque (evento `use` con el ataque, `NetMatch._on_slot_used`), el cliente lo hace sí o sí (`Creature.force_move`) y la copia del rival ya no ataca con las teclas (`NetCombatInput.attacks`). Los Pokémon que maneja una persona usan su orden (`MoveUser._player_owned`). `NetPeer.PROTOCOL` 5. Tests en `--autotest-online` y `--autotest-online-building`.
- **Ascensores (2026-11-02, pedido del usuario: "problema con la llave del ascensor y el ascensor")**: en FireRed el ascensor es un cuarto con destino dinámico que el importador no trae: las puertas del ascensor no llevaban a ningún lado y en el sótano 4 del Escondite Rocket la parte de Giovanni no se podía alcanzar. Ahora `Lifts` (`world.lifts`) suma las puertas de los ascensores (Escondite Rocket, Silph S.A. y Gran Almacén de Azulona) al arrancar: caminando contra la puerta (o con la E) sale "¿A qué piso?" y se sale por el ascensor del piso elegido; el del Escondite pide la Llave Ascensor. Test en `--autotest-story-h4`.
- **E frente a algo le gana a una persona al costado (2026-11-01, pedido del usuario)**: en el Gimnasio de Carmín, Benito y Dwayne están en los cruces entre basureros y la E les hablaba a ellos en vez de revisar el basurero de enfrente. Ahora, si la persona no está enfrente y hay algo para usar adelante (basurero, cartel...), va eso (`StoryDirector.try_interact` / `npc_ahead`). Test en `--autotest-story-h3`.
- **Animaciones por ataque, por familias (2026-11-01, en revisión, no están en el juego)**: cada ataque cae en una familia de movimiento (morder, puño, patada, soplar por la boca...) y se generan con Qwen las de cada especie de Kanto (`tools/comfy/family_anims.py`, docs/COMFYUI.md). El usuario las revisa en `out/animaciones/revision.html` antes de meterlas.
- **Golpes hechos con IA (2026-11-01, prueba con 5)**: Bulbasaur, Squirtle, Pidgey, Rattata y Geodude tienen su propio golpe (`Strike`) en 8 direcciones, dibujado con Qwen-Image 2.1 (`tools/comfy/strike_sheet.py`, docs/COMFYUI.md); antes usaban el Attack genérico. Vitrina: `--showcase-strike`.
- **Torre Pokémon con menos salvajes (2026-11-01, pedido del usuario)**: cada piso (`encounters/torre_pokemon_3p` a `7p`) tiene a lo sumo 2 a la vez (`max_alive` 2, `cells_per_wild` 0; antes se sumaba uno cada 150 celdas de suelo) y repone cada 40 s.
- **PP como Pokemon Arena 2D (2026-11-01, pedido del usuario)**: medida cuadro por cuadro la barra de energía en un video
  de Pokemon Arena 2D (6 contra 6): se llena en ~7 s y potencia 65 cuesta ~20 % de la barra, 85 ~43 %, y Lanzallamas gasta
  mientras sale. Ahora: recarga en pelea 13 %/s (antes 6 %), costo por curva `PP_COST_CURVE` sobre la barra de Nv. 30
  (220 PP; 40 → 29, 65 → 44, 85 → 88, 120 → 132, 150 → 154; estado 33) y los canalizados pagan el 30 % al empezar y el
  resto mientras salen (`channel_drain`; sin PP se cortan). El básico sigue gratis (+6 PP al pegar).
- **PP como maná (2026-10-31, pedido del usuario: "los ataques tienen que costar por ejemplo 40 PP y mientras subís de
  nivel tenés más PP", como Pokémon Reloaded)**: barra de PP por Pokémon = 100 + 4 × nivel (`MoveUser.max_pp`); cada
  ataque gasta 8 + 0,55 × potencia (estado 25; `pp_cost_of`); el básico es gratis y devuelve 6 PP al pegar; se recargan
  solos (6%/s en pelea, 30%/s fuera; 2026-11-01 subido de 3%/20% y costo de 10 + 0,4·potencia, pedido del usuario; ajuste `pp_regen`) y se llenan al curarse. Con PP las recargas quedan cortas (×0,3,
  0,35-2 s): limita la barra. HUD: barra azul bajo la vida y costo en cada ataque (se oscurece si no alcanza). La IA guarda
  PP (con menos del 30% los ataques que gastan valen la mitad). Ajuste `pp_mode`. `CreatureInstance.pp` no se guarda.
  Balance (400 peleas IA contra IA): victorias en ~10 s de promedio (antes 8,8; con solo teclas por rol 12,7), pero los
  empates por tiempo suben a 14% (antes 3%). A pulir jugando: costos, recarga de PP o daño del básico.
- **IA cuerpo a cuerpo (2026-10-31, pedido del usuario: "se quedan dando vueltas arriba de uno")**: entra cuando va a
  pegar, pega y sale para atrás (`_backoff`); mientras espera se queda a ~52 px de frente (`MELEE_SPACING`, modo
  "hold") en vez de orbitar pegado. Si hay una pared en el medio la rodea igual. Test en `--autotest-ai-steer`.
- **Empalmes y cercas de más (2026-10-31, pedido del usuario)**: revisión de todos los bordes entre zonas
  (`tools/check_seams.py`, informe en `docs/EMPALMES.md`). Arreglado en el importador: cercas y salientes dobles, en
  escalón o con huecos (`straighten_lines`, 31 zonas), Fucsia–Ruta 15 no se tocaban (`EXTEND`: camino nuevo), hueco y canal
  corrido entre Paleta y la Ruta 21 (`FIT` reparte lo que falta, `REALIGN`), franjas de acantilado (`pad`). Pendiente
  (decisión del usuario): las garitas dobles de Azafrán.
- **Dos ramas (decisión del usuario 2026-10-30)**: `main` = el juego (jugabilidad, historia, etc.), sin nada de los
  gráficos nuevos: volvió al estado de `ee776278` (antes de empezar con 2D-HD). **`hd2d`** = la versión con gráficos
  2D-HD hechos con IA (skins del mundo, Pueblo Paleta repintado, `tools/repaint_zone.py`, luz por hora más dramática,
  `docs/PLAN_TERRENO_PROPIO.md` y `docs/QWEN_PROMPTS.md`); en esta PC está en la carpeta `../pokemon-tiempo-real-hd2d`
  (git worktree). Lo de jugabilidad se hace en `main`; para traerlo a `hd2d`, `git merge main` desde esa carpeta.
- **Torneo más difícil (2026-10-30, pedido del usuario)**: los rivales generados salen de toda Kanto y hay 3 visitantes de
  Johto o Hoenn por cuadro, con 16 clases (cada una con sus tipos y su estilo de pelea) y Pokémon evolucionados según el
  nivel de la copa (`Tournament.evolve_for`, `pool_for`, `generated_trainer`); Brock y Azul también evolucionan. Ver
  `docs/PLAN_TORNEO.md`. Test `--autotest-tournament`.
- **IA de los Pokémon (2026-10-30, pedido del usuario): plan `docs/PLAN_IA.md`, fases IA-1 a IA-6.** Hecha la **IA-1**:
  `TacticalMind` (`Creature.mind`) elige el ataque por situación (potencia × STAB × efectividad, más ganas si estás en
  stagger/cargando/recuperándote, no repite siempre el mismo, no tira lo que no te hace nada) y lee el cruce de tipos
  (con los tipos en contra se cuida, a favor presiona). Justicia: reacción humana antes de esquivar y aviso (brillo
  anaranjado + pausa) antes de los ataques fuertes sin carga. Dificultad: `smarts`, `reaction`, `telegraph`. Sirve para
  salvajes y entrenadores (mismo estado "attack"). Test `--autotest-ai-mind`. **IA-2 (memoria corta)** también: te lee hacia qué lado esquivás y
  apunta ahí, nota si peleás de lejos o de cerca, castiga cuando tenés tus ataques fuertes en recarga, con poca vida
  huye / se juega todo / se cubre según el temperamento, y amaga (fintas, más en Difícil). **IA-3**: lee las
  habilidades (no tira lo que absorbés, evita el cuerpo a cuerpo contra Electricidad Estática y compañía, aprovecha
  Torrente...) y el suelo (descarga eléctrica si estás en lo mojado, te moja primero si tiene con qué electrificarte, no
  se queda en el agua frente a un eléctrico). **IA-4**: cada clase de entrenador pelea distinto
  (impaciente, aguante, estratega, rocket, líder), cambian de Pokémon cuando el cruce de tipos les es malo, sacan el que
  mejor les va, usan Superpociones, y los 8 líderes y el Campeón tienen su guion (Brock se planta con Fortaleza, Starmie
  inunda la cancha, Surge a toda carga...). Test `--autotest-ai-trainers`. **IA-5 (salvajes vivos)**: los nocturnos
  duermen de día y los diurnos de noche (si los despertás salen enfurecidos o huyen), no te atacan si tu Pokémon les lleva
  10 niveles, en manada se ayudan y te rodean (el grande defiende a su cría), los cazadores persiguen a sus presas y los
  curiosos van a mirar las Pokébolas tiradas. Test `--autotest-wild-life`. **IA-6**: dificultad dinámica (ajuste
  "Un entrenador que te gana seguido afloja un poco": 12 % por derrota seguida, hasta 3, sin avisar; se borra al ganarle)
  y batería de balance con la mente nueva. **Plan de IA terminado**; ideas para seguir en `docs/PLAN_IA.md`.
- **Noche más oscura y reloj (2026-10-30, pedido del usuario: "después de las 20 se ve mucho")**: noche plateada más
  oscura (Daylight 0,36/0,40/0,52, noche cerrada desde las 21), luna casi sin brillo (0,05, sin rayos) y sombras de luna
  más suaves (0,25). Bug arreglado: las sombras de nubes (`blend_mul`) con `modulate.a` bajo oscurecían toda la pantalla
  entre las 20 y las 21:30 y al amanecer, y les pegaba el Daylight (la noche se aplicaba dos veces): ahora `amount` en el
  shader y `unshaded`. **Reloj** arriba a la izquierda (`HudClock`, en `hud.gd`; sol o luna, los dos puntos titilan si
  la hora corre); el cartel de zona bajó abajo del reloj.
- **Sol, sombras y estrellitas (2026-10-30, pedido del usuario)**: el sol (y de noche la luna) hace un arco
  (`DayNight.sun_at`: sale por la derecha a las 5:30, pasa por arriba y se pone por la izquierda a las 19:30), así que
  las sombras giran y se estiran cuadro a cuadro (mediodía cortas hacia abajo, ×0,75; amanecer/atardecer largas, hasta
  ×3,8) y se desvanecen al ponerse el sol; la luz de esquina del post-procesado sigue al sol y encandila la mitad
  (`KEYS` sin posición ni sombras; `sun_reach` 1,1). Estrellitas rehechas (`ambient_fx.gd`): puntitos de 1 px con
  halo o destello, colores fríos/cálidos, parallax 0,2, alguna fugaz; aparecen de a poco y en interiores, cuevas y
  arenas se apagan en el acto. Test `--autotest-daynight` (43 OK).
- **Pokémon dormidos (2026-10-30, pedido del usuario)**: respiran (al inhalar la parte de arriba del cuerpo sube 1 px
  repitiendo la fila del pecho, sin deformar el pixel art) y les salen "z" de pixel art de la cabeza
  (`CreatureSprite._draw_breathing`, `_draw_zzz`). Las hojas de una sola fila (Sleep, Tumble, HitGround, LostBalance,
  LeapForth) se espejan cuando mira a la derecha: antes se pedía la fila de la dirección y **no se dibujaba nada**. Los que
  en la hoja de PMD dormían con los ojos abiertos ahora los cierran: cuadro 0 pasado por Qwen Image Edit ("cerrá los
  ojos, no cambies nada más") y `tools/sleep_eyes.py` lleva ese cambio a todos los cuadros con la paleta original
  (pisa `Sleep-Anim.png`). Son 21: Butterfree, Beedrill, Golbat, Magnemite, Magneton, Gastly, Horsea, Seadra,
  Magikarp, Gyarados, Aerodactyl, Articuno, Zapdos, Unown, Octillery, Dustox, Dusclops, Glalie, Relicanth, Beldum y
  Metang (de 58 probados: en los demás Qwen cambiaba el diseño, como Groudon o Latias, o no había ojos para cerrar). Vitrina `--showcase-sleep`; test `--autotest-anims`.
- **Plazas, playa y Snorlax (2026-10-29, pedidos del usuario)**: plazas con un puesto de panchos y hamburguesas (y su
  puestero) y una parrilla (y su parrillero) en Celeste, Carmín, Azulona, Azafrán y Fucsia, en el lugar más abierto de
  cada una (`tools/build_plazas.py`; sprites con Qwen-Image + LoRA MOSS: `sprites/props/puesto_panchos.png`,
  `parrilla.png`, `sombrilla.png`, `art/pret/characters/parrillero.png` y `puestero.png`). Playa en Ciudad Celeste: el
  cerco del lago de arriba a la izquierda es ahora orilla de arena y el césped, arena, con 3 sombrillas (`PAINTS` del
  importador). El Snorlax de la Ruta 12 vuelve a tapar la entrada del camino de la Ruta 11, como en FireRed (con el
  empalme de la garita había quedado 44 filas más arriba: `MOVE_NPCS`). El globo ya no "visita" las ciudades que
  sobrevuela (solo la de destino).
- **Consola de Game Master (2026-10-29, pedido del usuario)**: Ctrl+Shift+G (no en la versión portable). Pausa el juego;
  comandos (`GmCommands`): `exp`, `nivel`, `curar` (sin cambiar adónde volvés al perder), `dinero`, `objeto`, `pokemon`,
  `hora`, `volar`, `ayuda`. `volar` (`GmFlight`, `world.gm_flight`) = cámara libre con el juego en pausa (WASD, Shift,
  rueda = zoom hasta 1×); el entrenador no se mueve y las zonas que cruza la cámara **no quedan visitadas** (Mapa, globos):
  se restauran al volver con Esc. Test: `--autotest-gm`.
- **Globos aerostáticos (2026-10-29, pedido del usuario)**: en cada ciudad con Centro Pokémon hay un globo (sprite de
  Qwen-Image + LoRA MOSS, `sprites/props/globo.png`) y su piloto. Hablándole elegís una ciudad que ya visitaste (en el
  modo libre, cualquiera), gratis, y el globo sube y vuela por encima de las rutas hasta allá (zona por zona, por el medio
  de cada borde), con el entrenador en la canasta; E o Esc lo saltean. `BalloonTravel` (`world.balloon`), lugares y
  pilotos de `tools/build_balloons.py`. Test: `--autotest-balloon`; vitrina `--showcase-balloon` (Verde -> Plateada).
- **Centro de Combate Online en cada ciudad (2026-10-29, pedido del usuario)**: además del de Ciudad Verde, uno en
  Plateada, Celeste, Carmín, Lavanda, Azulona, Azafrán, Fucsia y Canela (copias del de Verde, cada uno con su interior y
  su recepcionista; al terminar la pelea online volvés al que entraste). `tools/build_online_centers.py` (`--buscar`
  lista lugares libres). Tests: `--autotest-online-building` y `--autotest-bounds`.
- **Sin Pokébolas adentro (2026-10-29, pedido del usuario)**: en casas, Centros, tiendas, gimnasios y garitas (bioma
  "interior": ahí nunca hay salvajes) la E ya no tira la bola ("Acá adentro no se pueden tirar Pokébolas."). En cuevas,
  Torre, Central y Mansión (bioma "cueva") sí. `PlayerItems.indoors`. Test: `--autotest-capture`.
- **MT como en FireRed (2026-10-29, decisión del usuario: "con la MT es mejor la progresión")**: las 50 MT y 8 MO son
  objetos (`tools/build_tms.py`), no se gastan, y un ataque de MT se equipa recién al enseñarle la MT (la ficha muestra
  "te falta la MT" / "enseñale la MT"). Se consiguen donde en FireRed: 27 tiradas en el mapa (el agente de mapas verificó
  las ubicaciones: todas se alcanzan; para la MT14 y la MT22 hizo las estatuas-interruptor de la Mansión, `MansionSwitches`), los 8 líderes, regalos (MT27 garita de la Ruta 12, MT29 Sr. Psíquico, MO02 casa de la Ruta 16, MO05 ayudante
  de la Ruta 2) y Azulona: vendedor de MT del 2º piso (las de FireRed + las de la azotea y las de las Islas Sete: MT10,
  36, 42, MO06-08) y el mostrador de premios del Casino (MT13, 23, 24, 30, 35, con plata). Partidas viejas: lo equipado de
  MT se conserva. Test: `--autotest-equip`.
- **La ficha muestra las MT (2026-10-29, bug del usuario)**: Equipo → ficha → Movimientos solo listaba "Aprende por
  nivel"; los ataques de MT se podían equipar pero no había dónde elegirlos. Ahora hay una sección "Por MT / MO" (las de
  su especie en FireRed) y "Enseñados" (lo que le enseñaron y no está en esas listas). `SummaryScreen._move_row`.
  Test: `--autotest-equip` (Nidoking: Tumba Rocas, Terremoto, Surf; equipar desde la ficha).
- **MT arregladas (2026-10-29, bug y pedido del usuario)**: la comprobación de "¿la puede aprender?" estaba al revés
  (miraba si el ataque ya estaba disponible, y todas las MT de la especie lo están): Nidoking no podía aprender Tumba Rocas
  y Kadabra sí Excavar. Ahora `CreatureInstance.can_learn_tm`: solo si su especie la aprende en FireRed (`tm_moves`,
  verificado contra pret/pokefirered `tmhm_learnsets.h` y Bulbapedia: 0 diferencias en las 386) y no se la enseñaron
  ni la sabe por nivel. **Las MT no se gastan** (sirven para todos los que la aprendan). La Mochila muestra "Puede
  aprenderla / Ya la sabe / No puede", como FireRed. Test: `--autotest-story-h1`.
- **Arreglo: EXP al matar de un golpe o mientras huye (2026-10-29, bug del usuario)**: la EXP solo contaba si el salvaje
  estaba en los enemigos del combate (entra recién cuando te ataca, y sale si deja de apuntarte); al matarlo de un golpe,
  el "se debilitó" sale antes que el "recibió daño". Ahora la criatura guarda quién le pegó último (`Creature.last_hit_by`)
  y CombatDirector da la EXP si lo mató tu Pokémon (`_killed_by_us`); además todo salvaje que golpeás cuenta como
  participante (`_on_creature_damaged`). Test: `--autotest-wild-ai`.
- **Online O-3: la pelea online (2026-10-29)**: después de elegir equipo, a la arena: el servidor simula la pelea con
  las teclas de los dos y cada juego la muestra con el combate de siempre (corrigiéndose con lo que dice el servidor).
  Cambios 1-6, debilitados, gana el que deja al otro sin Pokémon; da EXP como un combate en el mundo; sin pausa ni
  objetos. **Próximo: O-4/O-5** (EXP ya está; falta poner el servidor de verdad para jugar con amigos).
- **Online O-2: la sala (2026-10-29)**: la recepcionista abre la sala: ves a los conectados (equipo y si están libres),
  elegís el formato (1, 3 o 6) y desafiás; el otro acepta o rechaza (también si tiene la sala cerrada: se lo pregunta la
  recepcionista); los dos eligen equipo con 30 s. El servidor del juego queda fijo adentro del juego (`Net.OFFICIAL_SERVER`;
  Opciones → Online solo para otro servidor). **Próximo: O-3** (la pelea en la arena).
- **Online O-1: Centro de Combate Online en Ciudad Verde (2026-10-29)**: edificio nuevo hecho con Qwen a la derecha del
  Centro Pokémon, con su interior (enfermera, tienda y recepcionista que te conecta a la sala y muestra quién está).
  Se agrega sin tocar las zonas importadas (`ExtraContent`, `data/world/extra/`). Opciones → Online: nombre y servidor.
  Test `--autotest-online-building`, vitrina `--showcase-online-building`. **Próximo: O-2** (pantalla de la sala:
  desafiar, aceptar, elegir equipo).
- **Online O-0: base de red (2026-10-29)**: autoload `Net` + `NetPeer` (servidor y cliente con el mismo script), modo
  servidor `-- --server`, sala con lista de conectados (nombre, equipo, estado), chequeo de versión por huella de los
  datos, desconexiones. Todavía no hay nada a la vista en el juego (eso es O-1/O-2). Test `--autotest-online`. Detalle en
  `docs/PLAN_ONLINE.md`. **Próximo: O-1** (edificio en Ciudad Verde con Qwen + interior).
- **Multijugador online: plan escrito (2026-10-29)**: `docs/PLAN_ONLINE.md` (fases O-0 a O-6). Decidido: servidor
  propio que simula la pelea, solo una lista de conectados en un NPC, nivel real, da EXP como un combate en el mundo, y
  un edificio nuevo hecho con Qwen en Ciudad Verde (enfermera, tienda y recepcionista online). **Próximo paso: O-0**
  (base de red). Entrenadores vivos: sacado de la nueva partida y de Opciones por ahora (al cargar queda apagado; el
  sistema y su test siguen).
- **Solo la historia al empezar (2026-10-29, pedido del usuario)**: la pantalla de nueva partida (`starter_select`) ya no
  tiene las tarjetas del modo libre (empezar con un inicial directo en el mundo abierto): solo "Empezar la historia" +
  dificultad y opciones. El código del modo libre (`GameState.new_game`) queda para las partidas viejas y los tests.
  Arreglo de paso: después del tutorial del principio, Esc pausaba pero el menú no se veía (`PauseMenu.close`).
- **Tutorial "Cómo se juega" y qué hace cada ataque (2026-10-28, pedido del usuario)**: 9 páginas (controles, salvajes y
  temperamentos, combate, equipo y EXP, captura, ataques y habilidades, lo que se puede modificar, el menú) que salen
  solas la primera vez que entrás al mundo con una partida (también las partidas viejas, una vez) y siempre desde
  Esc → Cómo se juega (`TutorialScreen`). Cada ataque explica qué hace en palabras (`MoveInfo`, sale de cómo funciona
  en tiempo real) en la ficha, al aprender uno nuevo y en la Pokédex. Test: `--autotest-party`; vitrina `--showcase-menus`.
- **Bolas erradas en el piso (2026-10-28, pedido del usuario)**: si la Pokébola no toca a nadie, rebota y queda en el
  suelo (con su ícono: Super Ball, Ultra Ball...) durante 2 minutos; pasando por encima con el entrenador la recuperás
  ("¡Recuperaste Poké Ball!"). `BallThrow._leave_on_ground` → `FieldItem.thrown`. Test: `--autotest-capture`.
- **Respiro al huir (2026-10-28, pedido del usuario)**: si huís de un salvaje territorial (F) estando en su zona ya no te
  desafía al instante: queda 8 s tranquilo (`Creature.CALM_AFTER_FLEE`, lo pone `CombatDirector.end_battle` a todos los
  enemigos); si le pegás pelea igual, y si pasado el respiro seguís en su zona vuelve a pelear. Test: `--autotest-wild-ai`.
- **Versión para Mac (2026-10-28, pedido del usuario)**: `tools/build_portable.py ... --mac <zip de Godot para macOS>` arma
  `export/PokemonPilot-Mac-<fecha>.zip` (Godot.app oficial universal sin tocar + .pck + lanzador `.command` + LEEME con
  cómo abrirlo la primera vez). Sin probar en una Mac de verdad.
- **EXP repartida, Abra con Poder Oculto y huidas dispersas (2026-10-28, pedido del usuario)**: la EXP de un enemigo se
  divide entre los Pokémon que salieron a pelear contra él (cambiando con 1-6) y siguen en pie; los debilitados no reciben
  y su parte va para los demás (`CombatDirector.exp_shares`). Abra aprende Poder Oculto en el Nv. 1 (`OFFICIAL_EXTRAS` de
  `build_learnsets.gd`: con Teletransporte solo no podía ganar EXP). Los salvajes que huyen se desparraman: cada uno toma
  un rumbo propio según de qué lado del grupo está (hasta 75° de "justo en contra"), se separan entre sí y nunca huyen
  hacia vos (`creature_flee.gd`). Test: `--autotest-abilities`.
- **Iniciales salvajes e inmunidades de tipo (2026-10-28, pedido del usuario)**: Charmander 15% en todo Mt. Moon, Bulbasaur
  5% en el Bosque Verde (bajado de 17% a pedido del usuario) y Squirtle 12% en el cantero de flores de Ciudad Celeste (no tiene pasto alto: el resto de las
  veces no sale nada, fila sin especie); el resto de cada tabla se escaló para que sigan sumando 100. Inmunidades: un
  ataque contra un tipo inmune (Siniestro←Psíquico, Acero←Veneno, Hada←Dragón, Volador←Tierra, Fantasma←Normal/Lucha,
  Tierra←Eléctrico) no hace nada: ni daño, ni estado, ni empuje ("No le afecta"). Un tipo Veneno no se envenena
  (`StatusEffect.immune_types`). Test: `--autotest-abilities`.
- **Ataques nuevos y balance de disparos (2026-10-28, pedido del usuario)**: si aprende un ataque y tiene ranura libre
  se equipa solo; con las 4 llenas, al terminar la pelea aparece un cartel "¿reemplazar uno?" (`MoveLearnDirector` +
  `MoveLearnScreen`, lo crea `EvolutionDirector`). Balance: los golpes chicos ya no cortan una carga (solo los fuertes) y
  la IA anticipa al soltar un disparo cargado (Sofoco pegaba 24% de las veces → 44%; Rayo Solar 6% → 38%); los disparos
  van 25% más rápido (mismo alcance) y su zona de impacto es 2 px más grande. Desvío entre especies con sus mejores
  ataques: 19,6 → 18,4. Ditto, Metapod y Kakuna siguen sin ganar (como en los juegos, decisión del usuario).
- **Habilidades en vez de kits (2026-10-28, decisión del usuario)**: cada Pokémon pelea con su habilidad de 3ª gen
  (al azar entre las de su especie), su tipo y los ataques que elijas (nivel + MT; viene con los últimos 4 por nivel);
  los ataques son iguales para todos. Kit de jefe solo con los líderes (Onix, Starmie, Raichu). 76 habilidades
  adaptadas al tiempo real (`tools/apply_abilities.gd`), MT de FireRed por especie, pantallas con la habilidad,
  partidas viejas migradas. Batería en paralelo + `tools/balance_merge.py` → `docs/BALANCE_RESUMEN.md` (y
  `BALANCE_RESUMEN_KITS.md`, la era de kits, para comparar). Test `--autotest-abilities`. Ver
  `PLAN_IDENTIDAD_COMBATE.md` "ESTADO VIGENTE (v3)". Próximo: balancear ataques (Fuego, Transformación, capullos).
- **Batería de balance (2026-10-28, pedido del usuario)**: `--autotest-balance` hace pelear solos a dos Pokémon con kit
  (IA en Difícil, nivel 40, emparejados por stats base ±60, cada pareja dos veces cambiando de lado; ~2 peleas por
  segundo con `--fixed-fps 60`) y escribe `docs/BALANCE_INFORME.md` (victorias por especie, estilo y tipo, daño por
  ataque) + un CSV con cada pelea. Encontró un bug: el Filo Furioso de Scyther (y Scizor) curaba al rival (barra de
  tamaño 0); arreglado. Primera tanda (2000 peleas): bruisers 69% vs caóticos 25%; Dragón 13% y Hada 17%; Chansey,
  Blissey, Clefairy, Dragonair y Exeggutor casi no ganan. Pendiente: decidir con el usuario qué ajustar.
- **Kit para todos los Pokémon del juego + golpes con paso + stagger (2026-10-28, pedido del usuario)**: los 34 que
  aparecían sin kit (Gastly, Cubone, Doduo, Rhyhorn, los Hitmon, Charizard, Lapras, Snorlax, Articuno, Zapdos, las
  evoluciones de Eevee, los fósiles...) tienen su kit v9 y sus evoluciones lo heredan (`docs/PLAN_IDENTIDAD_COMBATE.md`
  "v9"). Todo golpe físico avanza 30 px antes de pegar, y todo golpe con daño deja al rival un ratito sin poder atacar
  (stagger, con respiro para que no se encadene; ajuste "Stagger al recibir un golpe"). Tests `--autotest-kits-v9` y
  `--autotest-ai-steer`. Falta probarlo jugando.
- **La historia hasta el final (2026-10-28, pedido del usuario: "continuá hasta donde puedas para terminar la historia")**:
  capítulos 4 a 8 (`docs/PLAN_RESTO_KANTO.md`), de la Torre Pokémon al Campeón de la Liga, sobre los mapas de todo
  Kanto de la sesión de mapas. Mecánicas: Surf, Fuerza, Poké Flauta, legendarios, Té y guardias de Azafrán. ~360
  entrenadores de FireRed (automáticos + los importantes a mano), 5 líderes, el rival ×4, Giovanni ×3, el Alto Mando,
  9 arenas temáticas, tiendas de todas las ciudades y la Guía con los 8 capítulos. Tests `--autotest-story-h4` (39) y
  `--autotest-field`. Falta probarlo jugando entero (ver "Pendiente" en el plan).
- **Día y noche, parte A (2026-10-28, pedido del usuario)**: plan y reparto en `docs/PLAN_DIA_NOCHE.md` (A y B:
  sesión de gráficos; C ventanas/faroles: sesión de mapas; D luces de ataques: sesión de kits), con las referencias que
  pintó Qwen en `docs/referencias/iluminacion/`. Hecho: `DayNight` (nodo del mundo): la hora del juego corre (un día =
  24 min reales), se guarda con la partida y avisa por `Events.time_changed(hora, fase)`. Pinta el Daylight, la
  gradación, una luz de esquina con rayos (post-procesado), las nubes y las luciérnagas de noche. Interiores y arenas
  van con luz pareja. "Hora fija" en Ajustes del juego. Por ahora solo visual (decisión del usuario). **Parte B (sombras largas)**:
  casas, árboles y cercas (`ZoneShadows`, máscara de las celdas sólidas + shader) y personajes y Pokémon (`SunShadow`,
  su propio cuadro acostado), según la hora. Test `--autotest-daynight` (23), vitrina `--showcase-daynight`.
- **18 proyectiles y Surf hechos con IA (2026-10-28, pedido del usuario)**: Lanzallamas, Confusión, Hiperrayo, Poder
  Pasado, Rayo Hielo, Psíquico, Rayo Burbuja, Llamarada, Electrocañón, Dragoaliento, Furia Dragón, Ácido, Gigadrenado,
  Pin Misil, Rapidez, Bomba Lodo, Disparo Lodo y Bola Sombra (`sprites/fx/moves/`, bucle de 4 cuadros, tamaño según el
  `size` del ataque) y el área de Surf (la ola, idea del usuario). ComfyUI con el LoRA MOSS; lecciones en
  `docs/COMFYUI.md`. Después, Hidrobomba (una bola de agua) y Lanzarrocas y Hoja Mágica (quietos: Wan los deformaba).
- **Noche con luz de luna (2026-10-28, pedido del usuario: "demasiado azulado oscuro")**: la noche es plateada y más
  clara, con un brillo de luna con rayos desde arriba a la derecha, sombras de luna y estrellitas que titilan
  (`AmbientFX`, solo afuera). Tabla `KEYS` de `DayNight`.
- **Día y noche, parte C: ventanas prendidas (2026-10-28, pedido del usuario)**: de noche las ventanas de casas, Centros,
  Tiendas, gimnasios y edificios se prenden con luz cálida y tiran un charco de luz al suelo (como `verde_noche.png` de
  Qwen). No se marcó nada a mano: `tools/find_windows.py` detecta los vidrios en los mapas de FireRed (sirve para toda
  la región) → `data/world/night_windows.json`; `ZoneLights` los dibuja.
  Revisado en Paleta, Verde, Plateada, Celeste, Carmín, Azulona y Azafrán (vitrina `--showcase-daynight`); los pisos
  altos (tapados por `Overhead`) se dibujan sobre los techos y el charco va solo bajo la planta baja. Faltan faroles (FireRed casi no
  tiene) y que algunas ventanas se apaguen tarde a la noche, si se quiere.
- **Pantalla VS (2026-10-28, pedido del usuario)**: antes de pelear con un líder, el Alto Mando, el rival o Giovanni,
  2,5 s de "VS" con los dos retratos entrando desde los costados, fondo partido con líneas de velocidad del color del
  tipo del rival, destello y temblor (E/Espacio la saltean). `--autotest-vs`, `--showcase-vs`.
- **Diálogos y HUD (2026-10-28, pedido del usuario)**: las charlas comunes ya no te frenan (alejarte las corta; las
  importantes siguen trabando hasta terminar). El HUD se esconde con cualquier diálogo (antes se encimaba en la Poké
  Flauta, el torneo, después de las peleas...) y se vuelve casi transparente cuando un Pokémon o una persona queda
  detrás. Arreglado el texto del estilo encimado con el nombre y la ayuda de teclas que pisaba las ranuras.
- **Cuevas oscuras con antorchas, y faroles en los caminos (2026-10-28, pedido del usuario)**: las cuevas (bioma
  "cueva": Mt. Moon, Túnel Roca, Islas Espuma, Calle Victoria, Torre Pokémon...) son oscuras y frías a toda hora, con
  una luz chica alrededor del entrenador; antorchas (luz cálida que titila) y cristales celestes (luz fría) se ponen
  solos al pie de las paredes. De noche, faroles al costado de los caminos de ciudades y rutas. Sprites hechos con
  ComfyUI (poste, antorcha, cristales; `tools/prop_from_image.py`). Vitrina `--showcase-cave`; test en `--autotest-daynight`.
- **Árboles y pasto alto hechos con IA: probados y descartados (2026-10-28)**: al usuario no le gustaron; volvieron los
  de FireRed. El paquete (`TilePack`, `tools/tile_pack.py`, interruptor en Ajustes) está en el commit d34b20ba por si se
  quiere retomar con otro estilo.
- **Efectos hechos con IA en el juego (2026-10-28, pedido del usuario)**: impactos de Hielo, Planta, Psíquico y Roca
  (`sprites/fx/types/`) y las áreas de Trueno y Giro Fuego (`sprites/fx/moves/`), con ComfyUI (Qwen-Image + LoRA de
  pixel art → Wan 2.2 → `tools/fx_from_frames.py`). Los proyectiles de 16 px siguen siendo los de código (a ese tamaño
  la IA no los mejora). La vitrina `--showcase-vfx` muestra también las áreas.
- **Creación de gráficos con IA local (2026-10-28)**: ComfyUI con Qwen-Image, Qwen Edit, Wan 2.2 y LoRAs de pixel art.
  Flujo de efectos de ataque (cuadro clave → animación → `tools/fx_from_frames.py` → `sprites/fx/`). Guía:
  `docs/COMFYUI.md`.
- **Capítulo 3 de la historia (2026-10-25, pedido del usuario: "hasta el gimnasio de Lt. Surge")**: plan en
  `docs/PLAN_CAPITULO_3.md` (mapas de la sesión de mapas, 0e8da6c2). Hecho: 29 entrenadores con los equipos de FireRed
  (Ruta 6, S.S. Anne, gimnasio), el Rocket de la casa robada (MT28 Excavar), el Ticket en el muelle, el rival en el
  S.S. Anne, el capitán y **Corte** (E frente a un árbol fino), el **puzzle de los basureros** con la barrera eléctrica,
  **Lt. Surge** (Raichu jefe) en la arena eléctrica, Medalla Trueno, Tienda de Carmín y la Guía del capítulo 3.
  Arreglado: un entrenador que te veía y se descargaba su zona a mitad de camino dejaba la historia trabada.
  Test `--autotest-story-h3` (28), vitrina `--showcase-surge`.
- **Evoluciones (2026-10-25, pedido del usuario)**: las 172 especies que evolucionan (PokeAPI) lo hacen por nivel o con
  piedra (Lunar, Fuego, Agua, Trueno, Hoja, Solar); intercambio y amistad quedan para cuando exista ese sistema
  (Kadabra, Graveler, Golbat... por ahora no evolucionan). Pantalla clásica con parpadeo, Esc la frena (con piedra no),
  espera a que termine el combate. Conserva nivel, daño y movimientos; aprende lo de su nivel. **Kits**: la evolución
  pelea con el kit de su preevolución (28 heredan: Charmeleon, Pidgeotto, Raticate...) salvo las que cambian mucho
  (Butterfree, Beedrill, Gyarados, Kadabra: ya tienen kit propio, de la sesión de kits; Charizard y
  Vaporeon/Jolteon/Flareon todavía no y pelean con su learnset de FireRed). La ficha y la Pokédex muestran a qué evolucionan.
  Test `--autotest-evolution` (20), vitrina `--showcase-evolution`.
- **Capítulo 2 de la historia (2026-10-24, pedido del usuario: "hasta el gimnasio de Ciudad Celeste")**: plan y reparto en
  `docs/PLAN_CAPITULO_2.md` (mapas: sesión de mapas; estilos y kit de Starmie: sesión de kits; historia: esta). Hecho
  en la historia: 45 entrenadores con los equipos de FireRed (Ruta 3, Mt. Moon, Rocket, Puente Pepita, Ruta 25, gimnasio),
  Miguel y el fósil a elección, el rival en Celeste (Pidgeotto/Abra/Rattata/inicial), el Rocket del puente (Pepita),
  Bill-Clefairy (Ticket del barco), Magikarp de $500 en el Centro de la Ruta 4, Tienda de Celeste, **arena de agua de
  Misty** (piletas reales), Medalla Cascada, Caramelo Raro que sube de nivel, la Guía del capítulo 2. Test
  `--autotest-story-h2` (21 chequeos), vitrina `--showcase-misty`.
- **Más salvajes en el Bosque Verde (2026-10-24, pedido del usuario)**: tenía 5600 celdas de pasto y el tope general de
  16 salvajes vivos (1 cada 350 celdas; la Ruta 1, 1 cada 110). `max_alive_cap = 40` en su tabla de encuentros
  (solo ese campo; se ajusta también en el editor de mapas, pestaña Salvajes).
- **Mercado hecho (2026-10-24, pedido del usuario)**: los vendedores de las Tiendas de Ciudad Verde y Plateada venden
  (lista oficial de FireRed, precios oficiales) y compran a la mitad. Ciudad Verde, después de entregar el Correo de
  Oak (modo libre: siempre). `Mart` + `ShopScreen` + `data/shops/`. Test `--autotest-mart`, vitrina `--showcase-mart`.
- **Ajustes de combate (2026-10-24, pedido del usuario)**: combos apagados (`GameConfig.combos_enabled`), Paralizado
  con tirones al azar (6 s, mitad de velocidad), Escarcha de Seel congela con 5, Somnífero duerme a los 0,6 s, el
  veneno no despierta, la estela de la Embestida Ígnea pega como un solo fuego y el salto de cráter también sale
  hacia donde caminás. Detalle en `PLAN_IDENTIDAD_COMBATE.md` ("Ajustes de estados y ataques").
- **Animaciones de combate de SpriteCollab (2026-10-24)**: `download_sprites.py` baja además Shoot, Charge, Strike,
  Swing, Double, Hop, Rotate, Tumble, LeapForth, Faint, HitGround, LostBalance, Sleep... (las que tenga cada
  especie). La criatura las usa según la forma del ataque (`CreatureSprite.CHAINS`/`chain_for_move`): disparo y
  cono → Shoot, carga → Charge, golpes → Strike/Swing/Double, embestida → LeapForth, esquive → Hop/Rotate/Tumble,
  debilitado → Faint (se queda caído), dormido → Sleep; sin la animación cae a Attack. Test `--autotest-anims`.
  Tutorial para efectos y animaciones con IA: `docs/TUTORIAL_PIXELLAB_SORCERESS.md`.
- **Efectos de ataque con sprite (2026-10-24)**: enganche listo, falta el arte. Una hoja en
  `sprites/fx/moves/<ataque>.png` o `sprites/fx/types/<tipo>.png` (`_impacto` para el golpe), o un SpriteFrames en
  el campo `vfx`/`impact_vfx` del ataque o del tipo, reemplaza el dibujo por código del proyectil, el área, el corte
  y el impacto (`DB.vfx_for`, `VfxSprite`). Test `--autotest-vfx`. Pendiente: conos y látigos.
  **Primeras hojas hechas por código** (`tools/make_vfx.py`, sin IA): impacto de los 18 tipos (estrella, llamas,
  salpicadura, rayos, hojas, cristales, escombros, viento, aros, burbujas, destellos) y cuerpo de 5 proyectiles.
  Vitrina `--showcase-vfx`. Calidad "de programador": la idea es ir reemplazándolas por arte de PixelLab/Sorceress.
- **El entrenador sigue a su Pokémon (2026-10-28, pedido del usuario)**: con la F (controlando al Pokémon, fuera de las
  arenas) el entrenador camina solo hacia él si se aleja más de 90 px (corre desde 150 px, frena a 55 px y rodea lo que
  tenga adelante). En las arenas se queda en su lugar. `Trainer.follow_target` (lo pone `CombatDirector`). Chequeos en
  `--autotest-ai-steer` y `--autotest-arena`.
- **Día y noche, parte D (2026-10-28)**: de noche los ataques no se oscurecen (los efectos compensan el Daylight), sus
  luces crecen (hasta 0,5), los impactos de fuego/eléctrico iluminan un instante y los Pokémon de fuego alumbran con
  su llama. Solo visual. Ver `docs/PLAN_DIA_NOCHE.md`. Test `--autotest-night-combat`.
- **Arreglo: equipar en plena pelea (2026-10-26)**: al subir de nivel en combate o al equipar desde la ficha del menú
  de combate, el Pokémon que está afuera no recibía los ataques nuevos hasta terminar la pelea. Ahora se actualizan
  ahí mismo (`MoveUser.refresh`; el recién equipado arranca con su recarga). Test `--autotest-equip`.
- **Sonido (2026-10-26, pedido del usuario)**: autoload `Sound`. Música por lugar y por momento (salvaje, entrenador,
  líder, rival, torneo, victorias, evolución, Centro, captura, nivel) desde archivos con nombre en `audio/musica/`
  (la pone el usuario: su soundtrack; tabla `data/audio/musica.json` con respaldos); efectos retro hechos por código
  (`tools/make_sfx.py`: menú, bola, puertas, saltos, un golpe por tipo...) y los gritos de los 386 de PokeAPI
  (`tools/fetch_cries.py`). Volumen en Opciones (de la PC). **Cómo cambiar las canciones: `docs/AUDIO.md`.** Test
  `--autotest-audio`.
- **Objetos en peleas y equipo arrastrable (2026-10-26, pedido del usuario)**: la C (objeto rápido) anda también en
  peleas de entrenador, gimnasio y torneo; **Esc en combate** abre un menú reducido (Mochila, Equipo, Cerrar) con la
  pelea en pausa (en la Mochila, lo que no se usa en combate sale deshabilitado; en Equipo, "Poner como activo" es un
  cambio de pelea). Usar un objeto en combate te deja expuesto `use_time` s (CombatDirector escucha
  `Events.item_used`). En **Equipo**, arrastrar una tarjeta sobre otra con el clic las intercambia
  (`GameState.swap_in_party`). Chequeos en `--autotest-arena`.
- **Ajustes del juego por partida (2026-10-26, pedido del usuario)**: Esc → Opciones → "Ajustes del juego…". Por
  partida (decisión del usuario): Progresión (EXP, dinero de premios, captura), Combate (daño que hacés y que recibís,
  vida ×N, combos, reglas de arena en todo el mundo), Mundo (cantidad de salvajes, curación sola, objetos en las
  rutas) y dificultad de la IA con modo **Personalizada** (ritmo, puntería, esquive, anticipación, daño, tácticas).
  Se aplican al instante y se guardan con la partida; "Valores por defecto" vuelve a los de siempre. Test
  `--autotest-settings`, vitrina `--showcase-settings`.
- **Kits v8 — Tanda C + sinergia (2026-10-26)**: Drowzee, Grimer, Koffing (nubes que detona), Ponyta (galope con
  estela de fuego), Slowpoke (reacciona tarde) y Magikarp (Azote y EXP extra): la propuesta de kits quedó completa.
  Y **sinergia**: los Pokémon con kit aprenden todo su learnset de FireRed; los ataques oficiales toman la forma de su
  versión de kit; los de mejora propia ahora hacen algo; las firmas reaccionan por tipo (un Rayo Hielo aprendido suma
  escarcha a Seel). El equipamiento inicial sigue siendo el kit. Ver `PLAN_IDENTIDAD_COMBATE.md`. Test
  `--autotest-kits-v8` (`--only sinergia`).
- **Kits v7 — Tanda B (2026-10-26)**: Clefairy (Metrónomo: un ataque al azar de cualquier kit), Jigglypuff (se infla y
  le dibuja la cara a los dormidos), Abra (se teletransporta solo al recibir un golpe: hay que dormirlo para atraparlo),
  Goldeen (el cuerno atraviesa defensas; rápido mojado), Magnemite (flota y atrae) y Meowth (Día de Pago: suma a tu
  dinero). Ver `PLAN_IDENTIDAD_COMBATE.md` "v7". Queda la Tanda C. Test `--autotest-kits-v7`.
- **Kits v6 — Tanda A (2026-10-26, pedido del usuario)**: Raichu ahora es **jefe de Lt. Surge** (Toma de Tierra:
  planta la cola, descarga y suelo electrificado; Sobrecarga a mitad de vida), y kits propios para Zubat, Ekans,
  Machop, Nidoran♀, Nidoran♂, Horsea, Shellder, Tentacool y Voltorb (sus evoluciones los heredan). Ver
  `PLAN_IDENTIDAD_COMBATE.md` "v6" y `PROPUESTA_KITS_PENDIENTES.md` (quedan las Tandas B y C). Test `--autotest-kits-v6`.
- **IA más pareja (2026-10-25, pedido del usuario: "se quedan trabados cuando tienen un obstáculo enfrente", "no
  parece tan buena en Normal")**: los Pokémon (salvajes y de entrenadores) rodean árboles, casas y rocas en vez de
  empujar contra ellos (y si se traban buscan camino por celdas); no disparan contra una pared (se acomodan para
  tener tiro); los de cuerpo a cuerpo ya no retroceden solos; si ningún ataque llega, se acercan en vez de quedarse
  un segundo quietos; los disparos anticipan tu movimiento. **Normal** ataca más seguido (×1,2 en vez de ×1,5),
  apunta mejor (±10° en vez de ±15°), esquiva más (22%) y pega 85%; Difícil esquiva 40%. Test `--autotest-ai-steer`.
- **Mapa en el menú (2026-10-25, pedido del usuario)**: Esc → Mapa (con el objeto Mapa que da Dalia; las partidas que
  ya lo tienen lo ven sin hacer nada). La región en miniatura dibujada desde los mapas reales, con nombres de ciudades
  y rutas, tu posición (adentro de una casa o cueva, en su puerta), la estrella del objetivo de la Guía, íconos de
  Centro/Tienda/Gimnasio y niebla en lo no visitado (las partidas viejas lo arman según su avance). Rueda/+−: zoom;
  arrastrar o WASD: mover; Espacio: centrar. Test `--autotest-town-map` (24), vitrina `--showcase-town-map`.
- **Capítulo 2, parte K (2026-10-24)**: kits de Staryu y **Starmie jefa de Misty** (`tools/build_kits_v5.py`, firma
  Núcleo `core_mechanic.gd`: gira y desvía proyectiles, +daño a lo Empapado, se regenera; a mitad de vida el núcleo
  brilla) + `FightStyle` de 33 Pokémon del capítulo 2. Test `--autotest-kits-v5`. Ver `PLAN_IDENTIDAD_COMBATE.md` "v5".
  2026-10-25: kits propios para las evoluciones que cambian de forma de pelear (Butterfree, Beedrill, Kadabra con la
  firma nueva Mente Rápida, Gyarados); el resto hereda el kit de su preevolución.
- **Versión portable para amigos (2026-10-24)**: `python -I -B tools/build_portable.py . <Godot_v4.7.2-stable_win64.exe>`
  arma `export/PokemonPilot-<fecha>.zip` (~115 MB: el Godot renombrado + `PokemonPilot.pck` + `LEEME.txt`). No usa
  plantillas de exportación. Preset "Windows Desktop" en `export_presets.cfg` con la feature `portable`, que apaga
  el editor de mapas y la trampa F9. `project.godot` tiene `export/convert_text_resources_to_binary=false`: al pasar
  los .tres a binario se perdían los PackedStringArray (diálogos y banderas de la historia). Se rearma cada vez que
  haya cambios para pasar.
- **Herramienta — Editor de mapas hecha** (no corre la numeración de etapas): acceso directo "Pokémon Pilot —
  Editor de mapas" (`-- --map-editor`). Ya tiene **todos los gráficos de FireRed**, la paleta organizada como la
  hoja de tiles del mundo de FireRed y 78 sellos sacados de los mapas reales. Ver "Herramienta — Editor de mapas".
- **Etapa 3 hecha (entorno reactivo)** — ver "Etapa 3" más abajo. **Etapa 2c hecha** (título, guardado,
  equipo y movimientos).
- **386 Pokémon (Kanto, Johto y Hoenn) cargados con stats, learnsets y sprites + Pokédex** en el menú
  (2026-10-22, ver "Etapa 2d"). Los spawns NO se tocaron (siguen los 4 de prueba).
- **Etapa 4a hecha (IA de los salvajes)**: cuerpo compartido + temperamentos (agresivo, territorial, tímido,
  curioso) — ver "Etapa 4a". Definido con el usuario: **la IA de salvajes y la de entrenadores son distintas**
  (salvajes = instinto sin memoria; entrenadores = órdenes + memoria) — ver `PLAN_ENTRENADORES.md`, sección 1b.
- **Entrenadores vivos — E-0 hecha** (2026-10-23; decisiones del plan confirmadas): interruptor "Entrenadores
  vivos (en prueba)" (inicio y Opciones, apagado por defecto), datos de los 3 entrenadores (Azul, Valeria, Tomás)
  y sus NPC en Ruta 1. Detalle en `docs/PLAN_ENTRENADORES.md` ("Avance").
- **Captura, Mochila y Caja hechas** (2026-10-23, pedido del usuario antes de E-1; `docs/PLAN_CAPTURA_MOCHILA.md`):
  E lanza la Pokébola (fórmula oficial de 3ª gen), IVs al azar en los salvajes, Caja con el equipo lleno, Mochila
  con bolsillos y objetos oficiales, C usa el objeto rápido en combate, objetos en el mapa y botín de salvajes.
- **Documentación de salvajes, movimientos y kits** (2026-10-23): `docs/SALVAJES_Y_MOVIMIENTOS.md` (cómo
  funcionan el spawner, los movimientos, los temperamentos y los kits, y cómo modificarlos) y
  `docs/SALVAJES_LISTADO.md` (generado por `tools/build_wild_docs.gd`: qué aparece en cada zona y con qué
  movimientos). Arreglado: el territorial (Bellsprout) cortaba el combate a cada rato. **Propuesta a confirmar:
  llegar a ~16 kits** para el modo historia (lista en `SALVAJES_Y_MOVIMIENTOS.md`, sección 4).
- **Rework de Empapado** (2026-10-23): los ataques de agua empapan al pegar (no por el camino), Empapado dura 4 s
  y solo resta 10% de velocidad, los charcos no empapan ni asustan a la IA, y el fuego contra un empapado pega
  30% menos y lo seca. Detalle en el plan de identidad ("Rework de Empapado").
- **v3: 10 kits nuevos implementados, en prueba** (Squirtle, Pikachu, Oddish, Paras, Psyduck, Poliwag, Growlithe,
  Eevee, Seel, Geodude): ya son **16 Pokémon con kit**. Detalle en el plan de identidad ("v3"); el usuario los va
  a ir ajustando mientras los prueba. Autotest `--autotest-kits-v3`. Primer ajuste: Rayo de Pikachu cae del cielo
  en área; Burbuja de Poliwag encierra sin mojar.
- **Spawns**: se respetan los de FireRed (cada zona nueva tiene la tabla real de su lugar, coinciden con la guía de
  Rojo Fuego/Verde Hoja). **Más salvajes en mapas grandes** (2026-10-23): `EncounterTable.cells_per_wild` (uno
  más cada 150 celdas donde pueden aparecer, tope `max_alive_cap` 16) y reponen más rápido; ej. Ruta 1 ≈ 10,
  Bosque Verde 16. **Objetos tirados solo en las rutas** (3-4 al azar por ruta y Bosque Verde; nada en ciudades ni
  interiores); el botín de salvajes sigue igual.
- **v4: kits de Kanto hasta Ciudad Plateada** (2026-10-23): Caterpie, Weedle, Metapod, Kakuna, Spearow, Mankey,
  Sandshrew y **Onix como jefe** (el de Brock). 24 Pokémon con kit. La **Pokédex** muestra el estilo de pelea, la
  mecánica de firma y los 4 ataques del kit de lo que ya viste. Detalle en el plan de identidad ("v4").
- **Qué hay hoy de la historia y qué falta (guía para jugar)**: `docs/HISTORIA.md`. Importante: **todavía no hay
  eventos de trama** (Oak, laboratorio, rival, paquete = H-1/H-2).
- **Plan de historia hasta la Medalla Roca** (2026-10-23): `docs/PLAN_HISTORIA.md` (la de FireRed, fases H-0 a
  H-6; necesita E-1, el combate contra entrenadores). Decisiones tomadas: inicial en el laboratorio, E contextual
  para hablar, entrenadores de historia fijos, perder = último Centro.
- **H-0 hecha** (2026-10-23): banderas de historia (se guardan), caja de diálogo, **67 personas reales de FireRed
  que hablan** (sprites de pret, diálogos propios), E contextual (habla o lanza la bola), disparadores y bloqueos
  por bandera, enfermeras y mamá curan. **Teclas 1-6 cambian de Pokémon** (también en combate). Detalle en
  `docs/PLAN_HISTORIA.md` ("Avance").
- **E-1 hecha: combates contra entrenadores en ARENA** (2026-10-23, pedido del usuario): fundido a una arena aparte
  (claro de pinos para los de ruta; **gimnasio de roca épico** para Brock), 1 contra 1 con cambios, el rival te ve
  y te desafía, perder te devuelve al último lugar donde te curaron. Ya pelean los 5 Cazabichos del Bosque Verde,
  el Campista Liam y **Brock** (Medalla Roca). Detalle en `docs/PLAN_ENTRENADORES.md` ("E-1").
- **EXP a la mitad** (2026-10-23, pedido del usuario: "se sube de nivel muy rápido"): `GameConfig.exp_multiplier`
  = 0,5 sobre la fórmula oficial (se cambia en el inspector de `data/config/game_config.tres`).
- **H-1 hecha** (2026-10-23): la historia empieza en tu cuarto sin Pokémon ("Empezar la historia"), Oak te frena
  y te lleva al laboratorio, inicial en la mesa (Sí/No), el rival elige el ventajoso y te desafía. Guía:
  `docs/HISTORIA.md`.
- **H-2 hecha** (2026-10-23): el Correo de Oak (Tienda de Ciudad Verde → Oak), la Pokédex de regalo (en la historia
  recién ahí aparece), 5 Poké Balls, Dalia y el Mapa, y el viejo que tapa la salida al norte hasta entregar el
  correo (después te enseña a atrapar).
- **H-3 hecha** (2026-10-23): el rival te frena en la Ruta 22 (Pidgey 9 + su inicial 9).
- **Capítulo 1 completo (H-4/H-5)** (2026-10-23): objetos fijos del camino, el chico de Plateada que te lleva al
  gimnasio, Brock da la Medalla Roca y la **MT39** (las MT enseñan movimientos de verdad), **Tarjeta de entrenador**
  con las medallas (Esc → Tarjeta). De Pueblo Paleta a la Medalla Roca se juega entero.
- **Plan del Torneo de Plateada** (2026-10-23, idea del usuario): `docs/PLAN_TORNEO.md` (dinero, edificio, copas de 3/6
  Pokémon con tope de nivel para inscribirse, 6 Pociones del torneo, arena épica con agua y rocas, y los entrenadores
  con memoria como Brock que aprenden de vos).
- **Torneo T-0 a T-3 hecho** (2026-10-23): **dinero** (empezás con $3000, premios por entrenadores), **Edificio del
  Torneo** en Plateada (la puerta del anexo del museo), copas de 3/6 Pokémon (Nv. 15, 30, Libre) con 6 Pociones y sin
  curar entre rondas, Brock y Azul en el cuadro, y el **estadio épico** con lagunas, pasto, rocas, público y confeti.
  Falta T-4 (que aprendan de vos: E-2 a E-4).
- **Varias partidas con nombre** (2026-10-23, pedido del usuario): Nueva partida pide el nombre; cada partida es
  `user://saves/<nombre>.json` (con su "save_name"); Continuar muestra la lista (cargar / borrar). En la historia se
  puede guardar antes de tener Pokémon. `SaveManager.list_saves` / `use_name` / `load_from` / `path_for_name`.
- **Los Pokémon ya no se curan solos** (pedido del usuario): solo Centro Pokémon, mamá u objetos. Si cae tu Pokémon
  fuera de una arena sale el siguiente sano; sin ninguno, **desmayo total** (`StoryDirector.blackout`: volvés al
  último lugar donde te curaron, curados). El modo práctica sigue reviviendo al instante (opción aparte).
- **Modo de prueba del torneo** (pedido del usuario): título → "Probar el torneo": elegís hasta 6 Pokémon con kit, el
  nivel y la copa, y se juega el Torneo de Plateada directo; no se guarda nada (`GameState.test_tournament`); al
  terminar, repetir o volver al título.
- **Combate de arena** (2026-10-24, inspirado en Pokémon Arena 2D): estilos de movimiento (ágil/pesado/volador),
  combos (cadena de golpes + un combo con nombre por Pokémon), cráteres que deja el terreno golpeado y superficies que
  frenan. Por ahora solo en las arenas (torneo, gimnasio, entrenadores); después se ajusta para el mundo abierto
  (`GameConfig.arena_rules_everywhere`). Detalle en el plan de identidad ("Combate de arena"). Además: los que
  tienen patas **saltan los cráteres** con el esquive hacia donde apuntás; sprite del cráter (agente de mapas);
  **tope de cráteres** por ataque y por cancha. **Propuesta de combos v2** en `docs/PROPUESTA_COMBOS.md` (a decidir).
- **Guía de la historia** (2026-10-24, pedido del usuario): Esc → Guía dice en qué paso estás y qué hacer
  (`StoryGuide`: pasos por bandera + lo opcional). Arreglo: el botón de la **Pokédex** no aparecía hasta volver a
  cargar la partida (el menú se armaba una vez); ahora se revisa al abrir. En la historia el menú se abre aunque
  todavía no tengas Pokémon (para guardar y ver la Guía).
- Pedido del usuario pasado al agente de mapas: **límites de las zonas** (se podía salir a partes sin dibujar o
  saltearse zonas). Lo hace el agente de mapas.
- Pedido del usuario pasado al agente de mapas: los saltos/salientes de las colinas se tienen que poder **bajar
  pero no subir** (como en FireRed). Lo hace el agente de mapas. **Próximo:** H-6 (bot que
  juega el capítulo + revisión) o seguir con E-2 / la Ruta 3 y el Monte Moon, a decidir con el usuario.
- **Mundo = mapas reales de FireRed de Pueblo Paleta a Ciudad Plateada** (2026-10-23, ver "Región de FireRed"):
  7 exteriores agrandados ×1,75 + 21 interiores con **puertas**; las 9 zonas generadas y la Ruta 1 vieja se
  borraron (pedido del usuario). Pinceles nuevos: piso de ciudad, empedrado y piso de cueva.
- **Siguiente: E-1** (combate contra entrenador: desafío, equipos de hasta 3, cambio de Pokémon con Tab, fin y
  EXP). Después, spawns por hora (Etapa 4b/5). El usuario aprobó los kits por ahora ("me gustan los de Charmander y
  Bulbasaur"); más adelante se harán **tests de balance** de los kits.
- v2 hecho: **sin energía** (solo recargas), **4 ataques + esquive en Espacio**, Charmander **bruiser** rearmado,
  Bellsprout/Bulbasaur **control**, y por ahora **todo el mapa** solo hace aparecer **Pidgey, Bellsprout,
  Rattata y Vulpix** (`WildSpawner.use_test_pool`; apagarlo devuelve los spawns por bioma).
- Pantalla de inicio con **Modo práctica** (por defecto on) y **Dificultad de la IA** (Fácil / Normal por
  defecto / Difícil = la IA original). Detalle en el plan de identidad.
- **Kits de Pidgey (hostigador, Vuelo), Rattata (asesino, Instinto) y Vulpix (desgaste, Rescoldo)** hechos
  (2026-10-22): los 4 de la zona de prueba tienen estilo propio. Detalle en el plan de identidad.
- Identidad pendiente: **Squirtle** (tanque/parry) y **Pikachu** (cargas). Propuestas en `PLAN_IDENTIDAD_COMBATE.md`.
- Lo de la sección "Combate (Etapa 2)" más abajo que hable de energía o de ataques 1-4 genéricos quedó
  superado por la v2 (ver el plan de identidad).

## Etapas

| # | Etapa | Estado |
|---|---|---|
| 1 | Refactor data-driven + mundo abierto con zonas | ✅ Hecha |
| 1b | Arte FireRed + efectos modernos | ✅ Hecha |
| 1c | Región grande (3×3 zonas, 9 biomas) | ✅ Hecha |
| 2 | Combate en tiempo real en el mapa + estados alterados | ✅ Hecha |
| 2b | Stats oficiales (PokeAPI), curvas de EXP, velocidad por stat, balance de energía, visual de fuego/estados | ✅ Hecha |
| 2c | Título, guardado, equipo (máx. 6) y movimientos por nivel (learnset + ficha) | ✅ Hecha |
| 2d | 386 Pokémon (3 regiones) con stats, learnsets y sprites + Pokédex (vistos/luchados) | ✅ Hecha |
| 3 | Entorno reactivo (fuego, agua, eléctrico) + puzzles | ✅ Hecha |
| 4a | IA de los salvajes: cuerpo compartido + temperamentos (sin memoria) | ✅ Hecha |
| 4 | IA salvaje con estados + spawns por bioma/hora | ⏭️ Siguiente |
| 5 | Ciclo día/noche, clima, NPCs con horarios | 🟡 Día/noche: partes A, B, C (ventanas) y D hechas (2026-10-28); faltan faroles, clima y horarios |
| 6 | Captura, equipo y progresión (incluye **IVs al azar al capturar**, naturalezas, EVs) | 🟡 Captura, Mochila, Caja e IVs al azar hechos (2026-10-23); faltan naturalezas, EVs, evoluciones, Centros |
| 7 | Primer gimnasio (arena con transición) | Pendiente |
| 8 | Pulido (juice, audio, partículas) | Pendiente |

## Región de FireRed: de Pueblo Paleta a Ciudad Plateada (2026-10-23)
Pedido del usuario: renombrar Ruta 1 a Pueblo Paleta, pinceles de piso de ciudad y de cueva, borrar las zonas que
había y reproducir hasta Ciudad Plateada (guía de Rojo Fuego). Durante el trabajo pidió: **adaptarlo a nuestra
escala** ("un poco más grande") y **usar el Pueblo Paleta original agrandado** en vez del que había dibujado.
Decidido con su "hacé tu mejor intento": mapas reales, puertas + interiores (el Bosque Verde se entra por sus garitas
como en FireRed) y salvajes de FireRed.
- `tools/import_frlg_maps.py`: los mapas de pret (más `data/maps/*/map.json` y `border.bin` bajados de
  pret/pokefirered) → `data/world/frlg_maps.json`. Agranda con **costuras** (ver CLAUDE.md, "Región de FireRed"):
  crecen pasto, caminos, agua, acantilados y arboledas; casas, carteles y puertas quedan como en FireRed.
  Los mapas se ubican por sus conexiones alineando los caminos; la columna Paleta–Ruta 1–Verde–Ruta 2–Plateada
  tiene un mismo ancho (los costados se rellenan con el borde de árboles), la Ruta 22 sale al oeste de Ciudad Verde.
- `tools/import_frlg_maps.gd`: zonas `hand_edited` (se siguen editando con el editor), región nueva, TileSet con la
  colisión por celda de los mapas y tablas de salvajes reales (Ruta 1: Pidgey/Rattata; Ruta 2, Ruta 22, Bosque
  Verde) **sin las filas de agua** (en FireRed son de Surf, de nivel 5-40, y nadarían al lado del inicio), y los
  árboles cortables de FireRed como objetos del entorno (Ciudad Verde, Ruta 2, Ciudad Plateada). El agua va en la
  capa Water y el pasto alto en Foliage, como con los pinceles. Borró las 9 zonas generadas y `zona_nueva` (backup en
  `scenes/world/zones/.backup/`).
- **Puertas** (`WarpSystem`, `ZoneEntry.warps`): casas, Laboratorio de Oak, Centros, Tiendas, gimnasios, Escuela,
  Museo (2 pisos), garitas de la Ruta 2 y de la Ruta 22 (la de la Ruta 22 todavía no lleva a la Calle Victoria).
  En el editor se ven con recuadro celeste y la barra dice a dónde llevan; validación de puertas.
- Pinceles nuevos (`tile_roles.tres`): **Piso de ciudad** (autotile, Ciudad Verde), **Empedrado** (autotile,
  Ciudad Plateada) y **Piso de cueva** (tile suelto).
- Entrenadores vivos: sus rutinas pasaron a Ruta 1, Ruta 22, Ruta 2 y Bosque Verde (celda transitable más cercana).
- `--autotest` reescrito: camina de Pueblo Paleta a Ciudad Plateada entrando al Laboratorio de Oak, pasando por la
  Ruta 22 y cruzando el Bosque Verde por sus garitas (`TourPlanner`).
- **MO sin trámite, como en Let's Go** (2026-10-28, pedido del usuario: "es tedioso el sistema de MO"): Corte, Surf
  y Fuerza se desbloquean igual que antes (la MO + su medalla) pero no se enseñan ni preguntan nada: caminando contra el
  árbol, el agua o la roca tu Pokémon lo hace solo (`FieldMoves._auto_use`). La E frente al obstáculo dice qué falta.
  Textos de la historia ajustados.
- **Pelea en el agua** (2026-10-28, el usuario eligió la "combinada"): navegando, si te ataca un salvaje, tu Pokémon de
  tipo Agua sale nadando; los Voladores, Fantasma y los que levitan flotan; el resto pelea montado sobre tu Pokémon de
  Surf (el primero de agua del equipo, o Lapras si no tenés), más lento y con el entrenador arriba. En tierra, los que
  nadan o flotan también pueden meterse al agua. Volvieron los salvajes de agua de FireRed (27 tablas: Tentacool,
  Psyduck, Seel...), que salen solo mientras navegás. Falta: verlo en pantalla (no se probó a mano).
  **Entorno del agua**: el hielo ya congelaba el agua (puente de hielo, 10 s). La electricidad, por pedido del usuario
  ("se propaga cuando impacta, si no estaría muy roto"), ahora es **una descarga de una vez**: al impactar en el agua (o
  lo mojado) paraliza, con la mitad de la duración, a los que están en las celdas alcanzadas (hasta 48 por el agua) y
  la celda queda solo visual 0,5 s (`EnvCellState.status_on_impact`, `ReactionSystem._shock`). No la sienten los que
  flotan ni el que pelea montado. El fuego sigue sin tocar el entorno (decisión anterior).
- **Mapas del resto de Kanto** (2026-10-28, pedido del usuario: "continuá hasta donde puedas para terminar la
  historia"): 145 zonas nuevas, toda Kanto hasta la Meseta Añil (Rutas 7-21 y 23; Lavanda + Torre Pokémon; Azulona
  + Gran Almacén, Casino, Escondite Rocket, gimnasio; Azafrán (ya no es hueco) + Silph S.A., Dojo, gimnasio; Fucsia
  + Zona Safari; Islas Espuma; Canela + Mansión, Laboratorio, gimnasio; Túnel Roca, Cueva Diglett, Central
  Eléctrica, Calle Victoria y el Alto Mando). Sin Islas Sete ni Cueva Celeste; ascensores no (destino dinámico).
  Los interiores bajaron 258 celdas (el mar al sur de Paleta los pisaba): las partidas viejas se migran al cargar.
  `--autotest-bounds`: con Corte se llega a Lavanda, Torre, Azulona, Azafrán (solo por sus garitas), Fucsia, Safari
  y Rutas 12-16; con Corte + Surf + Fuerza (simulados) a Canela, Islas Espuma, Calle Victoria y la Liga. **Falta
  (historia, otra sesión)**: Surf, Fuerza, Flash, Poké Flauta (Snorlax), guardias de Azafrán, puertas del Alto Mando y
  barreras de la Mansión (scripts de FireRed), y la historia de cada tramo.
- **Mapas del capítulo 3** (2026-10-25, pedido del usuario: "hasta el gimnasio de Ciudad Carmín respetando la
  guía"): Ruta 5 (guardería, garita), Vía Subterránea (entradas en las Rutas 5 y 6), Ruta 6 (garita), Ciudad Carmín +
  Centro, Tienda, Club de Fans, casas y Gimnasio, y el S.S. Anne entero (muelle, plantas 1 a 3, sótano, cubierta,
  cocina, 18 camarotes y el del capitán). Azafrán no se arma: se ubica para que la Ruta 6 y Carmín queden donde van
  y queda un hueco con paredes (en la guía está cerrada; se pasa por la Vía Subterránea). El Gimnasio de Carmín queda
  detrás del árbol cortable: hace falta Corte (lo hace la sesión de historia). `--autotest` llega al camarote del
  capitán; `--autotest-bounds` verifica que sin Corte no se llega al gimnasio y con Corte sí.
- **Mapas del capítulo 2** (2026-10-24, parte M de `docs/PLAN_CAPITULO_2.md`): Ruta 3, Ruta 4 + su Centro,
  Mt. Moon (3 pisos, agrandados como el Bosque Verde), Ciudad Celeste + Centro, Tienda, Gimnasio, tienda de bicis,
  casas y casa robada, Ruta 24 (Puente Pepita), Ruta 25 y la Casa de Bill, con sus puertas, personas (para la
  historia) y salvajes de FireRed (en las cuevas, en cualquier suelo). Importados con `import_frlg_maps.gd --
  --only-new`: las 28 zonas anteriores quedaron idénticas. En los mapas nuevos no se copian escaleras ni puertas al
  agrandar, y cuando un borde tiene varios caminos se alinea el del medio. Dos salientes seguidos se saltan juntos;
  una puerta sólida se usa empujándola 0,12 s (no se entra sin querer al pasar rozando). `--autotest` ahora camina
  hasta el Gimnasio de Celeste (Mt. Moon incluido) y `--autotest-bounds` verifica que no haya atajos (Bosque Verde ni
  Mt. Moon) y que se llegue a todo.
- **Límites de las zonas** (pedido del usuario: "en algunos mapas, rutas e interiores no hay límites"): los interiores
  de FireRed tienen piso hasta el borde y algunos caminos llevaban a mapas que no están (Ruta 3, Calle Victoria);
  `ZoneBounds` pone paredes invisibles en todo borde que da al vacío. Se sacó el árbol cortable de Plateada que tapaba
  la entrada del Torneo (`SKIP_OBJECTS` en el importador). `--autotest-bounds`: recorre todo lo alcanzable desde el
  inicio (con puertas), verifica las paredes caminando contra el vacío en 21 zonas, que se llegue a Centros, Tiendas,
  gimnasios, Museo y Torneo, y que sin el Bosque Verde no se llegue a Plateada. (La casa de la Ruta 2 sigue detrás de
  árboles cortables, como en FireRed.)
- **Salientes de un solo sentido** (pedido del usuario: "las colinas que tienen colisión puedo bajarlas pero no
  subirlas"): `LedgeJumper` salta el saliente caminando contra él en su dirección (behavior MB_JUMP_* de FireRed;
  hasta Plateada todos son hacia abajo) y el Pokémon salta detrás; desde abajo siguen siendo pared.
  `--autotest-ledges`.
- Pendiente: NPC, carteles y objetos (Pokébolas) de los mapas de FireRed (no se importan), editar puertas desde el editor,
  Calle Victoria / Ruta 3 en adelante.

## Herramienta — Editor de mapas (2026-10-22)
Pedido del usuario en `docs/PROMPT_EDITOR_DE_MAPAS.md`. Es una herramienta, no una etapa. Decisiones (todas las
recomendadas): **modo aparte del mismo proyecto** (`-- --map-editor` + acceso directo propio), **autotile
portado** a un script compartido (se probaron los terrains de Godot: ~7% de celdas distintas, cortan los caminos
en las salidas y no hay esquinas interiores en el 3×3 de FireRed), **marca `hand_edited`** en la zona
(`--force` la saltea, `--force-all` no), **roles y tags como datos** en `data/world/tile_roles.tres`, y los tilesets
`viridian_forest`/`pallet_town` **todavía no** (el editor quedó preparado: la paleta sale del TileSet).
- **Núcleo compartido**: `ZoneBuilder` (TileSet desde los roles, estructura de la zona, autotile, guardar),
  `ZoneGenerator` (el generador de `build_world.gd`, ahora reutilizable) y `MapRules` (colisión real por celda,
  celda libre más cercana, validaciones). Verificado: regenerar las 9 zonas y el TileSet con el núcleo nuevo da
  exactamente lo mismo que antes (celda por celda).
- **Editor** (`scenes/tools/map_editor.tscn`, `scripts/tools/map_editor/`): lienzo con las capas reales y las
  vecinas atenuadas; superposiciones (grilla, colisión, tags, sin tags, plaza/salidas, inicio); pinceles con las
  reglas (autotile, agua y follaje con pasto abajo, árboles con copa/apilado/sombra, borde de árboles, objetos de
  `scenes/world/objects/`); modo tile crudo con paleta filtrable; pincel 1-3, línea, rectángulo, balde,
  selección + copiar/pegar, gotero; deshacer/rehacer de todo; panel de tags y colisión por metatile (con backup del
  TileSet y sugerencias por behavior); zona: nombre, bioma, plaza y salidas arrastrables, inicio del juego,
  validaciones y "Nueva zona" en un lugar libre (en pasto o generada). Guardar con backup (últimos 5) y aviso de
  cambios sin guardar.
- **Probar en el juego (F5)**: proceso aparte (`OS.create_process` con `-- --debug --start-zone <id> --start-cell x,y`).
  Se eligió proceso aparte porque el juego arranca limpio (autoloads, guardado, streaming) sin arrastrar estado del
  editor, si el juego se cuelga el editor sigue abierto, y se pueden tener los dos a la vez. Usa el equipo de la
  partida guardada y guarda en `user://saves/map_editor_test.json` (no pisa la partida real).
- `World._ready()` **no** reubicaba al entrenador: ahora, si la posición guardada quedó en algo sólido o en el agua,
  aparece en la celda libre más cercana (`MapRules.nearest_walkable`).
- `EnvObject.display_name` (nombre en el editor): Roca frágil, Roca pesada, Árbol cortable.
- Autotest `--autotest-map-editor` (≈45 chequeos: ida y vuelta idéntica, arena/agua/árbol/roca con tags y
  colisión, deshacer/rehacer, balde, copiar/pegar, validaciones, zona nueva, panel de tile, la UI real manejada
  como con el mouse, reubicación del entrenador); vitrina `--showcase-map-editor`.
- **Todos los gráficos de FireRed en el editor (2026-10-22)**: se bajó del decomp pret/pokefirered (clon parcial
  de git) todo lo de tilesets + los 365 mapas. Decisiones (las recomendadas): **los 68 tilesets, interiores
  aparte** (se importan 62; los 6 sin mapas no), **tipos automáticos + editables**, **sellos de edificios** sacados
  de los mapas y **colisión desde los mapas reales**. Quedó: ~10.000 metatiles con tipo (terreno, pasto, arena,
  agua, hielo, árboles, rocas, edificios, puertas, escaleras, salientes, carteles, cercas, suelos especiales,
  suelo/paredes/muebles de interior, sin usar), 70 sellos de edificios, paleta con filtros por grupo/tileset/
  tipo/tag, pestaña Sellos y tipo editable en la pestaña Propiedades (antes "Tile"; la paleta se llama "Paleta"). Las 9 zonas quedaron con los mismos tags y colisión
  (verificado celda por celda). Pendiente: animaciones propias de los tilesets secundarios (fuentes, etc.) y
  esquinas interiores para caminos y lagos (ya anotado en pulido).

## Etapa 2d — 386 Pokémon y Pokédex (2026-10-22)
Pedido del usuario: "todos los Pokémon de las 3 primeras regiones con sus movimientos y estadísticas" (sin
tocar spawners) y la Pokédex en el menú.
- **Datos**: 386 especies (372 nuevas) con stats, tipos, experiencia, curva, captura, nombre, categoría,
  descripción (español), altura y peso; **learnset oficial completo de FRLG** para las nuevas (las 14 de antes
  conservan su kit/extras); **337 ataques** (304 nuevos, forma automática). **18 tipos** con la tabla oficial
  completa (incluye inmunidades: Normal→Fantasma, Eléctrico→Tierra, etc.). Sprites PMD de los 386 (29 MB).
- **Pokédex** (menú de pausa → Pokédex, `PokedexScreen`): pestañas Kanto/Johto/Hoenn (Tab), grilla con
  miniaturas. Lo **no visto** sale como **"?????"** con la **silueta oscura** sobre el fondo de rayos de
  "¿Quién es ese Pokémon?". Lo **visto** muestra nombre, categoría, tipos, altura, peso y descripción; lo
  **luchado** (●) suma las estadísticas base.
- **Registro** (`PokedexTracker` en el mundo → `GameState.pokedex_seen/fought`, se guarda en la partida): visto =
  un salvaje aparece en pantalla (mensaje "Pokédex: X registrado." la primera vez); luchado = entró en combate
  con tu Pokémon. El equipo cuenta como luchado. Partidas viejas: se arma con el equipo.
- Autotest `--autotest-pokedex` (14 chequeos: las 386 salen al mundo a Nv. 50 y usan sus 4 movimientos sin
  errores; registro, guardado y pantalla); vitrina `--showcase-pokedex`.

### Salvajes por zona en el editor (2026-10-22)
Decisiones (las recomendadas): **niveles fijos por fila** (como FireRed), **modo de prueba como interruptor
apagado** (Opciones → "Salvajes de prueba"), **por zona y por terreno** + (pedido del usuario a mitad de camino)
**áreas pintadas** que ajustan el % de algunos Pokémon, y **plantillas reales de FireRed**.
- `EncounterTable`/`EncounterEntry`/`EncounterArea`; tablas en `data/world/encounters/` (una por bioma con las
  especies del spawner viejo, y Ruta 1 con los 4 de prueba al 35/35/15/15, Nv. 2-5). `WildSpawner` reescrito:
  celda primero, fila de esa celda después (así cada área usa sus %), salvajes de agua que nadan.
- Editor: pestaña **Salvajes** (tabla, buscador de los 386, Copiar de FireRed con 132 lugares, densidad y
  reaparición, áreas pintadas con pincel/rectángulo/balde, % real del área y de la celda bajo el mouse),
  validaciones nuevas y deshacer de todo.
- `--autotest-encounters` (20 chequeos). Se arregló un bug del spawner (elegía celdas de lugares que la tabla no
  usaba) y se estabilizó `--autotest-input` (el spawner reponía un salvaje en medio de la prueba de teclas).
- Pendiente (Etapa 4/5): que la IA salvaje use su kit con criterio y los encuentros por hora (`time`).

### Sellos y paleta rehechos con las hojas de referencia (2026-10-22)
Pedido en `docs/PROMPT_REORGANIZAR_TILES_Y_SELLOS.md`. Decisiones (las recomendadas): lo que no está en ningún
mapa de FireRed queda **afuera y listado**; ante diferencias chicas manda **el mapa real**; variantes de color =
**un sello con selector**; los 70 sellos viejos **reemplazados**.
- Hojas de The Spriters Resource (las bajó el usuario: el sitio rechaza descargas automáticas) en
  `art_src/referencia/` (en `.gitignore`). Son una grilla de 16 px con 1 px transparente y fondo transparente.
- `tools/match_reference.py`: coincide el 85% de las celdas de edificios y el 85% de las del mundo (colores en 5
  bits; la hoja tiene retoques chicos). **78 sellos**: 57 edificios (29 casas, Centro y Tienda, 3 gimnasios, 19
  especiales, 4 garitas; 1 con variante) + 21 piezas del mundo. Cada uno coincide celda por celda (metatile y
  colisión) con su mapa real (`--check`). Sin ubicar en mapas (afuera): 7 piezas de edificios (un gimnasio de techo
  rojo, un edificio gris grande de 11×18, un edificio con banderas de 13×4, uno de 9×7 y 3 tramos de fachada) y el
  bloque de árboles redondos + estanque de la hoja del mundo, más celdas sueltas.
- Paleta: tipos y orden de la hoja del mundo (32 secciones, 13 tipos) + "Otros · …"; vista **"Como en la hoja"**.
- Tags y colisión de los tiles **sin cambios**; las 10 zonas (incluidas las que está editando el usuario) iguales
  celda por celda (17.911 celdas).
- Autotest nuevo `--autotest-stamps` (11 chequeos) y `match_reference.py --check`; vitrinas `--showcase-stamps` y
  `--showcase-stamp-sheets`.

## Etapa 4a — IA de los salvajes (2026-10-23)
Decisión del usuario: la IA de los salvajes y la de los entrenadores son **distintas** sobre una capa común.
- **Cuerpo compartido** (`CombatBody`, `scripts/creatures/ai/`): si un ataque llega, adónde apuntarlo (dirección
  y punto), esquivar proyectiles, salir de celdas peligrosas (electrificadas, mojadas). **La dificultad actúa
  solo acá** (puntería, frecuencia de ataque y de esquive). Lo usarán también los entrenadores.
- **Temperamentos** (`Temperament`, `data/ai/temperaments/*.tres`; `SpeciesData.temperament`, asignado a las 386
  por `tools/assign_temperaments.gd` con heurística por stats + ajustes a mano):
  **agresivo** (te ataca apenas te ve, persigue lejos) · **territorial** (te mira con "...", ataca solo si entrás a
  su zona y te suelta si salís) · **tímido** (huye sin pelear; si lo acorralás o le pegás, pelea; huye antes con
  poca vida) · **curioso** (se acerca a mirarte a ~55 px; si te le venís encima ataca o huye). Reparto: ~177
  territoriales, ~83 agresivos, ~78 tímidos, ~48 curiosos. "En grupo": reservado (`calls_group`) para más adelante.
- **Patrón reconocible** (sin azar): abre siempre con su ataque de acercamiento si está lejos (Rattata entra con
  Ataque Rápido) y después rota sus ataques en orden. Golpes fuertes pueden espantarlo (retrocede un momento).
- **Avisos** sobre la cabeza (`Creature.emote`): "!" te vio/pelea, "?" curiosidad, gota = miedo, "..." te ignora.
- Estados: `wander` (reacciona según temperamento), `watch` (nuevo, curioso), `chase` (correa por temperamento,
  apertura), `attack` (rotación + cuerpo), `flee` (tranquila o en combate; acorralado → pelea).
- El autotest de combate fuerza "agresivo" en el salvaje (Oddish ahora es tímido y huiría).
- Autotest `--autotest-wild-ai` (12 chequeos); vitrina `--showcase-wild-ai`.

## Etapa 3 — Entorno reactivo (2026-10-22)
- **El fuego NO interactúa con el entorno** (decisión del usuario, 2026-10-22: no le gustó que queme el pasto).
  Lo único que va a prender en el futuro son las **esporas que deje en el piso un ataque Espora** de los tipo
  planta (todavía no existe; ni Polvo Veneno ni Somnífero), que **arderán unos 3 s** quemando a quien esté adentro.
  Se sacaron los estados ardiendo/quemado, las reglas de fuego (prender, vapor, derretir, apagar) y la quema del
  árbol cortable. El código de llamas de `EnvironmentGrid` (`Look.FIRE`) quedó disponible para eso.
- **Estado por celda** (`EnvironmentGrid`, uno por zona, lo crea `ReactionSystem` al primer uso y se va con la
  zona): `data/environment/states/*.tres` (`EnvCellState`): **mojado** (15 s, Empapa), **congelado** (10 s; sobre
  el agua saca el tile de agua = **puente de hielo**, no se derrite con alguien encima), **electrificado** (1,2 s,
  Paraliza; al terminar vuelve al estado anterior). Visual: charcos, hielo y chispas.
- **Reglas** (`data/environment/reactions/*.tres`, `ReactionRule`, por prioridad): hielo congela agua y suelo
  mojado · eléctrico corre por el agua y lo mojado (propagación instantánea, hasta 80 celdas) · agua moja el suelo.
- `ReactionSystem` (en el mundo) escucha `Events.element_impact`. Los **proyectiles también tocan las celdas por
  las que pasan** (cada 14 px): el agua moja su camino.
- **Roca frágil**: se rompe con una embestida (`Events.env_object_struck` desde los estados dash/lunge;
  `EnvObject.break_power` = 30 de potencia): Embestida Ígnea, Ataque Rápido, Arañazo... abren el rincón de Ruta 1.
- `World.tags_at()` devuelve los tags con el estado aplicado.
- Autotest `--autotest-env` (17 chequeos con el mapa real, incluido que el fuego no haga nada); vitrina
  `--showcase-env` (puente de hielo y descarga en el lago).
- Pendiente: ataque Espora + esporas que arden, crecido (planta), que la IA salvaje evite lo electrificado.

## Etapa 2c — Título, guardado, equipo y movimientos (2026-10-22)
Pedido del usuario en `docs/PROMPT_MENU_GUARDADO_EQUIPO.md`. Decisiones (todas las recomendadas):
**learnset = kit al inicio + extras** (los 4 del kit en Nv. 1, 1, 3 y 5; 2 extras por especie al nivel de
FRLG), **ranuras libres**, **guardado solo manual**, debug **F9 con `-- --debug`** (o desde el editor).
- **Título** (`scenes/ui/title_screen.tscn`, escena principal): Continuar (con resumen: retratos, nivel del
  líder, zona, tiempo y fecha), Nueva partida (confirma si ya hay guardado) y Salir. Esc en la elección de
  inicial vuelve al título.
- **Guardado** (`SaveManager`, autoload): un slot `user://saves/slot_1.json`, JSON con ids y `version`,
  escritura atómica (`.tmp` + renombrar), tolerante a JSON roto o especies/movimientos que ya no existen.
  Guarda equipo (especie, nivel, EXP, IV/EV, PS, movimientos equipados, apodo/naturaleza vacíos), activo,
  Pokébolas, opciones, tiempo jugado y **posición del entrenador** (World aparece ahí). No se guarda en combate.
- **Menú de pausa** (Esc, `PauseMenu`): Equipo, Guardar, Opciones (dificultad y modo práctica), Volver al
  título (pregunta si guardar) y Cerrar. Pausa el mundo; no se abre en combate.
- **Equipo** (`PartyScreen`): 6 casillas (vacías con "—"), activo marcado; acciones Ver ficha / Poner como
  activo / Mover arriba-abajo. `GameState.MAX_PARTY = 6`, `add_to_party()` (rechaza el 7°), `set_active()`
  (no a un debilitado), `move_in_party()`.
- **Ficha** (`SummaryScreen`, Tab cambia de pestaña): Estadísticas (estilo, mecánica de firma con descripción,
  PS, EXP, 6 stats con base/IV/EV y barra, velocidad en px/s) y Movimientos (4 ranuras + learnset completo,
  bloqueados con su nivel; equipar = Enter en movimiento y en ranura; Supr vacía; nunca sin movimientos ni
  repetidos). Los cambios re-sacan al activo (`Events.equipment_changed`).
- **Modelo**: `LearnsetEntry` + `SpeciesData.learnset` (generado por `tools/build_learnsets.gd`; sin learnset
  hay uno de compatibilidad), `CreatureInstance.equipped_moves` (+ `learned_moves`, `can_equip`, `equip`,
  `default_equipment`, `to_dict`/`from_dict`), `MoveUser.setup(instance)`, `DB.all_moves` / `move_key` /
  `move_by_id` (las claves de los kits son `<pokémon>/<archivo>` porque varios kits comparten ids).
  `GameState.grant_exp()` sube de nivel, aprende ("¡Aprendió X!", `Events.move_learned`) y equipa solo si
  hay ranura libre.
- **12 ataques oficiales nuevos** para los extras: Cuchillada, Ataque Ala, Persecución, Rayo Solar, Ácido
  (adaptación: envenena 30%), Rueda Fuego, Rayo, Hidrobomba, Derribo, Golpe Cuerpo, Rayo Hielo, Viento Hielo
  (adaptación: ralentiza siempre). El fetcher ahora también baja `learnset_frlg` de cada especie.
- Autotests: `--autotest-save` (17 chequeos), `--autotest-party` (12); vitrina `--showcase-menus`.

## Decisiones tomadas (no volver a preguntar)
- Generación: **las 3 primeras regiones (Kanto, Johto, Hoenn: 386 Pokémon)**, nombres y sprites reales
  (antes solo Kanto; lo amplió el usuario el 2026-10-22).
- Control: **entrenador + Pokémon**. Explorás con el entrenador (Red) y tu Pokémon te sigue.
- Mundo: **zonas conectadas sin corte** (streaming), región continua; solo el borde exterior tiene árboles.
- Arte: **pixel art GBA (FireRed, del decomp pret) + efectos modernos**; renderer **Forward+**
  (PCs con placa decente). Pokémon con sprites PMD (8 direcciones).
- Entrar en combate (Etapa 2): cuando un salvaje te detecta o lo atacás, **tomás control directo del
  Pokémon** (cámara se centra en él); al terminar o alejarte volvés al entrenador. También se puede sacar
  al Pokémon a pelear con una tecla.
- **Estados alterados** (quemado, paralizado, congelado...) entran en la **Etapa 2**.
- Subir a GitHub al cerrar cada etapa.
- **Stats oficiales** (2b): stats base, experiencia, curvas y tasa de captura de PokeAPI; fórmula oficial
  de stats y de daño; tabla de tipos oficial (se sumaron veneno, volador y siniestro).
- **Por ahora todos los Pokémon tienen stats máximos para su nivel** (IV 31, EV 0, naturaleza neutra).
  **Más adelante (Etapa 6)** cada Pokémon capturado tendrá IVs al azar según la suerte; uno con stats
  perfectos tiene que ser **sumamente difícil** de conseguir.
- Los Pokémon **se mueven según su stat de Velocidad** (sube con el nivel, con rendimiento decreciente).
- Los ataques **no deben salir tan seguido**: energía con regeneración lenta (12/s) y recargas que crecen
  con la potencia.
- El fuego tiene que verse **rojizo**, no amarillo ni demasiado luminoso; las luces dinámicas, suaves.

## Estado actual
- 9 zonas de 48×32 (`tools/build_world.gd` → `REGION`/`BIOMES`): Bosque Profundo, Bosque Verde,
  Lago Celeste / Pradera Florida, **Ruta 1 (inicio)**, Colinas Rocosas / Humedal, Pradera Sur, Arboleda.
- Ruta 1 tiene un rincón de flores cerrado por rocas con 2 rocas frágiles (puzzle para la Etapa 3).
  Bosque Verde tiene un arroyo con vados donde lo cruzan los caminos (candidato a puente de hielo).
- 14 especies (`data/species`; se sumaron Pikachu y Seel), 21 ataques (`data/moves`), 9 tipos
  (fuego, agua, planta, normal, eléctrico, hielo, veneno, volador, siniestro), 3 estados (`data/status`:
  quemado, paralizado, congelado).

### Stats oficiales (Etapa 2b)
- Datos en `data/source/official.json` (PokeAPI) → `tools/apply_official_data.gd` → `.tres`.
  Detalle de fórmulas y adaptaciones al tiempo real en `CLAUDE.md` ("Stats, daño y progresión").
- Ejemplos verificados por `--autotest-stats`: Pikachu Nv.50 = PS 110 / At 75 / Def 60 / AtEsp 70 /
  DefEsp 70 / Vel 110; curvas de EXP a Nv.100 (1.000.000 medium, 1.059.860 medium-slow, etc.).
- Velocidad de movimiento a Nv.5 entre ~68 px/s (Oddish) y ~80 (Pikachu/Poliwag); a Nv.50 ~114-141.
- Recargas: Ascuas 1,45 s / 16 EN, Lanzallamas 2,35 s, áreas 3-5,5 s, Protección 8 s.
- Visual: fuego rojizo (centro naranja), luces dinámicas suaves; quemado con llamitas que suben, luz
  parpadeante y tinte naranja; paralizado con chispas; congelado dentro de un bloque de hielo.

### Combate (Etapa 2)
- **Modo combate** (`scripts/combat/combat_director.gd`): un salvaje te detecta (o apretás **F**) → controlás
  al Pokémon (WASD, mouse, 1-4/clic, espacio esquiva), la cámara (`CameraRig`) lo sigue y el entrenador queda
  quieto. Termina si no quedan enemigos cerca por 1,5 s, si tu Pokémon se debilita o con F. Si lo sacaste con
  F sin enemigos, no termina solo.
- **Componentes de la criatura** (`scenes/creatures/creature.tscn`): `Health`, `StatusEffects`, `MoveUser`
  (recargas/energía), `Hurtbox` (capa 6 aliada / 7 salvaje), `DashHitbox`. Estados: idle, follow, controlled,
  cast, dash, stunned, fainted, wander, chase, attack, flee.
- **Ataques**: `Projectile` (choca con paredes, capa 1), `AreaEffect`, embestida (hitbox durante el dash),
  escudo. La carga (cast time) la interrumpe un golpe fuerte (knockback ≥ 200). Daño en `Damage` (escala 0.4).
- **Estados alterados**: quemado (daño por segundo, -25% ataque, lo cura el agua), paralizado (lento +
  inmovilizado al azar), congelado (no actúa, lo derrite el fuego).
- **Feedback** (`scripts/fx/combat_feedback.gd`): números de daño (súper eficaz en grande), hitstop, temblor,
  chispas, luces dinámicas en ataques de fuego/eléctrico/hielo, destello HDR al recibir golpes, estelas al esquivar.
- `Events.element_impact(element, pos, radius)` ya se emite en cada impacto: **es la entrada del sistema de
  entorno reactivo de la Etapa 3**.
- **Provisorio** (lo reemplazan etapas futuras): `WildSpawner` (salvajes en el pasto alto según bioma; Etapa 4)
  y regeneración fuera de combate de 2%/s con vuelta al 30% (Etapa 6: Centros Pokémon / objetos).

### Pruebas automáticas
`--autotest` (recorre las 9 zonas), `--autotest-combat` (3 peleas: Charmander/Bulbasaur, Pikachu/Squirtle,
Seel/Oddish), `--autotest-input` (simula teclas reales y verifica el spawner), `--autotest-stats` (stats y
EXP contra valores oficiales), `--showcase` (vitrina visual de los 3 estados, para renderizar). Correr siempre con
`--quit-after 60000` como límite por si algo se cuelga.

## Próximo paso concreto
1. **Entrenadores vivos** (`docs/PLAN_ENTRENADORES.md`): E-0 hecha; seguir con E-1 (combate contra entrenador
   con cambio de Pokémon). La "mente" del entrenador
   (órdenes gritadas + perillas + memoria) usa el mismo `CombatBody` que los salvajes.
2. Salvajes, pendiente: "en grupo" (si atacás a uno vienen los demás), aprovechar la mecánica de firma
   (Pidgey sube al aire, Vulpix busca quemados).
3. Spawns por hora (las tablas por zona y bioma ya están: se arman en el editor de mapas, pestaña Salvajes).

## Pendientes de pulido (anotados)
- Esquinas interiores donde se cruzan caminos (quedan cuadradas).
- Lagos solo rectangulares (faltan esquinas interiores de agua).
- Bosques podrían ser más densos/variados (el tileset de Bosque Verde ya está en la paleta del editor).
- Reflejos de personajes en el agua; sombras de árboles más elaboradas.
- Verificar visualmente el pasto alto tapando las piernas.
