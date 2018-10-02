#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

uniform int u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec2 vs_UV;

out vec3 fs_Pos;
out vec3 fs_Nor;
out vec4 fs_LightVec;
out vec2 fs_UV;

void main()
{
    // TODO Homework 4
    fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));

    float interval = 200;
    float phase = interval / 6;

    vec4 modelposition = u_Model * vs_Pos;
    vec4 modelposition2 = vec4(vec3(u_Model * vs_Pos) * 1.25, 1);
    vec4 modelposition3 = vec4(vec3(u_Model * vs_Pos) * 1.5, 1);
    vec4 circle = vec4(normalize(vec3(modelposition)) * 2, 1);
    vec4 circle2 = vec4(normalize(vec3(modelposition)) * 2.75, 1);
    vec4 circle3 = vec4(normalize(vec3(modelposition)) * 3.5, 1);
    vec4 newPos;
    if(mod(u_Time, interval) < phase) {
        newPos = mix(modelposition, circle2, mod(u_Time, interval) / phase);
    } else if(mod(u_Time, interval) >= phase && mod(u_Time, interval) < 2 * phase) {
        newPos = mix(circle2, modelposition2, (mod(u_Time, interval) - phase) / phase);
    } else if(mod(u_Time, interval) >= 2 * phase && mod(u_Time, interval) < 3 * phase) {
        newPos = mix(modelposition2, circle3, (mod(u_Time, interval) - 2 * phase) / phase);
    } else if(mod(u_Time, interval) >= 3 * phase && mod(u_Time, interval) < 4 * phase) {
        newPos = mix(circle3, modelposition3, (mod(u_Time, interval) - 3 * phase) / phase);
    } else if(mod(u_Time, interval) >= 4 * phase && mod(u_Time, interval) < 5 * phase) {
        newPos = mix(modelposition3, circle, (mod(u_Time, interval) - 4 * phase) / phase);
    } else {
        newPos = mix(circle, modelposition, (mod(u_Time, interval) - 5 * phase) / phase);
    }
    fs_Pos = vec3(newPos);

    fs_LightVec = (inverse(u_View) * vec4(0,0,0,1)) - newPos;
    fs_UV = vs_UV;
    gl_Position = u_Proj * u_View * newPos;
}
