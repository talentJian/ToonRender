//支持LightMap,GI,顶点光照？Diffuse?
// 暂时支持的效果与 Mobile/Diffuse 一样
Shader "ZShader/Env/Env_SceneObj"
{
	Properties
	{
		_Color("Color",Color) =(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		[Toggle(_USE_Emmision)] _USE_Emmision("_USE_Emmision",Float) = 0
		_Emission("Emission (A)",2D) = "black" {}
		//[HDR]_GIColor("GIColor",Color) = (1,1,1,1)
		GIEmissionStrength("自发光Strength(GI)",Range(0,10))=1
		[Toggle(IS_USE_Fog)] _IS_USE_Fog("使用自带雾效?",Float) = 1

		 [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc("BlendSrc",Float) = 1
		 [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst",Float) = 0
		 [HideInInspector]_ZWrite("ZWrite开关",Float) = 1

		 [HideInInspector]_QueueMode("透明/不透明",Float) = 0
	}
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
			// #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			// #pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile_fog

			#pragma shader_feature _USE_Emmision
			#pragma shader_feature IS_USE_Fog

			//#pragma fragmentoption ARB_precision_hint_fastest 
			#pragma multi_compile_fwdbase TODO:验证为何AB出问题
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"


			#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
			#include "../GlobalColor/BulletTimeFog.cginc"
			//#pragma shader_feature _USE_BULLET_FOG
			
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
				float3 normal :NORMAL;
				
				#if UNITY_SHOULD_SAMPLE_SH
  					half3 sh : TEXCOORD3; // SH
  				#endif
				//float3 vertexLightColor :TEXCOORD3;
				UNITY_FOG_COORDS(7)
				SHADOW_COORDS(8)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
	#if _USE_Emmision
			sampler2D _Emission;
	#endif
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
				TRANSFER_SHADOW(o);


				// SH/ambient and vertex lights
				#ifndef LIGHTMAP_ON
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						o.sh = 0;
						// Approximated illumination from non-important point lights
						#ifdef VERTEXLIGHT_ON
						o.sh += Shade4PointLights (
							unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
							unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
							unity_4LightAtten0, o.worldpos, o.normal);
						#endif
						o.sh = ShadeSHPerVertex (o.normal, o.sh);
					#endif
				#endif // !LIGHTMAP_ON
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 finalCol = col;
				float3 normal = normalize(i.normal);
				
				#if LIGHTMAP_ON
					fixed3 lmcol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
					finalCol.rgb = col * lmcol;
					
				#else
					half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldpos));
					half halfLambert = saturate(dot(normal,lightDir)) *0.5 + 0.5;
					half3 diffuse = _LightColor0.rgb * halfLambert;
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldpos);
					finalCol.rgb = col.rgb *(diffuse.rgb) *atten;
				#endif

				#if UNITY_SHOULD_SAMPLE_SH
					fixed3 shColor = ShadeSHPerPixel(i.normal, i.sh, i.worldpos);
					finalCol.rgb += col * shColor;
    			#endif
				
				finalCol *= _Color;	
				//finalCol = clamp(finalCol,0,1);
				#if _USE_Emmision
				
				fixed4 emission = tex2D(_Emission,i.uv);
				//return fixed4(col.rgb * emission.a,1);
				finalCol.rgb = finalCol.rgb + (col.rgb * emission.a);
				#endif
				
				#if IS_USE_Fog
				UNITY_APPLY_FOG(i.fogCoord, finalCol);
				#endif
				
				return GetFogColor(finalCol,i.worldpos);
			}
			ENDCG
		}
		//方便烘焙的时候灯光预览
		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			ZWrite Off Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma fragmentoption ARB_precision_hint_fastest 
			#pragma multi_compile_fwdadd
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"


			// #pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
			// #include "../GlobalColor/BulletTimeFog.cginc"
			//#pragma shader_feature _USE_BULLET_FOG
			
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
				float3 normal :NORMAL;

				float3 vertexLightColor :TEXCOORD3;
				UNITY_FOG_COORDS(7)
				SHADOW_COORDS(8)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			sampler2D _Emission;
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
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 finalCol = 0;
				i.normal = normalize(i.normal);
				#if LIGHTMAP_ON
					fixed3 lmcol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
					finalCol.rgb = col * lmcol;
				#else
					half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldpos));
					half halfLambert = saturate(dot(i.normal,lightDir)) *0.5 + 0.5;
					half3 diffuse = _LightColor0.rgb * halfLambert;
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldpos);
					finalCol.rgb = col *(diffuse.rgb) * atten;
				#endif

				finalCol *= _Color;		
				UNITY_APPLY_FOG(i.fogCoord, finalCol);		
				//return GetFogColor(finalCol,i.worldpos);
				return finalCol;
			}
			ENDCG
		}
		Pass  
		{  
			Name "Meta"
			Tags {"LightMode" = "Meta"}
			Cull Off

			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta
			#pragma shader_feature _USE_Emmision
			#include "Lighting.cginc"
			#include "UnityMetaPass.cginc"
			float GIEmissionStrength;
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			uniform fixed4 _Color;
			uniform sampler2D _MainTex;
			sampler2D _Emission;
			v2f vert_meta(appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				o.pos = UnityMetaVertexPosition(v.vertex,v.texcoord1.xy,v.texcoord2.xy,unity_LightmapST,unity_DynamicLightmapST);
				o.uv = v.texcoord.xy;
				return o;
			}

			fixed4 frag_meta(v2f IN):SV_Target
			{
				UnityMetaInput metaIN;
				UNITY_INITIALIZE_OUTPUT(UnityMetaInput,metaIN);
				fixed4 col = tex2D(_MainTex,IN.uv);
				metaIN.Albedo = col.rgb * _Color.rgb;
				#if _USE_Emmision
					fixed4 emission = tex2D(_Emission,IN.uv);
					metaIN.Emission = col.rgb * emission.a * GIEmissionStrength;
				#else
					metaIN.Emission = 0;
				#endif
				return UnityMetaFragment(metaIN);
			}

			ENDCG
		}
	}	

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		//LOD 100是用来给实时反射用的,去掉了 受雾的影响
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile_fog

			#pragma shader_feature _USE_Emmision
			
			//#pragma fragmentoption ARB_precision_hint_fastest 
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			//#pragma shader_feature _USE_BULLET_FOG
			
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
				float3 normal :NORMAL;

				float3 vertexLightColor :TEXCOORD3;
				UNITY_FOG_COORDS(7)
				SHADOW_COORDS(8)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			sampler2D _Emission;
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
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
				finalCol *= _Color;		
				#if _USE_Emmision
				fixed4 emission = tex2D(_Emission,i.uv);
				finalCol.rgb += col.rgb * emission.a;
				#endif
				return finalCol;
			}
			ENDCG
		}
	}
	//Fallback "Mobile/Diffuse"
	CustomEditor "Env_SceneShaderGUI"
}
