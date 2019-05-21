//设置建筑的高度 消隐
sampler2D _DisHeightMask;
float4 _DisHeightMask_ST;
fixed _DisHeight;
fixed4 _DisHeightColor;
fixed _DisHeightColorStrenght; // 边缘光强度
float4 SetHeightDissovle(float4 finalCol,float2 uv,float3 worldPos)
{
    #if _HeightDissovleOn
        float4 _maskVar = tex2D(_DisHeightMask,TRANSFORM_TEX(uv,_DisHeightMask));
        float clipValue = saturate(_DisHeight - worldPos.y-_maskVar.r);
        clip(clipValue-0.5);

        float strenght = pow(clipValue,1-_DisHeightColorStrenght);
        float3 emissive = (lerp( (finalCol.rgb*(1.0 - _DisHeightColor.rgb)), finalCol.rgb, strenght ));
        return fixed4(emissive,1);
    #endif
    return finalCol;
}