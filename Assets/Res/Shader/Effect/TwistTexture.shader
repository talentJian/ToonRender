// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZShader/Effect/TwistTexture" 
{
	Properties 
	{
		[HDR]_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_Mask ("Mask ( R Channel )", 2D) = "white" {}
		_TwistTexture("TwistUV Texture", 2D) = "white" {}
		_Intensity("intensity",Range(-1,1)) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode ("Src Blend Mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlendMode ("Dst Blend Mode", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode ("ZTestMode", Float) = 4
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend [_SrcBlendMode] [_DstBlendMode]
		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
		ZTest [_ZTestMode]
		SubShader 
		{
			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _Mask;
				sampler2D _TwistTexture;
				fixed4 _TintColor;
				float _Intensity;
			
				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float2 texcoordMask : TEXCOORD1;
					float2 texcoorduv : TEXCOORD2;

				};
			
				float4 _MainTex_ST;
				float4 _Mask_ST;
				float4 _TwistTexture_ST;
				uniform float4x4 _Camera2World;

				v2f vert (appdata_t v)
				{
					v2f o;	
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.texcoordMask = TRANSFORM_TEX(v.texcoord,_Mask);
					o.texcoorduv = TRANSFORM_TEX(v.texcoord,_TwistTexture);
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 a = tex2D(_TwistTexture, i.texcoorduv) * _Intensity;
				    fixed4 c = tex2D(_MainTex, i.texcoord + a);
					c.a *= tex2D(_Mask, i.texcoordMask).r;
					return 2.0f * i.color * _TintColor * c;
				}
				ENDCG 
			}
		}
		
		// ---- Dual texture cards
		SubShader 
		{
			Pass 
			{
				SetTexture [_MainTex] 
				{
					constantColor [_TintColor]
					combine constant * primary
				}
				SetTexture [_MainTex] 
				{
					combine texture * previous DOUBLE
				}
			}
		}
	
		// ---- Single texture cards (does not do color tint)
		SubShader 
		{
			Pass 
			{
				SetTexture [_MainTex] 
				{
					combine texture * primary
				}
			}
		}	
	}
}
