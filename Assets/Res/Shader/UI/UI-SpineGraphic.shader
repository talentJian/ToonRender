Shader "ZShader/UI/UI-SpineGraphic"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		_ColorMask ("Color Mask", Float) = 15


		_GrayLerp("GrayLerp",Range(0,1)) = 1


		[HideInInspector] _ISUI("_ISUI",Float) = 1
		// _WorldClipRect("_WorldClipRect",Vector) = (0,0,0,0)
		// _IsUseClipRect("IsUseClip",Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			#pragma multi_compile __ UNITY_UI_GRAY
			#pragma multi_compile __ UNITY_UI_CLIP_RECT 
            #pragma multi_compile __ UNITY_UI_SOFTCLIP_RECT_4

			struct VertexInput {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			#if UNITY_UI_SOFTCLIP_RECT_2
            half2 _Softness;
            #endif 
            #if UNITY_UI_SOFTCLIP_RECT_4
            half4 _Softness;
            #endif

			VertexOutput vert (VertexInput IN) {
				VertexOutput OUT;

				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord = IN.texcoord;
				//OUT.worldPosition = mul(unity_ObjectToWorld,IN.vertex);
				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1);
				#endif

				OUT.color = IN.color * float4(_Color.rgb * _Color.a, _Color.a); // Combine a PMA version of _Color with vertexColor.
				return OUT;
			}

			inline half UnityGet2DClipping_Soft4(in float2 position, in float4 clipRect, in half4 softness)
			{
				softness = (softness == 0) ? 1 : softness;

				half4 inside;
				inside.xy = step(clipRect.xy, position.xy);
				inside.zw = step(position.xy, clipRect.zw);

				half4 alpha;
				alpha.xy = (position.xy - clipRect.xy) * softness.xw;
				alpha.zw = (clipRect.zw - position.xy) * softness.zy;
				inside = inside * saturate(alpha);

				return inside.x * inside.y * inside.z * inside.w;
			}
			
			inline half UnityGet2DClipping_Soft2(in float2 position, in float4 clipRect, in half2 softness)
			{
				softness = (softness == 0) ? 1 : softness;

				half2 inside = step(clipRect.xy, position.xy) * step(position.xy, clipRect.zw);
                //可以理解为 dis = x - min ,dis * softneww (这个已经在C#端除了，所以是线性递减)
				inside = inside * saturate(min(clipRect.zw - position.xy, position.xy - clipRect.xy) * softness);

				return inside.x * inside.y;
			}
			sampler2D _MainTex;
			float _GrayLerp;
			fixed4 frag (VertexOutput IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) ;
				//return _TextureSampleAdd;
				color.a *= IN.color.a;
				#ifdef UNITY_UI_CLIP_RECT
                     
                    #if UNITY_UI_SOFTCLIP_RECT_4
                    color.a *= UnityGet2DClipping_Soft4(IN.worldPosition.xy, _ClipRect,_Softness);
                    #else
                    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);             
                    #endif
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif
				color = color.a * color;//支持BlendOne 情況下的透明

				#ifdef UNITY_UI_GRAY
				half3 grayColor = Luminance(color.rbg).rrr * IN.color.rgb;
				color.rgb = lerp(color.rgb * IN.color.rgb,grayColor,_GrayLerp);
				#else
				color.rgb *= IN.color.rgb;
				#endif

				//color.a = lerp(color.a,color.a * UnityGet2DClipping(IN.worldPosition,_WorldClipRect), step(1,_IsUseClipRect));
				return color;
			}
		ENDCG
		}
	}
}
