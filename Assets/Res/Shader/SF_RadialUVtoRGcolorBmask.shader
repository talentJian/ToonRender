// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shader Forge/SF_RadialUVtoRGcolorBmask" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _RadialUV ("RadialUV", 2D) = "white" {}
        _FlowSpeed_U ("FlowSpeed_U", Float ) = 0.1
        _FlowSpeed_V ("FlowSpeed_V", Float ) = 1
        _FlowMap ("FlowMap", 2D) = "white" {}
        _FlowStrength ("FlowStrength", Float ) = 0.2
        _Color_R ("Color_R", Color) = (1,0.2205882,0.5914803,1)
        _Color_G ("Color_G", Color) = (0.2573529,0.4775862,1,1)
        _EmissStrength ("EmissStrength", Float ) = 1
        _AlphaStrength ("AlphaStrength", Float ) = 1
        _MainTex_copy ("MainTex_copy", 2D) = "white" {}
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _RadialUV; uniform float4 _RadialUV_ST;
            uniform float _FlowSpeed_U;
            uniform float _FlowSpeed_V;
            uniform sampler2D _FlowMap; uniform float4 _FlowMap_ST;
            uniform float _FlowStrength;
            uniform float4 _Color_R;
            uniform float4 _Color_G;
            uniform float _EmissStrength;
            uniform float _AlphaStrength;
            uniform sampler2D _MainTex_copy; uniform float4 _MainTex_copy_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_2398 = _Time + _TimeEditor;
                float4 _RadialUV_var = tex2D(_RadialUV,TRANSFORM_TEX(i.uv0, _RadialUV));
                float node_1342 = 0.0;
                float2 node_7415 = (((float2(_RadialUV_var.r,node_1342)+(node_2398.g*_FlowSpeed_U)*float2(1,0))+(float2(node_1342,_RadialUV_var.g)+(node_2398.g*_FlowSpeed_V)*float2(0,1)))/2.0);
                float4 _FlowMap_var = tex2D(_FlowMap,TRANSFORM_TEX(node_7415, _FlowMap));
                float node_2013 = (_FlowStrength+1.0);
                float2 node_9189 = float2(((i.uv0.r+(_FlowMap_var.r*_FlowStrength))/node_2013),((i.uv0.g+(_FlowMap_var.g*_FlowStrength))/node_2013));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_9189, _MainTex));
                float node_5065 = (_MainTex_var.r*_MainTex_var.g);
                float4 _MainTex_copy_var = tex2D(_MainTex_copy,TRANSFORM_TEX(i.uv0, _MainTex_copy));
                float3 emissive = ((((((_Color_R.rgb*_MainTex_var.r)+(_MainTex_var.g*_Color_G.rgb))+((node_5065*node_5065)*2.0))*_EmissStrength)*_MainTex_copy_var.b)*i.vertexColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,(i.vertexColor.a*(((_MainTex_var.r+_MainTex_var.g)*_AlphaStrength)*_MainTex_copy_var.b)));
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
    //CustomEditor "ShaderForgeMaterialInspector"
}
