#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

vec4 getCol(float x, float y) {
    x /= u_Dimensions[0];
    y /= u_Dimensions[1];
    return texture(u_RenderedTexture, vec2(clamp(fs_UV[0] + x, 0, 1), clamp(fs_UV[1] + y, 0, 1)));
}

void main()
{
    vec4 cols[9] = { getCol(-1, -1), getCol(0, -1), getCol(1, -1),
                     getCol(-1, 0), getCol(0, 0), getCol(1, 0),
                     getCol(-1, 1), getCol(0, 1), getCol(1, 1) };
    float horizontal[9] = { 3, 0, -3, 10, 0, -10, 3, 0, -3 };
    float vertical[9] = {3, 10, 3, 0, 0, 0, -3, -10, -3 };
    vec4 h, v;
    for(int i = 0; i < 9; i++) {
        h += cols[i] * horizontal[i];
        v += cols[i] * vertical[i];
    }
    h = vec4(h[0] * h[0], h[1] * h[1], h[2] * h[2], h[3] * h[3]);
    v = vec4(v[0] * v[0], v[1] * v[1], v[2] * v[2], v[3] * v[3]);
    vec4 sum = h + v;
    color = vec3(sqrt(sum[0]), sqrt(sum[1]), sqrt(sum[2]));
}
