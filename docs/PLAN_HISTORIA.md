# Plan de historia — de Pueblo Paleta a la Medalla Roca

> Pedido del usuario (2026-10-23): "empezar a ponerle historia… la misma historia hasta Ciudad Plateada como es en
> Pokémon Rojo Fuego. Hacé un plan de esto antes de actuar." Este documento es ese plan. **Todavía no se
> implementó nada**; las decisiones de la sección 4 ya las tomó el usuario.

## 1. Lo que ya existe y se reusa
- **Mundo**: los mapas reales de FireRed de Pueblo Paleta a Ciudad Plateada, con puertas e interiores (casa del
  jugador y del rival, Laboratorio de Oak, Centros y Tiendas, gimnasios, museo, garitas). Ver PROGRESO, "Región
  de FireRed".
- **Salvajes** con las tablas de FireRed, **24 Pokémon con kit** (todo lo que aparece hasta Plateada, más los
  iniciales y **Onix como jefe**).
- **Entrenadores vivos E-0**: `TrainerData`, `TrainerNPC` (sprite de FireRed, te mira, bloquea el paso),
  `TrainerDirector`, `TrainerState` guardado. Falta **E-1: el combate contra entrenadores** (desafío, equipos,
  cambio con Tab, fin y EXP) — **la historia lo necesita** (rival, bosque, gimnasio).
- Captura, Mochila, Caja, Pokédex, guardado.

## 2. La historia de FireRed hasta la Medalla Roca (lo que hay que contar)
Textos propios en español rioplatense (contando lo mismo; no se copian los diálogos del juego).

| # | Lugar | Qué pasa | Bloqueo que se abre |
|---|---|---|---|
| 1 | Casa del jugador | Despertás en tu cuarto; en la PC hay una Poción; mamá te despide abajo. | — |
| 2 | Pueblo Paleta → borde de Ruta 1 | Al pisar el pasto alto, **Oak te frena** ("¡Esperá! Es peligroso…") y te lleva al laboratorio. | No podés entrar al pasto sin Pokémon |
| 3 | Laboratorio de Oak | **Elegís inicial** de las 3 Pokébolas de la mesa; el rival (Azul) elige el de tipo ventajoso. | — |
| 4 | Laboratorio | **1ª pelea contra el rival** (Nv. 5, su inicial). Se puede perder (sigue la historia igual, como en FRLG). | — |
| 5 | Ruta 1 | Salvajes (Pidgey, Rattata). Un vendedor te regala una Poción de muestra. | — |
| 6 | Ciudad Verde, Tienda | El vendedor te da el **Paquete de Oak**. El viejo dormido en la calle tapa el camino al norte; el gimnasio está cerrado. | Norte de Ciudad Verde cerrado |
| 7 | Laboratorio | Entregás el paquete: Oak te da la **Pokédex** (hoy ya la tenés desde el inicio → pasa a recibirse acá) y **5 Pokébolas**. La hermana del rival (Dalia) te da el Mapa. | Se abre el norte de Ciudad Verde |
| 8 | Ciudad Verde | El viejo, ya despierto, te enseña a capturar (demostración con un Weedle). | — |
| 9 | Ruta 22 | **2ª pelea contra el rival** (Pidgey Nv. 9 + inicial Nv. 9). | — |
| 10 | Ruta 2 → Bosque Verde | Salvajes de bichos y Pikachu; **5 Cazabichos** con Weedle/Caterpie/Metapod/Kakuna (Nv. 6-9); objetos del bosque (Antídoto, Pokébola, Poción). | — |
| 11 | Ciudad Plateada | Museo (fósiles; entrada 50). Un chico no te deja ir a la Ruta 3 hasta que ganes la medalla. | Ruta 3 cerrada (no existe todavía) |
| 12 | Gimnasio de Plateada | **Campista** (Geodude Nv. 10 + Sandshrew Nv. 11) y **Brock** (Geodude Nv. 12 + **Onix Nv. 14, jefe**). Medalla Roca + MT39 Tumba Rocas. | Fin del capítulo |

## 3. Fases (cada una deja el juego ejecutable, con su autotest)

| Fase | Contenido | Depende de |
|---|---|---|
| **H-0** | **Base de la historia**: `StoryFlags` en GameState (banderas, se guardan); caja de diálogo (texto que se escribe, nombre del que habla, Avanzar); **NPC que habla** (`StoryNPC` con diálogo en .tres, condiciones por bandera, puede dar objetos o mover banderas); tecla de interactuar; **disparadores** de zona (pisar una celda dispara un evento, ej. Oak en el pasto); **bloqueos** (NPC o barrera que se va con una bandera). Centro Pokémon cura (enfermera), mamá cura en casa. | — |
| **E-1** | **Combate contra entrenadores** (del plan de entrenadores): visión y "¡!", desafío, equipos de hasta 6 que salen de a uno, cambio con Tab, premio/EXP, perder = volver al último Centro curado. Entrenadores de historia = **fijos** (sin memoria); el interruptor de "entrenadores vivos" sigue siendo aparte. | H-0 |
| **H-1** | Pueblo Paleta y Laboratorio: casa, Oak te frena, **elección del inicial en el laboratorio** (reemplaza la pantalla actual de elección para una partida nueva), rival elige el ventajoso, 1ª pelea. | H-0, E-1 |
| **H-2** | Paquete de Oak: Tienda de Ciudad Verde, entrega, Pokédex + Pokébolas, Dalia y el Mapa, viejo que bloquea y tutorial de captura. | H-1 |
| **H-3** | Ruta 22: 2ª pelea contra el rival. | E-1 |
| **H-4** | Bosque Verde: los 5 Cazabichos (equipos de FRLG) y los objetos fijos del bosque. | E-1 |
| **H-5** | Ciudad Plateada: museo, chico que bloquea la Ruta 3, **gimnasio**: Campista y **Brock con Onix jefe** (presentación de jefe: barra de vida grande arriba, cámara, música/temblor), medalla, MT39, tarjeta de entrenador con medallas. | E-1 |
| **H-6** | Pulido: autotest que juega el capítulo entero con un bot (de despertar a la medalla), textos revisados, guardado en cualquier punto. | todo |

Orden recomendado: H-0 → E-1 → H-1 → H-2 → H-3 → H-4 → H-5 → H-6.

### Avance
| Fase | Estado |
|---|---|
| H-0 | ✅ 2026-10-23 (ver abajo) |
| E-1 | ✅ 2026-10-23 (combate en arena, `docs/PLAN_ENTRENADORES.md`) |
| H-4 / H-5 (entrenadores) | ✅ adelantado con E-1: los 5 Cazabichos del bosque, el Campista Liam y **Brock** (Geodude 12 + Onix 14 jefe, arena de gimnasio épica, Medalla Roca = bandera `medalla_roca`). Falta el resto de esas fases (objetos fijos del bosque, museo, chico de la Ruta 3, MT39, tarjeta). |
| H-1 | ✅ 2026-10-23: partida de historia en tu cuarto sin Pokémon (`GameState.new_story`, botón "Empezar la historia"; las tarjetas = modo libre), mamá te manda al laboratorio, disparador "Oak te frena" (salida norte de Pueblo Paleta → te lleva al laboratorio), Oak/rival/3 Poké Balls en el laboratorio (Sí/No con `DialogBox.ask`; el rival se lleva el ventajoso con `rival_<especie>`), Oak no te deja irte sin Pokémon, el rival te desafía al salir (`battle_no_blackout`: si perdés seguís ahí curado). Autotest `--autotest-story-h1` (17 chequeos). |
| H-2 | ⏭️ Siguiente (Paquete de Oak, Pokédex, Dalia, viejo de Ciudad Verde) |

**H-0 (cómo quedó):**
- **Banderas**: `GameState.story_flags` (`has_flag` / `set_flag`, avisa `Events.story_flag_changed`), se guardan con
  la partida. `GameState.heal_party()`.
- **Datos** (`scripts/resources/`): `NpcData` (persona: zona, celda, sprite, mirada, `show_if`/`hide_if` para
  bloqueos que se abren con una bandera, `talks`), `NpcTalk` (condiciones `requires`/`forbids`, líneas, y al
  terminar `set_flags`, `give_items`, `heal`), `StoryTrigger` (pisar un rectángulo de celdas abre una
  conversación; `once`, `push_back` para bloquear con aviso). En `data/story/npcs/` y `data/story/triggers/`; `DB.npcs`
  y `DB.story_triggers`.
- **Personas reales de FireRed**: `tools/import_frlg_maps.py` ahora exporta los NPC de cada mapa (`npcs` en
  `data/world/frlg_maps.json`, celda ya agrandada). `tools/fetch_npc_sprites.py` baja de pret sus sprites con su
  paleta → `art/pret/characters/<gfx>.png` + `npcs.json`. `tools/build_story_npcs.py` arma **67 personas** con
  diálogos propios en rioplatense (vecinos, ayudantes de Oak, empleados, guías de gimnasio, museo...). Los
  entrenadores, Oak, el rival, el viejo del tutorial, Brock, etc. llegan en sus fases.
- **Mundo**: `StoryDirector` (nodo del mundo) saca/guarda las personas según su zona y banderas, revisa los
  disparadores, abre las conversaciones (traba al entrenador, oculta el HUD) y aplica los efectos. `StoryNPC`
  (`scenes/characters/story_npc.tscn`): sprite de FireRed, bloquea el paso, te mira, nombre al acercarte.
  `DialogBox`: globo abajo con nombre y texto que se escribe; E/Espacio/Enter/clic avanza.
- **E contextual**: `PlayerItems` pregunta primero a `StoryDirector.try_interact()` (hasta 36 px, alcanza por arriba
  de un mostrador); si no hay nadie, lanza la Pokébola.
- **Curar**: las enfermeras de los Centros (Verde y Plateada) y mamá curan al equipo (vida y estados).
- El empleado de la Tienda en Ruta 1 regala una Poción una sola vez (bandera `muestra_pocion`).
- Autotest `--autotest-story` (19 chequeos, incluye el cambio de Pokémon); vitrina `--showcase-story`.

**Cambio de Pokémon con 1-6** (pedido del usuario durante H-0): las teclas 1-6 sacan al Pokémon de ese lugar del
equipo (en el orden del equipo), también en combate: el nuevo sale donde estaba el anterior, sigue la pelea y los
rivales lo atacan a él. 1,5 s de recarga entre cambios; no se puede sacar a uno debilitado
(`CombatDirector.switch_to`). Los números ya no disparan ataques (siguen Clic, Clic der., Q y R).

## 4. Decisiones del usuario (2026-10-23, no volver a preguntar)
1. **Inicial en el laboratorio** como en FRLG (Oak te frena en el pasto, elegís una de las 3 Pokébolas de la mesa;
   la pantalla actual de elección queda solo para el modo práctica).
2. **E contextual**: si hay alguien o algo al lado, habla/interactúa; si no, lanza la Pokébola.
3. **Entrenadores de la historia fijos** como en FRLG (equipos y niveles de la guía, IA de combate normal); el
   rival suma la memoria de "entrenadores vivos" más adelante.
4. **Perder** = volver al último Centro Pokémon (o a casa) con el equipo curado, sin perder dinero (no hay dinero).

Sin confirmar todavía (se usa la opción recomendada salvo que el usuario diga otra cosa):
5. Brock: Onix jefe (kit v4) con presentación de jefe, niveles de FRLG.
6. La Pokédex se recibe de Oak al entregar el paquete (hasta ahí, vacía/no disponible).
