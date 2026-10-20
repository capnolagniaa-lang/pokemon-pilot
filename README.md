# Criaturas en Tiempo Real

Prototipo en Godot 4.7 de un juego de criaturas con combate en tiempo real (estilo Pokémon Reloaded).

## Cómo jugar
Bajá [Godot 4.7](https://godotengine.org/download) (versión estándar), abrilo, importá esta carpeta (`project.godot`) y apretá **F5**.

| Acción | Tecla |
|---|---|
| Moverse | WASD / flechas |
| Apuntar | Mouse |
| Ataques 1-4 | 1, 2, 3, 4 (o Clic izq. = 1, Clic der. = 2) |
| Esquivar (invulnerable un instante) | Espacio / Shift |
| Tirar Poké Ball | E |
| Cambiar de criatura | Tab / Q |

Cuanto menos vida tenga el salvaje, más fácil es atraparlo.

## Estructura
- `scripts/game.gd`: datos globales (tipos, ataques, especies, equipo, controles). Para agregar especies o ataques se edita este archivo.
- `scripts/creature.gd`: base de cualquier criatura (stats, ataques, esquive, daño, dibujo).
- `scripts/player_creature.gd`: control del jugador.
- `scripts/wild_creature.gd`: IA de las salvajes.
- `scripts/main.gd`: arena, aparición de salvajes, captura, experiencia, cambio de criatura.
- `scripts/hud.gd`: interfaz.

- `scripts/sprite_data.gd` + `sprites/`: generados por `tools/download_sprites.ps1`. Para sumar un Pokémon: agregá su número de Pokédex en ese script, correlo y sumá la especie en `game.gd`.

## Créditos
Sprites y retratos: [PMDCollab/SpriteCollab](https://github.com/PMDCollab/SpriteCollab) (artistas de la comunidad PMD). Poké Ball: [PokeAPI/sprites](https://github.com/PokeAPI/sprites). Pokémon es de Nintendo/Game Freak/The Pokémon Company; proyecto de fans sin fines de lucro.

Prueba automática sin ventana:
`Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --autotest`
