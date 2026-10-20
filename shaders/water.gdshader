shader_type canvas_item;
// Agua viva: ondulación suave, bandas de luz que se mueven y destellos que titilan (con glow).

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float ripple_px = 1.0;
uniform float sparkle_threshold = 0.78;
uniform float sparkle_intensity = 1.6;  // >1 para que el glow lo haga brillar
uniform vec3 highlight = vec3(0.75, 0.9, 1.0);
uniform float tile_size = 16.0;

varying vec2 world_pos;
varying vec4 vertex_color;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	vertex_color = COLOR;
}

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 tile_uv = px * tile_size;
	vec2 origin = floor(UV / tile_uv) * tile_uv;
	float wob = round(sin(TIME * 1.7 + world_pos.y * 0.35) * ripple_px);
	vec2 uv = clamp(UV + vec2(wob * px.x, 0.0), origin + px * 0.5, origin + tile_uv - px * 0.5);
	vec4 base = texture(TEXTURE, uv);
	// Solo afectamos píxeles "de agua" (azules); los bordes de tierra quedan igual.
	float is_water = smoothstep(0.05, 0.2, base.b - max(base.r, base.g * 0.85));
	vec2 p = floor(world_pos) / 128.0;
	float n1 = texture(noise, p + vec2(TIME * 0.02, TIME * 0.013)).r;
	float n2 = texture(noise, p * 1.7 - vec2(TIME * 0.017, -TIME * 0.021)).r;
	float band = smoothstep(0.55, 0.75, n1 * n2 * 1.8);
	float sparkle = step(sparkle_threshold, n2) * step(0.88, fract(n1 * 9.0 + TIME * 0.6));
	vec3 col = base.rgb + highlight * band * 0.12 * is_water;
	col = mix(col, highlight * sparkle_intensity, sparkle * is_water * 0.85);
	COLOR = vec4(col, base.a) * vertex_color;
}
