// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/Default"
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

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        _alphaClip("CutOff",Float) = 0.001
        _GrayLerp("GrayLerp",Range(0,1)) = 1

        [HideInInspector] _ISUI("_ISUI",Float) = 1
        // [HideInInspector][Enum(None,0,UNITY_UI_GRAY,1,UNITY_UI_PURECOLOR,5)] UI_ColorMode ("UI_ColorMode", Float) = 0
        // [HideInInspector] UNITY_UI_SOFTCLIP_RECT_4 ("UNITY_UI_SOFTCLIP_RECT_4", Float) = 0
        // [HideInInspector] UNITY_UI_CLIP_RECT ("UNITY_UI_CLIP_RECT", Float) = 0  
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
        //ZTest [unity_GUIZTestMode]
		ZTest Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            //ClipRect 和 SoftClipRect 必须分开是因为Unity底层 CanvasRender SetClipRect 会自动启用
            #pragma multi_compile __ UNITY_UI_CLIP_RECT 
            #pragma multi_compile __ UNITY_UI_SOFTCLIP_RECT_4
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #pragma multi_compile __ UNITY_UI_GRAY UNITY_UI_PURECOLOR

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            fixed _alphaClip;
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = v.texcoord;

                OUT.color = v.color * _Color;
                return OUT;
            }

            // softness为1除以需要软化边的像素宽度/高度，所以不可能为0，为0时变为1
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

            #if UNITY_UI_SOFTCLIP_RECT_2
            half2 _Softness;
            #endif 
            #if UNITY_UI_SOFTCLIP_RECT_4
            half4 _Softness;
            #endif
            
            fixed4 frag(v2f IN) : SV_Target
            {
                
                
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) ;
                color.a *= IN.color.a;
                #ifdef UNITY_UI_CLIP_RECT
                     
                    #if UNITY_UI_SOFTCLIP_RECT_4
                    color.a *= UnityGet2DClipping_Soft4(IN.worldPosition.xy, _ClipRect,_Softness);
                    #else
                    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);       
                    
                    #endif
                #endif
                
                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - _alphaClip);
                #endif
                
                #ifdef UNITY_UI_GRAY //灰度
			    half3 grayColor = Luminance(color.rgb).rrr * IN.color.rgb;       
				color.rgb = lerp(color.rgb * IN.color.rgb,grayColor,_GrayLerp);
                #elif UNITY_UI_PURECOLOR //纯色
                color.rgb = IN.color.rgb;
                #else
                color.rgb *= IN.color.rgb;
				#endif
                
                return color;
            }
        ENDCG
        }
    }
}
