# Pokémon Pilot

Juego tipo Pokémon en Godot 4.7: mundo abierto 2D top-down con combate en tiempo real.

Estado y próximos pasos: [docs/PROGRESO.md](docs/PROGRESO.md). Guía técnica: [CLAUDE.md](CLAUDE.md).

La región tiene 9 zonas (3×3, 144×96 celdas) que se cargan sin cortes: Bosque Profundo, Bosque Verde, Lago Celeste, Pradera Florida, Ruta 1 (inicio), Colinas Rocosas, Humedal, Pradera Sur y Arboleda.

## Cómo jugar
Bajá [Godot 4.7](https://godotengine.org/download) (versión estándar), importá esta carpeta (`project.godot`) y apretá **F5**.

Acceso directo sin abrir el editor: un `.lnk` que apunte a `Godot_v4.7.2-stable_win64.exe` con argumentos `--path "<carpeta del proyecto>"` e ícono `icon.ico` (en la PC de desarrollo está en el escritorio como **Pokémon Pilot**).

| Acción | Tecla |
|---|---|
| Moverse | WASD / flechas |
| Correr | Shift |
| Sacar / guardar a tu Pokémon para pelear | F |
| Mover al Pokémon (en combate) | WASD |
| Apuntar | Mouse |
| Ataque 1 | Clic izq. (o 1) |
| Ataque 2 | Clic der. (o 2) |
| Ataque 3 | Q (o 3) |
| Ataque 4 (el de más recarga) | R (o 4) |
| Esquivar | Espacio |
| Menú (Equipo, Guardar, Opciones) | Esc |
| Menús | Flechas/WASD + Enter/Espacio (o mouse) · Tab cambia de pestaña en la ficha |

El mundo **reacciona a los ataques**: el agua moja el suelo, el hielo congela el agua (puente para cruzar), el
eléctrico corre por el agua y lo mojado, y las embestidas rompen las rocas frágiles.

La partida se **guarda a mano** desde el menú (Esc → Guardar; no se puede en combate) y se retoma con
**Continuar** en la pantalla de título. En **Equipo** (hasta 6) elegís quién te sigue y en la **ficha** de cada
Pokémon ves sus stats y equipás sus 4 movimientos entre los que ya aprendió (aprende más al subir de nivel).

Al empezar elegís la **dificultad de la IA** (Fácil, Normal o Difícil) y si querés el **modo práctica** (tu Pokémon vuelve al instante con la vida al máximo si se debilita).

Si un salvaje te ve, el combate empieza solo y pasás a controlar a tu Pokémon. Sin energía: cada ataque tiene su recarga. Cada Pokémon con kit tiene un **estilo de pelea**: Charmander es **bruiser** (Ascuas en abanico, Arañazo que se lanza y encadena 2 golpes, Giro Fuego que atrapa, Embestida Ígnea; y su **Calor** lo lleva a Mar Llamas), Bellsprout y Bulbasaur son **control** (esporas que ralentizan y envenenan, Látigo Cepa que agarra, defensiva y Somnífero). Diseño: [docs/PLAN_IDENTIDAD_COMBATE.md](docs/PLAN_IDENTIDAD_COMBATE.md).

## Editor de mapas
Herramienta para armar las zonas pintando sobre un lienzo con los gráficos del juego. Se abre con el acceso
directo **Pokémon Pilot — Editor de mapas** (`--path "<proyecto>" -- --map-editor`), o desde el título con
`-- --debug` (botón "Editor de mapas"). No hace falta abrir el editor de Godot: guarda directo en `res://`
(funciona porque el juego corre desde la carpeta del proyecto; si `res://` no se puede escribir, avisa).

- **Lienzo**: la zona con sus capas reales (Ground, Water, Foliage, Overhead, Objects) y los bordes de las
  zonas vecinas atenuados para empalmar caminos y agua. Menú **Capas** (visibilidad, "solo capa activa") y
  **Ver** (grilla, colisión sólida en rojo / agua en azul, celdas sin tags, resaltar un tag, plaza y salidas,
  inicio del juego, vecinas).
- **Pinceles** (con las reglas del juego): pasto, pradera clara, arena, tierra y agua con **autotile** de bordes
  y esquinas; pasto alto y flores en Foliage con pasto abajo; agua en Water con pasto abajo; **árbol 2×2** con
  copa en Overhead, copa "apilada" si hay otro árbol justo arriba y sombra (`tree_cells`); borde de árboles;
  **objetos** (todo lo de `scenes/world/objects/`); borrar todo (deja pasto) o la capa activa. Los pinceles salen
  de `data/world/tile_roles.tres`.
- **Tiles** (modo crudo): los 640 metatiles agrupados por tags, con filtros (con/sin tags, con colisión,
  animados, parte de arriba). Se pinta en la capa activa; si el tile tiene parte de arriba, esa parte se pone sola en Overhead.
- **Tile**: tags y colisión (ninguna / sólida / agua) de un metatile, con sugerencias según el *behavior* de
  FireRed. Guarda en `tile_roles.tres` y en el TileSet (con backup en `art/tiles/.backup/`). Cambia en **todas** las zonas.
- **Zona**: nombre, bioma, plaza (hub) y salidas (se arrastran sobre el mapa), inicio del juego, validaciones
  (salidas transitables y que empalmen con la vecina, camino de la plaza a cada salida, inicio libre, pasto alto
  para los salvajes, tiles fuera de la zona) y **Nueva zona** (en un lugar libre de la región, en pasto o generada
  con el bioma).
- **Guardar** (Ctrl+S) escribe `scenes/world/zones/<id>.tscn` con la misma estructura que `build_world.gd`,
  marcada `hand_edited`, y `data/world/kanto.tres` si cambió la región. Antes hace backup en
  `scenes/world/zones/.backup/` (quedan los últimos 5). Pregunta si hay cambios sin guardar.
- **Probar ▶ (F5)**: guarda y abre el juego en otro proceso, en esa zona, con el entrenador en la celda del mouse
  (con tu equipo guardado; lo que guardes ahí va a otro archivo y no pisa tu partida).

| Acción | Tecla |
|---|---|
| Pincel / línea / rectángulo / balde | B / L / R / G (F: rectángulo relleno o borde) |
| Seleccionar, copiar, pegar, borrar selección | M, Ctrl+C, Ctrl+V, Supr |
| Gotero (toma el pincel o el tile de la celda) | I o Alt+clic |
| Mover plaza y salidas | H (arrastrar los marcadores) |
| Tamaño del pincel (1-3) / capa activa | [ ] / 1-5 |
| Pintar / borrar | Clic izq. / Clic der. |
| Deshacer / rehacer | Ctrl+Z / Ctrl+Y (o Ctrl+Shift+Z) |
| Zoom / mover el mapa | Rueda / clic del medio o Espacio + arrastrar |
| Grilla / colisión / celdas sin tags | F2 / F3 / F4 |
| Guardar / probar en el juego | Ctrl+S / F5 |

El editor de Godot también sirve: lo pintado con la herramienta usa el mismo TileSet, así que se puede seguir
retocando una zona con el pintor de `TileMapLayer` de Godot (y al revés). Pero ese pintor no conoce nuestras
reglas (agua con pasto abajo, árboles con copa y sombra, objetos, salidas), por eso existe esta herramienta.

**Por qué el autotile no usa los terrains de Godot**: se probaron terrains (modo esquinas y lados) con los 3×3 de
FireRed y daban otra pieza en ~7% de las celdas: tratan lo de afuera de la zona como vacío (cierran los caminos
en las salidas, donde tienen que seguir en la zona vecina) y, como el 3×3 no tiene esquinas interiores, eligen
una esquina donde se cruzan caminos. Por eso el autotile de `build_world.gd` se pasó a un script compartido
(`ZoneBuilder.autotile_piece`) que usan el generador y el editor.

## Estructura

```
data/                 Contenido (Resources .tres): se agrega sin tocar código
  types/              ElementType + type_chart.tres (tabla de efectividad)
  moves/              MoveData
  species/            SpeciesData
  world/kanto.tres    WorldData: zonas y su posición en el mundo
  config/             GameConfig: iniciales, nivel y objetos iniciales
scripts/
  autoload/           Events (bus de señales), DB (carga data/), GameState, Controls, Autotest
  resources/          Clases de los Resources
  core/               StateMachine + State
  characters/         Entrenador y sus estados
  creatures/          Criatura, su sprite PMD y sus estados
  world/              World, ZoneStreamer (carga de zonas sin corte), Zone
  ui/                 HUD, selección de inicial
  generated/          sprite_data.gd (lo genera tools/download_sprites.ps1)
scenes/               Una escena por responsabilidad (world, zones/, characters, creatures, ui)
art/pret/             Tiles, entrenador y objetos de FireRed (generados por tools/pret_import.py)
art/tiles/            TileSet del mundo (tags + colisiones)
art/fx/               Entorno de render (glow) y texturas de efectos
art_src/pret/         Gráficos originales del decomp pret/pokefirered
shaders/              Viento, agua, sombras de nubes, post-procesado (tilt-shift, color, viñeta)
sprites/              Sprites PMD de los Pokémon
tools/                Generadores de contenido
```

### Capas de colisión
1 mundo · 2 agua · 3 jugador · 4 criatura aliada · 5 criatura salvaje · 6 hurtbox aliada · 7 hurtbox salvaje · 8 entorno

### Tiles con tags
Cada tile del TileSet (`art/tiles/world_tileset.tres`) tiene un *custom data* `tags` (`inflamable`, `agua`, `conductor`, `fragil`, ...). `Zone.get_tags(celda)` los devuelve; el sistema de entorno reactivo los usa.

## Agregar contenido
- **Ataque/especie:** duplicá un `.tres` en `data/moves` o `data/species` y editalo en el inspector.
- **Pokémon nuevo (sprites):** sumá su número de Pokédex en `tools/download_sprites.ps1` y corrélo.
- **Zona nueva:** con el editor de mapas ("Nueva zona…"); o sumá una fila a `REGION` en `tools/build_world.gd` (id, nombre, columna, fila, bioma) y regenerá.
- **Objeto del entorno nuevo:** una escena con `EnvObject` (tags, `display_name`) en `scenes/world/objects/`: aparece sola en el editor.

## Herramientas
```
python -I tools/pret_import.py art_src/pret art/pret                     # convierte los gráficos de FireRed
godot --headless --path . --script res://tools/build_world.gd -- --force      # regenera TileSet y zonas (salvo las editadas a mano)
godot --headless --path . --script res://tools/build_world.gd -- --force-all  # regenera todo (pisa lo editado a mano)
godot --path . -- --map-editor                                            # editor de mapas
godot --headless --path . -- --autotest                                   # recorre las 9 zonas
godot --path . --write-movie mapa.png --fixed-fps 30 -- --overview      # imagen de toda la región
```

## Créditos
Sprites y retratos: [PMDCollab/SpriteCollab](https://github.com/PMDCollab/SpriteCollab). Tiles, entrenador y objetos: [pret/pokefirered](https://github.com/pret/pokefirered). Poké Ball: [PokeAPI/sprites](https://github.com/PokeAPI/sprites). Pokémon es de Nintendo/Game Freak/The Pokémon Company; proyecto de fans sin fines de lucro.
