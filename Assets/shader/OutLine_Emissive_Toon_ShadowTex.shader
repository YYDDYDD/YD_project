Shader "Custom/OutLine_Emissive_Toon_ShadowTex"
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

		_RampTex("Shadow Ramp (Toon)", 2D) = "gray" {}
	_ShadowTex("Shadow Color Texture", 2D) = "black" {} // ★追加
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
	sampler2D _ShadowTex; // ★追加

	struct Input
	{
		float2 uv_MainTex;
		float2 uv_EmissionMap;
		float2 uv_ShadowTex; // ★追加
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	fixed4 _EmissionColor;
	float _EmissionStrength;

	void surf(Input IN, inout SurfaceOutput o)
	{
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		o.Alpha = c.a;

		fixed4 e = tex2D(_EmissionMap, IN.uv_EmissionMap) * _EmissionColor;
		o.Emission = e.rgb * _EmissionStrength;
	}

	// --- トゥーンライティング（影に別テクスチャ使用） ---
	inline fixed4 LightingToonRamp(SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
	{
		float NdotL = dot(s.Normal, lightDir);

		bool isShadow = NdotL < 0.3;

		fixed3 lightColor = _LightColor0.rgb * atten;
		fixed3 col;

		if (isShadow)
		{
			// 影領域 → ShadowTexの色を使用（UVは中央固定。必要なら IN.uv_ShadowTex に変更可）
			fixed3 shadowColor = tex2D(_ShadowTex, float2(0.5, 0.5)).rgb;
			col = s.Albedo * shadowColor;
		}
		else
		{
			// 通常領域 → Rampテクスチャ使用
			float rampUV = NdotL * 0.5 + 0.5;
			fixed3 ramp = tex2D(_RampTex, float2(rampUV, 0)).rgb;
			col = s.Albedo * lightColor * ramp;
		}

		return fixed4(col + s.Emission, s.Alpha);
	}

	ENDCG
	}

		FallBack "Diffuse"
}
