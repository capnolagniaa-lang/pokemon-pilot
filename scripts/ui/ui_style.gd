class_name UiStyle
extends RefCounted
## Estilo común de los menús (título, pausa, equipo, ficha): paneles oscuros con borde, botones con foco
## amarillo bien visible (navegación por teclado), texto claro. Mismos colores que el HUD de combate.

const BG := Color(0.06, 0.08, 0.11, 0.97)
const BG_SOFT := Color(0.1, 0.13, 0.17, 0.98)
const BORDER := Color(1, 1, 1, 0.14)
const ACCENT := Color(1.0, 0.82, 0.3)
const TEXT := Color(0.93, 0.95, 0.97)
const TEXT_DIM := Color(1, 1, 1, 0.55)
const GOOD := Color(0.3, 0.85, 0.35)
const BAD := Color(0.95, 0.35, 0.3)

const KIND := {MoveData.Kind.PROJECTILE: "Disparo", MoveData.Kind.DASH: "Embestida", MoveData.Kind.AREA: "Área",
	MoveData.Kind.SHIELD: "Defensa", MoveData.Kind.MELEE: "Golpe", MoveData.Kind.ZONE: "Zona", MoveData.Kind.CHANNEL: "Canalizado",
	MoveData.Kind.LUNGE: "Embestida", MoveData.Kind.WHIP: "Látigo", MoveData.Kind.SELF_BUFF: "Mejora"}
const CATEGORY := {MoveData.Category.PHYSICAL: "Físico", MoveData.Category.SPECIAL: "Especial", MoveData.Category.STATUS: "Estado"}
const ARCHETYPES := {"bruiser": "Bruiser", "tanque": "Tanque", "control": "Control", "velocista": "Velocista",
	"hostigador": "Hostigador", "desgaste": "Desgaste", "espaciador": "Espaciador", "asesino": "Asesino"}
const ARCHETYPE_INFO := {
	"bruiser": "Entra, aguanta y gana peleas largas. Rango corto-medio.",
	"tanque": "Absorbe, bloquea y castiga errores.",
	"control": "Domina el espacio y decide dónde se pelea.",
	"velocista": "Movilidad alta: encadena golpes y sale.",
	"hostigador": "Golpea y se va; difícil de atrapar.",
	"desgaste": "Gana acumulando estados de a poco.",
	"espaciador": "Premia la distancia exacta.",
	"asesino": "Remata y explota errores. Muy frágil.",
}
const STAT_NAMES := {"hp": "PS", "attack": "Ataque", "defense": "Defensa", "sp_attack": "At. Esp.",
	"sp_defense": "Def. Esp.", "speed": "Velocidad"}

static var _theme: Theme


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font_size = 16
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", ACCENT)
	t.set_color("font_focus_color", "Button", ACCENT)
	t.set_color("font_pressed_color", "Button", ACCENT)
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.3))
	t.set_stylebox("normal", "Button", box(BG_SOFT, BORDER, 1))
	t.set_stylebox("hover", "Button", box(Color(0.15, 0.19, 0.24, 0.98), Color(ACCENT, 0.6), 1))
	t.set_stylebox("pressed", "Button", box(Color(0.2, 0.17, 0.08, 0.98), ACCENT, 2))
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), ACCENT, 2))
	t.set_stylebox("disabled", "Button", box(Color(0.08, 0.09, 0.11, 0.8), Color(1, 1, 1, 0.06), 1))
	t.set_stylebox("panel", "Panel", box(BG, BORDER, 1))
	t.set_stylebox("panel", "PanelContainer", box(BG, BORDER, 1, 10))
	t.set_color("font_color", "CheckBox", TEXT)
	t.set_color("font_focus_color", "CheckBox", ACCENT)
	t.set_color("font_hover_color", "CheckBox", ACCENT)
	t.set_stylebox("focus", "CheckBox", box(Color(0, 0, 0, 0), ACCENT, 2))
	t.set_stylebox("panel", "TabContainer", box(BG, BORDER, 1, 10))
	t.set_stylebox("tab_selected", "TabContainer", box(Color(0.2, 0.17, 0.08, 0.98), ACCENT, 2, 8))
	t.set_stylebox("tab_unselected", "TabContainer", box(BG_SOFT, BORDER, 1, 8))
	t.set_stylebox("tab_hovered", "TabContainer", box(BG_SOFT, Color(ACCENT, 0.6), 1, 8))
	t.set_stylebox("tab_focus", "TabContainer", box(Color(0, 0, 0, 0), ACCENT, 2, 8))
	t.set_color("font_selected_color", "TabContainer", ACCENT)
	t.set_color("font_unselected_color", "TabContainer", TEXT_DIM)
	_theme = t
	return t


static func box(bg: Color, border: Color, width: int, pad: int = 6) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(3)
	s.set_content_margin_all(pad)
	return s


static func label(text: String, size: int = 16, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func button(text: String, min_width: float = 200.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_width, 38)
	b.focus_mode = Control.FOCUS_ALL
	return b


## Etiqueta de tipo (fondo del color del tipo).
static func type_chip(t: ElementType) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(Color(t.color.darkened(0.25), 0.95), t.color.lightened(0.3), 1, 3))
	var l := label(t.display_name.to_upper(), 11, Color.WHITE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size.x = 64
	p.add_child(l)
	return p


## Barra simple (PS, EXP, stats).
static func bar(ratio: float, color: Color, size: Vector2 = Vector2(200, 8)) -> Control:
	var b := ColorRect.new()
	b.color = Color(0, 0, 0, 0.55)
	b.custom_minimum_size = size
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # que no se estire en los contenedores
	var fill := ColorRect.new()
	fill.color = color
	fill.size = Vector2(size.x * clampf(ratio, 0.0, 1.0), size.y)
	b.add_child(fill)
	return b


static func hp_color(ratio: float) -> Color:
	if ratio > 0.5:
		return GOOD
	if ratio > 0.2:
		return Color(0.95, 0.8, 0.2)
	return BAD


## Panel a pantalla completa con fondo oscurecido.
static func dim() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0.02, 0.03, 0.05, 0.72)
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	return r
