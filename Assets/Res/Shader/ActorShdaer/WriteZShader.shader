//专门用于写入深度的 Shader
Shader "Hidden/Common/WriteZShader"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent-100" }
		Pass
		{
			ColorMask 0
		}
	}
}
