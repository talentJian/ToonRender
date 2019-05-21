///用于给阴影渲染的
Shader "Hidden/ZShader/Toon/ToonShaderV2_Shadow"
{
	Properties
	{
		_MainTex ("主贴图", 2D) = "white" {}
		
		[Enum(On,1,Off,0)]_isLerpToMain("高光叠主贴图",Float) = 1
		_MaskTex("Mask(R阴影)",2D) = "white" {}
		[Toggle(_isUseMaskTex)]_isUseMaskTex("是否使用Mask图",Float) = 1

		//溶解
		_DisolveValue("溶解值",Float) = 0
		_DisolveTex("溶解图",2D) = "white"{}
		//默認 One Zero 不透明
		_SrcBlend("SrcBlend",Float) = 1 
		_DstBlend("DstBlend",Float) = 0
		
		[Toggle]_IsAlphaMode("是否透明",Float) = 0 
		//透明度
		_MainAlpha("_MainAlpha",Range(0,1)) = 1
		_Outline_Alpha("描边透明度",Float) = 1

		[Enum(On,2,Off,0)]_CullMode("裁剪",Float) = 0
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
			
			#pragma multi_compile _ _UseDissovle
			#pragma vertex ToonVert
			#pragma fragment Toonfrag

			struct appData{
				float4 vertex :POSITION;
				float4 vertexColor :COLOR0;
				float2 uv :TEXCOORD0;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 vertexColor :TEXCOORD3;
				SHADOW_COORDS(8)
			};

			fixed _MainAlpha;
			
			//溶解
			float _DisolveValue;
			fixed _DisolveLineWidth;
			fixed4 _DisolveLineFirstColor;
			fixed4 _DisolveLineSecondColor;
			sampler2D _DisolveTex;

			//计算溶解
			//包含扭曲或者不扭曲的人物溶解
			fixed4 GetDissovleAlpha(v2f i,fixed4 finalColor)
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
			
			v2f ToonVert(appData v)
			{ 
				v2f o;
				o.uv = v.uv;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.vertexColor = v.vertexColor;
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 Toonfrag(v2f i):SV_Target
			{
				fixed Alpha = _MainAlpha * i.vertexColor.a;
				return GetDissovleAlpha(i,fixed4(0,0,0,Alpha));
			}
			ENDCG
		}
	}
}
