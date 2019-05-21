//HDR开启时专门使用的辉光Image
Shader "Hidden/UI-HdrRawImage"
{
	Properties
	{
		_MainTex ("_MainTex", 2D) = "white" {}
		_AlphaTex("_AlphaTex",2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		LOD 200

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			fixed4 _Color;
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 main_color = tex2D(_MainTex, i.texcoord).rgb;
				fixed alpha = tex2D(_AlphaTex, i.texcoord).a;
				fixed4 final_color = fixed4(main_color.rgb,alpha)*_Color;
				return final_color;
			}
			ENDCG
		}
	}
}
