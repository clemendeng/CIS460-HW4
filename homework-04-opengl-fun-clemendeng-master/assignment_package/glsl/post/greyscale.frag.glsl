#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

void main()
{
    float dist = sqrt(abs(pow(fs_UV[0] - 0.5, 2) + pow(fs_UV[1] - 0.5, 2)));
    vec4 base = texture(u_RenderedTexture, fs_UV);
    float grey = base[0] * 0.21 + base[1] * 0.72 + base[2] * 0.07;
    color = vec3(grey - dist);
}
