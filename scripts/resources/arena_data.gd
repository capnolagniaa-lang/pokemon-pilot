class_name ArenaData
extends Resource
## Una arena de combate contra entrenadores (docs/PLAN_ENTRENADORES.md, E-1): la escena (una zona de tiles de
## FireRed, editable con el editor de mapas) y su ambientación (líneas de la cancha, partículas, braseros, luz).
## Datos en data/arenas/<id>.tres; las escenas las arma tools/build_arenas.gd en scenes/world/arenas/.

@export var id: String = ""
@export var display_name: String = ""
@export_file("*.tscn") var scene_path: String = ""
## Celdas locales: dónde se para el entrenador rival, dónde se para el jugador y dónde salen los Pokémon.
@export var foe_trainer_cell: Vector2i = Vector2i.ZERO
@export var player_cell: Vector2i = Vector2i.ZERO
@export var foe_mon_cell: Vector2i = Vector2i.ZERO
@export var player_mon_cell: Vector2i = Vector2i.ZERO
## Rectángulo de la cancha (celdas): ahí se dibujan las líneas.
@export var field: Rect2i = Rect2i()

@export_group("Ambientación")
## Tipo que ambienta la arena (los gimnasios: el de su líder). Vacío = arena común.
@export var element_id: String = ""
@export var line_color: Color = Color(1, 1, 1, 0.35)
## Partículas que flotan: vacío (nada), "polvo", "hojas", "chispas", "burbujas".
@export var particles: String = ""
@export var particle_color: Color = Color(1, 1, 1, 0.5)
## Braseros con fuego en las esquinas de la cancha.
@export var braziers: bool = false
## Tinte de ambiente (se multiplica sobre la arena).
@export var ambient: Color = Color(1, 1, 1, 1)
## Arena de gimnasio: cartel de entrada épico, temblor y presentación del líder.
@export var epic: bool = false
