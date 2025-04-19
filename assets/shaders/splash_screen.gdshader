shader_type canvas_item;

uniform float time;
uniform float swirl_speed = 0.5;
uniform vec2 screen_size;

const int BLOB_COUNT = 10;

float blob(vec2 uv, vec2 pos, float radius) {
    return exp(-pow(length(uv - pos) * radius, 1.7));
}

float rand(float x) {
    return fract(sin(x) * 43758.5453);
}

// Map uniform r [0,1] to edge-biased value in [-1,1]
float inverted_bell(float r) {
    float x = r * 2.0 - 1.0; // map to [-1, 1]
    return sign(x) * (1.0 - exp(-4.0 * abs(x))); // bias away from 0
}

void fragment() {
    vec2 uv = (UV * screen_size - screen_size * 0.5) / screen_size.y;

    float t = time * swirl_speed;
    float combined = 0.0;

    for (int i = 0; i < BLOB_COUNT; i++) {
        float fi = float(i);
        float seed = fi * 19.123;

        float base_x = inverted_bell(rand(seed));
        float drift_speed = 0.3 + rand(seed + 1.0) * 0.4;
        float x_drift = sin(t * drift_speed + seed) * 0.4;
        float x = base_x + x_drift;

        // Let wrapping handle overflows
        x = mod(x + 1.0, 2.0) - 1.0;

        float rise_speed = 0.1 + rand(seed + 2.0) * 0.1;
        float y_start = mix(-1.0, 1.0, rand(seed + 3.0));
        float y = mod(y_start + t * rise_speed, 2.0) - 1.0;

        vec2 pos = vec2(x, y);
        combined += blob(uv, pos, 7.0);
    }

    combined = clamp(combined, 0.0, 1.0);

    vec3 color1 = vec3(0.02, 0.0, 0.1);
    vec3 color2 = vec3(0.5, 0.2, 1.0);
    vec3 final_color = mix(color1, color2, combined);

    COLOR = vec4(final_color, 1.0);
}
