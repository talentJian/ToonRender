//带摇动
//可以接受LightMap
//
Shader "ZShader/Env/Env_LightMap_Wind"
{
	Properties
	{
		_Color("Main Color",Color) = (1,1,1,1)
		_Emission("Emissive Color",Color) = (0,0,0,0)
		_MainTex ("Texture", 2D) = "white" {}
		_Cutoff("Alpha cutoff",Range(0,1))= 0.5
		[Toggle(_IS_ANIM_ON)]_IS_ANIM_ON("随风而动~",Float) = 0
		[Toggle(_IS_USE_Fog)] _IS_USE_Fog("使用自带雾效?",Float) = 0
		[Enum(On,2,Off,0)]_CullMode("背面剔除",Float) = 2
		_NormalDir("Dir方向(针对面皮)",Vector) = (1,0,0)
		_DetailFactor("细节动 幅度",Float) = 1
		_SecondaryFactor("上下动（树干）", Float) = 0.2
		_Frequent("频率",Range(0,2)) = 0.5
	}
	SubShader
	{
		LOD 100
		//"DisableBatching" = "True"
		Tags { "Queue" = "AlphaTest" "IgnoreProjector"="true" "RenderType"="Transparent"  }
		Pass
		{
			Cull [_CullMode]
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT
		

			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"
			#include "../../GlobalColor/BulletTimeFog.cginc"
			#pragma #pragma multi_compile_fog
			#pragma shader_feature _IS_ANIM_ON
			#pragma shader_feature _IS_USE_Fog

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float3 normal:NORMAL;
				fixed4 color : COLOR0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float2 lmuv : TEXCOORD1;
				float3 vertexColor : TEXCOORD2;
				float3 worldPos :TEXCOORD3;

				UNITY_FOG_COORDS(4)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;
			fixed _DetailFactor;
			fixed _SecondaryFactor;
			fixed _Frequent;
			fixed4 _Emission;
			fixed4 _Color;
			fixed3 _NormalDir;

			inline float3 AnimateVertex2(float3 pos, float3 normal, float4 animParams, float SecondaryFactor)
			{
				float fDetailAmp = 0.1f * _DetailFactor;
				float fBranchAmp = 0.3f * SecondaryFactor;

				 float fObjPhase = dot(unity_ObjectToWorld._14_24_34, 1);
				
				//half fBranchPhase = fObjPhase;// + animParams.x;
				//half fVtxPhase = saturate(dot(pos.xyz, animParams.y + fBranchPhase));
				float fVtxPhase = saturate(dot(pos.xyz, animParams.y + fObjPhase));
				float2 vWavesIn = _Time *_Frequent + float2(fVtxPhase, fObjPhase);
				//float2 vWavesIn = _Time ;
				float4 vWaves = SmoothTriangleWave(frac(vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193)) * 2.0 - 1.0);
				float2 vWavesSum = vWaves.xz + vWaves.yw;

   				// Edge (xz) and branch bending (y)
				float3 bend = animParams.y * fDetailAmp * normalize(_NormalDir);
				bend.y = animParams.z * fBranchAmp ;
				pos.xyz += ((vWavesSum.xyx * bend) + (_Wind.xyz * vWavesSum.y * animParams.w)) * _Wind.w;

				pos.xyz += animParams.w * _Wind.xyz * _Wind.w;

				return pos;
			}

			
			v2f vert (appdata v)
			{
				v2f o;
				float4 animParams = float4(0,v.color.r,v.color.g,v.color.b);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				#if _IS_ANIM_ON
					float4 mdlPos =fixed4(AnimateVertex2(v.vertex,v.normal,animParams,_SecondaryFactor),v.vertex.w);
					o.pos = UnityObjectToClipPos(mdlPos);
				#else
					o.pos = UnityObjectToClipPos(v.vertex);
				#endif
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				#ifdef LIGHTMAP_ON
					o.lmuv = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				
				//o.vertexColor = ShadeVertexLights(v.vertex,v.normal);
				o.vertexColor = v.color;
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//return fixed4(i.vertexColor,1);
				fixed4 col = tex2D(_MainTex, i.uv);
				if (col.a <= _Cutoff) discard;
				//clip(col.a  - _Cutoff);

				fixed4 finalCol = fixed4(col.rgb +(_Emission * _Color),1);
				#ifdef LIGHTMAP_ON
					fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.lmuv));
					finalCol.rgb *= lm;
				#else
					//finalCol += i.vertexColor;
				#endif
				
				#ifdef _IS_USE_Fog
					UNITY_APPLY_FOG(i.fogCoord, finalCol);
				#endif
				finalCol.a = col.a;
				return GetFogColor(finalCol,i.worldPos);
			}
			ENDCG
		}
	}
}
