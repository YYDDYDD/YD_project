Shader "Unlit/MirrorShader"
{
    Properties
    {
        _ReflectionTex("Reflection Texture", 2D) = "black" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

sampler2D _ReflectionTex;
float4 _ReflectionTex_ST;

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 pos : SV_POSITION;
};

v2f vert(appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _ReflectionTex);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    float2 flippedUV = float2(i.uv.x, 1.0 - i.uv.y); // YŽ²”½“]
    return tex2D(_ReflectionTex, flippedUV);
}
ENDCG
        }
    }

    Fallback "Diffuse"
}