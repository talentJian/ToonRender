// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

float3 _Outline_Color;
fixed _Outline_Width;
fixed _MaxOutLine;
fixed _MinOutLine;

sampler2D _MainTex;
fixed _Outline_Alpha=1;
struct VertexInput{
	float4 vertex :POSITION;
	float3 normal :NORMAL;
	float4 vertexColor :COLOR0;
	float2 uv :TEXCOORD0;
};
struct v2f{
	float4 pos:SV_POSITION;
	float2 uv : TEXCOORD0;
	//float3 worldPos :TEXCOORD1;
	float4 vertexColor :TEXCOORD1;
	
};
// v2f toonOutline_vert(VertexInput v)
// {
// 	v2f o;
// 	float outlineWidth = _Outline_Width  * v.vertexColor.g;
// 	//将法线方向转换到视空间  
//     float3 vnormal =( mul((float3x3)UNITY_MATRIX_IT_MV, v.normal)); 
// 	float2 offset =  TransformViewToProjection(vnormal.xy); 
// 	o.pos = UnityObjectToClipPos(float4(v.vertex.xyz, 1));
// 	//LinearEyeDepth()
// 	o.pos.xy += offset* outlineWidth *0.001 * clamp(UNITY_Z_0_FAR_FROM_CLIPSPACE(o.pos.z),_MinOutLine,_MaxOutLine);
// 	o.uv = v.uv;
// 	o.vertexColor = v.vertexColor;
// 	return o;
// }
v2f toonOutline_vert(VertexInput v)
{
	v2f o;
	float outlineWidth = _Outline_Width  * v.vertexColor.g;
	//将法线方向转换到视空间  
    float3 vnormal =( mul((float3x3)UNITY_MATRIX_IT_MV, v.normal)); 
	float2 offset =  TransformViewToProjection(vnormal.xy); 
	o.pos = UnityObjectToClipPos(float4(v.vertex.xyz, 1));
	//LinearEyeDepth()
	o.pos.xy += offset* outlineWidth *0.001 ;
	o.uv = v.uv;
	o.vertexColor = v.vertexColor;
	return o;
}

float4 toonOutline_frag(v2f i):SV_TARGET
{
	fixed alpha = _Outline_Alpha * i.vertexColor.a;
	#if _isOutlineMulMainCol
		fixed4 mainTexCol = tex2D(_MainTex,i.uv);
		return float4(_Outline_Color * mainTexCol.rgb,alpha);
	#else
		return float4(_Outline_Color,alpha);
	#endif
	
}