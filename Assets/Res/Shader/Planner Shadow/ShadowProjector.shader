// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

Shader "ZShader/ShadowProjector"
{
	Properties
	{
		_ZShadowTex ("Texture", 2D) = "white" {}
		_Falloff("FalloffTex",Range(0,1)) = 0.5
		_ShadowColor("ShadowColor",Color) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector"="True" }
		LOD 100

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			// Stencil{
			// 	Ref 5
			// 	Comp Greater
			// 	Pass Replace
			// }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
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
				float4 texc :TEXCOORD1;
			};

			sampler2D _ZShadowTex;
			float4 _ZShadowTex_ST;
			half4 _ShadowColor;
			fixed _Falloff;
			float4x4 unity_Projector;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _ZShadowTex);
				o.texc = mul(unity_Projector, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = tex2Dproj(_ZShadowTex, i.texc);
				float4 finalCol = smoothstep(0.1,1,1-col.r) *_Falloff * _ShadowColor;
				finalCol.a *= col.a;
				return finalCol;
			}
			ENDCG
		}
	}
}
