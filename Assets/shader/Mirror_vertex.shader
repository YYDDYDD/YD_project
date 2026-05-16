Shader "Unlit/Mirror_vertexShader"
{
    Properties
    {
        _ReflectionTex ("Reflection Texture", 2D) = "black" {}
        _WaveAmplitude ("Wave Amplitude", Float) = 0.05
        _WaveFrequency ("Wave Frequency", Float) = 10.0
        _WaveSpeed     ("Wave Speed",     Float) = 2.0
        _Alpha         ("Alpha",          Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

sampler2D _ReflectionTex;
float4    _ReflectionTex_ST;
float     _WaveAmplitude;
float     _WaveFrequency;
float     _WaveSpeed;
float     _Alpha;

struct appdata
{
    float4 vertex : POSITION;
    float2 uv     : TEXCOORD0;
    float3 normal : NORMAL;
};

struct v2f
{
    float2 uv  : TEXCOORD0;
    float4 pos : SV_POSITION;
};

v2f vert(appdata v)
{
    v2f o;

    float wave = sin(v.vertex.x * _WaveFrequency + _Time.y * _WaveSpeed)
               * sin(v.vertex.z * _WaveFrequency * 0.7 + _Time.y * _WaveSpeed * 1.3);
    v.vertex.xyz += v.normal * (wave * _WaveAmplitude);

    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv  = TRANSFORM_TEX(v.uv, _ReflectionTex);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    float2 flippedUV = float2(i.uv.x, 1.0 - i.uv.y);
    fixed4 col = tex2D(_ReflectionTex, flippedUV);
    col.a = _Alpha;
    return col;
}
ENDCG
        }
    }

    Fallback "Diffuse"
}