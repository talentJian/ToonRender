Shader "ZShader/T4MShaders/Diffuse/T4M 4 Textures" {
Properties {
	_Splat0 ("Layer 1", 2D) = "white" {}
	_Splat1 ("Layer 2", 2D) = "white" {}
	_Splat2 ("Layer 3", 2D) = "white" {}
	_Splat3 ("Layer 4", 2D) = "white" {}
	_Control ("Control (RGBA)", 2D) = "white" {}
	_MainTex ("Never Used", 2D) = "white" {}
}
                
SubShader {
	Tags {
   "SplatCount" = "4"
   "RenderType" = "Opaque"
	}
CGPROGRAM
#pragma multi_compile_fog
#pragma surface surf Lambert finalcolor:final vertex:myvert
#pragma exclude_renderers xbox360 ps3

struct Input {
	float2 uv_Control : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	//float2 uv_Splat3 : TEXCOORD4;
	float3 worldPos : TEXCOORD5;
	UNITY_FOG_COORDS(6)
};
 
sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;


#pragma multi_compile _USE_BULLET_FOG_NONE _USE_BULLET_FOG_NORMAL _USE_BULLET_FOG_CAM _USE_BULLET_FOG_POINT 
#include "../GlobalColor/BulletTimeFog.cginc"

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
		
	fixed3 lay1 = tex2D (_Splat0, IN.uv_Splat0);
	fixed3 lay2 = tex2D (_Splat1, IN.uv_Splat1);
	fixed3 lay3 = tex2D (_Splat2, IN.uv_Splat2);
	fixed3 lay4 = tex2D (_Splat3, IN.uv_Splat2);
	o.Alpha = 0.0;
	o.Albedo.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
}

void myvert (inout appdata_full v, out Input data)
{
	UNITY_INITIALIZE_OUTPUT(Input,data);
	UNITY_TRANSFER_FOG(data,UnityObjectToClipPos(v.vertex));
}

void final(Input IN, SurfaceOutput o, inout fixed4 color) 
{
	UNITY_APPLY_FOG(IN.fogCoord, color);
	color = GetFogColor(color,IN.worldPos);

}
ENDCG 
}
// Fallback to Diffuse
Fallback "Diffuse"
}
