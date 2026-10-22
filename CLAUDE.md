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
- Pokémon de **primera generación (Kanto)**, con nombres y sprites reales. Estética: pixel art GBA/DS
  + efectos modernos ("next gen"). Renderer Forward+.

## Cómo correr y probar
Godot está en `C:\Users\Gusti\Documents\claude\tools\godot\` (fuera del repo).
```
G=C:/Users/Gusti/Documents/claude/tools/godot/Godot_v4.7.2-stable_win64_console.exe
$G --headless --path . --import                        # tras crear/cambiar assets o class_name
$G --headless --path . --quit-after 60000 -- --autotest          # recorre las 9 zonas ("-> OK"/"-> FALLO")
$G --headless --path . --quit-after 30000 -- --autotest-combat   # 3 peleas manejadas por un bot
$G --headless --path . --quit-after 30000 -- --autotest-input    # simula teclas reales + spawner
$G --headless --path . --quit-after 3000 -- --autotest-stats     # stats/EXP contra valores oficiales
$G --headless --path . --quit-after 3000 -- --autotest-identity  # reglas del plan de identidad (estados, CC...)
$G --headless --path . --quit-after 9000 -- --autotest-kit       # kits: Charmander, Bellsprout, Pidgey, Rattata, Vulpix
$G --headless --path . --quit-after 5000 -- --autotest-modes     # modo práctica + dificultad de la IA
$G --headless --path . --quit-after 9000 -- --autotest-save      # guardado/carga, learnset, archivos rotos
$G --headless --path . --quit-after 9000 -- --autotest-party     # equipo de 6, activo, menú, ficha
$G --path . --quit-after 900 --write-movie out/f.png --fixed-fps 30 -- --showcase-menus  # título, equipo, ficha
$G --path . --quit-after 2400 --write-movie out/f.png --fixed-fps 30 -- --showcase-kit  # vitrina de kits
$G --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase   # vitrina de estados
$G --path . --write-movie out/f.png --fixed-fps 30 -- --autotest   # renderiza frames (requiere GPU)
$G --path . --write-movie out/m.png --fixed-fps 30 -- --overview   # vista de toda la región
```
El usuario lanza el juego con el acceso directo **"Pokémon Pilot"** del escritorio
(`Godot_v4.7.2-stable_win64.exe --path <proyecto>`, ícono `icon.ico` generado por `tools/make_icon.py`).
Si se mueve la carpeta del proyecto o de Godot, hay que recrear el acceso directo.

Para ver resultados visuales: renderizar frames con `--write-movie` a la carpeta scratchpad y leer los PNG.

## Arquitectura (respetarla)
- **Data-driven**: especies, ataques, tipos y tabla de efectividad son Resources `.tres` en `data/`.
  `DB` (autoload) carga todo lo que haya en esas carpetas. Clases en `scripts/resources/`.
- **Autoloads**: `Events` (bus de señales; los sistemas no se llaman entre sí), `DB`, `GameState`,
  `Controls` (input por código, teclas físicas), `SaveManager` (guardado JSON en `user://saves/slot_1.json`),
  `Autotest`. Escena principal: `scenes/ui/title_screen.tscn` → `starter_select` → `world`.
- **Meta-juego (Etapa 2c)**: menús con nodos `Control` y el estilo de `UiStyle` (`scripts/ui/`), menú de pausa
  en su propia CanvasLayer (pausa el árbol). `GameState` no conoce archivos: `to_dict`/`from_dict`.
  Movimientos: `SpeciesData.learnset` (de `tools/build_learnsets.gd`) → `CreatureInstance.equipped_moves` →
  `MoveUser.setup(instance)`. La mecánica de firma sigue saliendo del kit de la especie.
- **Máquina de estados** genérica `StateMachine` + `State` (`scripts/core/`); los estados son nodos hijos
  con script (`scripts/characters/states`, `scripts/creatures/states`).
- **Una escena por responsabilidad** (`scenes/`). Entidades usan origen en los pies (y-sort).
- **Capas de colisión**: 1 mundo · 2 agua · 3 jugador · 4 criatura aliada · 5 criatura salvaje ·
  6 hurtbox aliada · 7 hurtbox salvaje · 8 entorno. Hitboxes/hurtboxes con Area2D (desde Etapa 2).
- **Mundo**: región de zonas (`data/world/kanto.tres`, `ZoneEntry` con origen, plaza `hub` y `exits`).
  `ZoneStreamer` carga/descarga zonas en segundo plano (sin pantallas de carga). `World.tags_at(pos)`.
- **Zonas** (`scenes/world/zones/*.tscn`): capas `Ground` (z-10), `Water` (shader agua), `Foliage`
  (shader viento), `TreeShadows`, `Overhead` (z 20, copas que tapan), `Objects` (EnvObject con tags).
- **Combate**: `CombatDirector` (modo combate), componentes `Health`/`StatusEffects`/`MoveUser`/`Hurtbox`/
  `Hitbox` en la criatura, `Projectile`/`AreaEffect`, `HitInfo` + `Damage`. El Pokémon controlado lee órdenes
  de un `CombatInput` (teclado/mouse) o `BotCombatInput` (autotest). El feedback escucha solo `Events`.
- **Kits / estilos de pelea** (plan de identidad, **v2 vigente**): `SpeciesData.kit` → `Kit` (`archetype`,
  `preferred_range`, `signature` opcional, `moves` = 4 `MoveData`). **Sin energía**: solo recargas. Teclas en
  `Controls.SLOT_ACTIONS` (Clic izq., Clic der., Q, R) + `dodge` (Espacio, igual para todos). La criatura usa
  `use_slot(slot 0-3, aim, point)` y `dodge(dir)`. Las mecánicas de firma son subclases de `SignatureMechanic`
  (`scripts/combat/signatures/`) conectadas a las señales de la criatura; **nunca** agregar
  `if especie == ...` en el código central. Spawns: por ahora todo el mapa usa `WildSpawner.TEST_POOL`
  (Pidgey, Bellsprout, Rattata, Vulpix) mientras se prueba el combate; `use_test_pool = false` vuelve a los
  spawns por zona/bioma.
- **Stats y progresión = reglas oficiales** (ver sección abajo). Nunca inventar stats: salen de PokeAPI.
- **Tags de entorno**: custom data `tags` del TileSet (`inflamable`, `agua`, `conductor`, `congelable`,
  `pasto_alto`, `solido`, `arbol`...) + `EnvObject.tags` (`fragil`, `pesado`, `cortable`...).
  Base del sistema de entorno reactivo (Etapa 3).

## Stats, daño y progresión (oficiales + adaptaciones al tiempo real)
- **Fuente**: `data/source/official.json`, bajado de PokeAPI con `tools/fetch_official_data.py`
  (stats base, experiencia base, curva de crecimiento, tasa de captura, tipos; potencia, categoría
  física/especial, tipo y probabilidad de efecto de los ataques). Se aplica a los `.tres` con
  `tools/apply_official_data.gd`, que también define la **tabla de tipos oficial** y la recarga/energía.
  Para sumar especie/ataque: agregarlo en `SPECIES`/`MOVES` del fetcher, correr fetcher + apply.
- **Stats** (`CreatureInstance.stat`): fórmula oficial 3ª gen+; IV 31 en todos los stats por ahora
  (**decisión del usuario: "stats máximos para su nivel"**), EV 0, naturaleza neutra.
  - **Plan futuro (Etapa 6)**: IVs al azar al capturar (0-31 por stat), con un perfecto (31 en todo)
    **muy difícil de conseguir**; después naturalezas y EVs. El código ya guarda `ivs`/`evs` por criatura.
- **Experiencia**: curvas oficiales (`exp_for_level`: fast, medium, medium-slow, slow, errática,
  fluctuante); EXP ganada = experiencia base × nivel del derrotado / 7 (fórmula 1ª-4ª gen).
- **Daño** (`Damage.resolve`): fórmula oficial con STAB 1.5, efectividad, variación 0.85-1, físico vs
  especial. Los **estados siguen el plan de identidad** (no los oficiales): Quemado −15% daño físico,
  Paralizado por acumulación, etc. (ver `docs/PLAN_IDENTIDAD_COMBATE.md`). No tocarlos desde
  `apply_official_data.gd`.
- **Adaptaciones al tiempo real** (documentarlas si se cambian):
  - `CreatureInstance.HP_SCALE = 3`: la vida se triplica para que un combate dure varios golpes.
  - Velocidad de movimiento = `40 + 26·log2(1 + Velocidad/8)` px/s (`Creature.move_speed_for`).
  - Recarga y energía derivadas de la potencia (`apply_official_data.gd::_pace`); energía 100, +12/s.
  - Se ignora la precisión (el jugador apunta). Giro Fuego quema 30% (en los juegos atrapa).
  - Tipos de ataques secundarios no implementados (retroceso, bajar stats) se omiten por ahora.

## Pipeline de contenido
- `tools/pret_import.py` (Python sin dependencias): convierte gráficos de `art_src/pret` (decomp
  pret/pokefirered) en atlas `art/pret/tiles/*_below|above|anim.png` + `manifest.json`, y sprites
  (Red, rocas, arbusto). Ojo: los metatiles se identifican por número (ver tabla en `tools/build_world.gd`).
- `tools/build_world.gd`: arma el TileSet y **genera las zonas** a partir de `REGION` y `BIOMES`.
  `-- --force` pisa las zonas (perdés lo pintado a mano en el editor). Para agrandar el mundo:
  sumar filas a `REGION`.
- `tools/build_learnsets.gd`: arma los learnsets (kit en Nv. 1/1/3/5 + extras de la tabla `EXTRAS`, niveles de
  FRLG) y los guarda en las especies. Correrlo después de cambiar un kit o los extras.
- `tools/download_sprites.ps1`: sprites PMD (PMDCollab/SpriteCollab) de Pokémon por número de Pokédex
  → `sprites/pokemon/` + `scripts/generated/sprite_data.gd`.

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
- Correr Godot headless siempre con `--quit-after`: si un script no compila, el autotest no carga y queda colgado.
- PowerShell 5: archivos .ps1 sin BOM se leen como ANSI → evitar caracteres no ASCII en scripts .ps1.
