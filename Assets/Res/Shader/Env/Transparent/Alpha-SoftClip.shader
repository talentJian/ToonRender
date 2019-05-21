Shader "ZShader/Transparent/Alpha-SoftClip"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_CutOff("CutOff",Range(0,1))=0.5
		[Toggle(IS_USE_Fog)] _IS_USE_Fog("使用自带雾效?",Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "AlphaTest" "IgnoreProjector"="true"}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature IS_USE_Fog
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
			#include "../../GlobalColor/BulletTimeFog.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 worldpos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _CutOff;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldpos = mul(unity_ObjectToWorld,v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				clip(col.a- _CutOff);

				fixed4 finalColor = col * _Color;
				//return finalColor;
				#ifdef IS_USE_Fog
				UNITY_APPLY_FOG(i.fogCoord, finalColor);
				#endif

				return GetFogColor(finalColor,i.worldpos);
			}
			ENDCG
		}
	}
}
