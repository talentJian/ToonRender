// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

float3 _Outline_Color;
fixed _Outline_Width;
// fixed _Farthest_Distance;
// fixed _Nearest_Distance;

fixed _Outline_Alpha=1;
struct VertexInput{
	float4 vertex :POSITION;
	float3 normal :NORMAL;
	float4 vertexColor :COLOR0;
	//float2 uv :TEXCOORD0;
};
struct v2f{
	float4 pos:SV_POSITION;
	//float2 uv0 : TEXCOORD0;
};
v2f vert(VertexInput v)
{
	v2f o;
	float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1));
	//TODO :MASK的控制，应该考虑使用VertexColor
	//float outlineWidth = _Outline_Width * 0.001 * smoothstep(_Farthest_Distance,_Nearest_Distance,distance(objPos,_WorldSpaceCameraPos)) * v.vertexColor.g;
	float outlineWidth = _Outline_Width * 0.001 * v.vertexColor.g;
	//将法线方向转换到视空间  
    float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); 
	//float2 offset =  TransformViewToProjection(vnormal.xy); 
	o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal * outlineWidth,1));
	return o;
	//  v2f o;  
	// //在vertex阶段，每个顶点按照法线的方向偏移一部分，不过这种会造成近大远小的透视问题  
	// //v.vertex.xyz += v.normal * _OutlineFactor;  
	// o.pos = UnityObjectToClipPos(v.vertex);  
	// //将法线方向转换到视空间  
	// float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
	// //将视空间法线xy坐标转化到投影空间  
	// float2 offset = TransformViewToProjection(vnormal.xy);  
	// //在最终投影阶段输出进行偏移操作  
	// o.pos.xy += offset * _Outline_Width * 0.001;  
	// return o;  
}
float4 frag(v2f i):SV_TARGET
{
	return float4(_Outline_Color,_Outline_Alpha);
}