Shader "Hidden/AvagerBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("BlurSize",Float) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
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
			};

			struct v2f
			{
				float2 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float  _BlurSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				

				o.uv[0] = v.uv;
				o.uv[1] = v.uv + _MainTex_TexelSize.xy * float2(0,1) * _BlurSize;
				o.uv[2] = v.uv + _MainTex_TexelSize.xy * float2(0,-1)* _BlurSize;
				o.uv[3] = v.uv + _MainTex_TexelSize.xy * float2(1,0)* _BlurSize;
				o.uv[4] = v.uv + _MainTex_TexelSize.xy * float2(-1,0)* _BlurSize;
				return o;
			}
			
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv[0]);
				// for(int index = 1;index <5;index++)
				// {
				// 	col += tex2D(_MainTex,i.uv[index]);
				// }
				col += tex2D(_MainTex,i.uv[1]);
				col += tex2D(_MainTex,i.uv[2]);
				col += tex2D(_MainTex,i.uv[3]);
				col += tex2D(_MainTex,i.uv[4]);
				col = col *0.2;
				return col;
			}
			ENDCG
		}
	}
}
