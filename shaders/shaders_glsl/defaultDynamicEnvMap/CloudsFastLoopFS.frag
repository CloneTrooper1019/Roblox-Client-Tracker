#version 110
#extension GL_ARB_shader_texture_lod : require

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <RayFrame.h>
#include <CloudsParams.h>
uniform vec4 CB0[53];
uniform vec4 CB1[1];
uniform vec4 CB2[3];
uniform sampler3D NoiseTexTexture;
uniform sampler3D CloudsDistanceFieldTexture;

void main()
{
    vec2 f0 = CB1[0].zw * ((gl_FragCoord.xy * CB1[0].xy) - vec2(1.0));
    vec3 f1 = normalize(((CB0[4].xyz * f0.x) + (CB0[5].xyz * f0.y)) - CB0[6].xyz);
    float f2 = f1.y;
    if (f2 < 0.0)
    {
        discard;
    }
    vec3 f3 = CB0[7].xyz * 0.00028000000747852027416229248046875;
    vec3 f4 = f3;
    f4.y = f3.y + 6371.0;
    float f5 = dot(f1, f4);
    float f6 = 2.0 * f5;
    vec2 f7 = (vec2(f5 * (-2.0)) + sqrt(vec2(f6 * f6) - ((vec2(dot(f4, f4)) - vec2(40615128.0, 40647000.0)) * 4.0))) * 0.5;
    float f8 = f7.x;
    float f9 = f7.y - f8;
    float f10 = dot(CB0[11].xyz, -f1);
    float f11 = f10 + 0.819406807422637939453125;
    vec3 f12 = f1;
    f12.y = 0.0375653542578220367431640625 + (0.96243464946746826171875 * f2);
    vec3 f13 = f3 + (f12 * f8);
    f13.y = 0.0;
    int f14 = int(CB2[2].z);
    float f15 = float(f14);
    float f16 = 1.0 / f15;
    float f17 = 0.0625 + (CB2[2].x * 0.5);
    float f18 = (f17 * f16) * f9;
    float f19 = f16 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))));
    float f20 = f17 * f9;
    vec3 f21;
    float f22;
    vec3 f23;
    vec4 f24;
    f24 = vec4(0.0);
    f23 = (f13 + ((f12 * f20) * f19)) + ((CB2[0].xyz * CB2[0].w) * 50.0);
    f22 = f8 + (f20 * f19);
    f21 = f13;
    float f25;
    vec3 f26;
    vec3 f27;
    bool f28;
    bool f29;
    float f30;
    float f31;
    vec4 f32;
    vec4 f33;
    int f34 = 0;
    float f35 = 1.0;
    bool f36 = false;
    for (;;)
    {
        if (f34 < f14)
        {
            float f37 = CB2[0].w * 1.5625;
            vec3 f38 = f21;
            f38.x = f21.x + f37;
            vec3 f39 = f38 * vec3(0.5, 2.0, 0.5);
            float f40 = 0.03125 + (CB2[2].x * 0.125);
            float f41 = texture3DLod(CloudsDistanceFieldTexture, vec4((f23 * vec3(0.03125, 1.0, 0.03125)).xzy, 0.0).xyz, 0.0).x - (f40 * (texture3DLod(NoiseTexTexture, vec4(fract(f39), 0.0).xyz, 0.0).x + (0.25 * texture3DLod(NoiseTexTexture, vec4(fract((f39 * mat3(vec3(0.0, 0.800000011920928955078125, 0.60000002384185791015625), vec3(-0.800000011920928955078125, 0.36000001430511474609375, -0.4799999892711639404296875), vec3(-0.60000002384185791015625, -0.4799999892711639404296875, 0.63999998569488525390625))) * 2.019999980926513671875), 0.0).xyz, 0.0).x)));
            bool f42 = f41 < CB2[2].x;
            if (f42)
            {
                float f43 = (CB2[2].y * 128.0) * (CB2[2].x - f41);
                vec3 f44 = -CB0[11].xyz;
                int f45 = int(CB2[2].w);
                float f46 = 4.0 / float(f45);
                float f47;
                f47 = 0.0;
                float f48;
                for (int f49 = 0; f49 < f45; f47 = f48, f49++)
                {
                    vec3 f50 = (f44 * float(f49)) * f46;
                    vec3 f51 = (f23 + ((f44 * f46) * fract(52.98291778564453125 * fract(dot(vec2(0.300000011920928955078125) + gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125)))))) + f50;
                    vec3 f52 = f23 + f50;
                    if (f51.y > 1.0)
                    {
                        break;
                    }
                    vec3 f53 = f52;
                    f53.x = f52.x + f37;
                    vec3 f54 = f53 * vec3(0.5, 2.0, 0.5);
                    float f55 = texture3DLod(CloudsDistanceFieldTexture, vec4((f51 * vec3(0.03125, 1.0, 0.03125)).xzy, 0.0).xyz, 0.0).x - (f40 * (texture3DLod(NoiseTexTexture, vec4(fract(f54), 0.0).xyz, 0.0).x + (0.25 * texture3DLod(NoiseTexTexture, vec4(fract((f54 * mat3(vec3(0.0, 0.800000011920928955078125, 0.60000002384185791015625), vec3(-0.800000011920928955078125, 0.36000001430511474609375, -0.4799999892711639404296875), vec3(-0.60000002384185791015625, -0.4799999892711639404296875, 0.63999998569488525390625))) * 2.019999980926513671875), 0.0).xyz, 0.0).x)));
                    if (f55 < 0.5)
                    {
                        f48 = f47 + (0.5 * (1.0 - (2.0 * f55)));
                    }
                    else
                    {
                        f48 = f47;
                    }
                }
                float f56 = f47 * f46;
                float f57 = mix(0.07999999821186065673828125, 1.0, smoothstep(0.959999978542327880859375, 0.0, f10));
                vec3 f58 = mix(vec3(0.1500000059604644775390625 + (0.300000011920928955078125 * f23.y)), mix(CB0[26].xyz, CB0[25].xyz, vec3(f23.y)), vec3(clamp(exp2(CB0[11].y), 0.0, 1.0))) + ((CB0[10].xyz * ((((exp2(-f56) + ((0.5 * f57) * exp2((-0.100000001490116119384765625) * f56))) + ((f57 * 2.0) * exp2((-0.0199999995529651641845703125) * f56))) * dot(exp2(vec4(((-93.775177001953125) * f10) + (-79.34822845458984375), ((-83.703338623046875) * f11) * f11, 7.810082912445068359375 * f10, (-4.5521251698654729977988608879969e-12) * f10)), vec4(9.8052332759834825992584228515625e-06, 0.13881979882717132568359375, 0.00205474696122109889984130859375, 0.0260056294500827789306640625))) * mix(0.0500000007450580596923828125 + (2.0 * pow(clamp(f43, 9.9999997473787516355514526367188e-06, 1.0), 0.300000011920928955078125 + (5.5 * f23.y))), 1.0, f56))) * 2.099999904632568359375);
                float f59 = exp2(((-1.44269502162933349609375) / f15) * f43);
                vec3 f60 = f24.xyz + (((f58 - (f58 * f59)) * f35) / vec3(f43));
                vec4 f61 = vec4(f60.x, f60.y, f60.z, f24.w);
                float f62 = f35 * f59;
                if (f62 < 0.001000000047497451305389404296875)
                {
                    f32 = f61;
                    f30 = f62;
                    f29 = true;
                    break;
                }
                f33 = f61;
                f31 = f62;
            }
            else
            {
                f33 = f24;
                f31 = f35;
            }
            f28 = f42 ? true : f36;
            f25 = f22 + f18;
            vec3 f63 = f12 * vec3(f18, f16, f18);
            f26 = f23 + f63;
            f27 = f21 + f63;
            f24 = f33;
            f23 = f26;
            f22 = f25;
            f35 = f31;
            f21 = f27;
            f34++;
            f36 = f28;
            continue;
        }
        else
        {
            f32 = f24;
            f30 = f35;
            f29 = f36;
            break;
        }
    }
    if (!f29)
    {
        discard;
    }
    vec3 f64 = mix(CB0[14].xyz, f32.xyz, vec3(exp2((CB0[13].z * 3.5714285373687744140625) * (f22 * f22))));
    vec4 f65 = vec4(f64.x, f64.y, f64.z, f32.w);
    f65.w = 1.0 - f30;
    gl_FragData[0] = f65;
}

//$$NoiseTexTexture=s1
//$$CloudsDistanceFieldTexture=s0
