shader_type canvas_item;
// Fondo de la pantalla VS (VsScreen): la pantalla partida en diagonal (tu lado a la izquierda, el rival a la derecha)
// con líneas de velocidad que corren hacia el centro.

uniform vec3 left_color = vec3(0.10, 0.30, 0.85);
uniform vec3 right_color = vec3(0.85, 0.15, 0.15);
uniform float split = 0.5;        // dónde corta la diagonal (0-1, en x a media altura)
uniform float slant = 0.18;       // inclinación de la diagonal
uniform float speed = 2.2;
uniform float reveal = 1.0;       // 0 = negro, 1 = todo a la vista (entrada)

float hash(float n) { return fract(sin(n) * 43758.5453); }

void fragment() {
	vec2 uv = UV;
	float edge = split + (0.5 - uv.y) * slant;
	bool left = uv.x < edge;
	vec3 base = left ? left_color : right_color;
	// Degradé hacia el borde de la pantalla.
	float d = left ? (edge - uv.x) / max(edge, 0.001) : (uv.x - edge) / max(1.0 - edge, 0.001);
	vec3 col = base * mix(1.15, 0.45, d);
	// Líneas de velocidad horizontales que corren hacia la diagonal.
	float row = floor(uv.y * 90.0);
	float len = 0.08 + hash(row) * 0.25;
	float dir = left ? 1.0 : -1.0;
	float x = fract(uv.x * 1.6 * dir - TIME * speed * (0.6 + hash(row + 3.0)) + hash(row + 7.0));
	float line = step(1.0 - len, x) * step(0.55, hash(row + 11.0));
	col += vec3(line) * 0.22;
	// Una franja clara sobre la diagonal.
	float glow = 1.0 - smoothstep(0.0, 0.012, abs(uv.x - edge));
	col = mix(col, vec3(1.0), glow * 0.9);
	COLOR = vec4(col * reveal, 1.0);
}
