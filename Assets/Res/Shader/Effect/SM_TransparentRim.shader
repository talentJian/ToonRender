Shader "ZShader/Ghost/TransparentRim" {
Properties {


_RimColor ("Rim Color", Color) = (0.5,0.5,0.5,0.5)
_InnerColor ("Inner Color", Color) = (0.5,0.5,0.5,0.5)
_InnerColorPower ("Inner Color Power", Range(0.0,1.0)) = 0.5
_RimPower ("Rim Power", Range(0.0,5.0)) = 2.5
_AlphaPower ("Alpha Rim Power", Range(0.0,8.0)) = 4.0
_AllPower ("All Power", Range(0.0, 10.0)) = 1.0
[HideInInspector]_Opacity("_Opacity",Range(0,1)) = 1

}
SubShader {
Tags { "Queue" = "Transparent" }

CGPROGRAM
#pragma surface surf Lambert alpha nofog
struct Input {
float3 viewDir;
INTERNAL_DATA
};
fixed4 _RimColor;
fixed _RimPower;
fixed _AlphaPower;
fixed _AlphaMin;
fixed _InnerColorPower;
fixed _AllPower;
fixed4 _InnerColor;
fixed _Opacity;
void surf (Input IN, inout SurfaceOutput o) {
half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
o.Emission = _RimColor.rgb * pow (rim, _RimPower)*_AllPower + (_InnerColor.rgb*2*_InnerColorPower);
o.Alpha = (pow (rim, _AlphaPower))*_AllPower * _Opacity;
}
ENDCG
}
Fallback "VertexLit"
} 