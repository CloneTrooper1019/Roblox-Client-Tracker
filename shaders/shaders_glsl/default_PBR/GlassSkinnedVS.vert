#version 110

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
    float debugFlagsShadows;
};

uniform vec4 CB0[47];
uniform vec4 CB1[216];
attribute vec4 POSITION;
attribute vec4 NORMAL;
attribute vec2 TEXCOORD0;
attribute vec2 TEXCOORD1;
attribute vec4 COLOR0;
attribute vec4 COLOR1;
varying vec2 VARYING0;
varying vec2 VARYING1;
varying vec4 VARYING2;
varying vec3 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;
varying vec4 VARYING7;
varying float VARYING8;

void main()
{
    vec3 v0 = (NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    int v1 = int(COLOR1.x) * 3;
    int v2 = v1 + 1;
    int v3 = v1 + 2;
    float v4 = dot(CB1[v1 * 1 + 0], POSITION);
    float v5 = dot(CB1[v2 * 1 + 0], POSITION);
    float v6 = dot(CB1[v3 * 1 + 0], POSITION);
    vec3 v7 = vec3(v4, v5, v6);
    float v8 = dot(CB1[v1 * 1 + 0].xyz, v0);
    float v9 = dot(CB1[v2 * 1 + 0].xyz, v0);
    float v10 = dot(CB1[v3 * 1 + 0].xyz, v0);
    vec3 v11 = vec3(v8, v9, v10);
    vec3 v12 = -CB0[11].xyz;
    float v13 = dot(v11, v12);
    vec3 v14 = CB0[7].xyz - v7;
    vec4 v15 = vec4(v4, v5, v6, 1.0);
    vec4 v16 = v15 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 v17 = vec4(v14, v16.w);
    float v18 = COLOR0.w * 2.0;
    float v19 = clamp(v18 - 1.0, 0.0, 1.0);
    float v20 = (clamp(2.0 - (dot(v11, normalize(v17.xyz)) * 3.0), 0.0, 1.0) * 0.300000011920928955078125) * clamp(v18, 0.0, 1.0);
    vec4 v21 = COLOR0;
    v21.w = mix(v19, 1.0, v20);
    vec4 v22 = vec4(dot(CB0[20], v15), dot(CB0[21], v15), dot(CB0[22], v15), 0.0);
    v22.w = mix((COLOR1.w * 0.0039215688593685626983642578125) * v19, 1.0, v20);
    float v23 = COLOR1.y * 0.50359570980072021484375;
    float v24 = clamp(v13, 0.0, 1.0);
    vec3 v25 = (CB0[10].xyz * v24) + (CB0[12].xyz * clamp(-v13, 0.0, 1.0));
    vec4 v26 = vec4(v25.x, v25.y, v25.z, vec4(0.0).w);
    v26.w = (v24 * CB0[23].w) * (COLOR1.y * exp2((v23 * dot(v11, normalize(v12 + normalize(v14)))) - v23));
    gl_Position = v16;
    VARYING0 = TEXCOORD0;
    VARYING1 = TEXCOORD1;
    VARYING2 = v21;
    VARYING3 = ((v7 + (v11 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    VARYING4 = v17;
    VARYING5 = vec4(v8, v9, v10, COLOR1.z);
    VARYING6 = v26;
    VARYING7 = v22;
    VARYING8 = NORMAL.w;
}

