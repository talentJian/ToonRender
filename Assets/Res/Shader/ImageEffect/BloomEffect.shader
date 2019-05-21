Shader "Hidden/BloomEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	struct v2f_threshold{
		float4 pos :SV_POSITION;
		float2 uv :TEXCOORD0;
	};
	struct v2f_bloom
	{
		float4 pos :SV_POSITION;
		float2 uv :TEXCOORD0;
	};
	struct v2f_NBloom
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uvFlippedSPR : TEXCOORD3; // Single Pass Stereo flipped UVs
	};
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _MainTex_TexelSize;
	sampler2D _BlurText;
	float4 _BlurText_TexelSize;
	float _colorThreshold;
	float4 _bloomColor;
	float _bloomFactor;

	sampler2D _BloomTex;
	float4 _BloomTex_TexelSize;
	float2 _Bloom_Settings;

	float3 DecodeHDR(half4 rgba)
	{
	#if USE_RGBM
		return rgba.rgb * rgba.a * 8.0;
	#else
		return rgba.rgb;
	#endif
	}
	half3 UpsampleFilter(sampler2D tex, float2 uv, float2 texelSize, float sampleScale)
	{
		// 4-tap bilinear upsampler
		float4 d = texelSize.xyxy * float4(-1.0, -1.0, 1.0, 1.0) * (sampleScale * 0.5);

		half3 s;
		s =  DecodeHDR(tex2D(tex, uv + d.xy));
		s += DecodeHDR(tex2D(tex, uv + d.zy));
		s += DecodeHDR(tex2D(tex, uv + d.xw));
		s += DecodeHDR(tex2D(tex, uv + d.zw));
		return s * (1.0 / 4.0);
	}
	v2f_threshold vert_image(appdata_img v)
	{
		v2f_threshold o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		//dx中纹理从左上角为初始坐标，需要反向  
		#if UNITY_UV_STARTS_AT_TOP  
        if (_MainTex_TexelSize.y < 0)  
            o.uv.y = 1 - o.uv.y;  
		#endif    
        return o;
	}
	v2f_NBloom vert_NBloom(appdata_img v)
	{
		v2f_NBloom o;
		o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;
		#if UNITY_UV_STARTS_AT_TOP  
        if (_MainTex_TexelSize.y < 0)  
            o.uv.y = 1 - o.uv.y;  
		#endif    
		o.uvFlippedSPR = UnityStereoScreenSpaceUVAdjust(o.uv, _MainTex_ST);
		return o;
	}

	fixed4 frag_threshold(v2f_threshold i) :SV_TARGET
	{
		fixed4 color = tex2D(_MainTex,i.uv);
		//return 1;
		//return _colorThreshold;
		fixed luminance = Luminance(color)- _colorThreshold;
		fixed4 finalColor =  lerp(0,color,step(0,luminance));
		return finalColor;
	}
	
	fixed4 frag_bloom(v2f_bloom i):SV_TARGET
	{
		fixed4 ori = tex2D(_MainTex,i.uv);
		fixed4 blur = tex2D(_BlurText,i.uv);
		fixed4 final = ori + _bloomFactor * blur ;
		return final;
	}

	fixed4 frag_Add(v2f_NBloom i):SV_TARGET
	{
		fixed3 ori = tex2D(_MainTex,i.uv).rgb;
		ori  = GammaToLinearSpace(ori);
		half3 bloom = UpsampleFilter(_BloomTex, i.uvFlippedSPR, _BloomTex_TexelSize.xy, _Bloom_Settings.x) * _Bloom_Settings.y;
		fixed3 color = ori + bloom;
		color = saturate(color);
		color = LinearToGammaSpace(color);
		return fixed4(color,1);
	}

	ENDCG
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		//提取阈值
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_image
			#pragma fragment frag_threshold
			#include "UnityCG.cginc"
			ENDCG
		}
		//bloom 效果
		Pass
		{
			// Stencil{
			// 	Ref 1
			// 	Comp Equal
			// }
			CGPROGRAM
			#pragma vertex vert_image
			#pragma fragment frag_bloom
			ENDCG
		}
		//bloom 效果
		Pass
		{
			Stencil{
				Ref 2
				Comp Equal
			}
			CGPROGRAM
			#pragma vertex vert_NBloom
			#pragma fragment frag_Add
			ENDCG
		}
	}
}
