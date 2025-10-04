Shader "Custom/OutLine_Emissive_Toon"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", Range(0.0, 0.1)) = 0.02

		_EmissionMap("Emission Map", 2D) = "black" {}
	_EmissionColor("Emission Color", Color) = (1,1,1,1)
		_EmissionStrength("Emission Strength", Range(0,10)) = 1.0

		_RampTex("Shadow Ramp (Toon)", 2D) = "gray" {}   // ★ 追加
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		// ---------- アウトライン描画 ----------
		Pass
	{
		Name "Outline"
		Tags{ "LightMode" = "Always" }
		Cull Front
		ZWrite On
		ZTest LEqual

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		uniform float _OutlineWidth;
	uniform float4 _OutlineColor;

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
	};

	v2f vert(appdata v)
	{
		v2f o;
		float3 norm = normalize(v.normal);
		v.vertex.xyz += norm * _OutlineWidth;
		o.pos = UnityObjectToClipPos(v.vertex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		return _OutlineColor;
	}
		ENDCG
	}

		// ---------- 本体描画 ----------
		CGPROGRAM
#pragma surface surf ToonRamp fullforwardshadows
#pragma target 3.0

		sampler2D _MainTex;
	sampler2D _EmissionMap;
	sampler2D _RampTex;

	struct Input
	{
		float2 uv_MainTex;
		float2 uv_EmissionMap;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	fixed4 _EmissionColor;
	float _EmissionStrength;

	// --- 通常のSurface設定 ---
	void surf(Input IN, inout SurfaceOutput o)
	{
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		o.Alpha = c.a;

		// Emission
		fixed4 e = tex2D(_EmissionMap, IN.uv_EmissionMap) * _EmissionColor;
		o.Emission = e.rgb * _EmissionStrength;
	}

	// --- トゥーンライティング ---
	inline fixed4 LightingToonRamp(SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
	{
		// N・L のドット値を計算
		float NdotL = dot(s.Normal, lightDir) * 0.5 + 0.5;

		// Rampテクスチャで明暗判定
		fixed3 ramp = tex2D(_RampTex, float2(NdotL, 0)).rgb;

		fixed3 col = s.Albedo * _LightColor0.rgb * ramp * atten;

		return fixed4(col + s.Emission, s.Alpha);
	}

	ENDCG
	}
		FallBack "Diffuse"
}
