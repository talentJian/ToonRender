// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:0,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:False,rfrpn:_GrabTexture,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9063,x:34266,y:33129,varname:node_9063,prsc:2|emission-4152-OUT,alpha-6323-OUT;n:type:ShaderForge.SFN_TexCoord,id:5057,x:32507,y:33789,varname:node_5057,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:3491,x:33082,y:33150,ptovrint:False,ptlb:Main_Tex,ptin:_Main_Tex,varname:node_3491,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-7901-OUT;n:type:ShaderForge.SFN_TexCoord,id:1680,x:32547,y:32965,varname:node_1680,prsc:2,uv:1,uaff:False;n:type:ShaderForge.SFN_Color,id:2947,x:33414,y:32739,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_2947,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:4152,x:33772,y:33149,varname:node_4152,prsc:2|A-2947-RGB,B-3491-RGB;n:type:ShaderForge.SFN_Slider,id:6628,x:32775,y:33986,ptovrint:False,ptlb:Rongjie,ptin:_Rongjie,varname:node_6628,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Step,id:6323,x:33154,y:33836,varname:node_6323,prsc:2|A-1193-OUT,B-6628-OUT;n:type:ShaderForge.SFN_RemapRange,id:354,x:32761,y:33789,varname:node_354,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-5057-UVOUT;n:type:ShaderForge.SFN_Length,id:1193,x:32932,y:33789,varname:node_1193,prsc:2|IN-354-OUT;n:type:ShaderForge.SFN_Multiply,id:8002,x:32679,y:33219,varname:node_8002,prsc:2|A-9379-R,B-1576-OUT;n:type:ShaderForge.SFN_Tex2d,id:9379,x:32393,y:33180,ptovrint:False,ptlb:maks,ptin:_maks,varname:node_9379,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:1576,x:32283,y:33431,ptovrint:False,ptlb:mask_qiangdu,ptin:_mask_qiangdu,varname:node_1576,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Add,id:7901,x:32837,y:33087,varname:node_7901,prsc:2|A-1680-UVOUT,B-8002-OUT;proporder:2947-3491-6628-9379-1576;pass:END;sub:END;*/

Shader "ZShader/Effect/Glass" {
    Properties {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _Main_Tex ("Main_Tex", 2D) = "white" {}
        _Rongjie ("Rongjie", Range(0, 1)) = 1
        _maks ("maks", 2D) = "white" {}
        _mask_qiangdu ("mask_qiangdu", Range(0, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 400
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
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Main_Tex; uniform float4 _Main_Tex_ST;
            uniform float4 _Color;
            uniform float _Rongjie;
            uniform sampler2D _maks; uniform float4 _maks_ST;
            uniform float _mask_qiangdu;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float4 _maks_var = tex2D(_maks,TRANSFORM_TEX(i.uv0, _maks));
                float2 node_7901 = (i.uv1+(_maks_var.r*_mask_qiangdu));
                float4 _Main_Tex_var = tex2D(_Main_Tex,TRANSFORM_TEX(node_7901, _Main_Tex));
                float3 emissive = (_Color.rgb*_Main_Tex_var.rgb);
                float3 finalColor = emissive;
                float node_6323 = step(length((i.uv0*2.0+-1.0)),_Rongjie);
                return fixed4(finalColor,node_6323);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
