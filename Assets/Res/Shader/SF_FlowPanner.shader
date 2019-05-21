// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shader Forge/SF_FlowPanner" 
{
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _FlowMap ("FlowMap", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Emissive_Strength ("Emissive_Strength", Float ) = 1
        _Alpha_Strength ("Alpha_Strength", Float ) = 2
        _FlowMap_Strength ("FlowMap_Strength", Float ) = 0.1
        _FlowU_Offset ("FlowU_Offset", Float ) = 1
        _MainTex_Voffset ("MainTex_Voffset", Float ) = 0.5
        _FlowMap_copy ("FlowMap_copy", 2D) = "white" {}
        _FlowV_Offset ("FlowV_Offset", Float ) = 1
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
            //#define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            uniform fixed4 _TimeEditor;
            uniform sampler2D _MainTex; uniform fixed4 _MainTex_ST;
            uniform sampler2D _FlowMap; uniform fixed4 _FlowMap_ST;
            uniform sampler2D _Mask; uniform fixed4 _Mask_ST;
            uniform fixed _Emissive_Strength;
            uniform fixed _Alpha_Strength;
            uniform fixed _FlowMap_Strength;
            uniform fixed _FlowU_Offset;
            uniform fixed _MainTex_Voffset;
            uniform sampler2D _FlowMap_copy; uniform fixed4 _FlowMap_copy_ST;
            uniform fixed _FlowV_Offset;

            struct VertexInput 
            {
                float4 vertex : POSITION;
                //fixed3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput 
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                //fixed4 posWorld : TEXCOORD1;
                //fixed3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                //o.normalDir = UnityObjectToWorldNormal(v.normal);
                //o.posWorld = mul(_Object2World, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }

            fixed4 frag(VertexOutput i, fixed facing : VFACE) : COLOR 
            {
                fixed isFrontFace = ( facing >= 0 ? 1 : 0 );
                fixed faceSign = ( facing >= 0 ? 1 : -1 );
                //i.normalDir = normalize(i.normalDir);
                //i.normalDir *= faceSign;
                //fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                //fixed3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                fixed4 node_8540 = _Time + _TimeEditor;
                fixed4 node_7117 = _Time + _TimeEditor;
                fixed2 node_5124 = (i.uv0+(node_7117.g*_FlowU_Offset)*fixed2(1,0));
                fixed4 _FlowMap_var = tex2D(_FlowMap,TRANSFORM_TEX(node_5124, _FlowMap));
                fixed2 node_1432 = (i.uv0+(node_7117.g*_FlowV_Offset)*fixed2(0,1));
                fixed4 _FlowMap_copy_var = tex2D(_FlowMap_copy,TRANSFORM_TEX(node_1432, _FlowMap_copy));
                fixed2 node_8492 = ((i.uv0+(fixed2(_FlowMap_var.r,_FlowMap_copy_var.g)*_FlowMap_Strength))+(node_8540.g*_MainTex_Voffset)*fixed2(0,1));
                fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_8492, _MainTex));
                fixed3 emissive = ((_MainTex_var.rgb*i.vertexColor.rgb)*_Emissive_Strength);
                fixed3 finalColor = emissive;
                fixed4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                //fixed node_1148 = (1.0 - pow(1.0-max(0,dot(normalDirection, viewDirection)),3.0));
                fixed node_1148 = (1.0 - pow(1.0-max(0,1.0),3.0));
                return fixed4(finalColor,(((i.vertexColor.a*(_MainTex_var.r*_Mask_var.r))*_Alpha_Strength)*(node_1148*node_1148)));
                //return fixed4(finalColor,(((i.vertexColor.a*(_MainTex_var.r*_Mask_var.r))*_Alpha_Strength)));
            }
            ENDCG
        }
    }
    //FallBack "Legacy Shaders/Transparent/VertexLit"
    //FallBack "Diffuse"
    //CustomEditor "ShaderForgeMaterialInspector"
}