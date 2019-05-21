Shader "ZShader/UI/UIBlurGlass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//_Color ("Tint", Color) = (1,1,1,1)
		_BlurSize("_BlurSize",Float) = 1
		[KeywordEnum(None, AvagerBlur, AvagerBlur9)] _BlurMode ("_BlurMode", Float) = 0
		//_BgTexture("_BgTexture",2D) = "white"{}
		_GrabTexture("_GrabTexture",2D) = "white"{}
	}
	SubShader
	{
		 Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
        Lighting Off
        ZWrite Off
		ZTest Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _BLURMODE_NONE _BLURMODE_AVAGERBLUR _BLURMODE_AVAGERBLUR9
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color    : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;

				fixed4 screenPos : TEXCOORD2;
				float4 color    : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GrabTexture;
			//sampler2D _BgTexture;
			fixed4 _GrabTexture_TexelSize;
			//fixed4 _Color;
			fixed4 _TextureSampleAdd;
			fixed _BlurSize;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return i.color.a;
				// sample the texture
				fixed4 col = (tex2D(_MainTex, i.uv) +_TextureSampleAdd);
				fixed2 screenPos = i.screenPos.xy / i.screenPos.w;
				fixed4 grabcol = tex2D(_GrabTexture,screenPos);
				//fixed4 bgCol = tex2D(_BgTexture, screenPos);
				#ifndef _BLURMODE_NONE
					grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(0,1)*_BlurSize);
					grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(0,-1)*_BlurSize);
					grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(1,0)*_BlurSize);
					grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(-1,0)*_BlurSize);

					#if _BLURMODE_AVAGERBLUR9
						grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(1,1)*_BlurSize);
						grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(-1,-1)*_BlurSize);
						grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(1,-1)*_BlurSize);
						grabcol += tex2D(_GrabTexture,screenPos + _GrabTexture_TexelSize.xy * float2(-1,1)*_BlurSize);
						grabcol /=9;
					#else
						grabcol /=5;
					#endif

				#endif
				fixed srcAlpha = col.a ;
				fixed4 finalCol = srcAlpha * col + (1-srcAlpha) *step(0.0001,srcAlpha)* grabcol;
				finalCol.a = step(0.0001,srcAlpha);
				return finalCol* i.color;
			}

			ENDCG
		}
	}
}
