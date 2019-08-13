#version 150

struct Globals
{
    mat4 ViewProjection;
    vec4 ViewRight;
    vec4 ViewUp;
    vec4 ViewDir;
    vec3 CameraPosition;
    vec3 AmbientColor;
    vec3 SkyAmbient;
    vec3 Lamp0Color;
    vec3 Lamp0Dir;
    vec3 Lamp1Color;
    vec4 FogParams;
    vec4 FogColor_GlobalForceFieldTime;
    vec4 Technology_Exposure;
    vec4 LightBorder;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 CascadeSphere0;
    vec4 CascadeSphere1;
    vec4 CascadeSphere2;
    vec4 CascadeSphere3;
    float hybridLerpDist;
    float hybridLerpSlope;
    float evsmPosExp;
    float evsmNegExp;
    float globalShadow;
    float shadowBias;
    float shadowAlphaRef;
    float debugFlagsShadows;
};

struct LightShadowGPUTransform
{
    mat4 transform;
};

uniform vec4 CB0[32];
uniform vec4 CB8[24];
uniform vec4 CB4[36];
uniform vec4 CB3[1];
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D ShadowAtlasTexture;
uniform sampler2DArray AlbedoMapTexture;
uniform sampler2DArray NormalMapTexture;
uniform sampler2DArray SpecularMapTexture;

in vec3 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec3 VARYING5;
in vec3 VARYING6;
in vec4 VARYING7;
in vec3 VARYING8;
in vec4 VARYING9;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec4 f1 = texture(AlbedoMapTexture, f0);
    vec3 f2 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f3 = texture(AlbedoMapTexture, f2);
    vec4 f4 = texture(AlbedoMapTexture, VARYING3.xyz);
    int f5 = int(VARYING9.x + 0.5);
    int f6 = int(VARYING9.y + 0.5);
    int f7 = int(VARYING9.z + 0.5);
    vec2 f8 = f1.xz - vec2(0.5);
    vec2 f9 = f3.xz - vec2(0.5);
    vec2 f10 = f4.xz - vec2(0.5);
    vec3 f11 = vec3(0.0);
    f11.x = CB4[f5 * 1 + 0].x * f1.y;
    float f12 = f8.x;
    float f13 = f8.y;
    vec3 f14 = f11;
    f14.y = (CB4[f5 * 1 + 0].y * f12) - (CB4[f5 * 1 + 0].z * f13);
    vec3 f15 = f14;
    f15.z = (CB4[f5 * 1 + 0].z * f12) + (CB4[f5 * 1 + 0].y * f13);
    vec3 f16 = vec3(0.0);
    f16.x = CB4[f6 * 1 + 0].x * f3.y;
    float f17 = f9.x;
    float f18 = f9.y;
    vec3 f19 = f16;
    f19.y = (CB4[f6 * 1 + 0].y * f17) - (CB4[f6 * 1 + 0].z * f18);
    vec3 f20 = f19;
    f20.z = (CB4[f6 * 1 + 0].z * f17) + (CB4[f6 * 1 + 0].y * f18);
    vec3 f21 = vec3(0.0);
    f21.x = CB4[f7 * 1 + 0].x * f4.y;
    float f22 = f10.x;
    float f23 = f10.y;
    vec3 f24 = f21;
    f24.y = (CB4[f7 * 1 + 0].y * f22) - (CB4[f7 * 1 + 0].z * f23);
    vec3 f25 = f24;
    f25.z = (CB4[f7 * 1 + 0].z * f22) + (CB4[f7 * 1 + 0].y * f23);
    vec4 f26 = ((vec4(f15.x, f15.y, f15.z, f1.w) * VARYING0.x) + (vec4(f20.x, f20.y, f20.z, f3.w) * VARYING0.y)) + (vec4(f25.x, f25.y, f25.z, f4.w) * VARYING0.z);
    float f27 = f26.x;
    float f28 = f27 - f26.z;
    vec3 f29 = vec4(vec3(f28, f27, f28) + (vec3(f26.yzy) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f30 = vec3(CB0[15].x);
    float f31 = clamp(1.0 - (VARYING7.w * CB0[24].y), 0.0, 1.0);
    float f32 = -VARYING6.x;
    vec2 f33 = (((texture(NormalMapTexture, f0) * VARYING0.x) + (texture(NormalMapTexture, f2) * VARYING0.y)) + (texture(NormalMapTexture, VARYING3.xyz) * VARYING0.z)).wy * 2.0;
    vec2 f34 = f33 - vec2(1.0);
    vec3 f35 = vec3(dot(VARYING8, VARYING0));
    vec3 f36 = normalize(((mix(vec3(VARYING6.z, 0.0, f32), vec3(VARYING6.y, f32, 0.0), f35) * f34.x) + (mix(vec3(0.0, -1.0, 0.0), vec3(0.0, -VARYING6.z, VARYING6.y), f35) * f34.y)) + (VARYING6 * sqrt(clamp(1.0 + dot(vec2(1.0) - f33, f34), 0.0, 1.0))));
    vec4 f37 = ((texture(SpecularMapTexture, f0) * VARYING0.x) + (texture(SpecularMapTexture, f2) * VARYING0.y)) + (texture(SpecularMapTexture, VARYING3.xyz) * VARYING0.z);
    vec3 f38 = -CB0[11].xyz;
    float f39 = dot(f36, f38);
    float f40 = clamp(dot(step(CB0[20].xyz, abs(VARYING4.xyz - CB0[19].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f41 = VARYING4.yzx - (VARYING4.yzx * f40);
    vec4 f42 = vec4(clamp(f40, 0.0, 1.0));
    vec4 f43 = mix(texture(LightMapTexture, f41), vec4(0.0), f42);
    vec4 f44 = mix(texture(LightGridSkylightTexture, f41), vec4(1.0), f42);
    float f45 = f44.y;
    vec3 f46 = VARYING5 - CB0[26].xyz;
    vec3 f47 = VARYING5 - CB0[27].xyz;
    vec3 f48 = VARYING5 - CB0[28].xyz;
    vec4 f49 = vec4(VARYING5, 1.0) * mat4(CB8[((dot(f46, f46) < CB0[26].w) ? 0 : ((dot(f47, f47) < CB0[27].w) ? 1 : ((dot(f48, f48) < CB0[28].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f46, f46) < CB0[26].w) ? 0 : ((dot(f47, f47) < CB0[27].w) ? 1 : ((dot(f48, f48) < CB0[28].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f46, f46) < CB0[26].w) ? 0 : ((dot(f47, f47) < CB0[27].w) ? 1 : ((dot(f48, f48) < CB0[28].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f46, f46) < CB0[26].w) ? 0 : ((dot(f47, f47) < CB0[27].w) ? 1 : ((dot(f48, f48) < CB0[28].w) ? 2 : 3))) * 4 + 3]);
    vec4 f50 = textureLod(ShadowAtlasTexture, f49.xy, 0.0);
    vec2 f51 = vec2(0.0);
    f51.x = CB0[30].z;
    vec2 f52 = f51;
    f52.y = CB0[30].w;
    float f53 = (2.0 * f49.z) - 1.0;
    float f54 = exp(CB0[30].z * f53);
    float f55 = -exp((-CB0[30].w) * f53);
    vec2 f56 = (f52 * CB0[31].y) * vec2(f54, f55);
    vec2 f57 = f56 * f56;
    float f58 = f50.x;
    float f59 = max(f50.y - (f58 * f58), f57.x);
    float f60 = f54 - f58;
    float f61 = f50.z;
    float f62 = max(f50.w - (f61 * f61), f57.y);
    float f63 = f55 - f61;
    float f64 = (f39 > 0.0) ? mix(f45, mix(min((f54 <= f58) ? 1.0 : clamp(((f59 / (f59 + (f60 * f60))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f55 <= f61) ? 1.0 : clamp(((f62 / (f62 + (f63 * f63))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f45, clamp((length(VARYING5 - CB0[7].xyz) * CB0[30].y) - (CB0[30].x * CB0[30].y), 0.0, 1.0)), CB0[31].x) : 0.0;
    vec3 f65 = (((min(((f43.xyz * (f43.w * 120.0)).xyz + CB0[8].xyz) + (CB0[9].xyz * f44.x), vec3(CB0[17].w)) + (((CB0[10].xyz * clamp(f39, 0.0, 1.0)) + (CB0[12].xyz * max(-f39, 0.0))) * f64)) + vec3((f37.z * 2.0) * f31)) * mix(f29, f29 * f29, f30).xyz) + (CB0[10].xyz * (((((step(0.0, f39) * f37.x) * f31) * CB3[0].z) * f64) * pow(clamp(dot(f36, normalize(f38 + normalize(VARYING7.xyz))), 0.0, 1.0), (clamp(f37.y, 0.0, 1.0) * 128.0) + 0.00999999977648258209228515625)));
    vec4 f66 = vec4(f65.x, f65.y, f65.z, vec4(0.0).w);
    f66.w = 1.0;
    vec3 f67 = mix(CB0[14].xyz, mix(f66.xyz, sqrt(clamp(f66.xyz * CB0[15].z, vec3(0.0), vec3(1.0))), f30).xyz, vec3(clamp(VARYING4.w, 0.0, 1.0)));
    _entryPointOutput = vec4(f67.x, f67.y, f67.z, f66.w);
}

//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$ShadowAtlasTexture=s1
//$$AlbedoMapTexture=s0
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s2
