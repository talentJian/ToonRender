// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Environment/Unlit-Lightmap、VertexLight-Wind Grass"
{
    Properties
    {
        _MainTex("Base (RGB) Alpha (A)", 2D) = "white" {}
        _lmIndensity("LM Indensity", float) = 1

	    _AlphaTex ("Alpha (R)", 2D) = "white" {}
	    _Cutoff ("Cutoff Value", Range(0,1)) = 0.8

        _SecondaryFactor("Factor for up and fown bending", float) = 2.5
    }

    SubShader
    {
        Tags{ "Queue"="AlphaTest" "IgnoreProjector" = "True" "RenderType"="TransparentCutout" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "TerrainEngine.cginc"
        #pragma multi_compile_fog

        sampler2D _MainTex;
        fixed4 _MainTex_ST;
	    sampler2D _AlphaTex;
	    fixed _Cutoff;
        fixed _SecondaryFactor;
        fixed _lmIndensity;

        struct v2f 
        {
            fixed4 pos : SV_POSITION;
            fixed4 color : COLOR;
            fixed4 vertexLightColor : COLOR1;
            fixed2 uv : TEXCOORD0;

            //#ifndef LIGHTMAP_OFF
            fixed4 lmap : TEXCOORD1;
            //#endif

            //fixed3 spec : TEXCOORD2;
            UNITY_FOG_COORDS(2)
        };

        inline float4 AnimateVertex2(float4 pos, float3 normal, float4 animParams, float SecondaryFactor)
        {
            float fDetailAmp = 0.1f;
            float fBranchAmp = 0.3f;

            float fObjPhase = saturate(dot(unity_ObjectToWorld[3].xyz, 1));

            //half fBranchPhase = fObjPhase;// + animParams.x;
            //half fVtxPhase = saturate(dot(pos.xyz, animParams.y + fBranchPhase));
            float fVtxPhase = saturate(dot(pos.xyz, animParams.y + fObjPhase));

            //half2 vWavesIn = _Time.yy + pos.xz * 0.3 + half2(fVtxPhase, fBranchPhase);
            float2 vWavesIn = _Time + pos.xz * 0.3 + float2(fVtxPhase, fObjPhase);

            float4 vWaves = SmoothTriangleWave(frac(vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193)) * 2.0 - 1.0);
            //vWaves = SmoothTriangleWave(vWaves);
            //vWaves = sin(_Time * vWaves);
            float2 vWavesSum = vWaves.xz + vWaves.yw;

            float3 bend = animParams.y * fDetailAmp * normal.xyz;

            bend.y = animParams.z * fBranchAmp * SecondaryFactor;
            pos.xyz += ((vWavesSum.xyx * bend) + (_Wind.xyz * vWavesSum.y * animParams.w)) * _Wind.w;

            pos.xyz += animParams.w * _Wind.xyz * _Wind.w;

            return pos;
        }

        v2f vert(appdata_full v)
        {
            v2f o;

            UNITY_INITIALIZE_OUTPUT(v2f,o)
            float4 windParams = float4(0, v.color.g, v.color.r, v.color.b);
            float4 mdlPos = AnimateVertex2(v.vertex, v.normal, windParams, _SecondaryFactor);
            o.pos = UnityObjectToClipPos(mdlPos);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

			//#ifndef DYNAMICLIGHTMAP_OFF
            o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            //#endif

            //#ifndef LIGHTMAP_OFF
            o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            //#endif

            o.color.rgba = v.color.rgba;
            UNITY_TRANSFER_FOG(o,o.pos);

            o.vertexLightColor.rgb = ShadeVertexLights(v.vertex, v.normal);
            return o;
        }
        ENDCG

        //沒有LM
        Pass
        {
            Tags{"LightMode" = "Vertex"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 d = tex2D(_AlphaTex, i.uv);

                fixed4 c;
                c.rgb = tex.rgb * i.color.a * _lmIndensity;
                //c.a = tex.a;
                clip (d.r - _Cutoff);

                //#ifndef LIGHTMAP_OFF
                fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap));
                c.rgb *= max(lm * _lmIndensity, i.vertexLightColor);
                //#endif

                c.a = 0.0;

                UNITY_APPLY_FOG(i.fogCoord,c);
                //return c;
                return fixed4(c.r, c.g, c.b, d.r);
            }
            ENDCG
        }
        //PC版LM編碼
        Pass
        {
            Tags{"LightMode" = "VertexLMRGBM"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 d = tex2D(_AlphaTex, i.uv);

                fixed4 c;
                c.rgb = tex.rgb * i.color.a * _lmIndensity;
                //c.a = tex.a;
                clip (d.r - _Cutoff);

                //#ifndef LIGHTMAP_OFF
                fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap));
                c.rgb *= max(lm * _lmIndensity, i.vertexLightColor);
                //#endif

                c.a = 0.0;

                UNITY_APPLY_FOG(i.fogCoord,c);
                //return c;
                return fixed4(c.r, c.g, c.b, d.r);
            }
            ENDCG
        }
        //Mobile版LM編碼
        Pass
        {
            Tags{"LightMode" = "VertexLM"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 d = tex2D(_AlphaTex, i.uv);

                fixed4 c;
                c.rgb = tex.rgb * i.color.a * _lmIndensity;
                //c.a = tex.a;
                clip (d.r - _Cutoff);

                //#ifndef LIGHTMAP_OFF
                fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap));
                c.rgb *= max(lm * _lmIndensity, i.vertexLightColor);
                //#endif

                c.a = 0.0;

                UNITY_APPLY_FOG(i.fogCoord,c);
                //return c;
                return fixed4(c.r, c.g, c.b, d.r);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
}