shader_type canvas_item;
// Agua en movimiento para las salas por piezas del Modo Desafío (pedido del usuario 2026-11-11): se aplica a la pintura
// del marco (el mar) y a los sprites de las pozas, y solo toca los píxeles que son agua (celestes) o espuma (blancos
// pegados al agua). Todo va alineado a la grilla de píxeles y a pocos pasos por segundo (`fps`), como el agua de
// GBA/DS: ondulación leve, brillos que viajan y la espuma que aparece y desaparece. Es solo visual: dónde moja y frena
// lo dice el plano de la sala. `strength` 0 = quieta. Para lava: subir `glow` y bajar `fps`.

uniform float strength : hint_range(0.0, 2.0) = 1.0;
uniform float fps : hint_range(1.0, 30.0) = 7.0;
uniform float glow : hint_range(0.0, 1.0) = 0.14;

varying vec4 tint;

void vertex() {
	tint = COLOR;  // (en fragment, COLOR ya trae la textura: el color del vértice se guarda acá)
}

bool is_water(vec4 c) {
	return c.a > 0.5 && c.b > c.r * 1.25 && c.g > c.r * 1.05 && c.b > 0.25;
}

bool is_foam(vec4 c) {
	float hi = max(c.r, max(c.g, c.b));
	float lo = min(c.r, min(c.g, c.b));
	return c.a > 0.5 && hi > 0.78 && hi - lo < 0.2;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 cell = floor(UV / px);
	float t = floor(TIME * fps) / fps;
	vec4 base = texture(TEXTURE, UV);
	vec4 col = base;
	if (strength > 0.0) {
		if (is_water(base)) {
			// Ondulación: cada fila y cada columna se corren 1-2 píxeles en vaivén.
			float ox = floor(sin(cell.y * 0.33 + t * 1.7) * 1.6 * strength + 0.5);
			float oy = floor(sin(cell.x * 0.21 + t * 1.2) * 1.1 * strength + 0.5);
			vec4 moved = texture(TEXTURE, (cell + vec2(ox, oy) + 0.5) * px);
			if (is_water(moved)) {
				col = moved;
			}
			// Brillos: franjas finas que viajan, cortadas en tramos.
			float wave = sin(cell.x * 0.16 + cell.y * 0.55 - t * 2.2);
			if (wave > 0.965 && hash(floor(cell / vec2(3.0, 1.0)) + floor(t * 1.5)) > 0.62) {
				col.rgb += vec3(glow) * strength;
			}
		} else if (is_foam(base)) {
			// Espuma: la que toca el agua se abre y se cierra de a manchitas.
			vec4 a = texture(TEXTURE, (cell + vec2(3.0, 0.0) + 0.5) * px);
			vec4 b = texture(TEXTURE, (cell + vec2(-3.0, 0.0) + 0.5) * px);
			vec4 c = texture(TEXTURE, (cell + vec2(0.0, 3.0) + 0.5) * px);
			vec4 d = texture(TEXTURE, (cell + vec2(0.0, -3.0) + 0.5) * px);
			vec4 near = is_water(a) ? a : (is_water(b) ? b : (is_water(c) ? c : d));
			if (is_water(near) && hash(floor(cell / 2.0) + floor(t * 0.45 * fps)) < 0.28 * strength) {
				col = mix(base, near, 0.75);
			}
		}
	}
	COLOR = col * tint;
}
