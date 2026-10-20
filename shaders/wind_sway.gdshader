shader_type canvas_item;
// Balanceo por viento para capas de tiles (pasto alto, flores, copas de árboles).
// Desplaza la parte de arriba de cada tile en píxeles enteros, sin salirse del tile en el atlas.

uniform float strength = 1.0;      // desplazamiento máximo en píxeles
uniform float speed = 1.4;
uniform float wave_scale = 0.045;  // tamaño de las ráfagas en el mundo
uniform float gust = 0.6;          // cuánto varían las ráfagas
uniform float tile_size = 16.0;

varying vec2 world_pos;
varying vec4 vertex_color;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	vertex_color = COLOR;
}

void fragment() {
	float local_y = mod(world_pos.y, tile_size) / tile_size;   // 0 arriba, 1 abajo
	float t = TIME * speed;
	float wave = sin(t + world_pos.x * wave_scale + world_pos.y * wave_scale * 0.6);
	float g = 1.0 + gust * sin(t * 0.37 + world_pos.x * 0.011);
	float dx = round(wave * g * strength * (1.0 - local_y));
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 tile_uv = px * tile_size;
	vec2 origin = floor(UV / tile_uv) * tile_uv;
	vec2 uv = clamp(UV + vec2(dx * px.x, 0.0), origin + px * 0.5, origin + tile_uv - px * 0.5);
	COLOR = texture(TEXTURE, uv) * vertex_color;
}
