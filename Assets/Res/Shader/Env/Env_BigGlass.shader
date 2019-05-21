//大块玻璃专用Shader,去除边缘光
Shader "ZShader/Env/Env_BigGlass"
{
	Properties
	{
		//_Alpha("alpha",Range(0,1)) = 0.5
		_MainTex ("Texture", 2D) = "white" {}
		_Shinness("高光",Float) = 0.5
		_ShinessColor("高光颜色",Color) = (1,1,1,1)
		_SpecularStrength("高光强度强度",Range(0,15)) = 1
		
		[Enum(On,1,Off,0)]_Cull("背面剔除",Float) = 1

		_Factor("距离倍数",Range(0.001,0.05)) = 0.01 
		[HideInInspector]_LightDir("灯光方向",Vector) = (0.5,0.5,0.5)
		[HideInInspector]_LightEular("灯光欧拉角",Vector) = (45,10,0,0) //保存欧拉角，在编辑器中转换为灯光方向
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"= "Transparent" "LightMode" = "ForwardBase"}
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull [_Cull]
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _IsUseCubeMap_ON
			// make fog work
			#pragma multi_compile_fog
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 viewDir :TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
				float3 worldPos :TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			#ifdef _IsUseCubeMap_ON
			samplerCUBE _CubeMap;
			fixed _CubeRoughness;
			#endif
			fixed _CubeMapScale;
			fixed _Alpha;
			fixed _Shinness;
			fixed _SpecularStrength;
			fixed3 _LightDir;
			fixed4 _ShinessColor;
			fixed _Factor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i , float facing : VFACE) : SV_Target
			{
				float faceSign = ( facing >= 0 ? 1 : -1 );  		//内弧的高光需要判定正反
				i.worldNormal = normalize(i.worldNormal) * faceSign;
				float dis = distance(_WorldSpaceCameraPos.xyz,i.worldPos);
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed4 col = tex2D(_MainTex, i.uv + dis *_Factor) ;

				fixed3 lightDir = _LightDir;
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = pow(max(0,dot(i.worldNormal,halfDir)),_Shinness)  * _SpecularStrength * _ShinessColor;
			
				//fixed4 cubeMapCol = 0;
				// #ifdef _IsUseCubeMap_ON
				// 	fixed3 relUv = reflect(-viewDir,i.worldNormal);
				// 	cubeMapCol = texCUBElod(_CubeMap,fixed4(relUv,_CubeRoughness));
				// 	fixed3 finalCol = col.rgb * (1-_CubeMapScale) + specular.rgb + cubeMapCol.rgb * _CubeMapScale;
				// #else
					fixed3 finalCol = col.rgb + specular.rgb;
				//#endif
					_Alpha = min(dis *_Factor,1);
				
				return fixed4(finalCol,_Alpha);
			}
			ENDCG
		}
	}

	CustomEditor "Env_BigGlassShaderGUI"
}
