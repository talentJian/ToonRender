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
    float4 mvPos = mul(UNITY_MATRIX_MV,v.vertex);
    float3 mvNormal = mul(UNITY_MATRIX_IT_MV,v.normal);
    mvPos.xyz = mvPos.xyz + mvNormal * _Outline;
    o.vertex = mul(UNITY_MATRIX_P,mvPos);
    //o.vertex = UnityObjectToClipPos(v.vertex);
    
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    return o;
}

fixed4 toonfrag (toonv2f i) : SV_Target
{
    // sample the texture

    return _OutlineColor;
}