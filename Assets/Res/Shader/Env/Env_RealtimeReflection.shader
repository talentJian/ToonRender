
///
//MainTex A 通道用作实时反射Mask
Shader "ZShader/Env/Env_RealtimeReflection" {
	Properties{
	_MainTex("Base (RGB)", 2D) = "white" {}
	_MaskTex("实时反射 遮罩",2D) = "white" {}
	_NormalTex("扰动图",2D) = "bump"{}
	_Disortion("骚动参数",Range(0,1)) = 0.1
	_ReflectionTex("Internal reflection(不要設置)", 2D) = "black" {}
	_ReflectionTex_scale("光滑度",Range(0,1)) = 0.5
	[HideInInspector]_ScrollSpeed("波动参数",Vector) = (0,0,0,0)
	[HideInInspector]_TexTiled("TexTiled",Vector) = (2,2,1,1)
	//_WaterTex("水波贴图",2D) = "black"{}
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "../GlobalColor/BulletTimeFog.cginc"
	#pragma shader_feature IsUseWaterFlow
	sampler2D _MainTex;
	sampler2D _MaskTex;
	sampler2D _ReflectionTex;
	sampler2D _NormalTex;
	half _ReflectionTex_scale;
	fixed _Disortion;

	struct v2f {
		half4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
		half4 scr : TEXCOORD1;
		#ifdef LIGHTMAP_ON
		half2 uvLM : TEXCOORD3;
		#endif
	};

	struct v2f_full {
		half4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
		half4 normaluv : TEXCOORD2; // 扰动图使用的Uv
		half4 scr : TEXCOORD1;
		#ifdef LIGHTMAP_ON
		half2 uvLM : TEXCOORD3;
		#endif
		
		half4 worldpos : TEXCOORD4;
		//half2 fakeRefl :TEXCOORD5;
		UNITY_FOG_COORDS(7)
	};

	ENDCG

		
		SubShader{
		LOD 400

		Tags{ "RenderType" = "Opaque" }
		Fog{ Mode Off }

		Pass
		{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma multi_compile_fog
		#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
		half4 _MainTex_ST;
		half4 _NormalTex_ST;
		half4 _WaterTex_ST;
		fixed4 _ScrollSpeed;
		fixed4 _TexTiled;
		sampler2D _WaterTex;
		v2f_full vert(appdata_full v)
		{
			v2f_full o;
			
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
			#ifdef IsUseWaterFlow
			o.normaluv.xyzw = TRANSFORM_TEX(v.texcoord.xy, _NormalTex).xyxy * _TexTiled;
			o.normaluv +=  _ScrollSpeed * _Time.x;
			#else
			o.normaluv.xy =TRANSFORM_TEX(v.texcoord.xy, _NormalTex).xy;
			#endif
		#ifdef LIGHTMAP_ON
			o.uvLM = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
		#endif

			o.scr = ComputeScreenPos(o.pos);
			o.worldpos = mul(unity_ObjectToWorld,v.vertex);
			//o.fakeRefl =  ((-_WorldSpaceCameraPos * 0.6 + o.worldpos) * 0.07).xz * _WaterTex_ST.xy + _ScrollSpeed * _Time.x;

		
			UNITY_TRANSFER_FOG(o,o.pos);
			return o;
		}


		half4 frag(v2f_full i) : COLOR
		{
			//使用扰动图 进行扰动
			#if IsUseWaterFlow
				
				fixed2 bump1 = tex2D(_NormalTex,i.normaluv.xy).xy * 2 ;
				//fixed2 bump1 = Luminance(tex2D(_NormalTex,i.normaluv.xy));
				fixed2 bump2 = tex2D(_NormalTex,i.normaluv.zw).xy * 2 ;
				//fixed2 bump2 = Luminance(tex2D(_NormalTex,i.normaluv.xy));
				fixed2 bump = ((bump1+bump2-0.6))*0.5 * _Disortion;
				
			#else
				fixed2 bump = tex2D(_NormalTex,i.normaluv).xy * 2 -1;
			#endif
			
			half4 color = tex2D(_MainTex, i.uv);
			half mask = tex2D(_MaskTex,i.uv).r;
			
			half2 screen = (i.scr / i.scr.w) + bump.xy * 0.1;
		#ifdef LIGHTMAP_ON
			fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM.xy));
			color.rgb *= lm;	
		#endif

			fixed4 reflectionCol = tex2D(_ReflectionTex,screen) * mask;
			fixed4 finalColor = lerp(color,reflectionCol,_ReflectionTex_scale);
			UNITY_APPLY_FOG(i.fogCoord, finalColor);
			return GetFogColor(finalColor,i.worldpos);
			//return finalColor;
		}

		ENDCG

		}

		//烘焙GI使用的
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

			struct v2f_meta
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _Emission;
			v2f_meta vert_meta(appdata_full v)
			{
				v2f_meta o;
				UNITY_INITIALIZE_OUTPUT(v2f_meta,o);
				o.pos = UnityMetaVertexPosition(v.vertex,v.texcoord1.xy,v.texcoord2.xy,unity_LightmapST,unity_DynamicLightmapST);
				o.uv = v.texcoord.xy;
				return o;
			}

			fixed4 frag_meta(v2f_meta IN):SV_Target
			{
				UnityMetaInput metaIN;
				UNITY_INITIALIZE_OUTPUT(UnityMetaInput,metaIN);
				fixed4 col = tex2D(_MainTex,IN.uv);
				metaIN.Albedo = col.rgb;
				metaIN.Emission = 0;
				return UnityMetaFragment(metaIN);
			}

			ENDCG
		}
	} 

	SubShader
	{
		LOD 200

		Tags{ "RenderType" = "Opaque" }
		Fog{ Mode Off }

		Pass{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma multi_compile_fog
		#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
		uniform half4 _MainTex_ST;

		v2f_full vert(appdata_full v)
		{
			v2f_full o;
			
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			#ifdef LIGHTMAP_ON
				o.uvLM = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
			#endif
			o.scr = ComputeScreenPos(o.pos);
			o.worldpos = mul(unity_ObjectToWorld,v.vertex);
			UNITY_TRANSFER_FOG(o,o.pos);
			return o;
		}

		fixed4 frag(v2f_full i) : COLOR
		{
			fixed4 color = tex2D(_MainTex, i.uv);
			#ifdef LIGHTMAP_ON
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM));
				color.rgb *= lm;
			#endif
			UNITY_APPLY_FOG(i.fogCoord, color); 
			return GetFogColor(color,i.worldpos);
			//return color;
		}
		ENDCG

		}	
	}

		//FallBack ""
	CustomEditor "Env_RefleEmission_ShaderGUI"
}
