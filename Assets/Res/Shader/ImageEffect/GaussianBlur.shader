//高斯模糊
Shader "Hidden/Post/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//_BlurSize("Blur Size",Float) = 1.0
		_BlurLerp("模糊过度",Float) = 1.0
		_SoureTex("_SoureTex",2D) = "white" {}
	}
	SubShader
	{
		
		CGINCLUDE
		
		struct appdata
		{
			float4 vertex : POSITION;
			half2 uv : TEXCOORD0;
		};

		struct v2f
		{
			half2 uv[5] : TEXCOORD0;
			float4 pos : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float _BlurSize;

		sampler2D _SoureTex;
		fixed _BlurLerp;
		v2f vertBlurVertical (appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.uv;
			o.uv[0] = uv + half2(0,0) * _MainTex_TexelSize.xy *_BlurSize;
			o.uv[1] = uv + half2(1,0) * _MainTex_TexelSize.xy *_BlurSize;
			o.uv[2] = uv + half2(-1,0) * _MainTex_TexelSize.xy *_BlurSize;
			o.uv[3] = uv + half2(2,0) * _MainTex_TexelSize.xy *_BlurSize;
			o.uv[4] = uv + half2(-2,0) * _MainTex_TexelSize.xy *_BlurSize;
			return o;
		}
		v2f vertBlurHorizontal (appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.uv;
			o.uv[0] = uv + half2(0,0) * _MainTex_TexelSize.xy *_BlurSize;
			o.uv[1] = uv + half2(0,-1) * _MainTex_TexelSize.xy * _BlurSize;
			o.uv[2] = uv + half2(0,1) * _MainTex_TexelSize.xy * _BlurSize;
			o.uv[3] = uv + half2(0,-2) * _MainTex_TexelSize.xy * _BlurSize;
			o.uv[4] = uv + half2(0,2) * _MainTex_TexelSize.xy * _BlurSize;
			return o;
		}
		
		fixed4 fragBlur (v2f i) : SV_Target
		{
			float weight[3] = {0.4026,0.2442,0.0545};
			fixed3 color;
			color = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
			for(int it=1,t=1;it<3;it++)
			{
				color += tex2D(_MainTex,i.uv[t]).rgb * weight[it] ;
				color += tex2D(_MainTex,i.uv[t+1]).rgb * weight[it];
				t+=2;
			}
			fixed4 finalColor = lerp(tex2D(_SoureTex,i.uv[0]),fixed4(color,1),_BlurLerp);
			return finalColor;
		}

		ENDCG
		
		Cull Off ZWrite Off ZTest Always
		Pass
		{
			// No culling or depth
			CGPROGRAM
			#pragma vertex vertBlurVertical
			#pragma fragment fragBlur
			
			#include "UnityCG.cginc"

			
			ENDCG
		}
			Pass
		{
			// No culling or depth
		
			CGPROGRAM
			#pragma vertex vertBlurHorizontal
			#pragma fragment fragBlur
			
			#include "UnityCG.cginc"

			
			ENDCG
		}
	}
}
