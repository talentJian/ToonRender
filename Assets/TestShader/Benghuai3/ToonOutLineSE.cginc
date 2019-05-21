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

//在裁剪空间下
v2f toonOutline_vert(VertexInput v)
{
	v2f o;
	o.uv = v.uv;
	o.vertexColor = v.vertexColor;
	o.pos = UnityObjectToClipPos(v.vertex);

	float outlineWidth = _Outline_Width  * v.vertexColor.g *  _ScreenParams.y / 720 ;
    float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, v.normal));
	float2 offset =  normalize(clipNormal.xy)/ _ScreenParams.xy  * outlineWidth  * o.pos.w * 2 ;
	float pow = _MaxOutLine * 0.01 ; 
	offset.x = clamp(offset.x,-pow,pow);
	offset.y = clamp(offset.y,-pow,pow);
	o.pos.xy += offset;

	return o;
}

float4 toonOutline_frag(v2f i):SV_TARGET
{
	fixed alpha = _Outline_Alpha * i.vertexColor.a;
	#if _isOutlineMulMainCol
		fixed4 mainTexCol = tex2D(_MainTex,i.uv);
		return float4(_Outline_Color * mainTexCol.rgb * _LightColor0.rgb,alpha);
	#else
		return float4(_Outline_Color,alpha);
	#endif
	
}