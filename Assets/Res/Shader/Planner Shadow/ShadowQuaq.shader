// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

Shader "ZShader/ShadowQuaq"
{
	Properties
	{
		
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent+2" }
		LOD 100

		Pass
		{
			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}
	}
}
