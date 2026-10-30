shader_type canvas_item;
// Sombras largas del mapa según el sol (ZoneShadows, docs/PLAN_DIA_NOCHE.md parte B).
// `mask` = una textura por zona (MASK_PX píxeles por celda): R = altura (0-1), G = proyecta sombra (silueta),
// B = ocupado (lo que no se oscurece: el propio edificio o árbol). Cada píxel del suelo mira "hacia el sol":
// si encuentra algo que proyecta y está a menos de su largo de sombra, queda a la sombra.

uniform sampler2D mask : filter_linear, repeat_disable;
uniform vec2 zone_px = vec2(1536.0, 1120.0);   // tamaño de la zona en píxeles del mundo
uniform vec2 dir = vec2(0.6, 0.8);             // hacia dónde caen las sombras
uniform float len_px = 18.0;                   // largo de la sombra de algo de altura 1
uniform float alpha = 0.6;
uniform vec3 shadow_color = vec3(0.16, 0.13, 0.32);
uniform float soften = 0.0;  // px de suavizado del borde (zonas con skin: la grilla por celda se nota sobre la pintura)

const int STEPS = 30;

float shadow_at(vec2 p) {
	float own = texture(mask, p / zone_px).b;
	float s = 0.0;
	if (own < 0.99 && len_px > 0.5) {
		for (int i = 0; i < STEPS; i++) {
			float t = len_px * (float(i) + 0.5) / float(STEPS);
			vec2 q = (p - dir * t) / zone_px;
			if (q.x < 0.0 || q.y < 0.0 || q.x > 1.0 || q.y > 1.0) {
				continue;
			}
			vec4 m = texture(mask, q);
			float reach = m.r * len_px;
			float k = m.g * (1.0 - smoothstep(reach * 0.55, reach + 1.0, t));
			s = max(s, k);
		}
	}
	return s * (1.0 - own);
}

void fragment() {
	vec2 p = UV * zone_px;
	float s = shadow_at(p);
	if (soften > 0.0) {
		s = (s * 2.0 + shadow_at(p + vec2(soften, 0.0)) + shadow_at(p - vec2(soften, 0.0))
			+ shadow_at(p + vec2(0.0, soften)) + shadow_at(p - vec2(0.0, soften))) / 6.0;
	}
	COLOR = vec4(shadow_color, s * alpha);
}
