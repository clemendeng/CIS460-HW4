#version 150

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float worley(int freq, float amp, int seed) {
    const int maxFreq = 4;
    float unit = 1.0 / freq;
    vec2 points[maxFreq * maxFreq];
    for(int y = 0; y < freq; y++) {
        for(int x = 0; x < freq; x++) {
            points[x + freq * y] = random2(vec2(13.72 * x * seed, 2.38 * y * seed));
        }
    }
    //Calculating which unit the pixel lies in
    int x = int(fs_UV[0] * freq);
    int y = int(fs_UV[1] * freq);
    if(x == freq) {
        x -= 1;
    }
    if(y == freq) {
        y -= 1;
    }
    //Calculating point of closest distance and that distance
    float dist = 1000;
    vec2 point;
    for(int i = x - 1; i < x + 2; i++) {
        for(int j = y - 1; j < y + 2; j++) {
            if(i >= 0 && i < freq && j >= 0 && j < freq) {
                point = vec2((i + points[i + freq * j][0]) * unit,
                        (j + points[i + freq * j][1]) * unit);
                if(distance(fs_UV, point) * freq < dist) {
                    dist = distance(fs_UV, point) * freq;
                }
            }
        }
    }
    return clamp(dist, 0, 1) * amp;
}

void main()
{
    //Fractal Brownian Motion
    float worley1 = 0, worley2 = 0;
    const int maxFreq = 4;
    float amp = 0.8;
    for(int freq = 2; freq <= maxFreq; freq *= 2) {
        worley1 += worley(freq, amp, freq);
        worley2 += worley(freq, amp, (freq + 5) * 3);
        amp *= 0.5;
    }
    float interval = (smoothstep(-1, 1, sin(u_Time * 3.14159 / 300)) * 3) + 0.5;
    color = vec3(texture(u_RenderedTexture,
                         vec2(fs_UV[0] + (0.5 - worley1) * 200 * interval / u_Dimensions[0],
                              fs_UV[1] + (0.5 - worley2) * 200 * interval / u_Dimensions[1])));
}
