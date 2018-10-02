#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader
uniform int u_Time;

in vec3 fs_Pos;
in vec3 fs_Nor;
in vec4 fs_LightVec;
in vec2 fs_UV;

layout(location = 0) out vec3 out_Col;

void main()
{
    vec4 diffuseColor = texture(u_Texture, fs_UV);

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), vec3(normalize(fs_LightVec)));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    vec3 a = vec3(0.5, 0.5, 0.5), b = vec3(0.5, 0.5, 0.5), c = vec3(1.0, 1.0, 1.0), d = vec3(0.3, 0.2, 0.2);

    vec3 gradientCol = vec3(0);
    for(int i = 0; i < 3; i++) {
        gradientCol[i] = a[i] + b[i] * cos(u_Time * 3.14159 * (c[i] * lightIntensity + d[i]) / 100);
    }
    diffuseColor = diffuseColor * lightIntensity;
    out_Col = mix(vec3(diffuseColor), gradientCol, (sin(u_Time * 3.14159 / 100) + 1) / 2);
    if(mod(u_Time, 200.f / 3.f) < 200.f / 6.f) {
        out_Col = mix(vec3(diffuseColor), gradientCol, mod(u_Time, 200.f / 3.f) / (200.f / 6.f));
    } else {
        out_Col = mix(gradientCol, vec3(diffuseColor), (mod(u_Time, 200.0 / 3.0) - (200.f / 6.f)) / (200.f / 6.f));
    }
}
