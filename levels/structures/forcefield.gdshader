shader_type spatial;

uniform vec4 glow_color : source_color = vec4(0.0, 0.6, 1.0, 0.3); // Bright blue
uniform float pulse_speed = 2.0;
uniform float glow_intensity = 0.6;

void fragment() {
	float pulse = sin(TIME * pulse_speed + VERTEX.y) * glow_intensity;
	ALBEDO = glow_color.rgb + pulse;
	ALPHA = glow_color.a;
}