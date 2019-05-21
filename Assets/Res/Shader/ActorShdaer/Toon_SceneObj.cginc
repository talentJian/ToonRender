

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float4 tangent :TANGENT;
	float3 normal:NORMAL;
	float3 vertexColor : COLOR0;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float4 pos : SV_POSITION;

	float4 TtoW0:TEXCOORD1;
	float4 TtoW1:TEXCOORD2;
	float4 TtoW2:TEXCOORD3;
	float3 vertexColor :TEXCOORD4;
	
#if _Emissve_Float_ON
	float2 uv_emissve_float :TEXCOORD5;
#endif

//使用溶解扭曲
#if _UseDissovleTwist
	float4 projPos : TEXCOORD6;
#endif

	fixed halfLambert : TEXCOORD7;
};

sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _ShadowTex;  //阴影图
float4 _ShadowColor;   //阴影颜色
float _Alpha;		   //透明度

#if USE_COMBINE_CHANNEL_ON
	sampler2D _LightMask;
#elif USE_SPLIT_CHANNEL_ON
	sampler2D _LightMask_R,_LightMask_G,_LightMask_B,_LightMask_A;
#endif

fixed4 _MainColor;
float _LightArea;         // diffuse 阈值
float _ShadowWidthSmooth; // 阴影平滑过渡

float4 _SpecularColor;
float _Gloss;
float _ShinnessMulti;

//使用使用法线贴图
#if NORMAL_MAP_ON
sampler2D _BumpMap;
float _BumpScale;
#endif

//是否使用边缘光
#if USE_RIM_LIGHT_ON
fixed4 _RimColor;
fixed _RimPower,_RimStrength;
#endif

fixed4 _SecondRimColor;
half _SecondRimStrenth;

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

//固定灯光
#if _USE_FIX_LIGHTDIR
//从外部传入
float3 _LightDir;
#endif


//获取世界坐标下的法线，包含是否使用 Normap
float3 GetWorldNormal(float3 normal,float3x3 tangentTransform,float2 uv)
{
	float3 worldNormal;
	#ifndef NORMAL_MAP_ON
		worldNormal = normalize(normal);
	#else
		float3 bump = UnpackScaleNormal(tex2D(_BumpMap,uv),_BumpScale);
		worldNormal = normalize( mul(bump,tangentTransform));
	#endif
	return worldNormal;
}

// 设置自发光
fixed4 SetEmmisveColor(v2f i,fixed4 lightMaskCol,fixed4 finalColor)
{
//流动
	#if _Emissve_Float_ON
		fixed moveTimeX = _Time.x * _EmissiveOffsetX;
		fixed moveTimeY = _Time.y * _EmissiveOffsetY;
		float2 emissveUv = float2(i.uv_emissve_float.x + moveTimeX,i.uv_emissve_float.y + moveTimeY);
		fixed4 EmissiveColor = lightMaskCol.g * tex2D(_EmissiveTex,emissveUv) * _EmissiveColor * _EmissiveStrength;
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



//顶点着色
v2f vert (appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);

#if _Emissve_Float_ON
	o.uv_emissve_float = TRANSFORM_TEX(v.uv,_EmissiveTex);
#endif

	float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
	float3 worldNormal = UnityObjectToWorldNormal(v.normal);
	float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
	float3 BiNormal =  cross(worldNormal,worldTangent) * v.tangent.w;
	o.TtoW0 = float4(worldTangent.x,BiNormal.x,worldNormal.x,worldPos.x);
	o.TtoW1 = float4(worldTangent.y,BiNormal.y,worldNormal.y,worldPos.y);
	o.TtoW2 = float4(worldTangent.z,BiNormal.z,worldNormal.z,worldPos.z);
	o.vertexColor = v.vertexColor;

	//是否使用固定光照，如果在UI上，一般直接写入灯光的方向
	#if _USE_FIX_LIGHTDIR
		float3 LightDir = _LightDir;
		
	#else
		float3 LightDir = UnityWorldSpaceLightDir(worldPos);
	#endif 
	o.halfLambert = dot(worldNormal,LightDir) * 0.5 + 0.5;

	
	return o;
}
//片元
fixed4 frag (v2f i) : SV_Target
{
	
	float3 worldTangent = float3(i.TtoW0.x,i.TtoW1.x,i.TtoW2.x);
	float3 WorldBiNormal = float3(i.TtoW0.y,i.TtoW1.y,i.TtoW2.y);
	float3 worldNormal = float3(i.TtoW0.z,i.TtoW1.z,i.TtoW2.z);
	float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);;
	float3x3 tangentTransform = float3x3(worldTangent,float3(WorldBiNormal),float3(worldNormal));

	worldNormal = GetWorldNormal(worldNormal,tangentTransform,i.uv);

	//是否使用固定光照，如果在UI上，一般直接写入灯光的方向
	#if _USE_FIX_LIGHTDIR
		float3 LightDir = _LightDir;
		fixed3 LightColor = fixed3(1,1,1);
	#else
		float3 LightDir = UnityWorldSpaceLightDir(worldPos);
		fixed3 LightColor = _LightColor0;
	#endif 

	
	fixed4 mainCol = tex2D(_MainTex, i.uv);
	
	fixed4 shadowCol = mainCol * _ShadowColor;


	fixed4 lightMaskCol = fixed4(0.5,0.5,1,0);
	//是否使用 Mask图
	#if USE_COMBINE_CHANNEL_ON
	lightMaskCol = tex2D(_LightMask,i.uv);
	#elif USE_SPLIT_CHANNEL_ON
	lightMaskCol.r = tex2D(_LightMask_R,i.uv).r;
	lightMaskCol.g = tex2D(_LightMask_G,i.uv).r;
	lightMaskCol.b = tex2D(_LightMask_B,i.uv).r;
	lightMaskCol.a = tex2D(_LightMask_A,i.uv).r;
	#endif

	fixed halfLambert = i.halfLambert;
	
	half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
	

	//======================================高光部分=================================
	//高光部分，包含，单纯的高光，单纯的MatCap,以及 同时包含 高光和MatCap
	fixed3 finalSpecularCol = 0;
	fixed specular = 0;
	#if USE_SPECULAR_ON // 高光
		half3 halfDir = normalize(viewDir + LightDir);	
		specular = pow(max(0,dot(worldNormal,halfDir)), _Gloss * 256);
		finalSpecularCol = _SpecularColor * _ShinnessMulti * specular * lightMaskCol.b ;
	#endif


	//===============================漫反射======================================
	//贴图 R 通道 *  顶点 R通道 共同控制
	fixed diffuseMask = (halfLambert + (lightMaskCol.r) * i.vertexColor.r ) * 0.5;
	fixed diffuseStep =  smoothstep(0,_ShadowWidthSmooth,saturate(diffuseMask - _LightArea));
	half3 finalDiffuseColor  = lerp(shadowCol,mainCol.rgb,diffuseStep);


	//===============================边缘光=====================================
	half NDOTV = dot(worldNormal,viewDir);
	half3 rimColor = 0;
	#if USE_RIM_LIGHT_ON
		half rim = pow(1-saturate(abs(NDOTV)),1 / _RimPower * 5 ) * _RimStrength;
		rimColor = rim * _RimColor;
	#endif		

	//===========第二层边缘光在代码控制，用来控制被攻击时候的闪白===
	half secondRim = 1 - saturate(abs(NDOTV));
	half3 secondRimColor = secondRim * _SecondRimColor * _SecondRimStrenth ;

	//==============加起所有着色后的颜色======
	fixed4 finalColor = fixed4(rimColor + secondRimColor + (finalDiffuseColor + finalSpecularCol) * LightColor,1);
	finalColor = finalColor * _MainColor;

	//自发光
	finalColor = SetEmmisveColor(i,lightMaskCol,finalColor);
	return finalColor;
}


struct low_appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

v2f veryLowVert(low_appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	return o;
}

fixed4 veryLowfrag (v2f i) : SV_Target
{
	
	fixed4 mainCol = tex2D(_MainTex, i.uv);
	fixed4 lightMaskCol = fixed4(0.5,0.5,1,0);

	//是否使用 Mask图
	// #if USE_COMBINE_CHANNEL_ON
	// lightMaskCol = tex2D(_LightMask,i.uv);
	// #elif USE_SPLIT_CHANNEL_ON
	// lightMaskCol.r = tex2D(_LightMask_R,i.uv).r;
	// lightMaskCol.g = tex2D(_LightMask_G,i.uv).r;
	// lightMaskCol.b = tex2D(_LightMask_B,i.uv).r;
	// lightMaskCol.a = tex2D(_LightMask_A,i.uv).r;
	// #endif
	fixed4 finalColor = mainCol;
	//finalColor = SetEmmisveColor(i,lightMaskCol,finalColor);
	return mainCol;
}