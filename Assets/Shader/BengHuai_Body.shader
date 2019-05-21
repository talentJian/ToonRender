Shader "ZShader/NPR/BengHuai_Body"
{
	Properties
	{
		_MainTex ("Main Color", 2D) = "white" {}
		_BloomMaskTex("BloomMask",2D) = "white"{}
		_LightMapTex("LightMap",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1)
		
		_FirstShadowMultColor("FirstShadowMultColor",Color) =(0.7,0.6,0.65,1)
		_SecondShadowMultColor("SecondShadowMultColor",Color) = (0.65,0.45,0.54,1)
		_Shiniess("Shininess",Float) = 0.5
		_SpecMulti("SpecMulti",Float) = 0.2
		_Emission("_Emssion",Color) = (0,0,0,0)
		_LightArea("_LightArea",Float) = 0.5
		_SecondShadow("SecondShadow",Float) = 0.5

		_OutlineColor("_Outline Color",Color) = (1,1,1,1)
		_Outline("Outline",Range(0,1)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
		
		LOD 100
		Tags { "RenderType"="Opaque" }
		//UsePass "Learn/Outline/OUTLINE"
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 vertexColor : Color; // 顶点颜色
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 vertexColor : Color;
				float3 worldNormal : TEXCOORD2;
				float4 worldPos :TEXCOORD3;
				float4 screenPos : TEXCOORD4;
			};

			sampler2D _MainTex,_LightMapTex,_BloomMaskTex;
			float4 _MainTex_ST,_BloomMaskTex_ST;
			float _Shiniess,_Emission,_LightArea,_SecondShadow;
			float4 _Color,_FirstShadowMultColor,_SecondShadowMultColor;
			v2f vert (appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.vertexColor = v.vertexColor;
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return i.worldPos;
				// sample the texture
				fixed4 mainTexColor = tex2D(_MainTex, i.uv);
				fixed4 lightMapColor = tex2D(_LightMapTex,i.uv);

				float3 worldNormal = normalize(i.worldNormal);
				float3 lightDir = UnityWorldSpaceLightDir(i.worldPos.xyz);
				//halfLambert 
				float halfLambert = saturate(dot(worldNormal,lightDir)) * 0.5 + 0.5;

				float3 firstShadowColor = mainTexColor.xyz * _FirstShadowMultColor;
				float3 secondShadowColor = mainTexColor.xyz * _SecondShadowMultColor;
				
				//这里拿出来的模型顶点色不对
				float4 vertexColor = 1;
				
				float firstMask = (vertexColor.x * lightMapColor.y + halfLambert ) *0.5;
				//return firstMask;
				float3 finalFirstShadow = (firstMask >= _LightArea) ? mainTexColor.xyz : firstShadowColor;
				
				float secondMask = (vertexColor.x * lightMapColor.y +halfLambert ) * 0.5;
				float3 finalSecondShadow = (secondMask >= (2 * _SecondShadow - 1)) ? firstShadowColor : secondShadowColor;

				float3 finalDiffuseColor = (vertexColor.x * lightMapColor.y) >= 0.0909999967 ? finalFirstShadow:finalSecondShadow;
				//return lightMapColor.y;
				return fixed4(finalDiffuseColor,1);
			}
			ENDCG
		}
	}
}
