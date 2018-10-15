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
    //sigma = 1, kernel = 7
    vec4 col[7];
    for(int i = -3; i < 4; i++) {
        col[i + 3] = 0.00598 * getCol(-3, i) + 0.060626 * getCol(-2, i) + 0.241843 * getCol(-1, i) +
                0.383103 * getCol(0, i) + 0.241843 * getCol(1, i) + 0.060626 * getCol(2, i) + 0.00598 * getCol(3, i);
    }
    vec4 c = 0.00598 * col[0] + 0.060626 * col[1] + 0.241843 * col[2] + 0.383103 * col[3]
             + 0.241843 * col[4] + 0.060626 * col[5] + 0.00598 * col[6];
    color = vec3(c);
}
