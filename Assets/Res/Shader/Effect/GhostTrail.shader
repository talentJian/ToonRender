Shader "ZShader/Ghost/GhostTrail"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
		_RimColor("RimColor",Color) = (1,1,1,1)
		_RimPower("RimPower",Range(0,1) ) = 0.5
		[HideInInspector]_Opacity("_Opacity",Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
		
		
		Pass
		{
			Blend SrcAlpha One
			Cull off
			ZWrite off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal:TEXCOORD0;
				float3 worldPos :TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed3 _RimColor;
			fixed _Opacity,_RimPower;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.normal);
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed rim =  (1-abs(dot(normal,viewDir))) * _RimPower;
				fixed3 rimColor = rim * _RimColor;
				//return rim;
				return fixed4((_Color.rgb + rimColor),_Color.a)  * _Opacity;

				return _Color * _Opacity;
			}
			ENDCG
		}
	}
}
