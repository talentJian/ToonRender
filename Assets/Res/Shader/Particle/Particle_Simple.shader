Shader "ZShader/Particles/Particle_Simple"
{
	Properties
	{
		[HDR] _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Texture", 2D) = "white" {}
		[Toggle]_IsGrey("灰色图",Float) = 0

		[Toggle(IS_USE_MASK)] _IS_USE_Mask("使用Mask图",Float) = 0
		_MaskTex ("Mask ( R Channel )", 2D) = "black" {}

		[Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc("BlendSrc",Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst",Float) = 6
		[Enum(LessEqual,4,Always,8)]_ZTestMode("ZTestMode",Float) = 4
		
		[Toggle(IS_USE_Fog)] _IS_USE_Fog("使用自带雾效?",Float) = 0
		[Enum(On,1,Off,0)]_CullMode("剔除模式",Float) = 0

		// _StencilComp ("Stencil Comparison", Float) = 8
        // _Stencil ("Stencil ID", Float) = 0
        // _StencilOp ("Stencil Operation", Float) = 0
        // _StencilWriteMask ("Stencil Write Mask", Float) = 255
        // _StencilReadMask ("Stencil Read Mask", Float) = 255
		// _ColorMask ("Color Mask", Float) = 15
		_IsUseClipRect("IsUseClip",Float) = 0
		_ClipRect("clipRect",Vector) = (0,0,0,0)
		_CanvasAlpha("CanvasGroupAlpha",Float) = 1
		_AlphaLerp("AlphaLerp",Range(0,1)) = 1  // 0的时候顶点通道的Alpha 不用于透明，只用于溶解
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		

		Pass
		{
			//  Stencil
			// {
			// 	Ref 1
			// 	Comp Equal
			// 	Pass [_StencilOp]
			// 	ReadMask [_StencilReadMask]
			// 	WriteMask [_StencilWriteMask]
			// }
			Blend [_BlendSrc][_BlendDst]
			Cull [_CullMode] Lighting Off ZWrite Off ZTest [_ZTestMode]
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#pragma shader_feature IS_USE_Fog
			#pragma shader_feature IS_USE_MASK

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color:COLOR;

			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				#if IS_USE_Fog
				UNITY_FOG_COORDS(1)
				#endif
				float4 vertex : SV_POSITION;
				fixed4 color :TEXCOORD2;
				fixed4 worldPos :TEXCOORD3;

			};

			//用于在2D界面的时候，被ClipRect 裁剪 
			inline float UnityGet2DClipping (in float2 position, in float4 clipRect)
			{
				float2 inside = step(clipRect.xy, position.xy) * step(position.xy, clipRect.zw);
				return inside.x * inside.y;
			}

			sampler2D _MainTex;
			fixed4 _MainTex_ST;

			sampler2D _MaskTex;
			fixed4 _MaskTex_ST;
			
			fixed4 _TintColor;
			fixed _IsGrey;

			float4 _ClipRect;
			float _IsUseClipRect;
			float _CanvasAlpha;

			fixed _AlphaLerp;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);
				o.color = v.color;
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				#if IS_USE_Fog
				UNITY_TRANSFER_FOG(o,o.vertex);
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed4 greyCol =  Luminance(col); 
				col.rgb = lerp(col,greyCol,_IsGrey);

				// fixed4 finalcol = 2 * i.color * _TintColor * col;
				fixed4 finalcol = 2 * _TintColor * col * fixed4(i.color.rgb,1);
				
				//#if IS_USE_MASK
				float4 maskcol = tex2D(_MaskTex,i.uv.zw);
				fixed dissovle = step(0,i.color.a-maskcol.r - 0.0001);
				finalcol.a = lerp(0,lerp(finalcol.a,i.color.a * finalcol.a,_AlphaLerp),dissovle);
				//#endif				
				

				#if IS_USE_Fog
				UNITY_APPLY_FOG(i.fogCoord, finalcol);
				#endif 
				//是否使用ClipRect 裁剪区域，目前只支持2D裁剪区域
				finalcol.a = lerp(finalcol.a,finalcol.a * UnityGet2DClipping(i.worldPos,_ClipRect)*_CanvasAlpha, step(1,_IsUseClipRect));
				return finalcol;
			}
			ENDCG
		}
	}
	CustomEditor "ParticleShaderGUI"
}
