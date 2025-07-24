shader_type spatial;

uniform float size;     // hex center→corner
uniform float height;   // dome radius
uniform int   rings;    // number of rings


void vertex() {
    // 1) Determine ring & index from INSTANCE_ID
    int id = INSTANCE_ID;
    int offset = 0;
    int ring = 0;
    if (id > 0) {
        for (int r = 1; r <= rings; r++) {
            int count = 6 * r;
            if (id < offset + count) {
                ring = r;
                break;
            }
            offset += count;
        }
    }
    int idx = id - offset;

    // 2) Compute latitude parameter t = ring/rings
    float t;
    if (ring == 0) {
        t = 0.0;
    } else {
        t = float(ring) / float(rings);
    }

    // 3) Compute ring radius & height on dome
    float lat = (1.0 - t) * PI * 0.5;
    float ring_r = cos(lat) * height;
    float y = sin(lat) * height;

    // 4) Compute center position of this hex
    float ang;
    if (ring == 0) {
        ang = 0.0;
    } else {
        ang = TAU * float(idx) / float(6 * ring);
    }
    vec3 center = vec3(ring_r * cos(ang), y, ring_r * sin(ang));

    // 5) Compute dome normal & rotation axis/angle
    vec3 normal = normalize(center);
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 axis = cross(up, normal);
    float dp = clamp(dot(up, normal), -1.0, 1.0);
    float c = cos(acos(dp));    // cos(angle)
    float s = sin(acos(dp));    // sin(angle)
    // For small angles, axis may be zero length

    // 6) Rotate VERTEX and NORMAL with Rodrigues’ formula
    vec3 v = VERTEX;
    vec3 n = NORMAL;
    vec3 v_rot;
    vec3 n_rot;

    if (length(axis) > 0.0001) {
        vec3 k = normalize(axis);
        // v_rot = v*c + cross(k, v)*s + k*dot(k, v)*(1-c)
        v_rot = v * c
              + cross(k, v) * s
              + k * (dot(k, v) * (1.0 - c));

        n_rot = n * c
              + cross(k, n) * s
              + k * (dot(k, n) * (1.0 - c));
    } else {
        v_rot = v;
        n_rot = n;
    }

    // 7) Output final world-space position & normal
    VERTEX = center + v_rot;
    NORMAL = normalize(n_rot);
}