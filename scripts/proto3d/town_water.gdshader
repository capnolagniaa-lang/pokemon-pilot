shader_type spatial;
render_mode blend_mix, cull_back;
// Agua estilizada: azul con ondas suaves que se mueven y brillitos.

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
	float a = noise(p * 1.4 + vec2(TIME * 0.35, TIME * 0.2));
	float b = noise(p * 2.6 - vec2(TIME * 0.25, TIME * 0.3));
	float wave = a * 0.6 + b * 0.4;
	vec3 col = mix(vec3(0.10, 0.36, 0.62), vec3(0.22, 0.58, 0.80), wave);
	col += smoothstep(0.72, 0.8, wave) * 0.25;
	ALBEDO = pow(col, vec3(2.2));
	ALPHA = 0.82;
	ROUGHNESS = 0.15;
	METALLIC = 0.1;
}
