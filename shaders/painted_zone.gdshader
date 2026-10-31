shader_type canvas_item;
// Zona repintada (PaintedZone). TEXTURE = la pintura de día; `tex_night` = la de noche (pintada desde la maqueta, con
// las ventanas prendidas), que se funde con `night_t`. `cells` (un píxel por celda) elige qué celdas dibuja esta capa:
// todas (suelo), las de la capa Overhead (techos y copas, encima de los personajes) o las de agua (con ondas).

uniform sampler2D tex_night : filter_linear_mipmap;
uniform float night_t = 0.0;
// Atardecer (<zona>@atardecer.png): se funde antes que la noche; de madrugada es el amanecer, con `dawn_tint`.
uniform sampler2D tex_dusk : filter_linear_mipmap;
uniform float dusk_t = 0.0;
uniform bool dawn = false;
uniform vec3 dawn_tint = vec3(0.92, 0.9, 1.06);
// Ventanas que se prenden antes de la noche (al atardecer) y se apagan después (al amanecer): las luces cálidas de la
// pintura de noche, solas, encima de la de día.
uniform float lights_t = 0.0;
uniform vec3 daylight = vec3(1.0);  // color del Daylight: la pintura de noche se divide por él (ya trae su luz)
uniform bool use_cells = false;
uniform sampler2D cells : filter_nearest;
uniform bool water = false;
uniform vec2 image_px = vec2(4096.0, 2048.0);   // tamaño de la pintura en píxeles (para que las ondas midan lo mismo)
// Perilla de la noche por skin (skin.json: "night_gain", "night_tint"): cuánto brilla la pintura de noche y de qué color.
// Las luces cálidas (ventanas) no se tiñen y brillan más ("window_boost"): el tinte, la desaturación y la viñeta de la noche
// las apagaban.
uniform float night_gain = 1.0;
uniform vec3 night_tint = vec3(1.0);
uniform float window_boost = 1.0;
// Destellos de luna (skin.json "moon_glints", 0 = sin): rocío que titila en el pasto (solo la capa del suelo) y el brillo
// del agua más plateado. Crecen con night_t. world_px = píxeles de la pintura por píxel del mundo (el tamaño del destello
// se mide en el mundo).
uniform float moon_glints = 1.0;
uniform float world_px = 3.0;

uint hash(uvec2 v) {  // con enteros: el hash de seno daba distinto a cada lado de un borde y salían bloques
	uint h = v.x * 1664525u + v.y * 1013904223u;
	h ^= h >> 16u;
	h *= 2246822519u;
	h ^= h >> 13u;
	h *= 3266489917u;
	h ^= h >> 16u;
	return h;
}

float rand01(uvec2 v) {
	return float(hash(v) & 0xffffu) / 65535.0;
}

// Rocío: una celda de 9 px del mundo de cada ~14 tiene un punto que titila un rato y se apaga, en su propio tiempo.
float dew(vec2 uv) {
	vec2 w = uv * image_px / world_px;
	vec2 cell = floor(w / 9.0);
	uvec2 id = uvec2(ivec2(cell) + ivec2(100000));
	if (rand01(id) > 0.07) {
		return 0.0;
	}
	vec2 spot = (cell + vec2(rand01(id + uvec2(7u, 0u)), rand01(id + uvec2(0u, 7u))) * 0.8 + 0.1) * 9.0;
	vec2 d = abs(w - spot);
	float shape = max(step(d.x + d.y * 3.0, 1.2), step(d.y + d.x * 3.0, 1.2));  // crucecita de un píxel
	float phase = rand01(id + uvec2(3u, 11u)) * 6.283;
	float speed = 0.8 + rand01(id + uvec2(5u, 2u)) * 1.4;
	return shape * pow(max(0.0, sin(TIME * speed + phase)), 12.0);
}

// Con HDR 2D (project.godot) el Daylight multiplica en lineal: la pintura de noche se pasa a lineal antes de dividirla
// por él, así se ve exactamente lo pintado (sin esto salía lavada y con bruma). `daylight` llega en lineal. La de día va
// tal cual (pasada a lineal quedaba más oscura que la pintura; probado en el juego, 2026-10-30).
uniform bool linear_out = true;

vec3 to_linear(vec3 c) {
	return linear_out ? pow(c, vec3(2.2)) : c;
}

vec4 paint(sampler2D day, vec2 uv) {  // (TEXTURE solo se puede leer dentro de fragment(): va como parámetro)
	vec4 n = texture(tex_night, uv);
	float warm = smoothstep(0.08, 0.3, n.r - n.b);  // luz de ventana: roja/amarilla bien por encima del azul
	float lamp = smoothstep(0.1, 0.3, n.r - n.b) * smoothstep(0.3, 0.55, max(n.r, n.g));  // solo lo que brilla
	n.rgb = to_linear(n.rgb) * night_gain * mix(night_tint, vec3(window_boost), warm);
	n.rgb = min(n.rgb / max(daylight, vec3(0.005)), vec3(16.0));  // el Daylight la vuelve a multiplicar
	vec4 c = texture(day, uv);
	if (dusk_t > 0.0) {
		vec4 k = texture(tex_dusk, uv);
		k.rgb = to_linear(k.rgb) * (dawn ? dawn_tint : vec3(1.0));
		k.rgb = min(k.rgb / max(daylight, vec3(0.005)), vec3(16.0));
		c = mix(c, k, dusk_t);
	}
	c.rgb = mix(c.rgb, n.rgb, lamp * lights_t);
	return mix(c, n, night_t);
}

varying vec4 tint;  // color de vértice (modulate); en fragment() COLOR ya viene multiplicado por la textura

void vertex() {
	tint = COLOR;
}

void fragment() {
	if (use_cells && texture(cells, UV).r < 0.5) {
		discard;
	}
	vec2 uv = UV;
	if (water) {
		// Ondas suaves: corre un poco la pintura (unos píxeles) con dos senos que se mueven, y un brillo leve.
		vec2 p = UV * image_px;
		vec2 off = vec2(sin(p.y * 0.045 + TIME * 1.3) + sin(p.x * 0.031 - TIME * 0.9),
			cos(p.x * 0.04 + TIME * 1.1) + sin(p.y * 0.027 + TIME * 0.7)) * 1.6;
		uv += off / image_px;
		vec4 c = paint(TEXTURE, uv);
		float glint = smoothstep(0.92, 1.0, sin(p.x * 0.05 + p.y * 0.03 + TIME * 2.0) * 0.5 + 0.5);
		COLOR = vec4(c.rgb + glint * 0.06, c.a) * tint;
	} else {
		COLOR = paint(TEXTURE, uv) * tint;
	}
}
