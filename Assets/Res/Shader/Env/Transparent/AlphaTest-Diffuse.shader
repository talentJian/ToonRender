Shader "ZShader/Transparent/Cutout/Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	_Emissive("EmissiveColor",Color) = (0,0,0,1)
	[Enum(On,1,Off,0)]_Cull("CullMode",Float) = 1
}

SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 200
	Cull [_Cull]
	CGPROGRAM
	#pragma surface surf Lambert alphatest:_Cutoff approxview halfasview exclude_path:prepass finalcolor:final
	#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT
	#include "../../GlobalColor/BulletTimeFog.cginc"
	sampler2D _MainTex;
	fixed4 _Color;
	fixed4 _Emissive;

	struct Input {
		float2 uv_MainTex;
		float3 worldPos;
	};

	void surf (Input IN, inout SurfaceOutput o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * (_Color + _Emissive);
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}

	void final(Input IN, SurfaceOutput o, inout fixed4 color) 
	{
		
		color = GetFogColor(color,IN.worldPos);
	}
	ENDCG
	}

//Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
