struct toonappdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal: NORMAL;
};

struct toonv2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _Outline;
float4 _OutlineColor;
toonv2f toonvert (toonappdata v)
{
    toonv2f o;
    float3 wpos = mul(unity_ObjectToWorld,fixed4(v.vertex.xyz,1)) + mul(v.normal,unity_WorldToObject)  * _Outline;
    float3 mvNormal = mul(UNITY_MATRIX_IT_MV,v.normal);

    o.vertex = mul(unity_MatrixVP,fixed4(wpos,v.vertex.w));
    
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    return o;
}

    // toonv2f o;
    // o.vertex = UnityObjectToClipPos(v.vertex);  
    // //将法线方向转换到视空间  
    // float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
    // //将视空间法线xy坐标转化到投影空间，只有xy需要，z深度不需要了  
    // float2 offset = TransformViewToProjection(vnormal.xy);  
    // //在最终投影阶段输出进行偏移操作  
    // o.vertex.xy += offset * _Outline;  
    // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    // return o;


fixed4 toonfrag (toonv2f i) : SV_Target
{
    // sample the texture

    return _OutlineColor;
}