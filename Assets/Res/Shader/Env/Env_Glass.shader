Shader "ZShader/Env/Env_Glass"
{
	Properties
	{
		_Color("Color",Color) =(1,1,1,1)
		_Alpha("alpha",Range(0,1)) = 0.5
		_MainTex ("Texture", 2D) = "white" {}
		//_CubeMap("CubeMap",CUBE) = "white" {}
		_Shinness("高光",Float) = 0.5
		_SpecularStrength("高光强度强度",Range(0,5)) = 1
		_SpecularColor("高光颜色",Color) =(1,1,1)
		_FrenelPow("边缘光 （边缘宽度）",Range(0.1,20)) = 5
		_FrenelScale("边缘光强度",Range(0,1)) = 0.5
		_FrenelColor("边缘光颜色",Color) = (1,1,1)
		_LightDir("灯光方向",Vector) = (0.2,0.70,-0.20,1)
		[Enum(On,1,Off,0)]_Cull("背面剔除",Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"= "Transparent" "LightMode" = "ForwardBase"}
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull [_Cull]
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 viewDir :TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
				float3 worldPos :TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			samplerCUBE _CubeMap;
			fixed _Alpha;
			fixed _Shinness;
			fixed _FrenelScale;
			fixed _SpecularStrength;
			fixed _SpecularColor;
			fixed3 _FrenelColor;
			fixed3 _LightDir;
			fixed3 _Color;
			fixed _FrenelPow;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				i.worldNormal = normalize(i.worldNormal);
				//fixed3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				//fixed3 lightDir = fixed3(0.2,0.70,-0.20);
				fixed3 lightDir = _LightDir;
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = pow(max(0,dot(i.worldNormal,halfDir)),_Shinness)  * _SpecularStrength * _SpecularColor;
				//fixed4 diffuse = (dot(i.worldNormal,lightDir) * 0.5 + 0.5)  ;
				fixed frenel = _FrenelScale * pow(1-abs(dot(viewDir,i.worldNormal)),_FrenelPow);
				//fixed3 worldRef1 = reflect(-viewDir,i.worldNormal);
				return fixed4(col.rgb+ specular,col.a * _Alpha)   +  fixed4( _FrenelColor,1)* frenel;
			}
			ENDCG
		}
	}
}
