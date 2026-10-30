extends Control
## Interfaz del mundo: reloj y cartel de zona arriba a la izquierda (el resto lo dibuja BattleHUD).

@onready var zone_banner: PanelContainer = $ZoneBanner
@onready var zone_label: Label = $ZoneBanner/Label

var _banner_tween: Tween


func _ready() -> void:
	zone_banner.modulate.a = 0.0
	var clock := HudClock.new()
	clock.name = "Clock"
	clock.position = Vector2(16, 16)
	add_child(clock)
	zone_banner.position.y = 16 + HudClock.SIZE.y + 8  # el cartel de zona, abajo del reloj
	Events.zone_entered.connect(_on_zone_entered)
	# La caja de diálogo va abajo, donde está el HUD: se esconde con cualquier diálogo (charlas, torneo, peleas...).
	Events.dialog_started.connect(func(): visible = false)
	Events.dialog_finished.connect(func(): visible = true)


func _on_zone_entered(zone: ZoneEntry) -> void:
	zone_label.text = zone.display_name
	if _banner_tween:
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_property(zone_banner, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_interval(2.0)
	_banner_tween.tween_property(zone_banner, "modulate:a", 0.0, 0.6)
