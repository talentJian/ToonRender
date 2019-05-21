Shader "ZShader/Toon/ToonShaderV2"
{
	Properties
	{
		_MainTex ("主贴图", 2D) = "white" {}
		_FalloffTex("FalloffTex",2D) = "white" {}
		_specularPow("高光係數",Range(0.8,2)) = 0.5
		_specularStrenght("高光强度",Range(0,1)) = 1
		_specularColor("高光颜色",Color)=(1,1,1,1)
		[Enum(On,1,Off,0)]_isLerpToMain("高光叠主贴图",Float) = 1
		_MaskTex("Mask(R阴影)",2D) = "white" {}
		[Toggle(_isUseMaskTex)]_isUseMaskTex("是否使用Mask图",Float) = 1
		_ShadowLightArea("阴影区域(Area)",Range(0.2,0.85)) = 0.5
		_ShadowColor("阴影颜色",Color) = (0.5,0.5,0.5,1)
		_ShadowWidthSmooth("阴影平滑度",Range(0,0.2))=0
		_ShadowStreath("阴影强度",Range(0,1)) = 0.5

		//溶解
		_DisolveValue("溶解值",Float) = 0
		_DisolveTex("溶解图",2D) = "white"{}
		//OutLine部分使用
		_Outline_Width ("Outline_Width", Float ) = 1
        _MaxOutLine ("_MaxOutLine", Range(0,5) ) = 1
        _MinOutLine ("_MinOutLine", Range(0,2) ) = 0.5
        _Outline_Color ("Outline_Color", Color) = (0.5,0.5,0.5,1)

		//默認 One Zero 不透明
		_SrcBlend("SrcBlend",Float) = 1 
		_DstBlend("DstBlend",Float) = 0
		
		[Toggle]_IsAlphaMode("是否透明",Float) = 0 
		//透明度
		_MainAlpha("_MainAlpha",Range(0,1)) = 1
		_Outline_Alpha("描边透明度",Float) = 1

		[Enum(On,2,Off,0)]_CullMode("裁剪",Float) = 0

		//由C#传入控制的闪白
		_SecondRimColor("被击 外发光",Color) = (1,1,1,1)
		_SecondRimStrenth("被攻 外发光",Range(0,1.0)) = 0

		//流动
		_EmissiveTex ("Emissive (RGB)", 2D) = "white" {}
		_EmissiveColor("EmissiveColor",Color) = (1,0,0,1)
		_EmissiveOffsetX ("Emissive (RGB) Offset x", Float) = 0
		_EmissiveOffsetY ("Emissive (RGB) Offset Y", Float) = 0
		_EmissiveStrength ("Emissive Strength", Float) = 1

		//闪动
		_SinEmissiveColor("_SinEmissiveColor",Color) = (1,0,0,1)
		_SinEmissiveStrength("_SinEmissiveStrength",Float) = 6
		_SinEmissiveFrequent ("Emissive Frequent", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		Pass
		{
			Blend [_SrcBlend][_DstBlend]
			Cull [_CullMode]
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"
			#include "AutoLight.cginc"  
			#include "UnityCG.cginc"
			#include "ToonMainCG.cginc"
			#pragma shader_feature _IsUseShadowMask
			#pragma shader_feature _isUseMaskTex
			//描边是否叠加
			#pragma shader_feature _isOutlineMulMainCol

			//流动
			#pragma shader_feature _Emissve_Float_ON
			//闪动 / 不动
			#pragma shader_feature _Emissve_SIN_ON

			#pragma multi_compile _ _UseDissovle
			
			#pragma vertex ToonVert
			#pragma fragment Toonfrag
			ENDCG
		}

		///外轮廓
		Pass
		{
			Name "OUTLNIE"
			Blend [_SrcBlend][_DstBlend]
			Cull Front
			CGPROGRAM
			#pragma shader_feature _isOutlineMulMainCol
			#include "UnityCG.cginc"
			#include "ToonOutLineSE.cginc"
			
			#pragma vertex toonOutline_vert
			#pragma fragment toonOutline_frag
			ENDCG
		}
	}
	FallBack "Mobile/Diffuse"
	CustomEditor "ToonShaderSEGUI"
}
