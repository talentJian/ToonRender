// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

struct appData{
	float4 vertex :POSITION;
	float3 normal :NORMAL;
	float4 vertexColor :COLOR0;
	float2 uv :TEXCOORD0;
};
struct v2f{
	float4 pos:SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 worldPos :TEXCOORD1;
	float3 worldNormal : TEXCOORD2;
	float4 vertexColor :TEXCOORD3;

	#if _Emissve_Float_ON
	float2 uv_emissve_float :TEXCOORD5;
	#endif

	SHADOW_COORDS(8)
};

sampler2D _MainTex;
//皮肤模拟Rim 图
sampler2D _FalloffTex;
//高光
fixed _specularPow;
fixed3 _specularColor;
fixed _specularStrenght;
fixed _isLerpToMain;

//阴影部分
fixed _ShadowLightArea;
float3 _ShadowColor;
fixed _ShadowWidthSmooth;
fixed _ShadowStreath;

sampler2D _MaskTex;

fixed _MainAlpha;

//溶解
float _DisolveValue;
fixed _DisolveLineWidth;
fixed4 _DisolveLineFirstColor;
fixed4 _DisolveLineSecondColor;
sampler2D _DisolveTex;

//受击边缘光
fixed4 _SecondRimColor;
half _SecondRimStrenth;


//计算溶解
//包含扭曲或者不扭曲的人物溶解
fixed4 SetDissovle(v2f i,fixed4 finalColor)
{
	#ifdef _UseDissovle
		fixed dissolve = tex2D(_DisolveTex,i.uv).r;
		float dissovle_area = dissolve - _DisolveValue;
		fixed4 dissvoleColor = lerp(_DisolveLineFirstColor,_DisolveLineSecondColor,dissovle_area); 
		if(dissovle_area <= 0.01)
		{
			return 0;
		}
		fixed4 alhpaColor = finalColor ;
		fixed4 alhpaFinalCol = lerp(alhpaColor,dissvoleColor * 2,smoothstep(0.0,_DisolveLineWidth,dissovle_area)) ;
		finalColor = lerp(alhpaFinalCol,finalColor,step(_DisolveLineWidth,dissovle_area));
	#endif
	return finalColor;
}


//自发光流动
#if _Emissve_Float_ON
sampler2D _EmissiveTex;
float4 _EmissiveTex_ST;
fixed _EmissiveStrength;
fixed _EmissiveOffsetX,_EmissiveOffsetY;
float4 _EmissiveColor;
#endif

//自发光闪动
#if _Emissve_SIN_ON	
fixed _SinEmissiveStrength;
float4 _SinEmissiveColor;
fixed _SinEmissiveFrequent;
#endif

// 设置自发光
fixed4 SetEmmisveColor(v2f i,fixed4 lightMaskCol,fixed4 finalColor)
{
//流动
	#if _Emissve_Float_ON
		fixed moveTimeX = _Time.x * _EmissiveOffsetX;
		fixed moveTimeY = _Time.y * _EmissiveOffsetY;
		float2 emissveUv = float2(i.uv_emissve_float.x + moveTimeX,i.uv_emissve_float.y + moveTimeY);
		fixed4 EmissiveColor = lightMaskCol.b * tex2D(_EmissiveTex,emissveUv) * _EmissiveColor * _EmissiveStrength;
		finalColor.rgb += EmissiveColor.rgb;
	#endif

	//直接自发光
	#if _Emissve_SIN_ON
		// 乘以一个控制值
		fixed EmissiveAlpha = sin(_SinEmissiveFrequent *  _Time.x) *0.5 + 0.5;
		fixed4 SinEmissiveColor = lightMaskCol.a * _SinEmissiveColor * _SinEmissiveStrength * EmissiveAlpha;
		finalColor.rgb += SinEmissiveColor.rgb;
	#endif 
	return finalColor;
}

v2f ToonVert(appData v)
{
	v2f o;
	o.uv = v.uv;
	o.pos = UnityObjectToClipPos(v.vertex);

	o.worldPos = mul(unity_ObjectToWorld,v.vertex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	o.vertexColor = v.vertexColor;
	TRANSFER_SHADOW(o);
	return o;
}

fixed4 Toonfrag(v2f i):SV_Target
{
	fixed4 mainTexCol = tex2D(_MainTex,i.uv);
	
	fixed4 maskTexCol = tex2D(_MaskTex,i.uv);

	half3 worldNormal = normalize(i.worldNormal);
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	half3 LightDir = UnityWorldSpaceLightDir(i.worldPos);

	half3 halfDir = normalize(LightDir + viewDir);
	//half NDOTH = dot(worldNormal,halfDir);
	half NDOTV = dot(worldNormal,viewDir);
	half NDOTL = dot(worldNormal,LightDir);

	half halfLambert = NDOTL *0.5 +0.5;
	half _rim =  clamp(1-abs(NDOTV),0.02,0.98);
	half3 _fallOff = tex2D(_FalloffTex,_rim);

	//模拟高光
	const fixed _specularRange = 0.65;
	half specular = pow(_rim,_specularPow) * (halfLambert + 0.5);
	specular = smoothstep(_specularRange,_specularRange + 0.05,specular);
	fixed3 specularColor = _specularColor * specular * mainTexCol.rgb  * _specularStrenght;
	specularColor = lerp(specularColor,specularColor*mainTexCol.rgb,_isLerpToMain) *  i.vertexColor.b;

	//阴影颜色
	
	// Unity自带的阴影
	UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

	half3 litColor =  mainTexCol.rgb ;

	//阴影颜色为 亮部 和 阴影颜色的混合
	half3 shadowColor = lerp(litColor,litColor * _ShadowColor,_ShadowStreath);


	#if _isUseMaskTex
		fixed4 MaskTexCol = tex2D(_MaskTex,i.uv);
	#endif
	
	//人物阴影
	#if _IsUseShadowMask && _isUseMaskTex
		const fixed ShadowLightArea = 0.5;
		fixed diffuseMask = (halfLambert * atten + MaskTexCol.r * i.vertexColor.r) * 0.5 ;
		fixed diffuseStep =  smoothstep(0,_ShadowWidthSmooth,saturate(diffuseMask  - ShadowLightArea));
		half3 finalDiffuseColor  = (lerp(shadowColor,litColor + specularColor,diffuseStep) ) * _LightColor0; 
	#else
		fixed ShadowLightArea = _ShadowLightArea;
		fixed diffuseMask = (halfLambert * atten);
		fixed diffuseStep =  smoothstep(0,_ShadowWidthSmooth,saturate(diffuseMask  - ShadowLightArea));
		half3 finalDiffuseColor  = (lerp(shadowColor,litColor + specularColor,diffuseStep) ) * _LightColor0; 
	#endif
	
	//===========第二层边缘光在代码控制，用来控制被攻击时候的闪白===
	half secondRim = 1 - saturate(abs(NDOTV));
	half3 secondRimColor = secondRim * _SecondRimColor * _SecondRimStrenth ;

	//衣服使用a 通道
	// 皮肤带有fallOff的边缘光
	half3 skinFallOff = finalDiffuseColor * _fallOff.rgb;
	#if _isUseMaskTex
		half3 finalCol = lerp(finalDiffuseColor,skinFallOff,MaskTexCol.g);
	#else
		half3 finalCol = finalDiffuseColor;
	#endif
	finalCol += secondRimColor;
	fixed4 finalColor= fixed4(finalCol,_MainAlpha * i.vertexColor.a);


	#if _isUseMaskTex
	finalColor = SetEmmisveColor(i,MaskTexCol,finalColor);
	#endif

	finalColor = SetDissovle(i,finalColor);
	return finalColor;
}





