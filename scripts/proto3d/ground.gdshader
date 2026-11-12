shader_type spatial;
// Suelo de la prueba 3D: pasto en dos tonos con manchas grandes y un camino de tierra, todo por código.

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
	float big = noise(p * 0.12) * 0.65 + noise(p * 0.45) * 0.35;
	float fine = noise(p * 6.0);
	vec3 grass = mix(vec3(0.30, 0.56, 0.22), vec3(0.46, 0.70, 0.28), smoothstep(0.3, 0.7, big));
	grass *= 0.92 + fine * 0.16;
	// camino que serpentea hacia el norte
	float cx = sin(p.y * 0.18) * 1.6;
	float d = abs(p.x - cx) + (noise(p * 0.9) - 0.5) * 0.9;
	float path = 1.0 - smoothstep(1.5, 2.2, d);
	vec3 dirt = vec3(0.72, 0.60, 0.40) * (0.9 + fine * 0.2);
	ALBEDO = pow(mix(grass, dirt, path), vec3(2.2));
	ROUGHNESS = 1.0;
}
