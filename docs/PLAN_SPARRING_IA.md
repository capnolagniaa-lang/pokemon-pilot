# Plan: entrenar la IA peleando contra vos ("sparring")

Pedido del usuario (2026-11-08): la IA toma decisiones muy al azar, se te viene encima aunque le estés disparando, y con
el botón de esquivar no hace sidesteps de tus ataques. Quiere **humanizarla** entrenándola con peleas contra él.
Este plan sigue al programa "IA humana" de `docs/PLAN_IA.md` (H-1 hecha; H-2 a H-4 propuestas).

## 1. Por qué pasa hoy (lo que dice el código)

**Se te viene encima aunque le dispares** (`creature_attack.gd::physics_update`):
- Cada 0,4-0,9 s elige un modo: `approach` si está más lejos que 1,3 × su distancia ideal, si tus fuertes están en
  recarga (`window_open`) o si no tiene tiro limpio; `retreat` solo los de distancia si están muy cerca; si no, `strafe`.
- Los cuerpo a cuerpo (`_melee_mode`) entran a pegar cada vez que `_attack_timer` baja, salen 0,4-0,65 s y vuelven.
- **Nada mira si le están pegando mientras se acerca.** No existe "me comí tres disparos de frente: dejo de venir de
  frente, rodeo o espero tu recarga". El único freno es `low_hp_plan` (vida baja → huir / cubrirse / jugarse todo).
- El azar está repartido en muchos lados (`randf` en el modo, en `_strafe`, en el ritmo, en `smarts`) sin un "plan"
  que los ate: por eso se siente random. H-2 ("plan de varios segundos") apunta a esto y sigue sin hacerse.

**Esquiva, pero no hace sidesteps** (`combat_body.gd::try_dodge`):
- Solo reacciona a **proyectiles** (`Projectile` con velocidad hacia ella, a menos de `SEE_SHOT`), con el tiempo de
  reacción de la dificultad y una probabilidad (`dodge_chance` 0,3 en Normal + `dodge_bonus`). Y la reacción es
  siempre **el botón de esquivar** (rodar perpendicular).
- **No reacciona a nada más**: ni a una carga tuya (estado `cast`), ni a un canalizado que viene barriendo, ni a una zona
  marcada en el piso, ni a una embestida o golpe cuerpo a cuerpo que estás por soltar. Tampoco existe el **sidestep**
  (moverse un par de celdas al costado sin gastar el esquive), que es lo que hace una persona la mayoría de las veces.
- La lectura de IA-7 (`read_dodge_due`) esquiva "antes" solo si repetís el mismo ataque 4 de 6 veces.

En una frase: la IA tiene **puntería y elección de ataque** razonables (IA-1 a IA-7, H-1), pero el **movimiento** sigue
siendo el de la Etapa 4a: modos fijos + azar, sin leer la amenaza ni aprender de la pelea.

## 2. Qué significa "entrenarla con peleas contra mí"

Hay tres cosas distintas que se pueden sacar de tus peleas, de la más simple a la más ambiciosa:

| | Qué se aprende de vos | Cómo lo usa la IA | Costo |
|---|---|---|---|
| **A. Medir y ajustar** | Dónde se equivoca la IA contra una persona (golpes que se comió viniendo de frente, ataques tuyos que no esquivó, esquives al vacío, PP gastados en nada). | Un informe por pelea y parámetros nuevos (cuánto respeta tus disparos, cuánto sidestep, cuánta paciencia) que se ajustan con los números, por dificultad y por especie. | Bajo. Es lo que ya se hace con la batería de balance, pero con vos adentro. |
| **B. Imitarte** | **Qué hacés en cada situación**: distancia, qué está haciendo el rival (cargando, disparando, en recarga, pegado), tu vida y tus recargas → tu acción (acercarte, alejarte, rodear a un lado, sidestep, esquivar, atacar con cuál). | Una **tabla de situaciones → acciones** con frecuencias (`data/ai/politica_jugador.json`). En vez de `randf()`, el movimiento de la IA sale de "qué haría el jugador acá" (sampleando la tabla), mezclado con las reglas que ya hay según la dificultad. | Medio. Es lo que más la humaniza: hereda tus ritmos, tus sidesteps, cuándo entrás y cuándo esperás. Sin redes neuronales: una tabla discreta alcanza y se puede leer y corregir a mano. |
| **C. Que gane más** | Nada de vos: se optimiza con IA contra IA (la batería `--autotest-balance`, 2000 peleas) buscando parámetros que ganen más. | Parámetros más fuertes. | Alto, y **no** la hace más humana: la hace más fuerte y más rara. Se descarta para esto. |

**Recomendación: A + B, en ese orden**, y arreglar primero las dos cosas concretas (amenaza al acercarse y sidestep),
porque la imitación necesita que la IA *pueda* hacer sidesteps y retroceder bajo fuego: hoy no tiene esas acciones.

## 3. Fases

Decisiones del usuario (2026-11-08): S-0 primero; la imitación (S-3) solo para entrenadores y líderes (los salvajes
mantienen su temperamento y heredan solo S-0); grabar en sparring y en las peleas normales, con el ajuste apagado por defecto.

| Fase | Qué | Cómo se prueba |
|---|---|---|
| **S-0. Acciones que faltan** ✅ (2026-11-08) | `CombatBody.sidestep(dir)`: paso al costado de 1-2 celdas sin gastar el esquive (es moverse, con prioridad sobre el modo). `threat()` en la mente: qué amenaza viene (proyectil en línea, carga apuntándote, canalizado barriendo, zona marcada encima, cuerpo a cuerpo a punto de salir) con su dirección y tiempo. `try_dodge` pasa a `react_to_threat`: según la amenaza y la dificultad elige **sidestep** (lo común), **esquivar** (lo fuerte o lo que no se puede evitar caminando) o nada. **Aprender a no comerse disparos**: si en los últimos ~3 s recibió ≥ 2 golpes viniendo de frente (`_mode == approach`), cambia a rodear o a esperar tu recarga (`window_open`), con un emote. | Test nuevo `--autotest-ai-threat`: un bot dispara en línea y la IA sale de la línea sin gastar el esquive; carga apuntada → se corre; zona marcada → sale del área; 3 disparos de frente → deja de venir de frente. Bot vs IA: golpes recibidos viniendo de frente bajan. |
| **S-1. Grabar sparring** ✅ (2026-11-08) | Modo sparring (desde la consola GM `sparring <especie> [nivel]`, o un ajuste "Grabar peleas" en Opciones que graba también las peleas de entrenador normales): cada pelea contra vos se guarda en `user://sparring/<fecha>.json`: por cuadro (10 por segundo) la **situación** de cada lado (posición, distancia, estado de la máquina, vida, PP, recargas, proyectiles en el aire, amenaza detectada) y las **acciones** (tu input: dirección, esquive, ranura, apuntado; de la IA: modo, slot, sidestep/esquive) y los **hechos** (golpe, quién lo dio, si el que lo recibió venía de frente, esquive con o sin ataque que evitar). Tecla de marca (por ejemplo F8) para "esto fue tonto": guarda la marca con los últimos 5 s. | `--autotest-sparring`: una pelea con bot graba el archivo y tiene las columnas esperadas; el tamaño por minuto es razonable. |
| **S-2. Informe** | `tools/sparring_report.py` (Python sin dependencias): lee los JSON y escribe `docs/SPARRING_INFORME.md`: por pelea y en total, los **errores de la IA** (golpes recibidos viniendo de frente, ataques tuyos telegrafiados que no evitó, esquives al vacío, PP gastados en ataques que no llegaron, segundos quieta), tus **patrones** (distancia típica por especie, cuánto sidestep hacés, cuándo entrás), y tus marcas F8 con lo que pasaba. Es lo que se mira para ajustar los parámetros de S-0 por dificultad. | Correrlo sobre las grabaciones del test. |
| **S-3. Política imitada** | `tools/sparring_policy.py` discretiza la situación (distancia en 5 bandas, qué hace el rival en 6 estados, tu vida en 3, tus fuertes listos o no, amenaza sí/no y de qué lado) y cuenta tus acciones → `data/ai/politica_jugador.json` (situación → frecuencia de cada acción: approach/retreat/strafe izq/der/sidestep/dodge/attack). `MovementPolicy` en el juego: en `creature_attack` el modo y los sidesteps salen de la tabla cuando hay datos suficientes para esa situación (≥ N muestras); si no, las reglas de hoy. Mezcla por dificultad: Fácil 30 % tabla, Normal 60 %, Difícil 85 % (y los líderes siempre tabla). Especies cuerpo a cuerpo y de distancia usan tablas separadas (tu forma de jugar cambia con lo que llevás). | `--autotest-ai-policy`: con una tabla armada a mano la IA hace lo que dice la tabla; con la tabla real, bot vs IA mide que no empeore el porcentaje de victorias de la batería de balance más de X puntos (humana, no tonta). Y jugarlo. |
| **S-4. Ciclo** | Jugás 10-20 peleas → informe → política nueva → se compara contra la anterior (la batería y tus marcas) → commit del JSON. Se repite cada tanto. La política viaja en el zip como cualquier dato (no se aprende en la PC de los amigos). | — |

Después, si gusta: H-2 (plan de varios segundos) y H-4 (ánimo) sobre la misma grabación, porque los datos de sparring
también dicen cuánto duran tus ráfagas y tus respiros.

### S-0, cómo quedó
- **`TacticalMind.threat()`**: la amenaza más urgente que viene, con lo que una persona ve: disparo en línea (`shot`: la
  línea del proyectil pasa por el cuerpo), carga apuntada (`cast`: el telegrafiado del rival, línea o círculo, con el
  tiempo que le falta + el vuelo), zona (`zone`: la marca del Rayo con `SkyStrike.time_left()`, o una nube en la que
  está parado), chorro (`beam`: el cono del canalizado, que cuelga del que lo tira) y golpe cuerpo a cuerpo saliendo
  (`melee`: estados `step`/`lunge` mirándote a menos de 70 px). Devuelve `eta`, hacia dónde salir (`out`), cuánto
  correrse (`clear`) y si es fuerte (`strong`: empuje ≥ STAGGER o potencia ≥ 80). El cuerpo (hurtbox) está 8 px arriba
  de los pies, igual que de donde salen los disparos: lo que vuela se mide ahí; lo del piso, en los pies.
- **`CombatBody.try_dodge()`** (mismo nombre de antes) decide **una vez por amenaza** al verla (esquivar con
  `dodge_chance` + bonus; dar el paso con `SIDESTEP_BASE` 0,25 + eso × 1,5) y actúa pasado el tiempo de reacción: con
  tiempo de sobra, **paso al costado** (`sidestep`: camina `clear` px perpendicular, 16-40 px, sin gastar el esquive, y
  se puede dar tambaleando); lo fuerte que viene justo (menos de 2,5 pasos de tiempo) o lo que no se alcanza caminando
  se **rueda**, recién cuando faltan `DODGE_WINDOW` 0,26 s (antes se desperdiciaba la invulnerabilidad); arrinconado
  (sin lugar para el paso) rueda; si no puede rodar, el paso igual. En Fácil (sin esquive) da el paso el 15 % de las veces.
- **Bajo fuego** (`TacticalMind.wary()`, vive en la mente para contar también los golpes que recibe en plena
  embestida): 2 golpes del rival en 3 s mientras venía hacia él (velocidad hacia el rival) → se cuida 2,5-4,5 s: los de
  distancia rodean en vez de acercarse; los de cuerpo a cuerpo esperan a `WARY_SPACING` 95 px de costado, no se tiran de
  lejos (la embestida es venir de frente) y entran recién con tus fuertes en recarga (`strong_on_cooldown`, sin contar el
  respiro de después de cada disparo) o con vos cargando / canalizando / aturdido; cuando entran, en zigzag. Ya pegado
  pelea normal (irse sería meterse en la línea de tiro).
- Test `--autotest-ai-threat` (busca un tramo despejado del pueblo y arma 6 escenarios).
- Lo que **no** cambió: puntería, elección de ataque, PP, temperamentos, el esquive leído de IA-7.

### S-1, cómo quedó
- `SparringRecorder` (`world.sparring`, `scripts/creatures/ai/sparring_recorder.gd`) graba las peleas de arena contra
  entrenadores cuando el ajuste **"Grabar peleas"** está prendido (Esc → Opciones → Ajustes del juego → Sparring;
  `record_fights`, apagado por defecto, se guarda con la partida) o cuando la consola GM arma la pelea con
  **`sparring [arena] [nivel]`** (por defecto el campo; `armed`, se apaga al terminar). No graba salvajes ni online.
- Un JSON por pelea en `user://sparring/<fecha>_<entrenador>.json` (~2 KB por segundo): cabecera (versión, fecha,
  dificultad, arena, entrenador, tu Pokémon con ataques y habilidad, el equipo rival, resultado, duración), **muestras**
  a 10 por segundo (`columns`: tiempo, distancia y, por lado, posición relativa a la arena, velocidad, estado de la
  máquina, vida, PP, ranuras listas como bits, stagger, estados; del rival además el modo del estado de ataque, la
  amenaza que ve y si se está cuidando; proyectiles en el aire), **hechos** (`use` de cada ataque, `slot` con la amenaza
  que había, `hit` con si el que lo recibió venía de frente, `dodge` con la amenaza que había al esquivar, `faint`,
  `send` al salir otro Pokémon, `wary`) y **marcas** (F8, tecla fija como F11: "esto fue tonto", guarda el tiempo).
- Avisos en pantalla al empezar ("Grabando la pelea...") y al terminar ("Pelea grabada: archivo").
- Test `--autotest-sparring`. Lo que sigue: **S-2**, `tools/sparring_report.py` sobre estos archivos.

## 4. Decisiones abiertas (preguntar al usuario)

Resueltas el 2026-11-08 (ver arriba): imitación solo para entrenadores y líderes; se graba en sparring y en las peleas
normales con el ajuste apagado por defecto; S-0 primero. S-0 y S-1 hechas. **S-2 hecha (2026-11-09)** dentro de la Fase 1 de
`docs/IA_AUDITORIA.md`: `tools/sparring_report.py` → `docs/SPARRING_INFORME.md` (peleas con las métricas de `AiFightStats`,
totales, errores de la IA, tus costumbres y tus marcas F8 con los 5 s anteriores). Los JSON pasan a la versión 2 (`metrics` y
hechos `ia` = decisiones del rival). S-3 queda como posible consideración más del cerebro de utilidad (Fase 3).

## 5. Qué no cambia
- La IA **no hace trampa**: la política imitada solo mira lo que una persona vería (sigue el criterio de IA-7).
- Puntería y elección de ataque siguen como están (IA-1 a IA-7, H-1); esto es movimiento y reacción.
- Nada de redes neuronales ni dependencias: tablas discretas en JSON, legibles y editables a mano.
