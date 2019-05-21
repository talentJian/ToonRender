Shader "ZShader/Toon/Toon_SceneObj"
{
	Properties
	{
		_MainColor("MainColor",Color) = (1,1,1,1)
		_MainTex ("主要贴图 (RGB)", 2D) = "white" {}
		_ShadowTex("阴影贴图 (RGB)",2D) = "white" {}
		_ShadowColor("阴影颜色",Color) = (1,1,1,1)

		_LightArea("阴影影响区域",Range(0,1)) = 0.6
		_ShadowWidthSmooth("阴影平滑距",Range(0,0.1)) = 0.05

		//[Toggle(USE_LIGHTMASK_ON)] _USE_LIGHTMASK_ON("使用Mask贴图",Float) = 0
		_LightMask("Mask贴图 (RGBA)",2D) = "red" {}

		_LightMask_R("Mask贴图 (R)",2D) = "white" {}
		_LightMask_G("Mask贴图 (G)",2D) = "gray" {}
		_LightMask_B("Mask贴图 (B)",2D) = "white" {}
		_LightMask_A("Mask贴图 (A)",2D) = "black" {}

		_SpecularColor("高光颜色",Color) = (1,1,1,1)
		_Gloss("高光Gloss",Range(0.001,5)) = 1
		_ShinnessMulti("高光强度",Range(0,5)) = 1

		_HairMatCapTex("头发扰动",2D) = "black"{}
		_TweakUv("扭动UV",Range(-0.5,0.5)) = 0
		_NormalMapForMatCap(" _NormalMapForMatCap",2D) = "bump" {}
		_MatcapColor("MatCap颜色",Color) = (0.5,0.5,0.5)

		//[Toggle(NORMAL_MAP_ON)] _UseNormalMap("使用法线贴图?",Float) = 0

		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Normal Scale",Float) = 1
		
		//[Toggle(USE_RIM_LIGHT_ON)] USE_RIM_LIGHT_ON("使用边缘光?",Float) = 0
		_RimColor("外发光_颜色",Color) = (0,0,0.5,1)
		_RimPower("外发光_边缘",Range(0.001,3)) = 0.5 
		_RimStrength("外发光_强度",Float) = 0.5

		//由C#传入控制的闪白
		_SecondRimColor("被击 外发光",Color) = (1,1,1,1)
		_SecondRimStrenth("被攻 外发光",Range(0,1.0)) = 0

		//OutLine部分使用
		_Outline_Width ("Outline_Width", Float ) = 1
        _Farthest_Distance ("Farthest_Distance", Float ) = 10
        _Nearest_Distance ("Nearest_Distance", Float ) = 0.5
        _Outline_Color ("Outline_Color", Color) = (0.5,0.5,0.5,1)

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
		_Alpha("透明度",Float)=1
		//==============================保存给编辑器用，不用作功能=================================
		_LightDir("灯光方向",Vector) = (0.5,0.5,0.5)
		_LightEular("灯光欧拉角",Vector) = (45,10,0,0) //保存欧拉角，在编辑器中转换为灯光方向
		//======================================================================================
	}
	SubShader
	{
		LOD 200
		Tags { "RenderType"="Opaque"}
		Pass{
			Name "OUTLNIE"
			Cull Front
			CGPROGRAM
			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "ToonOutline.cginc"
			ENDCG
		}
		
		Pass
		{
			Tags{ "LightMode" = "ForwardBase"}

        	
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma shader_feature NORMAL_MAP_ON
			#pragma shader_feature USE_LIGHTMASK_OFF USE_COMBINE_CHANNEL_ON USE_SPLIT_CHANNEL_ON 
			//只使用Mat高光，同时使用Mat高光和正常
			#pragma shader_feature USE_SPECULAR_ON
			#pragma shader_feature USE_RIM_LIGHT_ON
			//流动
			#pragma shader_feature _Emissve_Float_ON
			//闪动 / 不动
			#pragma shader_feature _Emissve_SIN_ON
			#pragma shader_feature _USE_FIX_LIGHTDIR
			#include "Toon_SceneObj.cginc"
			ENDCG
		}
	
	}

	SubShader
	{
		//特定100 是因为 专门为反射而设置的
		//去掉NormalMap, 去掉高光，去掉边缘光
		LOD 100
		Tags { "RenderType"="Opaque"}	
		Pass
		{
			Tags{ "LightMode" = "ForwardBase"}
			
        	
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex veryLowVert
			#pragma fragment veryLowfrag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma shader_feature USE_LIGHTMASK_OFF USE_COMBINE_CHANNEL_ON USE_SPLIT_CHANNEL_ON 
			//流动
			#pragma shader_feature _Emissve_Float_ON
			//闪动 / 不动
			#pragma shader_feature _Emissve_SIN_ON
			#pragma shader_feature _USE_FIX_LIGHTDIR
			#include "Toon_SceneObj.cginc"
			ENDCG
		}
	
	}
	Fallback "Legacy Shaders/Diffuse"
	CustomEditor "ToonEnvSceneShaderGUI"
}
