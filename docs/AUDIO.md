# Sonido: música, efectos y gritos — cómo cambiarlos

El juego busca cada sonido **por el nombre del archivo**. Para cambiar una canción o un efecto alcanza con poner tu
archivo con ese nombre; no hay que tocar código. Si falta un archivo, ese sonido no suena (nunca rompe el juego).

## Dónde van los archivos

| Qué | Carpeta | Nombre |
|---|---|---|
| Música | `audio/musica/` | `<tema>.ogg` (también `.mp3` o `.wav`) |
| Efectos | `audio/efectos/` | `<efecto>.wav` (o `.ogg`/`.mp3`) |
| Gritos | `audio/gritos/` | `<n.º de Pokédex>.ogg` (ej. `25.ogg` = Pikachu) |

Se busca en este orden y gana el primero que exista:
1. **La carpeta `audio` al lado del juego** (`PokemonPilot.exe` en la versión portable, o el `.exe` de Godot). Ahí
   cada uno pone su música: por ejemplo, `Pokemon Pilot\audio\musica\ruta_1.ogg`.
2. La carpeta `audio` del proyecto (lo que viene con el juego).
3. `%APPDATA%\Godot\app_userdata\Pokémon Pilot\audio\...`

Formato recomendado: **.ogg** (liviano y se repite sin cortes). `.mp3` también anda. Después de poner un archivo,
cerrá y volvé a abrir el juego.

## Los temas (música)

Hoy no viene música de fondo: los temas suenan cuando pongas tus archivos (por ejemplo, tu soundtrack de
FireRed/LeafGreen convertido a .ogg). Las **cortinas** cortas (curación, captura, subir de nivel, victoria, evolución)
vienen con una versión propia, retro: si ponés tu archivo con el mismo nombre, suena el tuyo.

| Tema (nombre del archivo) | Dónde suena | En FireRed sería… |
|---|---|---|
| `titulo` | Pantalla de título | Title Screen |
| `pueblo_paleta` | Pueblo Paleta y las casas de ahí | Pallet Town |
| `laboratorio` | Laboratorio de Oak | Professor Oak's Lab |
| `ruta_1` | Rutas 1, 2 y 22, garitas | Route 1 |
| `ciudad_verde` | Ciudad Verde y Ciudad Plateada | Viridian City / Pewter City |
| `bosque_verde` | Bosque Verde | Viridian Forest |
| `museo` | Museo de Ciencias | (Pewter / Museum) |
| `ruta_3` | Rutas 3 y 4 | Route 3 |
| `cueva` | Mt. Moon, Vía Subterránea | Mt. Moon |
| `ciudad_celeste` | Ciudad Celeste | Cerulean City |
| `ruta_24` | Rutas 24, 25, 5, 6, Casa de Bill | Route 24 (Nugget Bridge) |
| `ciudad_carmin` | Ciudad Carmín | Vermilion City |
| `ss_anne` | S.S. Anne y su muelle | S.S. Anne |
| `centro_pokemon` | Centros Pokémon | Pokémon Center |
| `tienda` | Tiendas | Poké Mart |
| `gimnasio` | Gimnasios (caminando adentro) | Pokémon Gym |
| `casa` | Otras casas | (la del pueblo) |
| `torneo_recepcion` | Recepción del Torneo | — |
| `batalla_salvaje` | Pelea con un salvaje | Wild Battle |
| `batalla_entrenador` | Pelea con un entrenador | Trainer Battle |
| `batalla_lider` | Líderes de gimnasio | Gym Leader Battle |
| `batalla_rival` | Tu rival | Rival Battle |
| `batalla_torneo` | Rondas del Torneo | — |
| `victoria_salvaje` | Al ganarle a un salvaje (cortina) | Victory (Wild) |
| `victoria_entrenador` | Al ganarle a un entrenador (cortina) | Victory (Trainer) |
| `victoria_lider` | Al ganarle a un líder o en el Torneo (cortina) | Victory (Gym Leader) |
| `evolucion` | Mientras evoluciona | Evolution |
| `evolucion_fin` | Cuando terminó de evolucionar (cortina) | Congratulations |
| `curacion` | Curar en el Centro o con mamá (cortina) | Pokémon Center Heal |
| `captura` | Atrapaste un Pokémon (cortina) | Caught a Pokémon! |
| `subir_nivel` | Subió de nivel (cortina) | Level Up |

**Respaldos**: si falta un tema se prueba con otro parecido (por ejemplo, sin `ruta_3` suena `ruta_1`; sin
`batalla_lider` suena `batalla_entrenador`). Así con unos pocos archivos ya suena todo el juego.

## Cambiar qué tema suena dónde

Está en `data/audio/musica.json` (texto; se edita con el Bloc de notas):
- `"zonas"`: zona → tema. Por ejemplo `"ciudad_plateada": "ciudad_verde"`. Para que Plateada tenga su propio tema:
  cambialo a `"ciudad_plateada": "ciudad_plateada"` y poné `audio/musica/ciudad_plateada.ogg`.
- `"patrones"`: para las zonas que no están en la lista (todos los Centros usan `centro_pokemon` porque su id tiene
  `_centro`).
- `"eventos"`: el tema de cada momento (peleas, victorias, evolución...).
- `"respaldos"`: qué suena si falta un tema.
- `"cortinas"`: los temas que suenan una vez (no se repiten) y después vuelve la música del lugar.

Los nombres de las zonas están en `data/world/kanto.tres` (los `id`), o mirando el Mapa del juego.

## Efectos

Los genera `python -I -B tools/make_sfx.py .` (sonidos retro propios, tipo Game Boy). Para cambiar uno, poné tu
archivo con el mismo nombre en `audio/efectos/`:
`menu_mover`, `menu_aceptar`, `menu_volver`, `golpe`, `golpe_fuerte`, `golpe_<tipo>` (uno por tipo: `golpe_fuego`,
`golpe_agua`, `golpe_electrico`...), `esquive`, `debilitado`, `bola_lanzar`, `bola_sacudir`, `bola_captura`,
`bola_escapa`, `puerta`, `saltar`, `subir_nivel`, `dinero`, `mensaje`, `firma`, `curacion`, `cambio`.
(Correr de nuevo `make_sfx.py` pisa los efectos, pero no tus cortinas en `audio/musica/`.)

## Gritos

Los 386 vienen de PokeAPI (`python -I -B tools/fetch_cries.py .`, los "legacy", de la época de GBA/DS). Suenan cuando
tu Pokémon sale a pelear, cuando un salvaje te ve y (más graves) al debilitarse. Para cambiar uno, reemplazá
`audio/gritos/<n.º>.ogg`.

## Volumen

Esc → Opciones → Volumen: música, efectos y gritos (se guardan en esta PC, no en la partida).

## Para programadores

Autoload `Sound` (`scripts/autoload/sound.gd`): escucha `Events` (zona, peleas, `trainer_battle_started/ended` con su
tipo, evolución, curación, captura, nivel, golpes por tipo, debilitado, puertas, saltos, la bola) y los botones de
todos los menús. `Sound.play_music(tema)`, `Sound.play_jingle(tema)`, `Sound.sfx(nombre)`, `Sound.cry(especie)`.
Test: `--autotest-audio`.
