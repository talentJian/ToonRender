// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:2,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:7952,x:33186,y:33187,varname:node_7952,prsc:2|emission-7528-OUT,alpha-2260-R;n:type:ShaderForge.SFN_Tex2d,id:2260,x:31877,y:33313,ptovrint:False,ptlb:MainMask,ptin:_MainMask,varname:node_2260,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:83a844108ca51c645aab07b81b04e992,ntxv:0,isnm:False|UVIN-841-OUT;n:type:ShaderForge.SFN_Tex2d,id:2980,x:31064,y:33113,ptovrint:False,ptlb:Tex_01,ptin:_Tex_01,varname:node_2980,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:51167cfd0a279614d89716a8fe1f4a42,ntxv:0,isnm:False|UVIN-6488-UVOUT;n:type:ShaderForge.SFN_Panner,id:6488,x:30906,y:33068,varname:node_6488,prsc:2,spu:0,spv:1|UVIN-195-OUT,DIST-7661-OUT;n:type:ShaderForge.SFN_TexCoord,id:2216,x:30329,y:33055,varname:node_2216,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:2829,x:30978,y:33452,ptovrint:False,ptlb:Tex_02,ptin:_Tex_02,varname:node_2829,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:f781c1490a9c1a147be5d51c26cd6b93,ntxv:0,isnm:False|UVIN-8500-UVOUT;n:type:ShaderForge.SFN_Panner,id:8500,x:30703,y:33670,varname:node_8500,prsc:2,spu:0,spv:1|UVIN-692-UVOUT,DIST-3810-OUT;n:type:ShaderForge.SFN_TexCoord,id:692,x:30409,y:33619,varname:node_692,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:620,x:31290,y:33397,varname:node_620,prsc:2|A-2980-R,B-2829-R;n:type:ShaderForge.SFN_Add,id:841,x:31642,y:33301,varname:node_841,prsc:2|A-8018-UVOUT,B-620-OUT;n:type:ShaderForge.SFN_TexCoord,id:8018,x:31340,y:33124,varname:node_8018,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:7528,x:32639,y:33058,varname:node_7528,prsc:2|A-7014-OUT,B-3882-RGB;n:type:ShaderForge.SFN_Color,id:3882,x:32328,y:33084,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_3882,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Multiply,id:195,x:30676,y:32992,varname:node_195,prsc:2|A-2303-OUT,B-2216-UVOUT;n:type:ShaderForge.SFN_Vector2,id:2303,x:30329,y:32932,varname:node_2303,prsc:2,v1:2,v2:1;n:type:ShaderForge.SFN_OneMinus,id:7014,x:32308,y:32921,varname:node_7014,prsc:2|IN-2260-R;n:type:ShaderForge.SFN_Time,id:3268,x:30411,y:33227,varname:node_3268,prsc:2;n:type:ShaderForge.SFN_Multiply,id:7661,x:30680,y:33282,varname:node_7661,prsc:2|A-3268-T,B-7768-OUT;n:type:ShaderForge.SFN_Slider,id:7768,x:30227,y:33512,ptovrint:False,ptlb:node_7768,ptin:_node_7768,varname:node_7768,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:6803,x:30070,y:34081,ptovrint:False,ptlb:node_7768_copy,ptin:_node_7768_copy,varname:_node_7768_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:4669,x:30254,y:33796,varname:node_4669,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3810,x:30476,y:33857,varname:node_3810,prsc:2|A-4669-T,B-6803-OUT;n:type:ShaderForge.SFN_Slider,id:6128,x:30639,y:33701,ptovrint:False,ptlb:node_7768_copy_copy,ptin:_node_7768_copy_copy,varname:_node_7768_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:8030,x:30823,y:33416,varname:node_8030,prsc:2;n:type:ShaderForge.SFN_Multiply,id:1140,x:31045,y:33477,varname:node_1140,prsc:2|A-8030-T,B-6128-OUT;n:type:ShaderForge.SFN_Slider,id:88,x:30681,y:33715,ptovrint:False,ptlb:node_7768_copy_copy_copy,ptin:_node_7768_copy_copy_copy,varname:_node_7768_copy_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:4309,x:30865,y:33430,varname:node_4309,prsc:2;n:type:ShaderForge.SFN_Multiply,id:649,x:31087,y:33491,varname:node_649,prsc:2|A-4309-T,B-88-OUT;n:type:ShaderForge.SFN_Slider,id:5663,x:30703,y:33765,ptovrint:False,ptlb:node_7768_copy_copy_copy_copy,ptin:_node_7768_copy_copy_copy_copy,varname:_node_7768_copy_copy_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:1119,x:30887,y:33480,varname:node_1119,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6721,x:31109,y:33541,varname:node_6721,prsc:2|A-1119-T,B-5663-OUT;n:type:ShaderForge.SFN_Slider,id:1366,x:30745,y:33779,ptovrint:False,ptlb:node_7768_copy_copy_copy_copy,ptin:_node_7768_copy_copy_copy_copy,varname:_node_7768_copy_copy_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:4220,x:30929,y:33494,varname:node_4220,prsc:2;n:type:ShaderForge.SFN_Multiply,id:1017,x:31151,y:33555,varname:node_1017,prsc:2|A-4220-T,B-1366-OUT;n:type:ShaderForge.SFN_Slider,id:9639,x:30569,y:33882,ptovrint:False,ptlb:node_7768_copy_copy_copy_copy,ptin:_node_7768_copy_copy_copy_copy,varname:_node_7768_copy_copy_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:6353,x:30753,y:33597,varname:node_6353,prsc:2;n:type:ShaderForge.SFN_Multiply,id:7004,x:30975,y:33658,varname:node_7004,prsc:2|A-6353-T,B-9639-OUT;n:type:ShaderForge.SFN_Slider,id:8199,x:30611,y:33896,ptovrint:False,ptlb:node_7768_copy_copy_copy_copy_copy,ptin:_node_7768_copy_copy_copy_copy_copy,varname:_node_7768_copy_copy_copy_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Time,id:6600,x:30795,y:33611,varname:node_6600,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4605,x:31017,y:33672,varname:node_4605,prsc:2|A-6600-T,B-8199-OUT;proporder:2260-2980-2829-3882-7768-6803;pass:END;sub:END;*/

Shader "ZShader/Effect/Dissolve_01(SF)" {
    Properties {
        _MainMask ("MainMask", 2D) = "white" {}
        _Tex_01 ("Tex_01", 2D) = "white" {}
        _Tex_02 ("Tex_02", 2D) = "white" {}
        [HDR]_MainColor ("MainColor", Color) = (0,0,0,1)
        _node_7768 ("node_7768", Range(0, 1)) = 0
        _node_7768_copy ("node_7768_copy", Range(0, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform sampler2D _MainMask; uniform float4 _MainMask_ST;
            uniform sampler2D _Tex_01; uniform float4 _Tex_01_ST;
            uniform sampler2D _Tex_02; uniform float4 _Tex_02_ST;
            uniform float4 _MainColor;
            uniform float _node_7768;
            uniform float _node_7768_copy;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_3268 = _Time;
                float2 node_6488 = ((float2(2,1)*i.uv0)+(node_3268.g*_node_7768)*float2(0,1));
                float4 _Tex_01_var = tex2D(_Tex_01,TRANSFORM_TEX(node_6488, _Tex_01));
                float4 node_4669 = _Time;
                float2 node_8500 = (i.uv0+(node_4669.g*_node_7768_copy)*float2(0,1));
                float4 _Tex_02_var = tex2D(_Tex_02,TRANSFORM_TEX(node_8500, _Tex_02));
                float2 node_841 = (i.uv0+(_Tex_01_var.r*_Tex_02_var.r));
                float4 _MainMask_var = tex2D(_MainMask,TRANSFORM_TEX(node_841, _MainMask));
                float3 emissive = ((1.0 - _MainMask_var.r)*_MainColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,_MainMask_var.r);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
