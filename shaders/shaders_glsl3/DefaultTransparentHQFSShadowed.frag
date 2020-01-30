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
    vec3 Exposure;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 SkyGradientTop_EnvDiffuse;
    vec4 SkyGradientBottom_EnvSpec;
    vec3 AmbientColorNoIBL;
    vec3 SkyAmbientNoIBL;
    vec4 AmbientCube[12];
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
    float debugFlags;
};

struct LightShadowGPUTransform
{
    mat4 transform;
};

uniform vec4 CB0[47];
uniform vec4 CB8[24];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;

in vec4 VARYING0;
in vec4 VARYING2;
in vec3 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
out vec4 _entryPointOutput;

void main()
{
    vec4 f0 = texture(DiffuseMapTexture, VARYING0.xy) * VARYING2;
    vec3 f1 = normalize(VARYING5.xyz);
    vec3 f2 = -CB0[11].xyz;
    float f3 = dot(f1, f2);
    vec3 f4 = f0.xyz;
    float f5 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f6 = VARYING3.yzx - (VARYING3.yzx * f5);
    vec4 f7 = vec4(clamp(f5, 0.0, 1.0));
    vec4 f8 = mix(texture(LightMapTexture, f6), vec4(0.0), f7);
    vec4 f9 = mix(texture(LightGridSkylightTexture, f6), vec4(1.0), f7);
    vec3 f10 = (f8.xyz * (f8.w * 120.0)).xyz;
    float f11 = f9.x;
    float f12 = f9.y;
    vec3 f13 = VARYING6.xyz - CB0[41].xyz;
    vec3 f14 = VARYING6.xyz - CB0[42].xyz;
    vec3 f15 = VARYING6.xyz - CB0[43].xyz;
    vec4 f16 = vec4(VARYING6.xyz, 1.0) * mat4(CB8[((dot(f13, f13) < CB0[41].w) ? 0 : ((dot(f14, f14) < CB0[42].w) ? 1 : ((dot(f15, f15) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f13, f13) < CB0[41].w) ? 0 : ((dot(f14, f14) < CB0[42].w) ? 1 : ((dot(f15, f15) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f13, f13) < CB0[41].w) ? 0 : ((dot(f14, f14) < CB0[42].w) ? 1 : ((dot(f15, f15) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f13, f13) < CB0[41].w) ? 0 : ((dot(f14, f14) < CB0[42].w) ? 1 : ((dot(f15, f15) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f17 = textureLod(ShadowAtlasTexture, f16.xy, 0.0);
    vec2 f18 = vec2(0.0);
    f18.x = CB0[45].z;
    vec2 f19 = f18;
    f19.y = CB0[45].w;
    float f20 = (2.0 * f16.z) - 1.0;
    float f21 = exp(CB0[45].z * f20);
    float f22 = -exp((-CB0[45].w) * f20);
    vec2 f23 = (f19 * CB0[46].y) * vec2(f21, f22);
    vec2 f24 = f23 * f23;
    float f25 = f17.x;
    float f26 = max(f17.y - (f25 * f25), f24.x);
    float f27 = f21 - f25;
    float f28 = f17.z;
    float f29 = max(f17.w - (f28 * f28), f24.y);
    float f30 = f22 - f28;
    float f31 = (f3 > 0.0) ? mix(f12, mix(min((f21 <= f25) ? 1.0 : clamp(((f26 / (f26 + (f27 * f27))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f22 <= f28) ? 1.0 : clamp(((f29 / (f29 + (f30 * f30))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f12, clamp((length(VARYING6.xyz - CB0[7].xyz) * CB0[45].y) - (CB0[45].x * CB0[45].y), 0.0, 1.0)), CB0[46].x) : 0.0;
    vec3 f32 = normalize(VARYING4.xyz);
    vec3 f33 = (f4 * f4).xyz;
    float f34 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f35 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f36 = reflect(-f32, f1);
    float f37 = f35 * 5.0;
    vec3 f38 = vec4(f36, f37).xyz;
    vec4 f39 = texture(PrecomputedBRDFTexture, vec2(f35, max(9.9999997473787516355514526367188e-05, dot(f1, f32))));
    float f40 = VARYING6.w * f34;
    vec3 f41 = mix(vec3(0.039999999105930328369140625), f33, vec3(f40));
    vec3 f42 = normalize(f2 + f32);
    float f43 = clamp(f3, 0.0, 1.0);
    float f44 = f35 * f35;
    float f45 = max(0.001000000047497451305389404296875, dot(f1, f42));
    float f46 = dot(f2, f42);
    float f47 = 1.0 - f46;
    float f48 = f47 * f47;
    float f49 = (f48 * f48) * f47;
    vec3 f50 = vec3(f49) + (f41 * (1.0 - f49));
    float f51 = f44 * f44;
    float f52 = (((f45 * f51) - f45) * f45) + 1.0;
    float f53 = 1.0 - f40;
    float f54 = f39.x;
    float f55 = f39.y;
    vec3 f56 = ((f41 * f54) + vec3(f55)) / vec3(f54 + f55);
    vec3 f57 = (vec3(1.0) - (f56 * f34)) * f53;
    vec3 f58 = f1 * f1;
    bvec3 f59 = lessThan(f1, vec3(0.0));
    vec3 f60 = vec3(f59.x ? f58.x : vec3(0.0).x, f59.y ? f58.y : vec3(0.0).y, f59.z ? f58.z : vec3(0.0).z);
    vec3 f61 = f58 - f60;
    float f62 = f61.x;
    float f63 = f61.y;
    float f64 = f61.z;
    float f65 = f60.x;
    float f66 = f60.y;
    float f67 = f60.z;
    vec3 f68 = (mix(textureLod(PrefilteredEnvIndoorTexture, f38, f37).xyz * f10, textureLod(PrefilteredEnvTexture, f38, f37).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f36.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f11)) * f56) * f34;
    vec3 f69 = (((((((((vec3(1.0) - (f50 * f34)) * f53) * CB0[10].xyz) * f43) * f31) + (f57 * (((((((CB0[35].xyz * f62) + (CB0[37].xyz * f63)) + (CB0[39].xyz * f64)) + (CB0[36].xyz * f65)) + (CB0[38].xyz * f66)) + (CB0[40].xyz * f67)) + (((((((CB0[29].xyz * f62) + (CB0[31].xyz * f63)) + (CB0[33].xyz * f64)) + (CB0[30].xyz * f65)) + (CB0[32].xyz * f66)) + (CB0[34].xyz * f67)) * f11)))) + (CB0[27].xyz + (CB0[28].xyz * f11))) * f33) + (((((f50 * ((f51 + (f51 * f51)) / (((f52 * f52) * ((f46 * 3.0) + 0.5)) * ((f45 * 0.75) + 0.25)))) * CB0[10].xyz) * f43) * f31) + f68)) + (f10 * mix(f33, f68 * (1.0 / (max(max(f68.x, f68.y), f68.z) + 0.00999999977648258209228515625)), ((vec3(1.0) - f57) * f34) * (1.0 - f11)));
    vec4 f70 = vec4(f69.x, f69.y, f69.z, vec4(0.0).w);
    f70.w = f0.w;
    vec3 f71 = mix(CB0[14].xyz, (sqrt(clamp(f70.xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    _entryPointOutput = vec4(f71.x, f71.y, f71.z, f70.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
