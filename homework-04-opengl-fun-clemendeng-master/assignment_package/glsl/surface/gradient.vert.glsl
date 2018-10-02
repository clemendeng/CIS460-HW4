#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec4 fs_Nor;
out vec4 fs_LightVec;

void main()
{
    // TODO Homework 4
    fs_Nor = normalize(vec4(u_ModelInvTr * vec3(vs_Nor), 0));;

    vec4 modelposition = u_Model * vs_Pos;

    fs_LightVec = (inverse(u_View) * vec4(0,0,0,1)) - modelposition;

    gl_Position = u_Proj * u_View * modelposition;
}
