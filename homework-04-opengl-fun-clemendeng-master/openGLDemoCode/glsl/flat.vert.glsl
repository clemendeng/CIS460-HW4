#version 150
// ^ Change this to version 130 if you have compatibility issues

uniform int u_Time;

in vec4 vs_Pos;
in vec3 vs_Col;

out vec3 fs_Pos;
out vec3 fs_Col;

void main()
{
    fs_Col = vs_Col;
    fs_Pos = vs_Pos.xyz;

    //built-in things to pass down the pipeline
    gl_Position = vs_Pos;

}
