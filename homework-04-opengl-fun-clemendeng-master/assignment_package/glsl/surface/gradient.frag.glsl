#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader

in vec4 fs_Nor;
in vec4 fs_LightVec;

layout(location = 0) out vec3 out_Col;

void main()
{
    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    vec3 a = vec3(0.5, 0.5, 0.5), b = vec3(0.5, 0.5, 0.5), c = vec3(1.0, 1.0, 1.0), d = vec3(0.3, 0.2, 0.2);

    for(int i = 0; i < 3; i++) {
        out_Col[i] = a[i] + b[i] * cos(2 * 3.14159 * (c[i] * lightIntensity + d[i]));
    }
}
