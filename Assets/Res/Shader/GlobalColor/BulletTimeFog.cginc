
fixed4 _FogColor;
fixed _FogIntensity; //强度
fixed _BulletFogStep; //插值变换

fixed4 GetFogColor_Normal(fixed4 src)
{
	fixed4 resultCol = src;
	#ifndef _USE_BULLET_FOG_NONE
		resultCol.rgb *= _FogColor.rgb;
	#else
		resultCol = src;
	#endif
	return resultCol;
}

fixed _FogSmoothWidth;
//从外围距离向摄像机内缩
fixed _FogStartDis;
fixed4 GetFogColor_Cam(fixed4 src,float3 worldPos)
{
	fixed4 resultCol = src;
	#if _USE_BULLET_FOG_CAM
		float3 camPos = _WorldSpaceCameraPos.xyz;
		float dis_cam = distance(camPos,worldPos);
		float dis_value = smoothstep(0,_FogSmoothWidth,_FogStartDis-dis_cam);
		resultCol.rgb = (resultCol.rgb * _FogColor.rgb) * (1-dis_value) + src.rgb * dis_value;
	#else
		resultCol = src;
	#endif
	return resultCol;
}


//从某个点开始外围扩散
float3 _FogStartPoint;
fixed _isRevert;
fixed4 GetFogColor_Point(fixed4 src,float3 worldPos)
{
	fixed4 resultCol = src;
	//return fixed4(_FogStartPoint,1);
	#if _USE_BULLET_FOG_POINT
		float dis = distance(_FogStartPoint,worldPos);
		float dis_value = smoothstep(0,_FogSmoothWidth,_FogStartDis - dis);
		//if(_isrevert == 1) a = 1-disvalue
		float a = (1-dis_value) * step(_isRevert,0) + dis_value * step(0.1,_isRevert);
		float b = (dis_value) * step(_isRevert,0) + (1-dis_value) * step(0.1,_isRevert);
		
		//resultCol = (resultCol * _FogColor) * (dis_value) + src * (1-dis_value);
		resultCol.rgb = (resultCol.rgb * _FogColor.rgb) * a + src.rgb * b;
	#else
		resultCol = src;
	#endif
	return resultCol;
}


fixed4 GetFogColor(fixed4 src,float3 worldPos)
{
	fixed4 resultCol = src;
	
	#if _USE_BULLET_FOG_NORMAL
		resultCol = GetFogColor_Normal(src);
	#elif _USE_BULLET_FOG_CAM
		resultCol =  GetFogColor_Cam(src,worldPos);
	#elif _USE_BULLET_FOG_POINT
		resultCol = GetFogColor_Point(src,worldPos);
	#else
		resultCol = src;
	#endif
	return resultCol;
}