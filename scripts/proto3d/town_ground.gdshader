shader_type spatial;
// Suelo de una zona: pasto, camino de tierra y piso de bosque según el mapa `kinds` (un píxel por celda: R camino,
// G agua, B bosque), con los bordes desparejos para que no se note la grilla. Donde hay agua el suelo se abre.

uniform sampler2D kinds : filter_linear, repeat_disable;
uniform vec2 map_size = vec2(100.0, 100.0);
varying vec3 wpos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = wpos.xz;
	vec2 wobble = vec2(noise(p * 0.9), noise(p * 0.9 + 37.0)) - 0.5;
	vec3 k = texture(kinds, (p + wobble * 0.9) / map_size).rgb;
	float big = noise(p * 0.1) * 0.6 + noise(p * 0.4) * 0.4;
	float fine = noise(p * 5.0);
	vec3 grass = mix(vec3(0.29, 0.55, 0.21), vec3(0.45, 0.69, 0.27), smoothstep(0.3, 0.7, big));
	grass *= 0.92 + fine * 0.16;
	vec3 dirt = vec3(0.74, 0.62, 0.42) * (0.9 + fine * 0.2);
	vec3 wood = vec3(0.17, 0.33, 0.14) * (0.85 + fine * 0.3);
	vec3 col = mix(grass, wood, smoothstep(0.35, 0.75, k.b));
	col = mix(col, dirt, smoothstep(0.4, 0.6, k.r));
	// orilla: arena antes del agua
	col = mix(col, vec3(0.80, 0.72, 0.50), smoothstep(0.15, 0.42, k.g));
	if (k.g > 0.5) {
		discard;
	}
	ALBEDO = pow(col, vec3(2.2));
	ROUGHNESS = 1.0;
}
