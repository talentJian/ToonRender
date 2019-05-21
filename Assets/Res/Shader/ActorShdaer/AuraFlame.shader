//气焰效果
Shader "ZShader/Effect/AuraFlame"
{
	Properties
	{
		_Color2("Aura Color",Color) = (1,1,1,1)
		_ColorR("Rim Color",Color) = (1,1,1,1)

		_DisolveTex("溶解圖",2D) = "white" {}

		_Outline("Outline width", Range(.002, 0.8)) = .3
		_OutlineZ("Outline Z", Range(-.06, 0)) = -.05
		_ScaleX("Noise Scale X", Range(0.0, 0.2)) = 0.01
		_ScaleY("Noise Scale y", Range(0.0, 0.2)) = 0.01
		_SpeedX("Speed X", Range(-10, 10)) = 0
		_SpeedY("Speed Y", Range(-10, 10)) = 3.0
		_Opacity("Noise Opacity", Range(0.01, 10.0)) = 10
		_Brightness("Brightness", Range(0.5, 3)) = 2
		_Edge("Rim Edge", Range(0.0, 1)) = 0.1
		_RimPower("Rim Power", Range(0.01, 10.0)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
		Pass{
			Cull Back
			ZWrite Off
        	ColorMask RGB
        	Blend SrcAlpha OneMinusSrcAlpha // Transparency Blending
			//Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			

			float _Outline;
			float _OutlineZ;
			sampler2D _DisolveTex;
			float _ScaleX,_ScaleY;
			float _SpeedX,_SpeedY;
			float _Opacity;
			float _Brightness;
			float _Edge;
			float _RimPower;

			float4 _ColorR,_Color2;

			struct VertexInput{
				float4 vertex :POSITION;
				float3 normal :NORMAL;
				float4 vertexColor :COLOR0;
				float2 uv :TEXCOORD0;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 dissovleuv :TEXCOORD1;
				float3 worldNormal : TEXCOORD4;
				float3 viewDir : TEXCOORD6;
				float4 clipPos:TEXCOORD7;
			};
			v2f vert(VertexInput v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//将法线方向转换到视空间  
				float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); 
				float2 offset =  TransformViewToProjection(vnormal.xy); 
				//o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal * _Outline,1));
				o.pos.xy += offset * _Outline * o.pos.z;
				o.pos.z += _OutlineZ;// push away from camera
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(WorldSpaceViewDir(v.vertex)); // view direction
				o.uv0 = v.uv;
				return o;
			}
			float4 frag(v2f i):SV_TARGET
			{
				//return 1;
				float2 uv = float2(i.pos.x * _ScaleX - (_Time.x * _SpeedX), i.pos.y  *_ScaleY - (_Time.x * _SpeedY)); // float2 based on speed, position and, scale

				float4 texDissovle = tex2D(_DisolveTex,uv);
				half NDotV = saturate(dot(i.viewDir, i.worldNormal));
				half4 iRim = pow(NDotV,_RimPower);
				iRim -= texDissovle;
				float4 tRim = saturate(iRim.r * _Opacity);
				float4 eRim = (saturate((_Edge + iRim.r) * _Opacity) - tRim) * _Brightness;
				float4 result = (_Color2 * tRim) +(_ColorR * eRim);

				return result;
			}
			ENDCG
		}
		
	
	}

	//Fallback "Legacy Shaders/Diffuse"
}
