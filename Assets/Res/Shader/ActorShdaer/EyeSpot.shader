// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:False,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.3764706,fgcg:0.7921569,fgcb:1,fgca:1,fgde:0.01,fgrn:15,fgrf:80,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33209,y:32712,varname:node_9361,prsc:2|custl-5342-OUT,alpha-9822-OUT;n:type:ShaderForge.SFN_Parallax,id:8743,x:32041,y:32549,varname:node_8743,prsc:2|HEI-9238-OUT;n:type:ShaderForge.SFN_Slider,id:9238,x:31613,y:32588,ptovrint:False,ptlb:Parallax,ptin:_Parallax,varname:node_9238,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-10,cur:0,max:10;n:type:ShaderForge.SFN_Tex2d,id:1840,x:32568,y:32656,ptovrint:False,ptlb:Tex,ptin:_Tex,varname:node_1840,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-8743-UVOUT;n:type:ShaderForge.SFN_Multiply,id:9822,x:32942,y:32973,varname:node_9822,prsc:2|A-1840-A,B-6196-OUT;n:type:ShaderForge.SFN_Tex2d,id:9591,x:32312,y:32973,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:node_9591,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2276-UVOUT;n:type:ShaderForge.SFN_UVTile,id:2276,x:31980,y:32974,varname:node_2276,prsc:2|WDT-3749-OUT,HGT-3749-OUT,TILE-4496-OUT;n:type:ShaderForge.SFN_Time,id:9109,x:31558,y:32945,varname:node_9109,prsc:2;n:type:ShaderForge.SFN_Vector1,id:3749,x:31691,y:32836,varname:node_3749,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:4496,x:31762,y:33100,varname:node_4496,prsc:2|A-9109-T,B-8771-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8771,x:31525,y:33144,ptovrint:False,ptlb:Speed,ptin:_Speed,varname:node_8771,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:7923,x:32523,y:32990,varname:node_7923,prsc:2|A-9591-R,B-8641-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8641,x:32379,y:33224,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:node_8641,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Clamp01,id:6196,x:32711,y:33001,varname:node_6196,prsc:2|IN-7923-OUT;n:type:ShaderForge.SFN_LightColor,id:6778,x:32423,y:32450,varname:node_6778,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5342,x:32914,y:32624,varname:node_5342,prsc:2|A-1199-OUT,B-1840-RGB;n:type:ShaderForge.SFN_RemapRange,id:1199,x:32687,y:32458,varname:node_1199,prsc:2,frmn:0,frmx:1,tomn:0.5,tomx:1|IN-6778-RGB;proporder:9238-1840-9591-8771-8641;pass:END;sub:END;*/

Shader "Shader Forge/EyeSpot" {
    Properties {
        _Parallax ("Parallax", Range(-10, 10)) = 0
        _Tex ("Tex", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Speed ("Speed", Float ) = 1
        _Alpha ("Alpha", Float ) = 0
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
            //#pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float _Parallax;
            uniform sampler2D _Tex; uniform float4 _Tex_ST;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _Speed;
            uniform float _Alpha;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float2 node_8743 = (0.05*(_Parallax - 0.5)*mul(tangentTransform, viewDirection).xy + i.uv0);
                float4 _Tex_var = tex2D(_Tex,TRANSFORM_TEX(node_8743.rg, _Tex));
                float3 finalColor = ((_LightColor0.rgb*0.5+0.5)*_Tex_var.rgb);
                float node_3749 = 1.0;
                float4 node_9109 = _Time;
                float node_4496 = (node_9109.g*_Speed);
                float2 node_2276_tc_rcp = float2(1.0,1.0)/float2( node_3749, node_3749 );
                float node_2276_ty = floor(node_4496 * node_2276_tc_rcp.x);
                float node_2276_tx = node_4496 - node_3749 * node_2276_ty;
                float2 node_2276 = (i.uv0 + float2(node_2276_tx, node_2276_ty)) * node_2276_tc_rcp;
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(node_2276, _Mask));
                return fixed4(finalColor,(_Tex_var.a*saturate((_Mask_var.r+_Alpha))));
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
