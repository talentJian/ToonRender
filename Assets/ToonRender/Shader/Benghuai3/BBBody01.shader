﻿///崩坏3 最简单的身体Shader
Shader "ZShader/Toon/BBBody01"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LightMapTex("_LightMapTex",2D) = "black"{}
		_LightArea("LightArea",Float) = 0.5
		_SecondShadow("_SecondShadow",Float) = 0.5
		_ShadowWidthSmooth("阴影平滑度",Range(0,0.2))=0

		_FirstShadowMultColor("第一层阴影叠加色",Color) =(0.72,0.6,0.65)
		_SecondShadowMultColor("第二层阴影叠加色",Color) =(0.5,0.5,0.5)
		_Shininess("高光系数",Float) = 10
		_SpecMulti("高光强度",Float) = 0.2
		_LightSpecColor("高光颜色",Color ) =(1,1,1)

		//OutLine部分使用
		_Outline_Width ("Outline_Width", Float ) = 1
        _MaxOutLine ("_MaxOutLine", Range(0,10) ) = 1
        _Outline_Color ("Outline_Color", Color) = (0.5,0.5,0.5,1)
		[Toggle(_isOutlineMulMainCol)]_isOutlineMulMainCol("颜色叠贴图",Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			Name "OUTLNIE"
			//Offset 20 , 1
			//Blend [_SrcBlend][_DstBlend]
			Cull Front
			CGPROGRAM
			#pragma shader_feature _isOutlineMulMainCol
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "ToonOutLineSE.cginc"
			
			#pragma vertex toonOutline_vert
			#pragma fragment toonOutline_frag
			ENDCG
		}
		Pass
		{
			Tags{
				"LightMode" = "FORWARDBASE"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
				float4 color :COLOR0;	
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float halfLambert :TEXCOORD1; //半兰伯特光照
				float4 vertexColor :TEXCOORD2; //顶点颜色
				float3 worldNormal :TEXCOORD3; //世界发现 
				float4 worldPos :TEXCOORD4; //世界坐标
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightMapTex;
			float _LightArea,_SecondShadow;
			float3 _FirstShadowMultColor,_SecondShadowMultColor;
			float _Shininess,_SpecMulti;
			float3 _LightSpecColor;
			float _ShadowWidthSmooth;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex); 
				
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);//世界坐标
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//世界法线
				o.vertexColor = v.color;//传递定定点颜色
				float3 lightDir = UnityWorldSpaceLightDir(o.worldPos);
				o.halfLambert = dot(o.worldNormal,lightDir) * 0.5 + 0.5;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 lightmap = tex2D(_LightMapTex,i.uv);
				float3 worldNormal = i.worldNormal;
				//return lightmap.g;
				float3 lightDir = UnityWorldSpaceLightDir(i.worldPos);				
				//float halfLambert = i.halfLambert;
				float halfLambert = dot(worldNormal,lightDir) * 0.5 + 0.5;

				
				float3 LightDir = UnityWorldSpaceLightDir(i.worldPos);
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 halfDir =  normalize(LightDir + viewDir);
				float NDotH = dot(worldNormal,halfDir);

				// float mask01 = lightmap.g * i.vertexColor.r;
				
				float3 firstCol = lerp(col.rgb * _FirstShadowMultColor ,col.rgb,1-i.vertexColor.b);
				float3 secondCol = lerp(col.rgb * _SecondShadowMultColor ,col.rgb,1-i.vertexColor.b);
				// float3 secondCol = col.rgb * _SecondShadowMultColor ;

				float3 diffuse = 0;
				//float diffuseMask = ceil((lightmap.g * i.vertexColor.r) * 10)/10; // 去掉更地位的小数，减少噪点
				fixed diffuseMask = lightmap.g * i.vertexColor.r;
				//不是特别暗的地方
				if(diffuseMask > 0.1)
				{
					float firstmask = diffuseMask > 0.5? diffuseMask *1.2 - 0.1 : diffuseMask * 1.25-0.125;
					
					// fixed diffuseStep =  smoothstep(0,_ShadowWidthSmooth,saturate(diffuseMask  - _LightArea));
					
					bool isLight = (firstmask + halfLambert) * 0.5 > _LightArea;
					//bool isLight = ceil((firstmask + halfLambert) * 0.5 * 10) / 10 >= _LightArea;
					diffuse = isLight ? col.rgb : firstCol;
				}
				//决定比较暗的地方
				else{
					bool isfirst = (diffuseMask + halfLambert) * 0.5 > _SecondShadow;
					diffuse = isfirst ? firstCol : secondCol;
				}
				//diffuse ;

				//高光
				float shinepow = max(pow(NDotH,_Shininess),0);

				float3 spec = shinepow + lightmap.b > 1.0 ? lightmap.r * _SpecMulti * _LightSpecColor : 0;

				return fixed4(diffuse + spec,1) ;
			}
			ENDCG
		}
	}
}
