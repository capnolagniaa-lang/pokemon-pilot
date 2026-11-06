shader_type canvas_item;
// Camiseta de fútbol pintada encima del sprite (SoccerMatch): el color "de piel" del Pokémon, de `chest` para abajo en
// píxeles sobre sus pies, pasa a los colores del equipo. Sirve para todos los cuadros y poses sin tocar las hojas.

uniform vec3 skin = vec3(0.86, 0.46, 0.12);
uniform float skin_range = 0.42;
uniform vec3 main_color = vec3(0.45, 0.74, 0.95);
uniform vec3 second_color = vec3(0.96, 0.96, 0.96);
// 0 = rayas verticales, 1 = banda horizontal.
uniform int pattern = 0;
uniform float chest = 15.0;
uniform float hem = 3.0;
uniform float base_light = 0.62;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	vec4 c = COLOR;  // (en un canvas_item ya trae la textura)
	float up = -floor(local.y);
	if (c.a > 0.5 && up <= chest && up >= hem && distance(c.rgb / max(max(c.r, c.g), 0.001), skin / max(skin.r, 0.001)) < skin_range) {
		bool second = pattern == 0 ? mod(floor(local.x / 3.0), 2.0) > 0.5 : abs(up - (chest + hem) * 0.5) < 2.0;
		vec3 team = second ? second_color : main_color;
		c.rgb = team * clamp(dot(c.rgb, vec3(0.34, 0.5, 0.16)) / base_light, 0.55, 1.15);
	}
	COLOR = c;
}
