shader_type canvas_item;

uniform float time;
uniform vec4 base_color : source_color = vec4(0.9, 0.75, 0.5, 0.2); // sandy beige
uniform vec4 accent_color : source_color = vec4(1.0, 0.65, 0.3, 0.25); // burnt orange

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv);

    // soft radial fade
    float alpha = 1.0 - smoothstep(0.0, 0.5, dist);

    // noise-like variation using sin waves
    float variation = sin(centered_uv.x * 10.0 + time) * cos(centered_uv.y * 10.0 + time * 0.5);

    // blend base and accent colors
    vec4 color = mix(base_color, accent_color, variation * 0.5 + 0.5);

    COLOR = vec4(color.rgb, alpha * color.a);
}