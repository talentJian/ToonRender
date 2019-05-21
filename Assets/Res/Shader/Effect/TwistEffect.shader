Shader "ZShader/Effect/TwistEffect"
{
	Properties
	{
		_TwistTex ("Texture", 2D) = "white" {}
		_TwistPow("TwistPower",Range(0,5)) = 1	
		_UvOffse("UvFloat",Range(0,1))=0
		
	}
	SubShader
	{
		LOD 200
		Tags { "RenderType"="Transparent" "Queue" = "Transparent-100" }
		GrabPass{ "_GlobalGrabTexture" }
		Pass
		{
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 vertexColor : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 projPos :TEXCOORD1;
				float4 vertexColor : COLOR;
			};
			sampler2D _GlobalGrabTexture;
			//sampler2D _GlobalGrabTexture;
			sampler2D _TwistTex;
			float4 _TwistTex_ST;
			fixed _TwistPow;
			fixed _UvOffse;
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _TwistTex);
				o.projPos = ComputeGrabScreenPos(o.pos);
				o.vertexColor = v.vertexColor;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{	
				//趋向圆形
				float uvWeight = (1.0 - 2 * distance(i.uv,float2(0.5,0.5)));
				// sample the texture
				float2 uv = _UvOffse * _Time.w * float2(0.5,-0.5);
				fixed4 twist_col = tex2D(_TwistTex, i.uv + uv);
				float2 twist_uv = i.projPos / i.projPos.w;
				twist_uv = twist_uv + float2(twist_col.r,twist_col.g) * _TwistPow * twist_col.a  *  saturate(uvWeight) * i.vertexColor.a;
				fixed4 finalColor = tex2D(_GlobalGrabTexture,twist_uv);
				return finalColor;
			}
			ENDCG
		}
	}
	SubShader
	{
		//实时反射地板不能再用GrabPass
		LOD 100
		Tags { "RenderType"="Transparent" "Queue" = "Transparent-1" }
		Pass
		{
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 vertexColor : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 projPos :TEXCOORD1;
				float4 vertexColor : COLOR;
			};
			sampler2D _GlobalGrabTexture;
			//sampler2D _GlobalGrabTexture;
			sampler2D _TwistTex;
			float4 _TwistTex_ST;
			fixed _TwistPow;
			fixed _UvOffse;
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _TwistTex);
				o.projPos = ComputeGrabScreenPos(o.pos);
				o.vertexColor = v.vertexColor;
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
