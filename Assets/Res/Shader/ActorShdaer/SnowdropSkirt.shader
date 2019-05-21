// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge

Shader "Shader Forge/SnowdropSkirt" {
    Properties {
        _RimLight ("RimLight", Range(0, 5)) = 0.8672428
        _Transparent ("Transparent", Range(0, 1)) = 1
        _RimTransparent ("RimTransparent", Range(0, 1)) = 0.4189994
        _Gloss ("Gloss", Range(0, 5)) = 3.38003
        _SpecColor ("SpecColor", Color) = (0.5,0.5,0.5,1)
        _Texture ("Texture", 2D) = "white" {}
        _Normal ("Normal", 2D) = "black" {}
        _RimColor ("RimColor", Color) = (0.5,0.5,0.5,1)
        [HDR]_MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform fixed _RimLight;
            uniform fixed _Transparent;
            uniform fixed _RimTransparent;
            uniform half _Gloss;
            uniform fixed4 _SpecColor;
            uniform sampler2D _Texture; uniform fixed4 _Texture_ST;
            uniform sampler2D _Normal; uniform fixed4 _Normal_ST;
            uniform fixed4 _RimColor;
            uniform fixed4 _MainColor;
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
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            fixed4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                fixed isFrontFace = ( facing >= 0 ? 1 : 0 );
                fixed faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                half3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                fixed4 node_9396 = tex2D(_Normal,TRANSFORM_TEX(i.uv0, _Normal)); // 提取rgb作为法线
                fixed3 normalLocal = node_9396.rgb;
                half3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                half3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                half3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                fixed4 node_7717 = tex2D(_Normal,TRANSFORM_TEX(i.uv0, _Normal)); // 提取a通道
                fixed4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
                fixed node_9664 = pow((isFrontFace*(1.0-max(0,dot(normalDirection, viewDirection)))),exp(_RimLight));
                fixed3 finalColor = saturate(((_SpecColor.rgb*saturate(pow(dot(normalDirection,halfDirection),exp(_Gloss))))+node_7717.a+(_Texture_var.rgb*_MainColor.rgb)+(node_9664*_RimColor.rgb)));
                return fixed4(finalColor,saturate((node_7717.a+_Transparent+(_Texture_var.a*saturate((0.4+isFrontFace)))+(_RimTransparent*node_9664))));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
