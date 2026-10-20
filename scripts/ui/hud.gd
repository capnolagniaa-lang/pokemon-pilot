extends Control
## Interfaz del mundo: cartel de zona, Pokémon activo y ayuda de controles.

@onready var zone_banner: PanelContainer = $ZoneBanner
@onready var zone_label: Label = $ZoneBanner/Label
@onready var portrait: TextureRect = $Party/HBox/Portrait
@onready var party_label: Label = $Party/HBox/Label

var _banner_tween: Tween


func _ready() -> void:
	zone_banner.modulate.a = 0.0
	Events.zone_entered.connect(_on_zone_entered)
	Events.party_changed.connect(_refresh_party)
	_refresh_party()


func _on_zone_entered(zone: ZoneEntry) -> void:
	zone_label.text = zone.display_name
	if _banner_tween:
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_property(zone_banner, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_interval(2.0)
	_banner_tween.tween_property(zone_banner, "modulate:a", 0.0, 0.6)


func _refresh_party() -> void:
	var c := GameState.active()
	if c == null:
		return
	portrait.texture = DB.portrait_of(c.species)
	party_label.text = "%s  Nv. %d\nPS %d/%d" % [c.species.display_name, c.level, ceili(c.hp), ceili(c.max_hp())]
