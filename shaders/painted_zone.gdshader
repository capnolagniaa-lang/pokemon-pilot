shader_type canvas_item;
// Zona repintada (PaintedZone): funde la imagen de un momento del día con la del siguiente según la hora (luz
// horneada por Qwen) y, para la capa de techos y copas, deja solo las celdas marcadas en `cells` (las de la capa
// Overhead de la zona).

uniform sampler2D tex_b : filter_linear_mipmap;  // la del momento siguiente (TEXTURE = la del anterior)
uniform float mix_t = 0.0;
uniform bool use_cells = false;
uniform sampler2D cells : filter_nearest;        // 1 píxel por celda: blanco = va en esta capa

void fragment() {
	vec4 a = texture(TEXTURE, UV);
	vec4 b = texture(tex_b, UV);
	COLOR = mix(a, b, mix_t);
	if (use_cells && texture(cells, UV).r < 0.5) {
		discard;
	}
}
