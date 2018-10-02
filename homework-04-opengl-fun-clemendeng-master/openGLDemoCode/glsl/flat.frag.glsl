#version 150
// ^ Change this to version 130 if you have compatibility issues

uniform int u_Time;

in vec3 fs_Pos;
in vec3 fs_Col;
out vec3 out_Col;

void main()
{
    // Copy the color; there is no shading.
    out_Col = fs_Col;
}
