shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

// INCREASED OPACITY: Jumped the alpha (4th value) up to 0.5 for wind and 0.6 for border
uniform vec4 wind_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);

uniform sampler2D noise_tex : repeat_enable;

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float dist_from_center = length(centered_uv);

    float angle = atan(centered_uv.y, centered_uv.x);

    vec2 polar_uv = vec2(angle * 2.0, dist_from_center * 0.1 - TIME * speed);
    float noise_val = texture(noise_tex, polar_uv).r;

    // THICKER LINES: Lowered the threshold (0.75 to 0.9) so more of the noise texture is drawn
    float wind = smoothstep(0.75, 0.9, noise_val);

    // TIGHTER DONUT HOLE: Brought the wind closer to the center of the screen (0.25 to 0.6)
    float wind_mask = smoothstep(0.25, 0.6, dist_from_center);
    wind *= wind_mask;

    // DARKER BORDER: Brought the vignette further in from the corners
    float border = smoothstep(0.45, 0.8, dist_from_center);

    vec4 final_wind = wind_color * wind;
    vec4 final_border = border_color * border;

    COLOR = (final_wind + final_border) * intensity;
}