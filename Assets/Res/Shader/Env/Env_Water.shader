Shader "ZShader/Env/Env_Water"
{
	Properties
	{
		//_WaterColor("Color",Color) = (1,1,1)
		_DisortionMap("扰动图",2D) = "white"{}
		_Caustic("海水图",2D) = "white"{}
		_BumpScale0("Bump图放大0",Float) = 1
		_BumpVeclocity0("Bump速度0",Vector) = (-0.2,0.15,1,1)
		_BumpScale1("Bump图放大1",Float) = 0.5
		_BumpVeclocity1("Bump图速度1",Vector) = (0.5,0.15,1,1)
		
		_CausticScale("CauticScale",Float) = 5
		_CausticVelocity("海水流动速度",Vector) =(0,0,1,1)
		
		_Distortion("_Distortion",Range(0,1)) = 0.12

		_RefColor("反射颜色",Color) = (0.5,0.5,0.5,1)
		_RefractionColor("折射颜色",Color) = (1,0,0,1)
		//_FrenelScale("菲涅尔Scale",Range(0,1)) = 0.1
		_FrenelFactor("_FrenelFactor",Vector) = (8,1,0.6,1)
		[HideInInspector]_ReflectionTex("反射图",2D) = "white"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 400

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD2;
				//float3 viewDir :TEXCOORD3;

				float2 uv1:TEXCOORD4;
				float2 uv2:TEXCOORD5;
				float2 uv3:TEXCOORD6;

				//float3 worldPos :TEXCOORD7;
				float frenel : TEXCOORD8; //X 是 菲涅尔 Power 的主要参数
			};

			sampler2D _DisortionMap,_Caustic;
			float4 _DisortionMap_ST;
			sampler2D _ReflectionTex;//反射图
			fixed _BumpScale0,_BumpScale1;
			fixed2 _BumpVeclocity0,_BumpVeclocity1;

			fixed _CausticScale;
			fixed2 _CausticVelocity;
			fixed _Distortion;
			//fixed4 _WaterColor;
			fixed4 _RefColor,_RefractionColor;
			//fixed _FrenelScale;
			fixed3 _FrenelFactor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				//o.viewDir = mul(unity_WorldToObject,_WorldSpaceCameraPos);
				o.uv = TRANSFORM_TEX(v.uv, _DisortionMap);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.screenPos = ComputeNonStereoScreenPos(o.vertex);
				o.frenel = pow(1-normalize(ObjSpaceViewDir(v.vertex)).y,_FrenelFactor.x) * _FrenelFactor.y + _FrenelFactor.z;
				o.uv1 = v.uv * _BumpScale0 + _BumpVeclocity0.xy * _Time.x;
				o.uv2 = v.uv * _BumpScale1 + _BumpVeclocity1.xy * _Time.x;
				o.uv3 = v.uv * _CausticScale + _CausticVelocity.xy *  _Time.x;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 bump1 = tex2D(_DisortionMap,i.uv1).xy;
				fixed2 bump2 = tex2D(_DisortionMap,i.uv2).xy;
				fixed2 bump = ((bump1 + bump2) -0.6) * _Distortion * 0.5;
				i.uv3 -= bump * 5;
				// sample the texture
				fixed4 _CausticCol = tex2D(_Caustic, i.uv3);
				float2 uv_refle  = i.screenPos.xy / i.screenPos.w;
				uv_refle.xy -= bump ;
				fixed4 reflectionCol = tex2D(_ReflectionTex,uv_refle);
				//return reflectionCol;
				i.frenel = clamp(i.frenel,0,1);
				fixed4 frenelCol = i.frenel * reflectionCol *_RefColor + (1-i.frenel) * _RefractionColor;
				return (frenelCol + _CausticCol) ;
			}
			ENDCG
		}
	}

	//降低质量，去除实时反射
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD2;
				//float3 viewDir :TEXCOORD3;

				float2 uv1:TEXCOORD4;
				float2 uv2:TEXCOORD5;
				float2 uv3:TEXCOORD6;

				//float3 worldPos :TEXCOORD7;
				float frenel : TEXCOORD8;
			};

			sampler2D _DisortionMap,_Caustic;
			float4 _DisortionMap_ST;
			//sampler2D _ReflectionTex;//反射图
			fixed _BumpScale0,_BumpScale1;
			fixed2 _BumpVeclocity0,_BumpVeclocity1;

			fixed _CausticScale;
			fixed2 _CausticVelocity;
			fixed _Distortion;
			//fixed4 _WaterColor;
			fixed4 _RefColor,_RefractionColor;
			//fixed _FrenelScale;
			fixed3 _FrenelFactor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				//o.viewDir = mul(unity_WorldToObject,_WorldSpaceCameraPos);
				o.uv = TRANSFORM_TEX(v.uv, _DisortionMap);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.screenPos = ComputeNonStereoScreenPos(o.vertex);
				o.frenel = pow(1-normalize(ObjSpaceViewDir(v.vertex)).y,_FrenelFactor.x) * _FrenelFactor.y + _FrenelFactor.z;
				o.uv1 = v.uv * _BumpScale0 + _BumpVeclocity0.xy * _Time.x;
				o.uv2 = v.uv * _BumpScale1 + _BumpVeclocity1.xy * _Time.x;
				o.uv3 = v.uv * _CausticScale + _CausticVelocity.xy *  _Time.x;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 bump1 = tex2D(_DisortionMap,i.uv1).xy;
				fixed2 bump2 = tex2D(_DisortionMap,i.uv2).xy;
				fixed2 bump = ((bump1 + bump2) -0.6) * _Distortion * 0.5;
				i.uv3 -= bump * 5;
				// sample the texture
				fixed4 _CausticCol = tex2D(_Caustic, i.uv3);
				float2 uv_refle  = i.screenPos.xy / i.screenPos.w;
				uv_refle.xy -= bump ;
				fixed4 reflectionCol = 0;
				i.frenel = clamp(i.frenel,0,1);
				fixed4 frenelCol = i.frenel * reflectionCol *_RefColor + (1-i.frenel) * _RefractionColor;
				return (frenelCol + _CausticCol) ;
			}
			ENDCG
		}
	}
}
