#version 110
#extension GL_ARB_shader_texture_lod : require

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

struct MaterialParams
{
    float textureTiling;
    float specularScale;
    float glossScale;
    float reflectionScale;
    float normalShadowScale;
    float specularLod;
    float glossLod;
    float normalDetailTiling;
    float normalDetailScale;
    float farTilingDiffuse;
    float farTilingNormal;
    float farTilingSpecular;
    float farDiffuseCutoff;
    float farNormalCutoff;
    float farSpecularCutoff;
    float optBlendColorK;
    float farDiffuseCutoffScale;
    float farNormalCutoffScale;
    float farSpecularCutoffScale;
    float isNonSmoothPlastic;
};

uniform vec4 CB0[32];
uniform vec4 CB2[5];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D WangTileMapTexture;
uniform sampler2D DiffuseMapTexture;

varying vec4 VARYING0;
varying vec4 VARYING2;
varying vec4 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;

void main()
{
    vec2 f0 = (VARYING0.xy * CB2[0].x) * 4.0;
    vec2 f1 = f0 * 0.25;
    vec4 f2 = vec4(dFdx(f1), dFdy(f1));
    vec4 f3 = texture2DGradARB(DiffuseMapTexture, (texture2D(WangTileMapTexture, f0 * vec2(0.0078125)).zw * 0.99609375) + (fract(f0) * 0.25), f2.xy, f2.zw);
    vec3 f4 = (mix(vec3(1.0), VARYING2.xyz, vec3(f3.w)) * f3.xyz).xyz;
    vec3 f5 = vec3(CB0[15].x);
    float f6 = clamp(dot(step(CB0[20].xyz, abs(VARYING3.xyz - CB0[19].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f7 = VARYING3.yzx - (VARYING3.yzx * f6);
    vec4 f8 = vec4(clamp(f6, 0.0, 1.0));
    vec4 f9 = mix(texture3D(LightMapTexture, f7), vec4(0.0), f8);
    vec4 f10 = mix(texture3D(LightGridSkylightTexture, f7), vec4(1.0), f8);
    vec4 f11 = texture2D(ShadowMapTexture, VARYING6.xy);
    float f12 = (1.0 - ((step(f11.x, VARYING6.z) * clamp(CB0[25].z + (CB0[25].w * abs(VARYING6.z - 0.5)), 0.0, 1.0)) * f11.y)) * f10.y;
    vec3 f13 = ((min(((f9.xyz * (f9.w * 120.0)).xyz + CB0[8].xyz) + (CB0[9].xyz * f10.x), vec3(CB0[17].w)) + (VARYING5.xyz * f12)) * mix(f4, f4 * f4, f5).xyz) + (CB0[10].xyz * (VARYING5.w * f12));
    vec4 f14 = vec4(f13.x, f13.y, f13.z, vec4(0.0).w);
    f14.w = VARYING2.w;
    vec3 f15 = mix(CB0[14].xyz, mix(f14.xyz, sqrt(clamp(f14.xyz * CB0[15].z, vec3(0.0), vec3(1.0))), f5).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    gl_FragData[0] = vec4(f15.x, f15.y, f15.z, f14.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$WangTileMapTexture=s9
//$$DiffuseMapTexture=s3
