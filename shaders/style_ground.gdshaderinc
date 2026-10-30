// Cuerpo común de style_ground.gdshader (pixel art: filtro nearest) y style_ground_hd.gdshader (HD: filtro lineal);
// cada uno define TEX_FILTER antes de incluir esto.
// Suelo de un paquete de estilo (StyleOverlay, docs/PLAN_TERRENO_PROPIO.md). `cells` = un píxel por celda con el
// índice del material (R × 255). Cada píxel busca su celda corrida un poco con ruido (pegado a la grilla de píxeles):
// así el borde entre dos materiales sale orgánico sin dibujar piezas de transición. Un borde más oscuro marca el
// cambio de material, y el agua ondula.

uniform sampler2D cells : filter_nearest, repeat_disable;
uniform vec2 zone_cells = vec2(40.0, 32.0);
uniform sampler2D tex0 : TEX_FILTER, repeat_enable;  // pasto
uniform sampler2D tex1 : TEX_FILTER, repeat_enable;  // tierra
uniform sampler2D tex2 : TEX_FILTER, repeat_enable;  // empedrado
uniform sampler2D tex3 : TEX_FILTER, repeat_enable;  // agua
uniform sampler2D tex4 : TEX_FILTER, repeat_enable;  // roca
uniform sampler2D tex5 : TEX_FILTER, repeat_enable;  // piso de cueva
uniform sampler2D tex6 : TEX_FILTER, repeat_enable;  // pasto alto
uniform float tex_px = 128.0;     // tamaño de cada textura en píxeles del mundo
uniform float wobble = 4.0;       // cuánto se corre el borde (px)
uniform float edge_dark = 0.78;   // oscurecido del borde

const float CELL = 16.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x), mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}

int mat_at(vec2 px) {
	vec2 c = clamp(floor(px / CELL), vec2(0.0), zone_cells - 1.0);
	return int(texelFetch(cells, ivec2(c), 0).r * 255.0 + 0.5);
}

int shifted(vec2 px) {
	vec2 off = vec2(vnoise(px / 7.0), vnoise(px / 7.0 + 31.7)) * 2.0 - 1.0;
	return mat_at(floor(px + off * wobble) + 0.5);
}

vec4 sample_mat(int i, vec2 px) {
	vec2 uv = px / tex_px;
	if (i == 0) return texture(tex0, uv);
	if (i == 1) return texture(tex1, uv);
	if (i == 2) return texture(tex2, uv);
	if (i == 3) {
		uv += vec2(sin(TIME * 0.6 + px.y * 0.05), cos(TIME * 0.5 + px.x * 0.05)) * (1.5 / tex_px);
		return texture(tex3, uv);
	}
	if (i == 4) return texture(tex4, uv);
	if (i == 5) return texture(tex5, uv);
	if (i == 6) return texture(tex6, uv);
	return vec4(0.0);
}

void fragment() {
	vec2 px = floor(UV * zone_cells * CELL) + 0.5;
	int i = shifted(px);
	vec4 c = sample_mat(i, px);
	// Manchas grandes y suaves de luz y sombra (el suelo parejo se ve plano; en los HD-2D hay variación amplia).
	float shade = vnoise(px / 110.0) * 0.55 + vnoise(px / 37.0 + 7.3) * 0.45;
	c.rgb *= 0.86 + 0.22 * shade;
	// Borde: si un vecino (corrido igual) es de otro material, se oscurece un poco.
	if (shifted(px + vec2(1.0, 0.0)) != i || shifted(px + vec2(0.0, 1.0)) != i
			|| shifted(px - vec2(1.0, 0.0)) != i || shifted(px - vec2(0.0, 1.0)) != i) {
		c.rgb *= edge_dark;
	}
	COLOR = c;
}
