# Prompt: editor de mapas interactivo (ejecutable)

> Pegá esto en Claude Code abierto en la carpeta del proyecto `pokemon-tiempo-real` (Pokémon Pilot),
> o decile: "Leé `docs/PROMPT_EDITOR_DE_MAPAS.md` y hacelo".

---

Hola Claude. Antes de tocar nada, seguí las reglas de `CLAUDE.md`: leé `docs/PROGRESO.md` ("Dónde estamos") y la sección de arquitectura del mundo. Hablame en español rioplatense.

Quiero una **herramienta para armar los mapas del juego de forma interactiva**: pintar sobre un lienzo con los gráficos que ya tiene el juego, guardar, y que el juego use ese mapa. Tiene que **respetar los tipos de tile, los tags, las colisiones y los objetos** que ya existen, y tiene que ser **ejecutable**, o sea abrirse con un acceso directo, como el juego, sin tener que entrar al editor de Godot. Anotala en `docs/PROGRESO.md` como **"Herramienta — Editor de mapas"**. Es una herramienta, no una etapa del juego, así que no corre la numeración de etapas.

## 0. Cómo están hechos los mapas hoy (análisis del proyecto, para que no lo redescubras)

**Región**
- `data/world/kanto.tres` es un `WorldData` con `tile_size = 16`, `spawn_cell` y 9 `ZoneEntry`.
- Cada `ZoneEntry` tiene `id`, `display_name`, `scene_path`, `origin` (en celdas), `size` (48×32), `biome`, `hub` (plaza central) y `exits` (lado → celda local donde arranca el camino).
- Las zonas forman una grilla de 3×3. `ZoneStreamer` las carga y descarga en segundo plano según dónde esté la cámara.

**Escena de zona** (`scenes/world/zones/<id>.tscn`)
- La raíz es un `Node2D` con `scripts/world/zone.gd`: `zone_id` y `tree_cells` (celda superior izquierda de cada árbol 2×2; la usa `TreeShadows`).
- Capas hijas, en este orden:
  - `Ground`: `TileMapLayer`, z −10.
  - `Water`: z −9, material `shaders/materials/water.tres`. El agua va en esta capa y abajo, en `Ground`, se pone pasto.
  - `Foliage`: z −8, material `foliage_wind.tres`. Pasto alto y flores, con pasto abajo en `Ground`.
  - `TreeShadows`: `Node2D` con `tree_shadows.gd`, z −7.
  - `Overhead`: z 20, material `canopy_wind.tres`. La parte "de arriba" de los metatiles, que tapa al personaje (copas).
  - `Objects`: `Node2D` con y-sort. Adentro van instancias de `EnvObject`: `rock_smash_rock.tscn` (roca frágil), `strength_boulder.tscn` (roca pesada) y `cut_tree.tscn` (árbol cortable). Se posicionan en `celda*16 + (8, 16)`, con origen en los pies.

**TileSet** (`art/tiles/world_tileset.tres`)
- Tiles de 16×16 con 3 fuentes:
  - `0` = `general_below.png` (640 metatiles de FireRed, 16 por fila).
  - `1` = `general_anim.png` (versiones animadas de 167 metatiles; `build_world._below_ref()` prefiere la animada).
  - `2` = `general_above.png` (la parte superior; solo los marcados en `manifest.json → above_used`).
- **Capas de física**: `0` es sólido (capa de colisión 1, "mundo") y `1` es agua (capa 2).
- **Custom data `tags`** (`PackedStringArray`), que leen `Zone.get_tags()`, `World.tags_at()` (pasado por el `EnvironmentGrid`), el `WildSpawner` (aparece en `pasto_alto`), el `TallGrassOverlay` y las reglas del entorno reactivo:
  - pasto `suelo, pasto`; pasto alto `suelo, pasto_alto, inflamable`; flores `… flores, inflamable`;
  - arena `suelo, arena`; tierra `suelo, tierra`;
  - agua `agua, conductor, congelable` (+ física 1);
  - árbol `arbol, solido, inflamable` (+ física 0).
- **Solo unos 49 de los 640 metatiles tienen tags.** Todos los demás no tienen tags ni colisión.

**Cómo se generan hoy**
- Las genera `tools/build_world.gd` (SceneTree headless) a partir de `REGION` y `BIOMES`, con roles (`ROLES`), autotile 3×3 propio para arena, tierra, laguna y pradera clara (`_autotile`), árboles 2×2 con copa "apilada" cuando hay otro árbol arriba (`finish_trees`), borde de árboles y caminos.
- Sin `--force` no pisa zonas existentes; **con `--force` pisa todo** lo pintado a mano.

**Otros datos útiles**
- `art/pret/tiles/manifest.json` tiene, por metatile, `behavior` y `layer_type` de FireRed (sirven para sugerir tags). Además de `general` ya están exportados los tilesets **`viridian_forest`** y **`pallet_town`**, que todavía **no** están en el TileSet.
- El entorno reactivo (`EnvironmentGrid`) toca las capas en tiempo de juego. Por ejemplo, el hielo saca el tile de `Water` y lo restaura. Por eso la estructura de capas **no se puede cambiar**.
- Hay un estilo de UI compartido en `scripts/ui/ui_style.gd`, y debug con `-- --debug` (`World.debug_enabled()`).

## 1. Qué ya da Godot y hay que reutilizar (no reinventar)

- **`TileMapLayer` y `TileSet` funcionan igual en tiempo de ejecución**: `set_cell`, `erase_cell`, `get_cell_source_id`/`atlas_coords`, `get_used_cells`, `local_to_map`, y la física y el custom data se leen del TileSet. El lienzo del editor tiene que ser **las mismas capas de una zona real**, no un dibujo propio.
- **Terrains del TileSet** (`terrain_sets` + `TileMapLayer.set_cells_terrain_connect` / `set_cells_terrain_path`): es el autotile nativo de Godot. Evaluá definir terrains para arena, tierra, laguna y pradera clara en el TileSet, en vez de portar `_autotile`. Si se puede, `build_world.gd` tendría que pasar a usar lo mismo. Si los 3×3 de FireRed no encajan bien con los terrains (esquinas interiores, por ejemplo), portá `_autotile` a un script compartido y explicame por qué.
- **`TileMapPattern`** (`TileMapLayer.get_pattern` / `set_pattern`, `TileSet.add_pattern`): para "sellos" de varias celdas, como el árbol 2×2 (below + overhead) o recortes copiados del mapa.
- **`UndoRedo`** (la clase core, usable en runtime) para deshacer y rehacer.
- **`PackedScene.pack` + `ResourceSaver.save`**: es lo mismo que ya usa `build_world.gd` para guardar zonas (acordate de poner `owner` en los nodos).
- `Camera2D` (zoom y paneo), `FileDialog`, `ItemList`/`GridContainer` para la paleta y `SubViewport` para miniaturas.
- **El editor de Godot ya tiene un pintor de `TileMapLayer`** (pincel, línea, rectángulo, balde, terrains) y un editor de TileSet (colisiones y custom data). No reemplaza lo que pido porque no es ejecutable aparte y no conoce nuestras reglas (agua con pasto abajo, árboles con copa y sombra, objetos y salidas). Pero **reutilizá la misma data** (TileSet, terrains y patterns), así lo que se pinte en un lado se puede seguir editando en el otro. Mencionalo en el README.

## 2. Lo que quiero

### A. Forma de ejecutarlo
- Una escena `scenes/tools/map_editor.tscn` (scripts en `scripts/tools/map_editor/`) que se abre con `-- --map-editor`.
- Crear un **acceso directo en el escritorio, "Pokémon Pilot — Editor de mapas"**: igual que el del juego, con `--path <proyecto> -- --map-editor` y el mismo ícono.
- Desde la pantalla de título, solo con `-- --debug` o en el editor: un botón "Editor de mapas".
- Guarda directo en `res://` (funciona porque el juego corre desde la carpeta del proyecto y no exportado). Si `res://` no se puede escribir, avisá claramente.

### B. Lienzo
- Muestra una zona con **sus capas reales**. Zoom con la rueda, paneo con clic del medio o Espacio + arrastrar, grilla de celdas opcional y coordenadas de la celda bajo el cursor.
- Muestra **atenuados los bordes de las zonas vecinas** según `kanto.tres`, para que los caminos y el agua empalmen.
- **Visibilidad por capa** (Ground, Water, Foliage, Overhead, Objects) y "solo capa activa".
- **Superposiciones de depuración** (toggles):
  - colisión sólida (rojo) y agua (azul);
  - tags (con un selector: por ejemplo, ver todo lo `inflamable` o el `pasto_alto` donde aparecen salvajes);
  - celdas sin tags;
  - `hub` y `exits` de la zona;
  - `spawn_cell` si cae en esta zona.

### C. Pinceles con reglas del juego (el modo principal)
Pinceles "semánticos" que ya saben en qué capa va cada cosa y qué poner abajo:
- **Pasto** (con las variantes aleatorias de `GRASS_IDS`), **pradera clara**, **arena**, **tierra**: los que tienen autotile 3×3 recalculan bordes y esquinas al pintar y al borrar.
- **Pasto alto** y **flores**: van en `Foliage`, con pasto en `Ground`.
- **Agua / laguna**: va en `Water` con autotile y pasto en `Ground`.
- **Árbol**: sello 2×2 que pone below, la parte `Overhead` (`above_used`) y la copa "apilada" si hay otro árbol justo arriba (y actualiza el de abajo). También agrega o saca la celda en `tree_cells`, para que las sombras sigan andando. **Borde de árboles**: hilera doble sobre un lado.
- **Objetos**: roca frágil, roca pesada, árbol cortable. Se agregan como instancias en `Objects`, en la celda (no hay dos objetos en la misma celda). La lista sale de una carpeta (`scenes/world/objects/`), así un objeto nuevo aparece solo.
- **Borrar**: por capa, o "todo lo de la celda", que limpia los tiles y el objeto y deja pasto.

### D. Modo tile crudo (avanzado)
- Paleta con **todos los metatiles** de las 3 fuentes, agrupados por tags y con filtro ("con tags", "sin tags", "con colisión", "animados"). Hover con el número de metatile y sus tags.
- Se pinta en la capa activa. Si el metatile tiene parte `above`, preguntá o hacelo automático: que ponga también la de `Overhead`.
- **Gotero** (Alt + clic): toma el tile o el pincel de la celda.

### E. Herramientas
- Pincel (tamaño 1, 2 o 3), línea, rectángulo (relleno o borde), balde (relleno por inundación en la capa activa), seleccionar, copiar y pegar (con `TileMapPattern`), y gotero.
- **Deshacer y rehacer** (Ctrl+Z / Ctrl+Y) para todo: tiles, objetos, árboles, hub y salidas.
- Atajos visibles en una barra de ayuda, con el mismo estilo que el juego (`UIStyle`).

### F. Propiedades de los tiles: tags y colisiones
- Panel para ver y **editar los tags y la colisión** (ninguna, sólida o agua; cuadrado completo de 16×16) de un metatile del TileSet. Eso habilita tiles que hoy están sin tags: cercas, carteles, caminos, etc.
- Sugerí tags a partir de `manifest.json → behavior` cuando se pueda.
- Guarda en `art/tiles/world_tileset.tres`, **haciendo un backup antes**. **Avisá que afecta a todas las zonas.**
- Ojo: `build_world.gd` regenera el TileSet con `--force`. Hacé que **no pierda** lo editado. Por ejemplo, moviendo los roles y tags a un `.tres` de datos (`data/world/tile_roles.tres`) que lean tanto `build_world.gd` como el editor. Proponé la forma antes de hacerla.

### G. Zonas y región
- **Abrir** cualquier zona de `kanto.tres`.
- **Nueva zona**: id, nombre, bioma (los de `BIOMES`), tamaño (por defecto 48×32) y su lugar en la grilla de la región (`origin`, que no puede encimarse con otra). Arranca en pasto, o generada con el generador de `build_world.gd` para ese bioma, y la agrega a `kanto.tres`.
- Editar `display_name`, `biome`, `hub` y `exits` (arrastrando marcadores sobre el lienzo), y elegir `spawn_cell` del mundo.
- **Validaciones al guardar** (advertencias, no bloqueos, salvo lo que rompa el juego):
  - cada salida es transitable (no es sólida ni agua) y **empalma con la salida de la vecina**;
  - hay un camino transitable entre el `hub` y cada salida (búsqueda en grilla con la colisión real);
  - `spawn_cell` no cae en algo sólido;
  - si la zona no tiene `pasto_alto`, avisar que no aparecen salvajes;
  - no hay tiles fuera del tamaño de la zona.

### H. Guardar y "que se aplique"
- **Guardar** escribe `scenes/world/zones/<id>.tscn` con **exactamente la misma estructura** que genera `build_world.gd`: nombres, orden, z_index, materiales, script, `tree_cells` y owners. Además actualiza `kanto.tres` si cambió algo de la región.
- Antes de pisar, hace **backup** en `scenes/world/zones/.backup/<id>_<fecha>.tscn` y se queda con los últimos 5.
- Indicador de "cambios sin guardar", que pregunta al cerrar o al cambiar de zona.
- **Proteger lo editado a mano**: `build_world.gd -- --force` **no** tiene que pisar zonas editadas con la herramienta (por ejemplo, con una marca en la zona o una lista en `data/world/`, más una opción explícita para forzarlo igual). Documentalo en `CLAUDE.md`, en la parte de "Pipeline de contenido".
- **Probar en el juego**: un botón (F5) que guarda y abre el juego en esa zona, con el entrenador en la celda que elijas. Puede ser un proceso nuevo (`OS.create_process` con `-- --debug --start-zone <id> --start-cell x,y`) o un cambio de escena con vuelta al editor. Elegí la opción más robusta y explicame por qué.
- Si la partida guardada del jugador quedó en una celda que ahora es sólida, al cargar se reubica en la celda transitable más cercana. **Verificá que `World._ready()` lo haga, y si no, agregalo.**

## 3. Decisiones a preguntarme ANTES de implementar (AskUserQuestion, con la opción recomendada primero)

1. **¿Dónde vive la herramienta?** (a) Recomendado: modo aparte del mismo proyecto, con `-- --map-editor` y su propio acceso directo (es ejecutable, reutiliza todo y no necesita el editor de Godot). (b) Un `EditorPlugin` dentro del editor de Godot (más integrado, pero no es ejecutable). (c) Las dos cosas: el núcleo compartido y dos frentes.
2. **¿Autotile con terrains de Godot o portando `_autotile`?** (a) Recomendado: probar terrains de Godot y quedarte con eso si se ve igual que hoy; si no, portar `_autotile` a un script compartido. (b) Portar `_autotile` directamente.
3. **¿Cómo protegemos las zonas editadas del `--force`?** (a) Recomendado: una marca `hand_edited` en la zona; `--force` las saltea salvo con `--force-all`. (b) Una lista en `data/world/hand_edited.tres`. (c) Que `--force` solo regenere el TileSet y nunca las zonas.
4. **¿Sumamos ya los tilesets `viridian_forest` y `pallet_town` a la paleta?** (a) Recomendado: todavía no; primero el editor con `general` y que quede preparado para sumar fuentes. (b) Sí, ahora.
5. Si te surge otra decisión de diseño importante, preguntame igual.

## 4. Restricciones

- **No romper el juego**: el formato de la zona guardada tiene que cargar igual en `ZoneStreamer`, `EnvironmentGrid`, `ReactionSystem`, `WildSpawner`, `TallGrassOverlay` y `TreeShadows`. **Todos los autotests existentes tienen que seguir en "OK"**, incluidos `--autotest` (recorre las 9 zonas) y `--autotest-env` (usa el mapa real de Ruta 1).
- **Abrir y guardar una zona sin cambios no tiene que modificarla**: el mismo contenido de tiles y objetos, sin diferencias de comportamiento. Comprobalo.
- Data-driven: la paleta, los pinceles y los objetos salen de los datos (TileSet, roles y carpeta de objetos), no de listas escritas en la UI.
- Usá la **misma estética de UI** que el juego (`UIStyle`) y filtro `NEAREST`. Que sea usable a 1280×720 con mouse y teclado.
- Recordá las trampas de `CLAUDE.md`: nada de `:=` con Variant, `--import` después de agregar un `class_name`, Godot headless siempre con `--quit-after`, y archivos `.ps1` sin caracteres no ASCII (si creás el acceso directo con PowerShell).

## 5. Criterios de aceptación y pruebas

Agregá **`--autotest-map-editor`** que, sin ventana:
- Abre Ruta 1 en el editor y la guarda en una ruta temporal **sin cambios**: tiles por capa, objetos y `tree_cells` idénticos al original.
- Pinta arena en un rectángulo, agua en otro, un árbol y una roca frágil, y guarda en temporal. Al recargar:
  - los bordes del autotile son correctos;
  - el agua está en `Water` con pasto abajo;
  - el árbol tiene `Overhead` y está en `tree_cells`;
  - la roca es un `EnvObject` con sus tags.
- Comprueba que `Zone.get_tags()` y la colisión de esas celdas son los esperados.
- Hace deshacer y rehacer de esas operaciones y verifica el estado.
- Las validaciones detectan una salida bloqueada y una zona sin pasto alto.
- Crea una zona nueva en un lugar libre de la región y la valida (sin dejarla en `kanto.tres`).

Además:
- Que `--force` respete las zonas marcadas.
- Que todos los autotests anteriores sigan en "OK".
- Renderizá con `--write-movie` capturas del editor (lienzo con superposición de colisiones, paleta y panel de tile) y revisalas vos antes de mostrármelas.

## 6. Orden de trabajo sugerido

1. Preguntas de la sección 3.
2. Núcleo compartido entre `build_world.gd` y el editor: roles y tags como datos, autotile (terrains o porteado) y "guardar zona" con el formato actual. Que `build_world.gd` lo use y que los autotests sigan en verde.
3. Escena del editor: lienzo con capas reales, cámara, abrir zona, superposiciones y guardar con backup (prueba de ida y vuelta).
4. Pinceles semánticos, objetos, árboles y herramientas (línea, rectángulo, balde, copiar/pegar), con deshacer y rehacer.
5. Modo tile crudo, gotero y panel de propiedades de tile (tags y colisión) con backup del TileSet.
6. Región: nueva zona, hub, salidas, `spawn_cell`, validaciones y protección del `--force`.
7. "Probar en el juego" y reubicación segura del jugador al cargar.
8. `--autotest-map-editor`, acceso directo del escritorio y documentación (`README` con controles del editor, `CLAUDE.md` y `PROGRESO.md`). Después, commit y push como dice `CLAUDE.md`.

Al terminar cada paso, contame brevemente qué cambió y cómo probarlo.
