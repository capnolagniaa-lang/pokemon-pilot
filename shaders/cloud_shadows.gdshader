shader_type canvas_item;
render_mode blend_mul, unshaded;
// Sombras de nubes que pasan sobre el mundo (multiplica lo que hay debajo).

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec2 wind = vec2(9.0, 4.0);   // píxeles por segundo
uniform float scale = 0.0022;
uniform float darkness = 0.22;
uniform float coverage = 0.5;
// Cuánto se ven (0-1, DayNight según la hora). No usar modulate.a: con blend_mul una opacidad baja no las apaga,
// oscurece toda la pantalla (pasaba entre las 20 y las 21:30 y al amanecer).
uniform float amount = 1.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 p = (world_pos - wind * TIME) * scale;
	float n = texture(noise, p).r * 0.7 + texture(noise, p * 2.3 + 0.37).r * 0.3;
	float shade = smoothstep(coverage, coverage + 0.18, n);
	COLOR = vec4(vec3(1.0 - darkness * shade * amount), 1.0);
}
