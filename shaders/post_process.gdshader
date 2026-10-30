shader_type canvas_item;
// Post-procesado de pantalla: tilt-shift (desenfoque arriba/abajo, estilo HD-2D),
// gradación de color, luz que entra desde un costado con rayos (el sol según la hora: DayNight),
// viñeta y aberración cromática muy leve en los bordes.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float tilt_blur = 1.3;        // nivel de mip en los bordes
uniform float tilt_band = 0.45;       // franja central nítida (0..1)
uniform float saturation = 1.28;
uniform float contrast = 1.06;
uniform vec3 tint = vec3(1.04, 1.01, 0.93);
// Gradación en dos tonos: lo oscuro recibe su propio tinte (sombras frías o violetas con luz cálida); split = cuánto.
uniform float split = 1.0;
uniform vec3 shadow_tint = vec3(0.94, 0.96, 1.04);
// Niebla baja animada (mañana, anochecer): 0 = nada.
uniform float mist = 0.0;
uniform float vignette = 0.32;
uniform float aberration = 0.0012;
// Luz de esquina (0 = apagada). sun_pos en coordenadas de pantalla (0..1, puede caer afuera).
uniform vec2 sun_pos = vec2(0.15, -0.25);
uniform vec3 sun_color = vec3(1.0, 0.9, 0.65);
uniform float sun_strength = 0.0;
uniform float sun_reach = 1.1;        // hasta dónde llega (en altos de pantalla)
uniform float rays = 0.0;             // rayos de luz (0..1)

float mist_hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.3, 289.1))) * 23758.5453);
}

float mist_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mist_hash(i), mist_hash(i + vec2(1.0, 0.0)), f.x), mix(mist_hash(i + vec2(0.0, 1.0)), mist_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float d = abs(uv.y - 0.5) * 2.0;
	float lod = smoothstep(tilt_band, 1.0, d) * tilt_blur;
	vec2 off = (uv - 0.5) * aberration * d;
	vec3 c;
	c.r = textureLod(screen_tex, uv + off, lod).r;
	c.g = textureLod(screen_tex, uv, lod).g;
	c.b = textureLod(screen_tex, uv - off, lod).b;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(l), c, saturation);
	c = (c - 0.5) * contrast + 0.5;
	c *= mix(mix(vec3(1.0), shadow_tint, split), tint, smoothstep(0.15, 0.75, l));
	if (mist > 0.0) {
		vec2 p = uv * vec2(3.0, 2.0) + vec2(TIME * 0.02, TIME * 0.008);
		float n = mist_noise(p) * 0.6 + mist_noise(p * 2.1 + 3.7) * 0.4;
		float fog = smoothstep(0.35, 0.8, n) * mist * 0.45 * (0.6 + 0.4 * uv.y);
		vec3 mist_color = mix(vec3(0.76, 0.85, 1.0), sun_color, 0.2);
		c = mix(c, mist_color, fog);
	}
	if (sun_strength > 0.0) {
		vec2 aspect = vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
		vec2 to = (uv - sun_pos) * aspect;
		float dist = length(to);
		float fall = pow(clamp(1.0 - dist / sun_reach, 0.0, 1.0), 2.2);
		float ang = atan(to.y, to.x);
		float beams = 0.5 + 0.5 * sin(ang * 23.0 + 2.0 * sin(ang * 7.0 + TIME * 0.12));
		beams = pow(beams, 6.0) * rays * smoothstep(0.05, 0.35, dist);
		vec3 light = sun_color * sun_strength * fall * (1.0 + beams);
		// Mezcla "trama" (screen): ilumina sin quemar a blanco ni saturar a amarillo.
		c = 1.0 - (1.0 - clamp(c, 0.0, 1.0)) * (1.0 - clamp(light, 0.0, 1.0));
	}
	float v = smoothstep(0.95, 0.3, length((uv - 0.5) * vec2(1.25, 1.0)));
	c *= mix(1.0 - vignette, 1.0, v);
	COLOR = vec4(c, 1.0);
}
