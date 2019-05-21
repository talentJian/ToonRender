// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Atl/Distortion_a" {
Properties {
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_MainTex ("Alpha (A)", 2D) = "white" {}     //r 范围mask  g 强度控制
	_HeatTime  ("Heat Time", float) = 1
	_HeatForce  ("Heat Force", float) = 0.1
}

Category {
	Tags { "Queue"="Transparent+1" "RenderType"="Transparent" "IgnoreProjector"="True"}
	Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater .01
	Cull Off Lighting Off ZWrite Off
	

	SubShader {
		GrabPass {							
			Name "BASE"
			Tags { "LightMode" = "Always" }
			"_CommonGrabTexture"    // 自定义贴图，这样每帧只会有一个对象的GrabTexture操作
 		}

		Pass {
			Name "BASE"
			Tags { "LightMode" = "Always" }
			
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord: TEXCOORD0;
};

struct v2f {
	float4 vertex : POSITION;
	float4 uvgrab : TEXCOORD0;
	float2 uvmain : TEXCOORD1;
};

float _HeatForce;
float _HeatTime;
float4 _MainTex_ST;
float4 _NoiseTex_ST;
sampler2D _NoiseTex;
sampler2D _MainTex;

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
	#else
	float scale = 1.0;
	#endif
	o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
	o.uvgrab.zw = o.vertex.zw;
	o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
	return o;
}

//sampler2D _GrabTexture;
sampler2D _CommonGrabTexture; //_GrabTexture;// 由GrabPass赋值


half4 frag( v2f i ) : COLOR
{
	half4 tint = tex2D(_MainTex, i.uvmain);
	//noise effect
	half4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz*_HeatTime);
    half4 offsetColor2 = tex2D(_NoiseTex, i.uvmain - _Time.yx*_HeatTime);
	i.uvgrab.x += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce* tint.g;
	i.uvgrab.y += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForce *tint.g;
	

	half4 col = tex2Dproj( _CommonGrabTexture, UNITY_PROJ_COORD(i.uvgrab));
	//Skybox's alpha is zero, don't know why.
	col.a = 1.0f;
	
	col.a = tint.r;
	return col;
}
ENDCG
		}
}

	// ------------------------------------------------------------------
	// Fallback for older cards and Unity non-Pro
	
	SubShader {
		Blend DstColor Zero
		Pass {
			Name "BASE"
			SetTexture [_MainTex] {	combine texture }
		}
	}
}
}
