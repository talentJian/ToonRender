//支持LightMap,GI,顶点光照？Diffuse?
// 暂时支持的效果与 Mobile/Diffuse 一样
Shader "ZShader/Env/Env_SceneObj_CubeMap"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MaskTex("MaskTex (RGB)",2D) = "red"{}

		[HideInInspector]_MaskTex_R("_MaskTex_R",2D) = "white"{}
		[HideInInspector]_MaskTex_G("_MaskTex_G",2D) = "black"{}
		//_Emissive("自发光",Color) = (0,0,0,1)
		[Toggle(_IsUseCubeMap_ON)] _IsUseCubeMap_ON("使用CubeMap",Float) = 0
		//[Toggle(_IsUseBoxProjection_ON)] _IsUseBoxProjection_ON("使用CubeMap_BoxProjection",Float) = 0
		_CubeMap("Cube Map",CUBE) ="black" {}
		_CubeReflTex_scale("_CubeReflTex_scale",Range(0,1)) = 1
		_CubeRoughness("_CubeRoughness",Range(0,2)) = 0
		[Toggle(IS_USE_Fog)] _IS_USE_Fog("使用自带雾效?",Float) = 1

		 [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc("BlendSrc",Float) = 1
		 [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst",Float) = 0
		 [HideInInspector]_ZWrite("ZWrite开关",Float) = 1

		 [HideInInspector]_QueueMode("透明/不透明",Float) = 0
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "Lighting.cginc"
	#include "AutoLight.cginc"
	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float2 uv2 :TEXCOORD1; // lightmapUv
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float2 lightmapUV :TEXCOORD1;
		float4 pos : SV_POSITION;

		float3 worldpos :TEXCOORD2;
		fixed3 normal :NORMAL;

		float3 vertexLightColor :TEXCOORD3;
		UNITY_FOG_COORDS(7)
		SHADOW_COORDS(8)
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	v2f vert (appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		UNITY_TRANSFER_FOG(o,o.pos);

		#if LIGHTMAP_ON
		o.lightmapUV = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
		#endif

		o.normal = UnityObjectToWorldNormal(v.normal);
		o.worldpos = mul(unity_ObjectToWorld,v.vertex);


		o.vertexLightColor = 0;
		#ifdef VERTEXLIGHT_ON
			o.vertexLightColor += Shade4PointLights (
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, o.worldpos, o.normal);
		#endif
		o.vertexLightColor = ShadeSHPerVertex (o.normal, o.vertexLightColor);
		return o;
	}
	ENDCG
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			ZWrite[_ZWrite]
			Blend[_BlendSrc][_BlendDst]
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile_fog

			#pragma shader_feature _IsUseCubeMap_ON
			#pragma shader_feature _IsUseSplitChannel
			#pragma shader_feature IS_USE_Fog
			#pragma fragmentoption ARB_precision_hint_fastest 
			
			#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
			#include "../GlobalColor/BulletTimeFog.cginc"
			//#pragma shader_feature _USE_BULLET_FOG
			
		
			sampler2D _MaskTex;
			#if _IsUseSplitChannel
			sampler2D _MaskTex_R;
			sampler2D _MaskTex_G;
			#endif 
			#if _IsUseCubeMap_ON
			samplerCUBE _CubeMap;
			fixed _CubeReflTex_scale;
			float _CubeRoughness;
			#endif
			fixed4 _Color;
			sampler2D _Emission;
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				fixed4 finalCol = 0;
				finalCol.a = col.a;
				i.normal = normalize(i.normal);

				#ifndef _IsUseSplitChannel
					fixed4 mask = tex2D(_MaskTex,i.uv);
				#else
					fixed4 mask_r = tex2D(_MaskTex_R,i.uv);
					fixed4 mask_g = tex2D(_MaskTex_G,i.uv);
					fixed4 mask = 0;
					mask.r= mask_r.r;
					mask.g = mask_g.g;
				#endif

				#if LIGHTMAP_ON
					fixed3 lmcol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
					finalCol.rgb = col * lmcol;
				#else
					half3 lightDir = UnityWorldSpaceLightDir(i.worldpos);
					half halfLambert = saturate(dot(i.normal,lightDir)) *0.5 + 0.5;
					half3 diffuse = _LightColor0.rgb * halfLambert;
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldpos);
					finalCol.rgb = col *(diffuse.rgb + i.vertexLightColor) * atten;
				#endif
					fixed3 emission = mask.g * col.rgb;

				#if _IsUseCubeMap_ON
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldpos);
					fixed3 worldRefl = reflect(-viewDir,i.normal);
					fixed3 cubeMap =  texCUBElod(_CubeMap,float4(worldRefl,_CubeRoughness)) * _CubeReflTex_scale * mask.r;
					finalCol.rgb += cubeMap + emission;
				#else
			 		finalCol.rgb += emission;
				#endif
				
				#if IS_USE_Fog
				UNITY_APPLY_FOG(i.fogCoord, finalCol);
				#endif
				return GetFogColor(finalCol,i.worldpos);
			}
			ENDCG
		}
	}	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		//LOD 100是用来给实时反射用的,去掉了 受雾的影响,以及CubeMap,Mask图的读取
		LOD 100
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile _ VERTEXLIGHT_ON

			#pragma fragmentoption ARB_precision_hint_fastest 
			
			#include "../GlobalColor/BulletTimeFog.cginc"
			#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
			sampler2D _MaskTex;
			sampler2D _MaskTex_R;
			sampler2D _MaskTex_G;
			samplerCUBE _CubeMap;
			float _CubeRoughness;
			fixed _CubeReflTex_scale;
			fixed4 _Color;
			sampler2D _Emission;
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				fixed4 finalCol = 0;
				i.normal = normalize(i.normal);

				#if LIGHTMAP_ON
					fixed3 lmcol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
					finalCol.rgb = col * lmcol;
				#else
					half3 lightDir = UnityWorldSpaceLightDir(i.worldpos);
					half halfLambert = saturate(dot(i.normal,lightDir)) *0.5 + 0.5;
					half3 diffuse = _LightColor0.rgb * halfLambert;
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldpos);
					finalCol.rgb = col *(diffuse.rgb + i.vertexLightColor) * atten;
				#endif
				return finalCol;
			}
			ENDCG
		}
	}	

	Fallback "Mobile/Diffuse"
	CustomEditor "Env_SceneShaderGUI"
}
