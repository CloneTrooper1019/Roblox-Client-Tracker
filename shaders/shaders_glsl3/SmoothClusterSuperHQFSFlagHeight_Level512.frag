#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform vec4 CB5[74];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2DArray SpecularMapTexture;
uniform sampler2DArray AlbedoMapTexture;
uniform sampler2DArray NormalMapTexture;

in vec4 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec3 VARYING4;
in vec4 VARYING5;
in vec3 VARYING6;
in vec3 VARYING7;
in vec4 VARYING8;
in vec3 VARYING9;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec4 f1 = texture(SpecularMapTexture, f0);
    vec3 f2 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f3 = texture(SpecularMapTexture, f2);
    vec4 f4 = texture(SpecularMapTexture, VARYING3.xyz);
    vec3 f5;
    if (VARYING8.w < 1.0)
    {
        ivec3 f6 = ivec3(VARYING8.xyz + vec3(0.5));
        int f7 = f6.x;
        int f8 = f6.y;
        int f9 = f6.z;
        float f10 = dot(VARYING0.xyz, vec3(CB5[f7 * 1 + 0].z, CB5[f8 * 1 + 0].z, CB5[f9 * 1 + 0].z));
        float f11 = f1.w;
        float f12 = f3.w;
        float f13 = f4.w;
        vec3 f14 = vec3(f11, f12, f13);
        f14.x = clamp((f11 * CB5[f7 * 1 + 0].x) + CB5[f7 * 1 + 0].y, 0.0, 1.0);
        vec3 f15 = f14;
        f15.y = clamp((f12 * CB5[f8 * 1 + 0].x) + CB5[f8 * 1 + 0].y, 0.0, 1.0);
        vec3 f16 = f15;
        f16.z = clamp((f13 * CB5[f9 * 1 + 0].x) + CB5[f9 * 1 + 0].y, 0.0, 1.0);
        vec3 f17 = VARYING0.xyz * f16;
        float f18 = 1.0 / f10;
        float f19 = 0.5 * f10;
        float f20 = f17.x;
        float f21 = f17.y;
        float f22 = f17.z;
        float f23 = clamp(((f20 - max(f21, f22)) + f19) * f18, 0.0, 1.0);
        float f24 = clamp(((f21 - max(f20, f22)) + f19) * f18, 0.0, 1.0);
        float f25 = clamp(((f22 - max(f20, f21)) + f19) * f18, 0.0, 1.0);
        vec2 f26 = dFdx(VARYING1.xy);
        vec2 f27 = dFdy(VARYING1.xy);
        f5 = mix(vec3(f23, f24, f25) / vec3((f23 + f24) + f25), VARYING0.xyz, vec3(clamp((sqrt(max(dot(f26, f26), dot(f27, f27))) * 7.0) + clamp(VARYING8.w, 0.0, 1.0), 0.0, 1.0)));
    }
    else
    {
        f5 = VARYING0.xyz;
    }
    vec4 f28 = ((f1 * f5.x) + (f3 * f5.y)) + (f4 * f5.z);
    vec4 f29 = ((texture(AlbedoMapTexture, f0).yxzw * f5.x) + (texture(AlbedoMapTexture, f2).yxzw * f5.y)) + (texture(AlbedoMapTexture, VARYING3.xyz).yxzw * f5.z);
    vec2 f30 = f29.yz - vec2(0.5);
    float f31 = f29.x;
    float f32 = f31 - f30.y;
    vec3 f33 = vec4(vec3(f32, f31, f32) + (vec3(f30.xyx) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    float f34 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    float f35 = -VARYING6.x;
    vec2 f36 = (((texture(NormalMapTexture, f0) * f5.x) + (texture(NormalMapTexture, f2) * f5.y)) + (texture(NormalMapTexture, VARYING3.xyz) * f5.z)).wy * 2.0;
    vec2 f37 = f36 - vec2(1.0);
    vec3 f38 = normalize(((vec3(f37, sqrt(clamp(1.0 + dot(vec2(1.0) - f36, f37), 0.0, 1.0))) - vec3(0.0, 0.0, 1.0)) * inversesqrt(dot(f5, f5))) + vec3(0.0, 0.0, 1.0));
    vec3 f39 = vec3(dot(VARYING7, f5));
    vec3 f40 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f35), vec3(VARYING6.y, f35, 0.0), f39) * f38.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f39) * f38.y)) + (VARYING6 * f38.z)), 0.0).xyz;
    vec3 f41 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f42 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f43 = VARYING4.yzx - (VARYING4.yzx * f42);
    vec4 f44 = vec4(clamp(f42, 0.0, 1.0));
    vec4 f45 = mix(texture(LightMapTexture, f43), vec4(0.0), f44);
    vec4 f46 = mix(texture(LightGridSkylightTexture, f43), vec4(1.0), f44);
    float f47 = f46.x;
    vec4 f48 = texture(ShadowMapTexture, f41.xy);
    float f49 = f41.z;
    vec3 f50 = normalize(VARYING9);
    vec3 f51 = (f33 * f33).xyz;
    float f52 = f28.y;
    float f53 = CB0[26].w * f34;
    vec3 f54 = reflect(-f50, f40);
    vec3 f55 = -CB0[11].xyz;
    float f56 = dot(f40, f55) * ((1.0 - ((step(f48.x, f49) * clamp(CB0[24].z + (CB0[24].w * abs(f49 - 0.5)), 0.0, 1.0)) * f48.y)) * f46.y);
    vec3 f57 = normalize(f55 + f50);
    float f58 = clamp(f56, 0.0, 1.0);
    float f59 = f52 * f52;
    float f60 = max(0.001000000047497451305389404296875, dot(f40, f57));
    float f61 = dot(f55, f57);
    float f62 = 1.0 - f61;
    float f63 = f62 * f62;
    float f64 = (f63 * f63) * f62;
    vec3 f65 = vec3(f64) + (vec3(0.039999999105930328369140625) * (1.0 - f64));
    float f66 = f59 * f59;
    float f67 = (((f60 * f66) - f60) * f60) + 1.0;
    float f68 = f52 * 5.0;
    vec3 f69 = vec4(f54, f68).xyz;
    vec4 f70 = texture(PrecomputedBRDFTexture, vec2(f52, max(9.9999997473787516355514526367188e-05, dot(f40, f50))));
    float f71 = f70.x;
    float f72 = f70.y;
    vec3 f73 = ((vec3(0.039999999105930328369140625) * f71) + vec3(f72)) / vec3(f71 + f72);
    vec3 f74 = f73 * f53;
    vec3 f75 = f40 * f40;
    bvec3 f76 = lessThan(f40, vec3(0.0));
    vec3 f77 = vec3(f76.x ? f75.x : vec3(0.0).x, f76.y ? f75.y : vec3(0.0).y, f76.z ? f75.z : vec3(0.0).z);
    vec3 f78 = f75 - f77;
    float f79 = f78.x;
    float f80 = f78.y;
    float f81 = f78.z;
    float f82 = f77.x;
    float f83 = f77.y;
    float f84 = f77.z;
    vec3 f85 = ((((((CB0[35].xyz * f79) + (CB0[37].xyz * f80)) + (CB0[39].xyz * f81)) + (CB0[36].xyz * f82)) + (CB0[38].xyz * f83)) + (CB0[40].xyz * f84)) + (((((((CB0[29].xyz * f79) + (CB0[31].xyz * f80)) + (CB0[33].xyz * f81)) + (CB0[30].xyz * f82)) + (CB0[32].xyz * f83)) + (CB0[34].xyz * f84)) * f47);
    vec3 f86 = (mix(textureLod(PrefilteredEnvIndoorTexture, f69, f68).xyz, textureLod(PrefilteredEnvTexture, f69, f68).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f54.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f47)) * f73) * f53;
    vec3 f87 = (((((((((vec3(1.0) - (f65 * f53)) * CB0[10].xyz) * f58) + (CB0[12].xyz * clamp(-f56, 0.0, 1.0))) + (((vec3(1.0) - f74) * f85) * CB0[25].w)) + ((CB0[27].xyz + (CB0[28].xyz * f47)) * 1.0)) + vec3((f28.z * 2.0) * f34)) * f51) + (((((f65 * (((f66 + (f66 * f66)) / (((f67 * f67) * ((f61 * 3.0) + 0.5)) * ((f60 * 0.75) + 0.25))) * f58)) * CB0[10].xyz) * f34) * VARYING0.w) + f86)) + (((f45.xyz * (f45.w * 120.0)).xyz * mix(f51, f86 * (1.0 / (max(max(f85.x, f85.y), f85.z) + 0.00999999977648258209228515625)), f74 * (f53 * (1.0 - f47)))) * 1.0);
    vec4 f88 = vec4(f87.x, f87.y, f87.z, vec4(0.0).w);
    f88.w = 1.0;
    float f89 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f90 = textureLod(PrefilteredEnvTexture, vec4(-VARYING9, 0.0).xyz, max(CB0[13].y, f89) * 5.0).xyz;
    bvec3 f91 = bvec3(CB0[13].w != 0.0);
    vec3 f92 = sqrt(clamp(mix(vec3(f91.x ? CB0[14].xyz.x : f90.x, f91.y ? CB0[14].xyz.y : f90.y, f91.z ? CB0[14].xyz.z : f90.z), f88.xyz, vec3(f89)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f92.x, f92.y, f92.z, f88.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s2
//$$AlbedoMapTexture=s0
//$$NormalMapTexture=s4
