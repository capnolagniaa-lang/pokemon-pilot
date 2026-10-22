# Prompt: pantalla de título, guardado de partida, menú de equipo y ficha de Pokémon

> Pegá esto en Claude Code abierto en la carpeta del proyecto `pokemon-tiempo-real` (Pokémon Pilot).

---

Hola Claude. Antes de tocar nada, seguí las reglas de `CLAUDE.md`: leé `docs/PROGRESO.md` ("Dónde estamos") y `docs/PLAN_IDENTIDAD_COMBATE.md` ("ESTADO VIGENTE"). Hablame en español rioplatense.

Quiero sumar **cuatro sistemas de "meta-juego"** alrededor del combate que ya existe. Esto es una **etapa nueva** que se mete antes de la Etapa 6 (captura y progresión) y le prepara el terreno. Anotala en `docs/PROGRESO.md` como **"Etapa 2c — Título, guardado, equipo y movimientos"**.

## 0. Lo que ya existe (análisis del proyecto, para que no lo redescubras)

- **Godot 4.7, GDScript**, data-driven. Autoloads: `Events`, `DB`, `GameState`, `Controls`, `Autotest`.
- **Escena principal actual:** `scenes/ui/starter_select.tscn` (`run/main_scene` en `project.godot`). Ahí se elige el inicial (Bulbasaur, Charmander o Squirtle, de `DB.config.starters`), la **dificultad de la IA** y el **modo práctica**. Después hace `GameState.new_game(sp)` y `change_scene_to_file("res://scenes/world/world.tscn")`.
- **No hay pantalla de título ni guardado.** Cerrar el juego pierde todo.
- **`GameState`** guarda `party: Array[CreatureInstance]`, `active_index`, `balls`, `practice_mode`, `difficulty` (`AiDifficulty`) y `wilds_enabled`. `new_game()` crea un equipo de 1 y emite `Events.party_changed` y `Events.game_started`.
- **`CreatureInstance`** (Resource) tiene `species`, `level`, `experience`, `ivs`, `evs` y `hp`. También tiene `stat(name)` (fórmula oficial), `max_hp()` (con `HP_SCALE = 3`), `exp_for_level`, `exp_progress()`, `exp_to_next()` y `add_exp()`. **No guarda movimientos.**
- **Movimientos hoy:** `MoveUser.setup(species)` toma `species.kit.moves` si hay kit, y si no `species.moves`. Son **4 ranuras fijas** (Clic izq., Clic der., Q y R; `Controls.SLOT_ACTIONS`/`SLOT_KEYS`). **No hay learnset por nivel** ni movimientos equipables por individuo.
  - Los movimientos de los kits están en `data/kits/<pokémon>/*.tres` (por ejemplo `ascuas_abanico`, `embestida_ignea`). Esa carpeta también tiene el `kit.tres` y la firma (por ejemplo `calor.tres`).
  - **`DB.moves` solo carga `data/moves/`, no los movimientos de los kits.** Tenelo en cuenta para buscar movimientos por id.
  - Hay kits para Charmander, Bulbasaur, Bellsprout, Pidgey, Rattata y Vulpix. Algunos movimientos usan el recurso de firma (`resource_cost` / `resource_scaling`).
- **Mundo:** `World._ready()` pone al entrenador en `world.spawn_cell` y saca al compañero con `respawn_companion()`, que escucha `party_changed`. `CombatDirector.in_battle` indica si hay combate.
- **HUD:** `scripts/ui/battle_hud.gd` dibuja todo con `_draw()`: el panel del Pokémon activo, la barra de firma, los ataques y los mensajes. Para el retrato está `DB.portrait_of(species)`, y para las animaciones PMD, `DB.anims_of(species)`.
- **Controles:** `Controls.KEYS` ya tiene `switch` (Tab) y `capture` (E) definidos pero **sin implementar**. No hay acción para abrir el menú.
- **Autotests:** varios (`--autotest-kit`, `--autotest-identity`, `--autotest-combat`, etc.) llaman `GameState.new_game(...)` y saltan directo a `world.tscn`. Además leen `me.moves.slots[0..3]` **dando por hecho que son los movimientos del kit en su orden**. Eso tiene que seguir funcionando.

## 1. Lo que quiero

### A. Pantalla de título (nueva escena principal)
- Nueva `scenes/ui/title_screen.tscn` como `run/main_scene`, con título "Pokémon Pilot" y fondo con algo de vida (por ejemplo, los retratos de los iniciales o el Pokémon del guardado), siguiendo la estética pixel GBA y los efectos modernos.
- Opciones:
  - **Continuar**: solo si hay un guardado. Muestra un resumen: Pokémon del equipo (retratos), nivel del líder, tiempo jugado y fecha.
  - **Nueva partida**: va a la `starter_select` actual, que sigue eligiendo el inicial, la dificultad y el modo práctica. Si ya hay un guardado, pedí **confirmación antes de pisarlo**.
  - **Salir.**
- Se maneja con teclado (flechas/WASD + Enter/Espacio) y con mouse.

### B. Guardado sencillo
- Un **único slot** en `user://saves/slot_1.json`. Usá **JSON con ids**, no `ResourceSaver` de los `.tres`, así un cambio en los datos no rompe los guardados.
- Contenido mínimo:
  - `version` (para migraciones futuras), fecha y **tiempo jugado**.
  - Por cada Pokémon del equipo: `species_id`, `level`, `experience`, `ivs`, `evs`, `hp` y `equipped_moves` (ids). Dejá lugar para `nickname` y `nature` (vacíos por ahora).
  - `active_index`, `balls`, `practice_mode` e id de `difficulty`.
  - **Posición del entrenador** (y la zona), para aparecer donde guardaste. `World._ready()` tiene que usarla en vez de `spawn_cell` si viene de un guardado.
- Un autoload nuevo **`SaveManager`** (`has_save()`, `save_game()`, `load_game()`, `delete_save()`, `summary()`). `GameState` sigue sin conocer escenas ni archivos. Agregá `GameState.to_dict()` / `from_dict()` y `CreatureInstance.to_dict()` / `from_dict()`.
- Hacé la escritura **atómica** (archivo temporal y renombrar) y que sea **tolerante a errores**: con un JSON corrupto o una especie/movimiento que ya no existe, avisa y no crashea; si el movimiento falta, lo saca de lo equipado.
- **Guardado manual desde el menú de pausa** (ver C). **No se puede guardar en combate.** Mostrá un mensaje "Partida guardada" con `Events.message_requested`.
- Sumá a `Events`: `game_saved` y `game_loaded`.

### C. Menú de pausa y menú de Equipo (máx. 6)
- **Esc** abre un menú de pausa en el mundo: **Equipo**, **Guardar**, **Opciones** (por ahora dificultad y modo práctica, editables en partida), **Volver al título** (preguntando si quiere guardar) y **Cerrar**. Agregá la acción en `Controls.KEYS`.
- El menú **pausa el mundo** (`get_tree().paused` y `process_mode` en la UI). **No se abre durante el combate** (`CombatDirector.in_battle`). Si se intenta, mensaje corto.
- **Pantalla de Equipo**: **6 casillas fijas**; las vacías se muestran como "—". Cada casilla tiene retrato, nombre, nivel, tipo(s), estilo (arquetipo del kit), barra de PS y barra de EXP.
  - Marcá cuál es el **activo** (el que te sigue) y dejá elegir otro: **"Poner como activo"**. Cambia `active_index`, emite `party_changed` y el mundo ya respawnea al compañero.
  - **Reordenar** (mover arriba/abajo o arrastrar).
  - No se puede poner activo un Pokémon con PS 0.
  - Entrar a uno abre la **ficha** (D).
- **Límite de 6** en el modelo, no solo en la UI: `GameState.MAX_PARTY := 6` y `GameState.add_to_party(inst) -> bool` (devuelve `false` si está lleno). Así la Etapa 6 (captura) solo llama a eso; más adelante lo que no entre irá a una "caja", que **ahora no se implementa**.
- Todavía **no hay captura**: para poder probar el equipo, agregá una **herramienta de debug** (ver preguntas) que sume Pokémon al equipo. Que no esté activa en una partida normal.

### D. Ficha del Pokémon: estadísticas y movimientos
Dos pestañas, con el retrato o la animación Idle PMD a la izquierda.

**Estadísticas**
- Nombre, nivel, tipos (con su color de `ElementType`), **estilo de pelea** (arquetipo) y **mecánica de firma** (nombre y una descripción corta), si tiene kit.
- PS actuales/máximos y EXP total, EXP para el próximo nivel y barra de progreso.
- Los 6 stats (`PS`, `Ataque`, `Defensa`, `At. Esp.`, `Def. Esp.`, `Velocidad`) con valor actual, **base** e **IV/EV**, y una barra comparativa. Hoy los IV son todos 31, pero mostralos, que en la Etapa 6 van a variar.
- Velocidad de movimiento real (`Creature.move_speed_for`), como dato secundario.

**Movimientos**
- Arriba, las **4 ranuras equipadas** con su tecla (`Controls.SLOT_KEYS`: Clic, Clic der., Q, R).
- Abajo, **todos los movimientos que aprende por nivel** (el learnset completo), ordenados por nivel:
  - **Aprendidos** (nivel ≤ actual): se pueden equipar en una ranura.
  - **Bloqueados** (nivel > actual): se ven atenuados, con candado y "Nv. X", **y no se pueden equipar**.
- De cada movimiento: nombre, tipo, categoría (físico/especial/estado), forma (usá el diccionario `KIND` de `battle_hud.gd`: Disparo, Golpe, Zona, Látigo...), potencia, recarga, carga/recuperación si tiene, estados que aplica y si usa el recurso de firma.
- Equipar: elegís un movimiento aprendido y una ranura, y se reemplaza. **No se puede repetir** un movimiento en dos ranuras ni dejar el Pokémon **sin ningún movimiento**.
- Los cambios se guardan en `CreatureInstance.equipped_moves`, y el Pokémon en el mundo los usa la próxima vez que sale. Si es el activo y no está en combate, re-sacalo para que se apliquen enseguida.
- Al **subir de nivel** y aprender algo nuevo: mensaje "¡X aprendió Y!". Si hay una ranura vacía, se equipa solo; si no, queda disponible en la ficha. **No** quiero el diálogo clásico de "¿olvidar un movimiento?".

## 2. Cambios de modelo de datos (propuesta, adaptala)

- `LearnsetEntry` (Resource): `level: int`, `move: MoveData`.
- `SpeciesData.learnset: Array[LearnsetEntry]`. Si una especie no tiene learnset, se arma uno de compatibilidad con los movimientos de `kit.moves` o `moves` en el nivel 1, para que nada se rompa.
- `CreatureInstance.equipped_moves: Array[MoveData]` (4 ranuras, puede haber `null`). Funciones: `learned_moves()`, `can_equip(move)`, `equip(slot, move)` y `default_equipment()`.
- `MoveUser.setup(...)` toma las ranuras de **`instance.equipped_moves`** en lugar de leer el kit directo. Los salvajes usan `default_equipment()` para su nivel.
- **Mecánica de firma:** sigue viniendo del **kit de la especie**, no de los movimientos equipados. Un movimiento que consume recurso de firma solo puede estar en el learnset de una especie que tenga esa firma.
- `DB` necesita encontrar **cualquier** `MoveData` por id, incluidos los de `data/kits/*/`, para cargar los guardados (por ejemplo `DB.move_by_id(id)`). Filtrá por clase, porque en esas carpetas también están `kit.tres` y las firmas.
- Nada de `if especie == ...` en el código central (regla del proyecto).

## 3. Decisiones a preguntarme ANTES de implementar (AskUserQuestion, con la opción recomendada primero)

1. **¿De dónde salen los niveles del learnset?** (a) Recomendado: los movimientos del kit se aprenden en niveles bajos (los 4 del kit a nivel ≤ 5, así el estilo de pelea está desde el principio) y se suman 2-4 movimientos extra a niveles más altos, tomando como referencia el learnset oficial de FireRed/LeafGreen de PokeAPI (sumándolo a `tools/fetch_official_data.py`). (b) Learnset oficial puro, aunque al nivel 5 el Pokémon tenga 2 movimientos y el kit aparezca de a poco. (c) Niveles a mano.
2. **¿Ranuras libres o con rol?** (a) Recomendado: cualquier movimiento aprendido en cualquiera de las 4 ranuras, con el orden del kit como valor por defecto. (b) Cada movimiento tiene una ranura fija según su rol (por ejemplo R = el de más recarga) y solo se elige entre alternativas para esa ranura.
3. **Herramienta de debug para llenar el equipo**: (a) Recomendado: tecla F9 que, solo con `-- --debug` o en el editor, suma un Pokémon al azar de `DB.species` al nivel del líder. (b) Un botón "Agregar Pokémon (debug)" en la pantalla de Equipo. (c) Un autotest que arme un equipo de 6 y guarde.
4. **Autoguardado**: (a) Recomendado: solo manual por ahora. (b) Además, autoguardado al cambiar de zona y al terminar cada combate.
5. Si te surge otra decisión de diseño importante, preguntame igual.

## 4. Restricciones

- El juego tiene que quedar **siempre ejecutable** y **los autotests existentes tienen que seguir pasando**. Ojo: `new_game()` con un inicial a nivel 5 tiene que dejar equipados **los mismos 4 movimientos del kit, en el mismo orden**, porque los tests leen `moves.slots[0..3]`.
- `GameState.new_game()` sigue funcionando igual para los autotests (que saltan directo al mundo sin pasar por el título).
- La UI, hecha con nodos `Control` (Theme propio está bien) o con `_draw` como el HUD, pero **consistente**. Pixel art con filtro `NEAREST`, legible a 1280×720 y con navegación completa por teclado. Las pantallas nuevas van en `scenes/ui/` y `scripts/ui/`, una escena por responsabilidad.
- Los sistemas se comunican por `Events`, no llamándose entre sí.
- Recordá las trampas de `CLAUDE.md`: nada de `:=` con Variant, `--import` después de agregar un `class_name` y Godot headless siempre con `--quit-after`.

## 5. Criterios de aceptación y pruebas

Agregá `--autotest-save` y `--autotest-party` al `Autotest`:
- Nueva partida → subir EXP → equipar otro movimiento → guardar → reiniciar `GameState` → cargar: equipo, niveles, EXP, PS, movimientos equipados, opciones y posición idénticos.
- Un JSON corrupto o con especie/movimiento inexistente no crashea.
- `add_to_party` rechaza el 7°.
- Cambiar el activo respawnea al compañero correcto.
- Un movimiento de nivel mayor al actual **no** se puede equipar; al subir a ese nivel, sí.
- Al subir de nivel se emite el mensaje de movimiento aprendido.
- No se puede guardar ni abrir el menú en combate.
- Todos los autotests anteriores siguen en "OK".

Además renderizá con `--write-movie` capturas del título, el menú de Equipo con 6 Pokémon (usando el debug) y las dos pestañas de la ficha. Revisalas vos antes de mostrármelas.

## 6. Orden de trabajo sugerido

1. Preguntas de la sección 3.
2. Modelo: learnset, `equipped_moves`, `DB.move_by_id`, serialización `to_dict`/`from_dict` y `MoveUser` leyendo de la instancia (con los autotests viejos en verde).
3. `SaveManager` y `--autotest-save`.
4. Pantalla de título y flujo Continuar / Nueva partida.
5. Menú de pausa y pantalla de Equipo (con el debug), y `--autotest-party`.
6. Ficha del Pokémon: estadísticas y movimientos.
7. Mensaje de "aprendió movimiento" al subir de nivel.
8. Actualizar `docs/PROGRESO.md` y el README (controles: Esc), y después commit y push, como dice `CLAUDE.md`.

Al terminar cada paso, contame brevemente qué cambió y cómo probarlo en el juego.
