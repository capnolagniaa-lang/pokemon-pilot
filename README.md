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
- **Zona nueva:** sumá una fila a `REGION` en `tools/build_world.gd` (id, nombre, columna, fila, bioma) y regenerá; o creá la escena a mano y agregala a `data/world/kanto.tres`.

## Herramientas
```
python -I tools/pret_import.py art_src/pret art/pret                     # convierte los gráficos de FireRed
godot --headless --path . --script res://tools/build_world.gd -- --force  # regenera TileSet y zonas (pisa cambios)
godot --headless --path . -- --autotest                                   # recorre las 9 zonas
godot --path . --write-movie mapa.png --fixed-fps 30 -- --overview      # imagen de toda la región
```

## Créditos
Sprites y retratos: [PMDCollab/SpriteCollab](https://github.com/PMDCollab/SpriteCollab). Tiles, entrenador y objetos: [pret/pokefirered](https://github.com/pret/pokefirered). Poké Ball: [PokeAPI/sprites](https://github.com/PokeAPI/sprites). Pokémon es de Nintendo/Game Freak/The Pokémon Company; proyecto de fans sin fines de lucro.
