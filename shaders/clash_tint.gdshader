shader_type canvas_item;
// Choque de proyectiles: la hoja es en grises; cada mitad toma el color de un ataque, a lo largo de `axis` (de A hacia B), y
// el centro queda blanco. Las hojas van a `half_size` px del centro (mitad del ancho de un cuadro).
uniform vec3 color_a = vec3(1.0, 0.45, 0.15);
uniform vec3 color_b = vec3(0.25, 0.55, 1.0);
uniform vec2 axis = vec2(1.0, 0.0);
uniform float half_size = 32.0;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	vec4 sheet = COLOR;  // (en fragment, COLOR ya trae la textura)
	vec2 pixel = floor(local) + 0.5;  // color por pixel de la hoja, no por pixel de pantalla
	float side = dot(pixel, axis) / half_size;
	float k = floor(clamp(abs(side) * 6.0, 0.0, 1.0) * 4.0 + 0.5) / 4.0;
	vec3 tint = side < 0.0 ? color_a : color_b;
	COLOR = vec4(mix(vec3(1.0), tint, k * (1.0 - 0.1 * sheet.r)) * (0.6 + 0.4 * sheet.r), sheet.a);
}
