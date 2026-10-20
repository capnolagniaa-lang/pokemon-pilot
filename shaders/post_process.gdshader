shader_type canvas_item;
// Post-procesado de pantalla: tilt-shift (desenfoque arriba/abajo, estilo HD-2D),
// gradación de color, viñeta y aberración cromática muy leve en los bordes.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float tilt_blur = 1.3;        // nivel de mip en los bordes
uniform float tilt_band = 0.45;       // franja central nítida (0..1)
uniform float saturation = 1.28;
uniform float contrast = 1.06;
uniform vec3 tint = vec3(1.04, 1.01, 0.93);
uniform float vignette = 0.32;
uniform float aberration = 0.0012;

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
	c *= tint;
	float v = smoothstep(0.95, 0.3, length((uv - 0.5) * vec2(1.25, 1.0)));
	c *= mix(1.0 - vignette, 1.0, v);
	COLOR = vec4(c, 1.0);
}
