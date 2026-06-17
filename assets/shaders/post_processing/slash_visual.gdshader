shader_type spatial;
// unshaded: ignores lighting. cull_disabled: visible from both sides. blend_add: glowing overlap.
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

uniform vec4 slash_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float curve_height : hint_range(0.0, 1.0) = 0.5;
uniform float thickness : hint_range(0.0, 0.5) = 0.1;
uniform float fade_opacity : hint_range(0.0, 1.0) = 1.0; // The script will animate this!

void fragment() {
    vec2 uv = UV;

    // 1. Math for the Taper
    float curve = sin(uv.x * PI);

    // 2. Math for the Bend
    float y_offset = (1.0 - curve) * curve_height;
    float adjusted_y = uv.y - y_offset;

    // 3. Dynamic Thickness
    float current_thickness = thickness * curve;

    // 4. Draw the Shape
    float dist = abs(adjusted_y - 0.5);
    float alpha = smoothstep(current_thickness, current_thickness - 0.02, dist);

    // 5. Clean up the edges
    alpha *= smoothstep(0.0, 0.05, uv.x) * smoothstep(1.0, 0.95, uv.x);

    // 6. Output to screen
    ALBEDO = slash_color.rgb;
    // We multiply our shape's alpha by the uniform so the script can fade the whole thing
    ALPHA = alpha * slash_color.a * fade_opacity;
}