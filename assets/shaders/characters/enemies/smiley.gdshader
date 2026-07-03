shader_type spatial;
render_mode cull_disabled;

// --- Wind & Environment ---
uniform vec2 wind_direction = vec2(1.0, 0.5);
uniform float wind_strength = 0.6;
uniform float wind_chaos = 0.7;

// --- Body Controls ---
uniform float speed = 4.0;
uniform float sway_amount = 0.4;

// --- Arm Flail Controls ---
uniform float body_radius = 0.5;
// Added a falloff to prevent tearing!
uniform float arm_blend_distance = 0.3;
uniform float arm_speed = 8.0;
uniform float arm_flap_amount = 0.5;

uniform float shoot_intensity = 0.0;

// --- Visuals ---
uniform vec4 base_color : source_color = vec4(0.9, 0.8, 0.1, 1.0);
uniform sampler2D albedo_texture : source_color, filter_nearest;

void vertex() {
    vec3 orig = VERTEX;
    float height = orig.y;
    float dist_from_center = length(orig.xz);
    float offset = orig.x * 3.0 + orig.z * 2.0;

	float instance_offset = NODE_POSITION_WORLD.x * 1.3 + NODE_POSITION_WORLD.z * 0.9;
	float t = TIME + instance_offset;

    float gust = sin(t * 1.5) * 0.5 + 0.5;

    float arm_weight = smoothstep(
        body_radius,
        body_radius + arm_blend_distance,
        dist_from_center
    );

    float arm_length = max(0.0, dist_from_center - body_radius);

    // --- Calculate the Arm Flap (Isolated) ---
    float flap1 = sin(t * arm_speed + arm_length * 2.0 + offset);
    float flap2 = cos(t * (arm_speed * 1.6) - arm_length * 3.0 + offset);
    float total_flap = (flap1 + flap2 * wind_chaos) * arm_flap_amount * arm_length;

    vec3 arm_movement = vec3(0.0);
    arm_movement.y = mix(total_flap, 0.0, shoot_intensity);
    arm_movement.x = mix(sin(t * arm_speed * 1.2 + offset) * arm_flap_amount * 0.15 * arm_length, 0.0, shoot_intensity);
    
    // Stretch arms forward (+Z) to point at player when shooting!
    arm_movement.z = mix(0.0, arm_length * 3.0, shoot_intensity);

    // --- Calculate the Body Sway (Isolated) ---
    vec3 body_movement = vec3(0.0);
    if (height > 0.0) {
        float wobbleX = sin(t * speed + height * 1.5 + offset * 0.2);
        float wobbleZ = cos(t * (speed * 1.2) - height * 2.0 - offset * 0.2);

        wobbleX += sin(t * (speed * 2.1) + offset) * wind_chaos;
        wobbleZ += cos(t * (speed * 1.8) + offset) * wind_chaos;

        body_movement.x = (wind_direction.x * wind_strength * gust + wobbleX * sway_amount) * height;
        body_movement.z = (wind_direction.y * wind_strength * gust + wobbleZ * sway_amount) * height;
    }

    VERTEX = orig + mix(body_movement, arm_movement + body_movement, arm_weight);
}

void fragment() {
    vec4 tex_color = texture(albedo_texture, UV);
    // Use brightness to preserve black eyes/mouth while allowing any hue override
    float brightness = max(tex_color.r, max(tex_color.g, tex_color.b));
    ALBEDO = base_color.rgb * brightness;
}