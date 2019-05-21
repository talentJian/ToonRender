// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge

Shader "Shader Forge/GaleBody" {
    Properties {
        _Normal ("Normal", 2D) = "bump" {}
        _Textrue ("Textrue", 2D) = "white" {}
        _RimRange ("RimRange", Range(3, 0)) = 3
        _Transparency ("Transparency", Range(0, 1)) = 0
        [HDR]_light ("light", Color) = (0.5,0.5,0.5,1)
        _RimLight ("RimLight", Range(0, 5)) = 5
        [HDR]_RimColor ("RimColor", Color) = (0.5,0.5,0.5,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Pass {
            zwrite on
            ColorMask  0
            }

        Pass {
            Name "FORWARD"
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
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _Normal; uniform half4 _Normal_ST;
            uniform half _RimRange;
            uniform sampler2D _Textrue; uniform half4 _Textrue_ST;
            uniform fixed _Transparency;
            uniform fixed4 _light;
            uniform fixed _RimLight;
            uniform fixed4 _RimColor;
            struct VertexInput {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
                half2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                half4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
                half4 posWorld : TEXCOORD1;
                half3 normalDir : TEXCOORD2;
                half3 tangentDir : TEXCOORD3;
                half3 bitangentDir : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, half4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                half3x3 tangentTransform = half3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                fixed3 _Normal_var = UnpackNormal(tex2D(_Normal,TRANSFORM_TEX(i.uv0, _Normal)));
                fixed3 normalLocal = _Normal_var.rgb;
                half3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
////// Lighting:
                half4 _Textrue_var = tex2D(_Textrue,TRANSFORM_TEX(i.uv0, _Textrue));
                half node_4196 = pow(1.0-max(0,dot(normalDirection, viewDirection)),_RimRange);
                half node_6570 = saturate((_Textrue_var.a+node_4196+_Transparency));
                fixed3 node_7962 = (_light.rgb*(1.0 - node_6570));
                fixed3 finalColor = (node_7962+_Textrue_var.rgb+(saturate(pow(node_4196,_RimLight))*_RimColor.rgb));
                return fixed4(finalColor,node_6570);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
