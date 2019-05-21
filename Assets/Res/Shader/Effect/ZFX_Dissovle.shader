Shader "ZShader/Effect/ZFX_Dissovle"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR]_MainColor("MainColor",Color) = (1, 1, 1, 1)
		_DissovleTex("溶解图",2D) = "white" {}
		_DissvoleValue("_DissvoleValue",Range(-2,2)) = 1
		_Width("_Width",Range(0,1)) = 0.2
		_LineTex("LineTex",2D) = "black" {}
		_RampTex("过渡图",2D) = "white" {}
		[HDR]_dissvoleColor("溶解颜色",Color) = (1,1,1,1)
		_LineWidth("过度边缘宽度",Range(0,1)) = 0.05
		_TwistTex("扭曲图",2D) = "white" {}
		_TwistStren("扭曲强度",Range(0,1)) = 1
		
		[HDR]_LineColor("LineColor",Color) = (1,1,1,1)
		_LuaminaceValue("_LuaminaceValue",Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				//float2 srcuv:TEXCOORD1;
				float2 lineTexuv : TEXCOORD2;
				float2 twistTexuv :TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainColor;
			
			float _DissvoleValue;
			sampler2D _DissovleTex;
			float4 _DissovleTex_ST;
			float _Width; 

			float4 _dissvoleColor;

			sampler2D _LineTex;
			float4 _LineTex_ST;

			sampler2D _RampTex;
			sampler2D _TwistTex;
			float4 _TwistTex_ST;

			float4 _LineColor;
			fixed _LineWidth;
			float _TwistStren;

			fixed _LuaminaceValue;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _DissovleTex);
				//o.srcuv = v.uv;
				o.lineTexuv = TRANSFORM_TEX(v.uv,_LineTex);
				o.twistTexuv = TRANSFORM_TEX(v.uv,_TwistTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy)*_MainColor;
				//return col;
				float dissolveTexCol = tex2D(_DissovleTex,i.uv.zw).r;
				float2 rampTexUv = i.uv + ((tex2D(_TwistTex,i.twistTexuv)*2-1) * _TwistStren);
				float tempValue = tex2D(_RampTex,rampTexUv).r;
				//return tempValue;
				float dissolveThreshold = tempValue-_DissvoleValue - (_DissvoleValue-dissolveTexCol)*_Width;

				//float alpha = step(0,dissolveThreshold) smoothstep(0.0,_LineWidth,dissolveThreshold));
				float alpha = smoothstep(0.0,_LineWidth,dissolveThreshold) ;
				col.a = alpha*col.a ;

				float4 lineTexCol = tex2D(_LineTex,i.lineTexuv);
				//float4 lineTexCol = col;
				col.rgb = lerp(_dissvoleColor.rgb,col.rgb,smoothstep(0.0,_LineWidth,dissolveThreshold));
				float lineCol = saturate(((lineTexCol.r*3.0+1.0)- ((dissolveThreshold)*2.5+1)));
				col.rgb += lineCol * _LineColor;
				//col.a *= lineCol * _LineColor.a;

				fixed4 luaminCol = Luminance(col.rgb);
				luaminCol.a = col.a;
				col = lerp(luaminCol,col,_LuaminaceValue);

				return col;
			}
			ENDCG
		}
	}
}
