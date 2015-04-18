Shader "FShader/Car_Glass" {
    Properties {
        _CubeMap ("CubeMap", Cube) = "_Skybox" {}
        _CubeMapColor ("CubeMap Color", Color) = (1,1,1,1)
        _Fresnel ("Fresnel", Range(0, 5)) = 5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            float4 _LightColor0;
            samplerCUBE _CubeMap;
            float4 _CubeMapColor;
            float _Fresnel;
            struct Input {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct Output {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };
            Output vert (Input v) {
                Output o;
                o.normalDir = mul(float4(v.normal,0), _World2Object).xyz;
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            fixed4 frag(Output i) : COLOR {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection =  i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
                float NdotL = dot( normalDirection, lightDirection );
                float3 diffuse = max( 0.0, NdotL) * attenColor + UNITY_LIGHTMODEL_AMBIENT.rgb;
                float a = pow(1.0-max(0,dot(normalDirection, viewDirection)),_Fresnel);
                float3 emissive = float3(a,a,a);
                float3 finalColor = 0;
                float3 diffuseLight = diffuse;
                finalColor += diffuseLight * (texCUBE(_CubeMap,viewReflectDirection).rgb*_CubeMapColor.rgb);
                finalColor += emissive;
                return fixed4(finalColor,_CubeMapColor.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
