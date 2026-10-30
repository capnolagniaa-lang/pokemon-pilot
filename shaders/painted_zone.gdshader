shader_type canvas_item;
// Zona repintada (PaintedZone). TEXTURE = la pintura de día; `tex_night` = la de noche (pintada desde la maqueta, con
// las ventanas prendidas), que se funde con `night_t`. `cells` (un píxel por celda) elige qué celdas dibuja esta capa:
// todas (suelo), las de la capa Overhead (techos y copas, encima de los personajes) o las de agua (con ondas).

uniform sampler2D tex_night : filter_linear_mipmap;
uniform float night_t = 0.0;
uniform vec3 daylight = vec3(1.0);  // color del Daylight: la pintura de noche se divide por él (ya trae su luz)
uniform bool use_cells = false;
uniform sampler2D cells : filter_nearest;
uniform bool water = false;
uniform vec2 image_px = vec2(4096.0, 2048.0);   // tamaño de la pintura en píxeles (para que las ondas midan lo mismo)

vec4 paint(sampler2D day, vec2 uv) {  // (TEXTURE solo se puede leer dentro de fragment(): va como parámetro)
	vec4 n = texture(tex_night, uv);
	n.rgb = min(n.rgb / max(daylight, vec3(0.05)), vec3(1.25)) * 0.85;  // un poco más oscura que la pintura (se veía lavada)
	return mix(texture(day, uv), n, night_t);
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
