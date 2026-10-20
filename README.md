# Pokémon Pilot

Juego tipo Pokémon en Godot 4.7: mundo abierto 2D top-down con combate en tiempo real.

## Cómo jugar
Bajá [Godot 4.7](https://godotengine.org/download) (versión estándar), importá esta carpeta (`project.godot`) y apretá **F5**.

| Acción | Tecla |
|---|---|
| Moverse | WASD / flechas |
| Correr | Shift |

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
- **Zona nueva:** creá la escena (copiá una de `scenes/world/zones`), pintala en el editor y agregala a `data/world/kanto.tres` con su origen en celdas.

## Herramientas
```
python -I tools/pret_import.py art_src/pret art/pret                     # convierte los gráficos de FireRed
godot --headless --path . --script res://tools/build_world.gd -- --force  # regenera TileSet y zonas (pisa cambios)
godot --headless --path . -- --autotest                                   # prueba automática
```

## Créditos
Sprites y retratos: [PMDCollab/SpriteCollab](https://github.com/PMDCollab/SpriteCollab). Tiles, entrenador y objetos: [pret/pokefirered](https://github.com/pret/pokefirered). Poké Ball: [PokeAPI/sprites](https://github.com/PokeAPI/sprites). Pokémon es de Nintendo/Game Freak/The Pokémon Company; proyecto de fans sin fines de lucro.
