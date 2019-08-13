#version 150

struct Params
{
    vec4 TextureSize;
    vec4 Params1;
    vec4 Params2;
    vec4 Params3;
    vec4 Params4;
    vec4 Params5;
    vec4 Params6;
    vec4 Bloom;
};

uniform vec4 CB1[8];
uniform sampler2D Texture0Texture;
uniform sampler2D Texture1Texture;

in vec2 VARYING0;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = texture(Texture0Texture, VARYING0 + (vec2(0.25) * CB1[0].zw)).xyz;
    vec3 f1 = (f0 * f0) * 4.0;
    float f2 = max(max(f1.x, f1.y), f1.z);
    vec3 f3 = f1 * ((vec3(max(f2 - CB1[7].y, 0.0)) / vec3(f2 + 0.001000000047497451305389404296875)) * CB1[7].x);
    vec3 f4 = texture(Texture0Texture, VARYING0 + (vec2(-0.25) * CB1[0].zw)).xyz;
    vec3 f5 = (f4 * f4) * 4.0;
    float f6 = max(max(f5.x, f5.y), f5.z);
    vec3 f7 = f5 * ((vec3(max(f6 - CB1[7].y, 0.0)) / vec3(f6 + 0.001000000047497451305389404296875)) * CB1[7].x);
    vec3 f8 = texture(Texture0Texture, VARYING0 + CB1[1].xy).xyz;
    vec3 f9 = (f8 * f8) * 4.0;
    float f10 = max(max(f9.x, f9.y), f9.z);
    vec3 f11 = texture(Texture1Texture, VARYING0).xyz;
    _entryPointOutput = vec4(mix(f9 * ((vec3(max(f10 - CB1[7].y, 0.0)) / vec3(f10 + 0.001000000047497451305389404296875)) * CB1[7].x), clamp((f11 * f11) * 4.0, min(f3, f7), max(f3, f7)), vec3(CB1[1].z)), 1.0);
}

//$$Texture0Texture=s0
//$$Texture1Texture=s1
