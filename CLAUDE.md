# Pokémon Pilot — guía para Claude

Juego tipo Pokémon en **Godot 4.7 (GDScript)**: mundo abierto 2D top-down con combate en tiempo real
(estilo Pokémon Reloaded). Proyecto personal para el usuario y sus amigos (no se publica).

**Al empezar una sesión: leé `docs/PROGRESO.md` (sección "Dónde estamos") y
`docs/PLAN_IDENTIDAD_COMBATE.md` (sección "ESTADO VIGENTE")** antes de tocar código. Ahí están las decisiones
ya tomadas (no volver a preguntarlas), lo implementado, las propuestas en discusión y el próximo paso.
Antes de cerrar una sesión larga: actualizar esos dos archivos, commit y push.

Hay **dos planes**:
1. `docs/PROGRESO.md` — plan de etapas del juego (mundo, entorno, IA, clima, captura, gimnasios...).
2. `docs/PLAN_IDENTIDAD_COMBATE.md` — **plan de identidad de combate en tiempo real** (definido por el
   usuario): arquetipos, mecánica de firma y kit propio por Pokémon. Es la dirección del combate: cada
   Pokémon tiene que sentirse distinto de jugar. Tiene su propia tabla de avance (pasos I-0 a I-9).

## Reglas de trabajo (acordadas con el usuario)
- Hablar en **español rioplatense** (voseo).
- Se trabaja **por etapas** (ver `docs/PROGRESO.md`). Al terminar cada una: autotest OK, explicar brevemente
  qué cambió y cómo probarlo, **actualizar `docs/PROGRESO.md`**, commit y **push** a
  `https://github.com/capnolagniaa-lang/pokemon-pilot` (rama `main`).
- **Decisiones de diseño importantes: preguntar antes de elegir** (AskUserQuestion con opción recomendada).
- El juego tiene que quedar **siempre ejecutable**.
- Pokémon de las **3 primeras regiones (Kanto, Johto y Hoenn: N.º 1-386)**, con nombres y sprites reales
  (decisión del usuario 2026-10-22; antes era solo Kanto). Estética: pixel art GBA/DS
  + efectos modernos ("next gen"). Renderer Forward+.

## Cómo correr y probar
Godot está en `C:\Users\Gusti\Documents\claude\tools\godot\` (fuera del repo).
```
G=C:/Users/Gusti/Documents/claude/tools/godot/Godot_v4.7.2-stable_win64_console.exe
$G --headless --path . --import                        # tras crear/cambiar assets o class_name
$G --headless --path . --quit-after 60000 -- --autotest          # camina de Pueblo Paleta a Ciudad Plateada, con puertas ("-> OK"/"-> FALLO")
$G --headless --path . --quit-after 30000 -- --autotest-combat   # 3 peleas manejadas por un bot
$G --headless --path . --quit-after 30000 -- --autotest-input    # simula teclas reales + spawner
$G --headless --path . --quit-after 3000 -- --autotest-stats     # stats/EXP contra valores oficiales
$G --headless --path . --quit-after 3000 -- --autotest-identity  # reglas del plan de identidad (estados, CC...)
$G --headless --path . --quit-after 9000 -- --autotest-kit       # kits: Charmander, Bellsprout, Pidgey, Rattata, Vulpix
$G --headless --path . --quit-after 60000 -- --autotest-kits-v3  # los 10 kits nuevos (v3): ataques + mecánicas
$G --headless --path . --quit-after 90000 -- --autotest-kits-v4  # kits v4 (bichos, Spearow, Mankey, Sandshrew, Onix jefe)
$G --headless --path . --quit-after 60000 -- --autotest-kits-v5  # kits v5 (Staryu, Starmie jefa de Misty, Butterfree, Beedrill, Kadabra, Gyarados)
$G --headless --path . --quit-after 200000 -- --autotest-kits-v6  # kits v6 (Raichu jefe de Surge + Tanda A; lento: `--only <especie>` prueba una sola)
$G --headless --path . --quit-after 200000 -- --autotest-kits-v7  # kits v7 (Tanda B: Clefairy, Jigglypuff, Abra, Goldeen, Magnemite, Meowth)
$G --headless --path . --quit-after 200000 -- --autotest-kits-v8  # kits v8 (Tanda C) + sinergia (`--only sinergia`)
$G --path . --quit-after 360 --write-movie out/f.png --fixed-fps 30 -- --showcase-onix  # el jefe Onix en acción
$G --headless --path . --quit-after 30000 -- --autotest-story  # historia H-0 (banderas, NPC, diálogos, disparadores) + cambio 1-6
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-story  # la enfermera hablando
$G --headless --path . --quit-after 150000 -- --autotest-story-h1  # historia H-1 a H-5 (de tu cuarto a la Medalla Roca)
$G --headless --path . --quit-after 150000 -- --autotest-story-h2  # capítulo 2: Mt. Moon, fósil, rival en Celeste, Puente Pepita, Bill, Misty
$G --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-misty  # Staryu y Starmie en el gimnasio de agua
$G --headless --path . --quit-after 150000 -- --autotest-story-h3  # capítulo 3: MT28, Ticket, rival en el S.S. Anne, Corte, basureros, Surge
$G --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-surge  # la arena eléctrica de Lt. Surge
$G --headless --path . --quit-after 400000 -- --autotest-story-h4  # capítulos 4-8: de la Torre Pokémon al Campeón (todos los hitos)
$G --headless --path . --quit-after 60000 -- --autotest-field      # MO de campo: Surf, Fuerza, Poké Flauta
$G --headless --path . --quit-after 100000 -- --autotest-arena-rules  # combate de arena: estilos, combos (apagados), cráteres, salto, superficies
$G --path . --quit-after 650 --write-movie out/f.png --fixed-fps 30 -- --showcase-arena-rules  # Geodude vs Onix (cráteres)
$G --headless --path . --quit-after 60000 -- --autotest-slots      # varias partidas con nombre, sin curación sola, desmayo total, modo de prueba del torneo
$G --headless --path . --quit-after 300000 -- --autotest-tournament  # torneo de Plateada (dinero, copas, rondas, premio)
$G --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-tournament  # el estadio del torneo
$G --headless --path . --quit-after 100000 -- --autotest-arena  # combates contra entrenadores en arena (E-1): Brock, Cazabichos
$G --path . --quit-after 700 --write-movie out/f.png --fixed-fps 30 -- --showcase-arena  # Brock y Onix en el gimnasio épico
$G --headless --path . --quit-after 20000 --script res://tools/build_arenas.gd  # rearma las arenas (pisa las escenas; -- --only <id> arma solo una)
$G --headless --path . --quit-after 5000 -- --autotest-modes     # modo práctica + dificultad de la IA
$G --headless --path . --quit-after 9000 -- --autotest-save      # guardado/carga, learnset, archivos rotos
$G --headless --path . --quit-after 30000 -- --autotest-night-combat  # día/noche D: efectos que no se oscurecen, luces, llama de fuego
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-night-combat  # Charmander tirando Ascuas de noche
$G --headless --path . --quit-after 60000 -- --autotest-equip     # equipar: todo lo aprendido, en plena pelea, al subir de nivel
$G --headless --path . --quit-after 20000 -- --autotest-audio     # sonido: tabla de música, respaldos, archivos propios, gritos, efectos
$G --headless --path . --quit-after 30000 -- --autotest-settings  # Ajustes del juego por partida (EXP, dinero, captura, daño, vida, salvajes, IA...)
$G --path . --quit-after 60 --write-movie out/f.png --fixed-fps 30 -- --showcase-settings  # la pantalla de ajustes
$G --headless --path . --quit-after 30000 -- --autotest-daynight   # día y noche: hora, fases, guardado, hora fija, interiores
$G --path . --quit-after 700 --write-movie out/f.png --fixed-fps 30 -- --showcase-daynight  # 3 zonas × 4 horas (comparar con docs/referencias/iluminacion)
$G --headless --path . --quit-after 30000 -- --autotest-town-map  # Mapa del menú (zonas, entradas, íconos, niebla, objetivo, partidas viejas)
$G --path . --quit-after 90 --write-movie out/f.png --fixed-fps 30 -- --showcase-town-map  # el Mapa abierto
$G --headless --path . --quit-after 9000 -- --autotest-party     # equipo de 6, activo, menú, ficha
$G --path . --quit-after 900 --write-movie out/f.png --fixed-fps 30 -- --showcase-menus  # título, equipo, ficha
$G --headless --path . --quit-after 12000 -- --autotest-env      # entorno reactivo (fuego, agua, hielo, rocas)
$G --path . --quit-after 900 --write-movie out/f.png --fixed-fps 30 -- --showcase-env    # vitrina del entorno
$G --headless --path . --quit-after 30000 -- --autotest-wild-ai  # IA salvaje: temperamentos, apertura, huida, peligros
$G --headless --path . --quit-after 30000 -- --autotest-ai-steer  # IA que rodea obstáculos, tiro limpio, anticipación, Normal
$G --path . --quit-after 400 --write-movie out/f.png --fixed-fps 30 -- --showcase-wild-ai  # un salvaje de cada temperamento
$G --headless --path . --quit-after 20000 -- --autotest-trainers  # entrenadores vivos (E-0: interruptor, NPC, guardado)
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-trainers  # los 3 en Ruta 1
$G --headless --path . --quit-after 30000 -- --autotest-capture   # captura (fórmula, lanzar, escapar, Caja, guardado)
$G --headless --path . --quit-after 30000 -- --autotest-bag       # mochila (curas, ranura rápida, objetos del mapa, botín)
$G --headless --path . --quit-after 20000 -- --autotest-mart      # mercado: Tiendas, precios, comprar/vender, vendedores
$G --headless --path . --quit-after 60000 -- --autotest-evolution # evoluciones: nivel, piedra, frenarla, kit heredado, guardado
$G --path . --quit-after 330 --write-movie out/f.png --fixed-fps 30 -- --showcase-evolution  # Charmander → Charmeleon
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-mart  # pantalla de compra y de venta
$G --path . --quit-after 400 --write-movie out/f.png --fixed-fps 30 -- --showcase-capture  # lanzar bola, Mochila, Caja
$G --headless --path . --quit-after 60000 -- --autotest-pokedex  # 386 especies (datos, salen y usan sus ataques) + Pokédex
$G --path . --quit-after 900 --write-movie out/f.png --fixed-fps 30 -- --showcase-pokedex  # vitrina de la Pokédex
$G --headless --path . --quit-after 30000 -- --autotest-anims    # animaciones de combate (Shoot, Charge, Strike, Hop, Faint, Sleep...)
$G --headless --path . --quit-after 20000 -- --autotest-vfx      # efectos de ataque con sprite (hojas, prioridad, proyectil/área/golpe/impacto)
$G --path . --quit-after 500 --write-movie out/f.png --fixed-fps 30 -- --showcase-vfx  # el impacto de cada tipo y los proyectiles con hoja, de cerca
$G --path . --quit-after 2400 --write-movie out/f.png --fixed-fps 30 -- --showcase-kit  # vitrina de kits
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase   # vitrina de estados
$G --path . --write-movie out/f.png --fixed-fps 30 -- --autotest   # renderiza frames (requiere GPU)
$G --path . --write-movie out/m.png --fixed-fps 30 -- --overview   # vista de toda la región
$G --headless --path . --quit-after 20000 -- --autotest-map-editor  # editor de mapas (ida y vuelta, pinceles, UI...)
$G --headless --path . --quit-after 20000 -- --autotest-stamps      # sellos: sin agujeros, colisión, puertas, deshacer
$G --headless --path . --quit-after 20000 -- --autotest-encounters  # salvajes: tablas, %, áreas pintadas, agua, editor
$G --headless --path . --quit-after 6000 -- --autotest-ledges       # salientes: se bajan saltando, no se suben
$G --headless --path . --quit-after 20000 -- --autotest-bounds      # límites: no se sale al vacío, se llega a todo, sin atajos
python -I -B tools/match_reference.py . --check                    # sellos vs. mapas reales y referencia
$G --path . --quit-after 3000 -- --showcase-stamp-sheets <carpeta>  # hojas de contacto de sellos y paleta (PNG)
$G --path . --quit-after 220 --write-movie out/f.png --fixed-fps 30 -- --showcase-stamps  # todos los sellos pegados
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-map-editor  # capturas del editor
$G --path . -- --map-editor                                        # editor de mapas (herramienta)
python -I tools/pret_import.py art_src/pret art/pret && $G --headless --path . --import && $G --headless --path . --quit-after 20000 --script res://tools/build_world.gd -- --tileset  # reimportar FireRed
$G --path . -- --debug --start-zone ruta1 --start-cell 20,12        # juego directo en una zona (lo usa F5 del editor)
```
El usuario lanza el juego con el acceso directo **"Pokémon Pilot"** del escritorio
(`Godot_v4.7.2-stable_win64.exe --path <proyecto>`, ícono `icon.ico` generado por `tools/make_icon.py`).
**Versión portable para los amigos**: `python -I -B tools/build_portable.py . <Godot_v4.7.2-stable_win64.exe>` (el de
ventana) → `export/PokemonPilot-<fecha>.zip` (`export/` no se sube). En esa versión `OS.has_feature("portable")`:
sin editor de mapas ni F9 (`World.debug_enabled`).
El **editor de mapas** tiene su acceso directo **"Pokémon Pilot — Editor de mapas"** (mismos argumentos +
`-- --map-editor`, ícono `Pokemon.ico`). Si se mueve la carpeta del proyecto o de Godot, hay que recrear los dos.

Para ver resultados visuales: renderizar frames con `--write-movie` a la carpeta scratchpad y leer los PNG.

## Arquitectura (respetarla)
- **Data-driven**: especies, ataques, tipos y tabla de efectividad son Resources `.tres` en `data/`.
  `DB` (autoload) carga todo lo que haya en esas carpetas. Clases en `scripts/resources/`.
- **Autoloads**: `Events` (bus de señales; los sistemas no se llaman entre sí), `DB`, `GameState`,
  `Controls` (input por código, teclas físicas), `Sound` (música por zona/momento, efectos y gritos **por nombre de
archivo** en `audio/musica|efectos|gritos`, tabla `data/audio/musica.json`; escucha Events; guía `docs/AUDIO.md`),
`SaveManager` (**varias partidas con nombre**: una por archivo
  `user://saves/<nombre>.json`; `slot_path` = la actual),
  `Autotest`. Escena principal: `scenes/ui/title_screen.tscn` → `starter_select` → `world`.
- **Meta-juego (Etapa 2c)**: menús con nodos `Control` y el estilo de `UiStyle` (`scripts/ui/`), menú de pausa
  en su propia CanvasLayer (pausa el árbol). En combate se abre reducido (`PauseMenu.BATTLE_ENTRIES`: Mochila, Equipo,
  Cerrar). Las peleas de entrenador arrancan desde una charla (`StoryDirector.busy` toda la pelea): lo que se bloquea
  "en una charla" tiene que dejar pasar `world.arena.active` (cambio 1-6, C, E). `GameState` no conoce archivos: `to_dict`/`from_dict`.
  Movimientos: `SpeciesData.learnset` (de `tools/build_learnsets.gd`) → `CreatureInstance.equipped_moves` →
  `MoveUser.setup(instance)`. La mecánica de firma sigue saliendo del kit de la especie.
- **Máquina de estados** genérica `StateMachine` + `State` (`scripts/core/`); los estados son nodos hijos
  con script (`scripts/characters/states`, `scripts/creatures/states`).
- **Una escena por responsabilidad** (`scenes/`). Entidades usan origen en los pies (y-sort).
- **Capas de colisión**: 1 mundo · 2 agua · 3 jugador · 4 criatura aliada · 5 criatura salvaje ·
  6 hurtbox aliada · 7 hurtbox salvaje · 8 entorno. Hitboxes/hurtboxes con Area2D (desde Etapa 2).
- **Mundo**: región de zonas (`data/world/kanto.tres`, `ZoneEntry` con origen, plaza `hub`, `exits`, `warps` e
  `interior`). Son los **mapas reales de FireRed de toda Kanto** (Pueblo Paleta a la Meseta Añil: 234 zonas, sin
  las Islas Sete ni la Cueva Celeste), agrandados (ver "Pipeline"). Los interiores, cuevas, bosques y la Zona Safari
  van debajo de todo el mundo (desde el resto de Kanto bajaron 258 celdas: `GameState.MAP_VERSION` 2 migra las
  posiciones guardadas).
  `ZoneStreamer` carga/descarga zonas en segundo plano (sin pantallas de carga). `World.tags_at(pos)`.
  Los interiores (casas, Centros, gimnasios, garitas) y el Bosque Verde están lejos, debajo del mundo, y se llega
  por **puertas**: `WarpSystem` (nodo del mundo; puerta sólida = caminar contra ella, transitable = pisarla;
  fundido, aparece al lado de la puerta de destino; `Events.warped`). Interior = sin salvajes ni sombras de nubes.
  `TourPlanner` (tests) arma caminos por celdas cruzando zonas y puertas.
  Límites: `ZoneBounds` (World la agrega a cada zona al cargarla) pone paredes invisibles en todo borde de zona que
  da al vacío (afuera de toda zona); donde empalma con otra queda abierto.
  Salientes (behaviors MB_JUMP_* de FireRed): sólidos, pero `LedgeJumper` (nodo del mundo) los salta caminando
  contra ellos en su dirección; desde el otro lado no se suben. El Pokémon que sigue salta detrás.
- **Zonas** (`scenes/world/zones/*.tscn`): capas `Ground` (z-10), `Water` (shader agua), `Foliage`
  (shader viento), `TreeShadows`, `Overhead` (z 20, copas que tapan), `Objects` (EnvObject con tags).
  La estructura la arma **un solo lugar**: `ZoneBuilder.new_zone_root` (`scripts/world/zone_builder.gd`), que usan
  el generador (`ZoneGenerator`) y el editor de mapas. `Zone.hand_edited` = editada con el editor.
  `MapRules` (`scripts/world/map_rules.gd`): colisión real por celda, celda libre más cercana (World reubica al
  entrenador si la posición guardada quedó en algo sólido) y validaciones de zona.
- **Editor de mapas** (herramienta, no etapa; `scenes/tools/map_editor.tscn`, `scripts/tools/map_editor/`):
  `MapDocument` = la zona real abierta + operaciones con reglas (pinceles por rol, autotile, árboles, objetos,
  balde, copiar/pegar con `TileMapPattern`, `UndoRedo`, guardar con backup). La UI (`map_editor.gd` + paneles)
  no tiene lógica de mapa. Ver README, "Editor de mapas".
- **Combate**: `CombatDirector` (modo combate; con la F el entrenador queda `locked` pero sigue a su Pokémon con
  `Trainer.follow_target`, salvo en las arenas), componentes `Health`/`StatusEffects`/`MoveUser`/`Hurtbox`/
  `Hitbox` en la criatura, `Projectile`/`AreaEffect`, `HitInfo` + `Damage`. El Pokémon controlado lee órdenes
  de un `CombatInput` (teclado/mouse) o `BotCombatInput` (autotest). El feedback escucha solo `Events`.
- **Kits / estilos de pelea** (plan de identidad, **v2 vigente**): `SpeciesData.kit` → `Kit` (`archetype`,
  `preferred_range`, `signature` opcional, `moves` = 4 `MoveData`). **Sin energía**: solo recargas. Teclas en
  `Controls.SLOT_ACTIONS` (Clic izq., Clic der., Q, R) + `dodge` (Espacio, igual para todos). La criatura usa
  `use_slot(slot 0-3, aim, point)` y `dodge(dir)`. Las mecánicas de firma son subclases de `SignatureMechanic`
  (`scripts/combat/signatures/`) conectadas a las señales de la criatura; **nunca** agregar
  `if especie == ...` en el código central.
- **Salvajes** (`WildSpawner`): cada zona usa su `EncounterTable` (`data/world/encounters/<zona>.tres`, o la de su
  bioma en `encounters/biomas/<bioma>.tres`): filas `EncounterEntry` (especie, peso %, niveles, `where` = tag de
  celda) y `EncounterArea` (celdas pintadas cuyos ajustes pisan o suman filas). El spawner elige primero la celda y
  después la fila de esa celda (`EncounterTable.pick_at`); en el agua nadan (`Creature.swims`). Se editan en el
  editor de mapas (pestaña Salvajes). `GameState.wild_test_pool` (Opciones → "Salvajes de prueba", se guarda en la
  partida) vuelve a los 4 de prueba del combate. Plantillas de FireRed: `tools/build_encounter_templates.py` →
  `encounters/plantillas_frlg.json`. `EncounterEntry.time` (día/noche) queda reservado para la Etapa 5.
- **IA de criaturas** (Etapa 4a; ver `docs/PLAN_ENTRENADORES.md` 1b): **cuerpo** compartido `CombatBody`
  (`Creature.body`: alcance, apuntar, esquivar, peligros; la dificultad actúa solo acá) + **mente**. Salvajes =
  `Creature.temperament` (`Temperament`, `data/ai/temperaments/`; `SpeciesData.temperament` lo asigna
  `tools/assign_temperaments.gd`) leído por los estados wander/watch/chase/attack/flee; sin memoria, patrón fijo.
  Entrenadores (pendiente): órdenes + memoria, mismo cuerpo. Mientras hay golpes (`Creature.engaged`, 5 s) un
  salvaje no suelta la pelea por territorio; al soltarla queda tranquilo 6 s (`calm_until`).
  **No se traban** (2026-10-25): los estados se mueven con `CombatBody.steer(dir, meta)` (si adelante hay algo sólido
  gira hacia un lado y lo mantiene; trabado 0,35 s → camino por celdas con `find_path`, AStarGrid2D sobre
  `MapRules`). `clear_shot` (rayo contra mundo y entorno): no dispara contra paredes y se acomoda para tener tiro.
  `AiDifficulty.lead`: los disparos anticipan tu movimiento (Fácil 0, Normal 0,6, Difícil 1).
- **Historia** (`docs/PLAN_HISTORIA.md`, fases H; **capítulo 2** hasta Misty: `docs/PLAN_CAPITULO_2.md`; **capítulo 3**
  hasta Lt. Surge: `docs/PLAN_CAPITULO_3.md`; **capítulos 4-8** hasta el Campeón: `docs/PLAN_RESTO_KANTO.md`). **E frente
  a algo** (`StoryDirector.register_interaction`): `FieldMoves` = Corte (MO01 + Cascada: EnvObject "cortable"), Surf (MO03
  + Alma: el agua deja de frenar al entrenador, al pisar tierra se baja), Fuerza (MO04 + Arcoíris: empujar EnvObject
  "pesado"), Poké Flauta (Snorlax) y legendarios (acciones de su charla); `VermilionGymPuzzle` (basureros de Carmín).
  Entrenadores de las zonas nuevas: automáticos desde `data/source/trainers_frlg.json` (`tools/fetch_frlg_trainers.py`,
  de pret) con frases por clase; en `build_story_npcs.py` el bloque "Capítulos 4 a 8" tiene los hitos y al final un
  **relleno** que le da una frase a toda persona sin charla propia. `GameState.story_flags` (banderas, se guardan); `NpcData`/`NpcTalk`/
  `StoryTrigger` en `data/story/` (`DB.npcs`, `DB.story_triggers`); `StoryDirector` (nodo del mundo: saca las personas,
  disparadores, conversaciones con `DialogBox`, efectos). **E contextual**: `PlayerItems` llama a
  `StoryDirector.try_interact()` antes de lanzar la bola. Personas: `tools/build_story_npcs.py` (desde los NPC de
  `frlg_maps.json` + sprites de `tools/fetch_npc_sprites.py`). Teclas 1-6 = cambiar de Pokémon (`CombatDirector.switch_to`).
- **Combate contra entrenadores en arena** (E-1, `docs/PLAN_ENTRENADORES.md`): `TrainerBattle` (`world.arena`): fundido a
  una arena aparte (`ArenaData` en `data/arenas/`, escena = zona de tiles en `scenes/world/arenas/`, ambientación
  `ArenaDecor`), 1 contra 1 con cambios, `CombatDirector.arena_lock`, `Creature.owner_name` (no se atrapa).
  Entrenadores de la historia = `NpcData.trainer` (TrainerData) + `sight`; perder → `GameState.last_heal_position`.
- **Combate de arena** (estilo Pokkén, `docs/PLAN_IDENTIDAD_COMBATE.md`): `FightStyle` por especie en `data/estilos/`
  (`tools/build_fight_styles.py`: estilo de movimiento + `ComboData`; **combos apagados** por decisión del usuario:
  `GameConfig.combos_enabled`); `Creature.arena_rules()` (en arenas registradas en
  el `ReactionSystem`, o en todos lados con `GameConfig.arena_rules_everywhere`); `MoveData.crater_radius` →
  `Events.ground_impact` → estado de celda "crater".
- **Mapa del menú** (Esc → Mapa): `TownMap` (`scripts/world/town_map.gd`) dibuja la región en miniatura **desde las
  capas de tiles de las zonas reales** (4 px por celda; la primera vez que se abre, en el hilo principal) y calcula dónde van los
  interiores/cuevas/Bosque Verde (en la puerta por la que se entra, siguiendo las puertas), los íconos de Centro/Tienda/
  Gimnasio y los nombres. `TownMapScreen` (`scripts/ui/`): zoom, arrastre, niebla en lo no visitado
  (`GameState.visited_zones`, se guarda; partidas viejas: `TownMap.visited_from_progress`), tu posición y la estrella
  del objetivo (`StoryGuide.GOALS`). En la historia aparece con el objeto Mapa (Dalia); en el modo libre, siempre.
- **Día y noche** (`docs/PLAN_DIA_NOCHE.md`): `DayNight` (`world.day_night`) hace correr `GameState.time_of_day`
  (1 h = 1 min real; ajuste `time_lock` = hora fija) y pinta según la tabla `KEYS`: Daylight, uniforms del
  post-procesado (tinte, `sun_pos`/`sun_strength`/`rays` = luz de esquina; de noche, la luna), nubes, luciérnagas y
  estrellitas de noche (`AmbientFX`). Interiores
  y arenas: `INDOOR` (luz pareja). Otros sistemas leen `darkness`, `shadow_direction`, `shadow_length` y escuchan
  `Events.time_changed(hour, phase)`. Por ahora solo visual (no cambia salvajes ni tipos). Sombras largas: `ZoneShadows`
  (World la agrega a cada zona exterior: máscara de celdas sólidas + `shaders/sun_shadows.gdshader`) y `SunShadow`
  (cuadro acostado de personajes y Pokémon, desde `CreatureSprite` y `blob_shadow.gd`).
- **Ajustes del juego por partida** (Esc → Opciones → "Ajustes del juego…", `GameSettingsScreen`): `GameState.settings`
  (se guarda con la partida; solo lo cambiado; el resto sale de `default_settings()` = GameConfig + dificultad Normal;
  una partida nueva arranca de cero). Leer siempre con `GameState.setting(clave)`: `exp_mult` (exp_yield), `money_mult`
  (`add_prize`: premios de entrenadores y torneo), `catch_mult` (Capture), `dealt_mult`/`taken_mult` (HitInfo.from),
  `hp_scale` (`CreatureInstance.hp_scale()`, reescala la vida actual), `combos`, `arena_everywhere`, `wild_mult`
  (WildSpawner.max_alive), `regen` (curación sola, CombatDirector), `field_items`, `time_lock` (DayNight), y `ai_*` (dificultad
  "personalizado" = `GameState.custom_difficulty()`). **No leer más `DB.config.exp_multiplier`/`combos_enabled`/
  `arena_rules_everywhere` ni `CreatureInstance.HP_SCALE` directo** (son los valores por defecto).
- **Dinero y Torneo** (`docs/PLAN_TORNEO.md`): `GameState.money`; `Tournament` (`world.tournament`, acción "torneo" de la
  recepcionista vía `StoryDirector.register_action`), copas `TournamentCup` en `data/tournament/`; durante el torneo
  `GameState.tournament` guarda el equipo y la mochila de antes (los usa `to_dict`).
- **Mercado** (Tiendas Pokémon): `ShopData` en `data/shops/<ciudad>.tres` (lo que vende cada una, lista oficial de
  FireRed con los objetos que hay); `Mart` (`world.mart`) registra la acción `tienda_<id>` en el `StoryDirector` (la usa
  la conversación del vendedor, `NpcTalk.action`, en `tools/build_story_npcs.py`) y abre `ShopScreen` (comprar / vender,
  su propia CanvasLayer 11). Precio oficial `ItemData.price` (tabla `PRICES` de `tools/fetch_items.py`: PokeAPI ya no
  los trae); se vende a la mitad (`sell_price`; objetos clave y Master Ball no). Ciudad Verde vende recién después de
  entregar el Correo de Oak (en modo libre, siempre).
- **Evoluciones**: `SpeciesData.evolutions` (`EvolutionData`: a qué especie, "nivel"/"piedra"/"intercambio"/"amistad")
  y `evolves_from`, de PokeAPI (`tools/fetch_evolutions.py` → `data/source/evolutions.json` → `tools/apply_evolutions.gd`
  → `build_learnsets.gd`). Reglas en `Evolution` (solo nivel y piedras: no hay intercambio ni amistad todavía).
  `GameState.grant_exp` y las piedras (`ItemData.evolves`) emiten `Events.evolution_ready`; `EvolutionDirector`
  (`world.evolutions`) espera un momento tranquilo y muestra `EvolutionScreen` (Esc la frena, salvo con piedra); la
  criatura conserva nivel, daño y movimientos (`CreatureInstance.evolve_into`). **Kits** (decisión del usuario
  2026-10-25): la evolución hereda el kit de su preevolución (`kit_inherited`) salvo las que cambian mucho
  (`NEW_KIT` de apply_evolutions: Butterfree, Beedrill, Gyarados, Kadabra, Charizard, Eeveelutions...: kit propio).
- **Entrenadores vivos** (`docs/PLAN_ENTRENADORES.md`, fases E): interruptor `GameState.living_trainers`; datos
  `TrainerData` en `data/trainers/` (de `tools/build_trainers.gd`); estado jugando `TrainerState` en
  `GameState.trainers` (se guarda); `TrainerDirector` (nodo del mundo) saca/guarda los `TrainerNPC`.
- **Captura, Mochila y Caja** (`docs/PLAN_CAPTURA_MOCHILA.md`): `ItemData` en `data/items/` (de
  `tools/fetch_items.py`); `GameState.bag`/`selected_ball`/`quick_item`/`box`/`field_picked`; `PlayerItems` (nodo del
  mundo: E lanza `BallThrow`, C usa el objeto rápido); `Capture` (fórmula oficial 3ª gen); `FieldItemSpawner` +
  `FieldItem` (objetos del mapa y botín, tablas `LootTable` en `data/items/loot/`). Pantallas `BagScreen` y
  `BoxScreen` en el menú de pausa.
- **Stats y progresión = reglas oficiales** (ver sección abajo). Nunca inventar stats: salen de PokeAPI.
- **Entorno reactivo (Etapa 3)**: `ReactionSystem` (nodo del mundo) escucha `Events.element_impact` y aplica
  `ReactionRule` (`data/environment/reactions/`) a las celdas; el estado vive en un `EnvironmentGrid` por zona
  (`EnvCellState` en `data/environment/states/`). Sumar reacciones = sumar .tres, sin tocar código.
- **Tags de entorno**: custom data `tags` del TileSet (`inflamable`, `agua`, `conductor`, `congelable`,
  `pasto_alto`, `solido`, `arbol`...) + `EnvObject.tags` (`fragil`, `pesado`, `cortable`...).
  Base del sistema de entorno reactivo (Etapa 3).

## Stats, daño y progresión (oficiales + adaptaciones al tiempo real)
- **Fuente**: `data/source/official.json`, bajado de PokeAPI con `tools/fetch_official_data.py` (las 386
  especies: stats base, experiencia, curva, tasa de captura, tipos, nombre/categoría/descripción en español,
  altura, peso y learnset por nivel de FRLG; los ~337 ataques que aprenden: potencia, categoría, tipo, objetivo,
  prioridad, problema de estado). Caché en `tools/.pokeapi_cache` (no se versiona). Se aplica a los `.tres` con
  `tools/apply_official_data.gd`: **18 tipos y tabla oficial completa** (6ª gen+, incluye Hada), crea las
  especies/ataques que falten y la recarga. Después `tools/build_learnsets.gd` arma los learnsets.
  Orden: fetcher → `--import` → apply → `--import` → build_learnsets.
- **Ataques automáticos** (`auto` en el JSON): su forma en tiempo real sale de `_shape()` en el apply (estado a
  uno mismo → mejora/escudo/curación; estado al rival → disparo que aplica el problema de estado; daño a todos →
  área; físico con prioridad o ≥80 → embestida, si no golpe; especial → disparo, con carga si ≥80). Los hechos
  a mano (`MOVES` del fetcher, kits) no se tocan. Rearmar los automáticos: apply con `-- --regen-auto`.
  Pendiente: subir/bajar stats, drenar, retroceso (los ataques de ese tipo existen pero sin ese efecto).
- **Stats** (`CreatureInstance.stat`): fórmula oficial 3ª gen+; IV 31 en todos los stats por ahora
  (**decisión del usuario: "stats máximos para su nivel"**), EV 0, naturaleza neutra.
  - **Plan futuro (Etapa 6)**: IVs al azar al capturar (0-31 por stat), con un perfecto (31 en todo)
    **muy difícil de conseguir**; después naturalezas y EVs. El código ya guarda `ivs`/`evs` por criatura.
- **Experiencia**: curvas oficiales (`exp_for_level`: fast, medium, medium-slow, slow, errática,
  fluctuante); EXP ganada = experiencia base × nivel del derrotado / 7 (fórmula 1ª-4ª gen) ×
  `GameConfig.exp_multiplier` (**0,5**: decisión del usuario 2026-10-23, se subía de nivel muy rápido).
- **Daño** (`Damage.resolve`): fórmula oficial con STAB 1.5, efectividad, variación 0.85-1, físico vs
  especial. Los **estados siguen el plan de identidad** (no los oficiales): Quemado −15% daño físico,
  Paralizado con tirones al azar, etc. (ver `docs/PLAN_IDENTIDAD_COMBATE.md`). No tocarlos desde
  `apply_official_data.gd`.
- **Adaptaciones al tiempo real** (documentarlas si se cambian):
  - `CreatureInstance.HP_SCALE = 3`: la vida se triplica para que un combate dure varios golpes.
  - Velocidad de movimiento = `40 + 26·log2(1 + Velocidad/8)` px/s (`Creature.move_speed_for`).
  - Recarga y energía derivadas de la potencia (`apply_official_data.gd::_pace`); energía 100, +12/s.
  - Se ignora la precisión (el jugador apunta). Giro Fuego quema 30% (en los juegos atrapa).
  - Tipos de ataques secundarios no implementados (retroceso, bajar stats) se omiten por ahora.

## Pipeline de contenido
- `tools/pret_import.py` (Python sin dependencias): convierte **todos los tilesets** de `art_src/pret` (decomp
  pret/pokefirered: tilesets, `data/layouts` con los 365 mapas, `headers.h`) en atlas
  `art/pret/tiles/<tileset>_below|above|anim.png` + `manifest.json` (con `order`, `base`, `sources`, `group`
  exterior/interior) + `catalog.json` (tipo, tags y colisión por metatile sacados de behaviors y mapas reales;
  sellos de edificios). Después: `build_world.gd -- --tileset` (pasa el catálogo a `data/world/tile_catalog.tres`
  y rearma el TileSet). Los 6 tilesets que no usa ningún mapa (dummy/garitas) no se importan.
- **Sellos y paleta curados** (`tools/match_reference.py`, Python sin dependencias): cruza las hojas de referencia
  `art_src/referencia/frlg_edificios.png` y `frlg_tiles_mundo.png` (The Spriters Resource; **no se suben a git**,
  las baja el usuario) con los metatiles renderizados (comparando en 5 bits por canal, todos los cuadros de las
  animaciones) y los mapas reales. Ubica cada pieza en un mapa (tolerante a retoques chicos y a techos que siguen
  más allá del borde del mapa) y genera `data/world/stamps.json` (sellos con origen layout + rectángulo, celdas,
  colisión por celda, puertas y variantes de color) y `data/world/palette_layout.json` (secciones y grilla de la
  hoja del mundo). Nombres, grupos, secciones y descartes: `data/world/reference_curation.json` (a mano).
  `pret_import.py` usa esos datos cuando existen (si no, vuelve a las heurísticas); los **tags y la colisión de
  los tiles no cambian** (siguen saliendo de los mapas). Orden para regenerar: `match_reference.py` →
  `pret_import.py` → `build_world.gd -- --tileset`. Verificar con `python -I -B tools/match_reference.py . --check`.
  Las celdas de un sello con otra colisión que la de su tile usan **tiles alternativos** del TileSet
  (`ZoneBuilder.ALT_SOLID` / `ALT_WALKABLE`).
- **Ids de metatile globales**: general 0-639 (sin cambios); cada otro tileset `base` = 1000·(k+1) según
  `manifest.json → order`, que es **estable** (solo se agregan al final: las zonas guardan fuentes del TileSet
  por número). Fuentes del TileSet: general 0/1/2, el k-ésimo 3+3k (abajo), 4+3k (animado), 5+3k (arriba).
  Todo pasa por `ZoneBuilder` (`set_of`, `local_of`, `below_ref`, `above_ref`, `metatile_of`...).
  Tags/colisión: ajuste manual (`TileRoleSet.overrides`) > rol > catálogo.
- **Roles de tile** (`data/world/tile_roles.tres`, `TileRoleSet` de `TileRole`): pasto, arena, agua, árbol...
  con sus metatiles, capa, lo que va abajo, autotile 3×3, tags y colisión, + `overrides` por metatile (los
  escribe la pestaña "Propiedades" del editor) y `behavior_hints` (sugerencias por behavior de FireRed). **Es la fuente
  de los tags y la colisión del TileSet**: tocar tags acá (o con el editor), no a mano en `world_tileset.tres`.
- **Región de FireRed** (`tools/import_frlg_maps.py` → `data/world/frlg_maps.json` → `tools/import_frlg_maps.gd`):
  mapas de art_src/pret (`data/layouts` + `data/maps/<mapa>/map.json` con conexiones y puertas, bajados de
  pret/pokefirered). Agranda ×1,75 con **costuras** de 2 celdas que cruzan el mapa doblándose: solo se aceptan si
  cada empalme nuevo existe en algún mapa real (pares de metatiles vecinos), y nunca se copian edificios, carteles ni
  puertas (categorías del catálogo); si hace falta, mete suelo de relleno del mapa. Ubica los mapas según las
  conexiones de FireRed alineando los caminos, y rellena los costados continuando el borde (o con el bloque de borde
  del mapa). El .gd rearma el TileSet (colisión por celda: `ZoneBuilder.imported_collision_alts`), guarda las zonas
  `hand_edited` (agua en Water y pasto alto en Foliage, como los pinceles; árboles cortables de FireRed como
  EnvObject), la región, las tablas de salvajes de FireRed sin las filas de agua (son de Surf) y **borra las zonas viejas** (backup en `.backup/`;
  `-- --keep-others` las conserva). Orden: `.py` → `--import` → `.gd`. **Para sumar mapas** (como el capítulo
  2): agregarlos al final de las tablas del `.py` (`EXTERIORS`, `CAVES`, `INTERIORS_2`; así lo viejo no se mueve: el
  corrimiento sale solo de `FIRST_EXTERIORS` y los interiores nuevos van después) y correr el `.gd` con
  `-- --only-new` (solo arma las zonas que no están en kanto.tres; las que ya existen quedan tal cual). Verificar que
  las zonas viejas del JSON no cambiaron. Cuevas: `kind` "cave" (interior, salvajes en cualquier suelo). Desde el capítulo 3 tampoco se ensancha el paso
  que tapa un árbol cortable o una roca (`blocked_passage`: sin costuras pegadas): el Gimnasio de Carmín sigue
  necesitando Corte (`TourPlanner.new(world, cut, surf, strength)` simula Corte, Surf y Fuerza en los tests).
  **Resto de Kanto** (`EXTERIORS_4`, `STRETCHED_4`, `CAVES_4`, `WILD_INTERIORS_4`, `INTERIORS_4`): se ubican en una
  segunda pasada (`PLACE_ORDER`: cada uno pegado al borde con relleno de su padre, sin mover lo anterior); los que
  cierran un círculo (`FIT`: Rutas 8, 11, 15 y 21) se agrandan justo hasta llenar el espacio; si igual se encima con
  otra zona, se recorta el que se ubicó después por el lado que menos camino pierde (nunca el de una conexión). En
  esos mapas el agua no es suelo de relleno (cortaba muelles). Salvajes: plantilla de FireRed del mismo nombre
  (`snake`). Con `--only-new` también se actualizan los `warps` y el `origin` de las zonas que ya existían. **Pisa las zonas importadas**: después de
  editarlas con el editor de mapas no volver a correrlo.
- `tools/build_world.gd`: arma el TileSet (desde los roles) y **genera las zonas** a partir de `REGION` (vacía desde la
  región de FireRed) y
  `ZoneGenerator.BIOMES` (`scripts/world/zone_generator.gd`). Sin flags no pisa nada.
  `-- --force` regenera TileSet y zonas **salvo las marcadas `hand_edited`** (editadas con el editor de mapas),
  que conservan también su entrada en `kanto.tres` (hub, salidas, nombre); `-- --force-all` pisa todo.
  Las zonas creadas con el editor (que no están en `REGION`) se conservan siempre. Para agrandar el mundo:
  sumar filas a `REGION` o usar "Nueva zona" en el editor.
- **Editor de mapas**: guarda zonas en `scenes/world/zones/<id>.tscn` (backup en `.backup/`, últimos 5) y el
  TileSet con backup en `art/tiles/.backup/`. El autotile es `ZoneBuilder.autotile_piece` (no terrains de
  Godot: ver README).
- `tools/build_kits_v3.py`: generó los 10 kits v3 (ataques, firmas, estados nuevos). **Correrlo de nuevo pisa los
  ajustes hechos a mano** en esos .tres: retocar en el inspector y no volver a correrlo.
- `tools/build_kits_v4.py`: igual para los kits v4 (Kanto hasta Plateada, Onix jefe); además engancha el kit en la
  especie. Mismo aviso: correrlo de nuevo pisa los ajustes a mano.
- `tools/build_kits_v5.py`: igual para el capítulo 2 (Staryu y Starmie jefa, firma `core_mechanic.gd`) y las evoluciones
  con kit propio (Butterfree, Beedrill, Kadabra, Gyarados). Criterio: una evolución hereda el kit salvo que cambie mucho
  su forma de pelear.
- `tools/build_kits_v6.py`: igual para la Tanda A de `docs/PROPUESTA_KITS_PENDIENTES.md` (Raichu jefe de Surge, Zubat,
  Ekans, Machop, Nidoran♀/♂, Horsea, Shellder, Tentacool, Voltorb). Firmas genéricas por parámetros: `grounding`,
  `still` y `body_trait` (`scripts/combat/signatures/`); `SignatureMechanic.blocks_status` (inmunidades). Después:
  `build_learnsets.gd` y `apply_evolutions.gd` (herencia) y otra vez `build_learnsets.gd`.
- `tools/build_kits_v7.py`: igual para la Tanda B (Clefairy, Jigglypuff, Abra, Goldeen, Magnemite, Meowth); firmas
  `metronome`, `puff`, `wary`, `payday`.
- `tools/build_kits_v8.py`: igual para la Tanda C (Drowzee, Grimer, Koffing, Ponyta, Slowpoke, Magikarp).
- `tools/link_official_moves.py`: los ataques oficiales automáticos toman la forma de su versión de kit del mismo
  nombre (y los de mejora propia sin kit, un efecto genérico). **Correrlo después de `apply_official_data.gd --
  --regen-auto`** (si no, vuelven a la forma inventada). `SignatureData.params.element_marks` = sinergia por tipo.
- **IA local (ComfyUI, fuera del repo)**: `docs/COMFYUI.md`. `tools/comfy/build_workflows.py` arma los workflows de
  efectos (`efecto_1_cuadro_clave` con Qwen-Image + LoRA de pixel art, `efecto_2_animar` con Wan 2.2) y
  `tools/fx_from_frames.py` (necesita Pillow) pasa los cuadros a una hoja de `sprites/fx/` (`--clean-key` limpia el
  cuadro clave antes de animar).
- `tools/fetch_cries.py` (gritos de PokeAPI → `audio/gritos/<n.º>.ogg`) y `tools/make_sfx.py` (efectos retro hechos
  por código → `audio/efectos/`, + cortinas por defecto en `audio/musica/` sin pisar las tuyas). Música: la pone el
  usuario (`docs/AUDIO.md`).
- `tools/fetch_npc_sprites.py`: baja de pret/pokefirered los sprites de las personas de los mapas importados (y las de
  la historia) → `art/pret/characters/<gfx>.png` + `npcs.json`. `tools/build_story_npcs.py`: arma `data/story/npcs/`
  (diálogos en su tabla `TALKS`; correrlo de nuevo pisa esos .tres).
- `tools/build_learnsets.gd`: arma los learnsets (kit en Nv. 1/1/3/5 + **todo el learnset de FRLG** + extras de la
  tabla `EXTRAS`) y los guarda en las especies; el equipamiento inicial es el kit (`default_equipment`). Correrlo después de cambiar un kit o los extras.
- `tools/fetch_items.py`: objetos de la mochila (PokeAPI: nombre/descripción en español e ícono) → `data/items/` +
  `sprites/items/`. El efecto de cada objeto está en su tabla `ITEMS`.
- `tools/build_wild_docs.gd`: genera `docs/SALVAJES_LISTADO.md` (qué aparece en cada zona, kit, temperamento y
  movimientos de cada especie). Correrlo después de tocar tablas de encuentros, kits o learnsets. Cómo funciona
  todo eso y cómo modificarlo: `docs/SALVAJES_Y_MOVIMIENTOS.md`.
- `tools/download_sprites.py`: sprites PMD (PMDCollab/SpriteCollab) de los N.º 1-386 (Idle, Walk, Attack, Hurt,
  retrato y las de combate que tenga cada especie: Shoot, Charge, QuickStrike, Strike, Kick, Swing, Double, Hop,
  Rotate, Tumble, LeapForth, Faint, HitGround, LostBalance, Sleep; lista `ANIMS`) → `sprites/pokemon/` +
  `scripts/generated/sprite_data.gd`. No vuelve a bajar lo que ya está (tampoco el `AnimData.xml`: se pueden
  agregar animaciones hechas a mano). Qué animación usa cada acción: `CreatureSprite.CHAINS` (disparo → Shoot,
  carga → Charge, golpes → Strike/Swing/Double según potencia y paso del combo, embestida → LeapForth, esquive →
  Hop/Rotate/Tumble según el estilo de movimiento, debilitado → Faint/HitGround/LostBalance, dormido → Sleep; si la
  especie no la tiene, cae a Attack). Efectos y animaciones con IA: `docs/TUTORIAL_PIXELLAB_SORCERESS.md`.
- **Efectos de ataque con sprite** (opcionales; sin ellos se dibujan por código): `MoveData.vfx`/`impact_vfx` y
  `ElementType.vfx`/`impact_vfx` (SpriteFrames), o hojas `sprites/fx/moves/<id>[_impacto].png` y
  `sprites/fx/types/<id>[_impacto].png` (una fila de cuadros cuadrados, apuntando a la derecha, 15 fps).
  `DB.vfx_for` elige (ataque > hoja del ataque oficial del mismo nombre, para las variantes de los kits > tipo);
  `VfxSprite` los dibuja en `Projectile`, `AreaEffect`, `MeleeSwing` y el impacto en `combat_feedback.gd`. Conos y
  látigos todavía no. **Hojas hechas por código** con `python -I -B tools/make_vfx.py .` (impacto de 14 tipos + cuerpo de
  Ascuas, Impactrueno, Pistola Agua, Burbuja, Hoja Afilada; `--sheet <png>` = hoja de contacto); correrlo de nuevo
  pisa esas hojas. **Hechas con IA** (ComfyUI, `docs/COMFYUI.md`; están en `HECHOS_CON_IA` de make_vfx para no pisarlas):
  impactos de Hielo, Planta, Psíquico y Roca, y las áreas de Trueno (`moves/trueno.png`, 64 px) y Giro Fuego (48 px).

## Trampas conocidas
- En shaders `canvas_item`, `COLOR` en `fragment()` ya trae la textura: guardar el color de vértice en un
  varying si se re-muestrea la textura (si no, sale todo más oscuro).
- GDScript: no usar `:=` con valores Variant (arrays/dicts sin tipo) → error "Cannot infer the type".
- Godot `--script` + `class_name`: correr `--import` antes para registrar las clases.
- Simular input en tests: `Input.action_press` justo después de `process_frame` (acciones leídas en
  `_process`) o de `physics_frame` (leídas en `_physics_process`); si no, `is_action_just_pressed` no lo ve.
- Las `PointLight2D` se suman sobre el suelo claro y lo saturan a amarillo: mantener energía ≤ 0,35 y
  escala chica (el usuario se quejó de que el fuego se veía amarillo). El color del fuego va en
  `ElementType.color`/`core_color` (rojizo/naranja, no blanco).
- El hitstop se mide con reloj real: al grabar con `--write-movie` se desactiva (si no, la vitrina va en cámara lenta).
- Correr Python sobre `tools/` con `-B` (`python -I -B ...`): hay `.pyc` versionados en `tools/__pycache__`.
- Correr Godot headless siempre con `--quit-after`: si un script no compila, el autotest no carga y queda colgado.
- PowerShell 5: archivos .ps1 sin BOM se leen como ANSI → evitar caracteres no ASCII en scripts .ps1.
