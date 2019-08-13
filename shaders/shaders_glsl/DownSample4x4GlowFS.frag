#version 110

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

varying vec4 VARYING1;
varying vec4 VARYING2;

void main()
{
    vec4 f0 = texture2D(Texture0Texture, VARYING1.xy);
    float f1 = f0.x;
    vec4 f2 = texture2D(Texture0Texture, VARYING1.zw);
    float f3 = f2.x;
    vec4 f4 = texture2D(Texture0Texture, VARYING2.xy);
    float f5 = f4.x;
    vec4 f6 = texture2D(Texture0Texture, VARYING2.zw);
    float f7 = f6.x;
    gl_FragData[0] = ((((vec4(f1, f0.yz, 1.0) * max(1.0 - f0.w, CB1[7].x * pow(clamp(max(max(f1, f0.y), f0.z), 0.0, 1.0), CB1[7].y))) + (vec4(f3, f2.yz, 1.0) * max(1.0 - f2.w, CB1[7].x * pow(clamp(max(max(f3, f2.y), f2.z), 0.0, 1.0), CB1[7].y)))) + (vec4(f5, f4.yz, 1.0) * max(1.0 - f4.w, CB1[7].x * pow(clamp(max(max(f5, f4.y), f4.z), 0.0, 1.0), CB1[7].y)))) + (vec4(f7, f6.yz, 1.0) * max(1.0 - f6.w, CB1[7].x * pow(clamp(max(max(f7, f6.y), f6.z), 0.0, 1.0), CB1[7].y)))) * 0.25;
}

//$$Texture0Texture=s0
