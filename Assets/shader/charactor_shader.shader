Shader "Custom/charactor_shader" {
Properties{
		// --- Albedo ---
		_MainTex("Albedo Texture", 2D) = "white" {}
		_Color("Albedo Color", Color) = (1,1,1,1)

		// --- Normal ---
		_BumpMap("Normal Texture", 2D) = "bump" {}
		_BumpScale("Normal Strength", Range(0,2)) = 1.0

		// --- Normal (2枚目 / ブレンド用) ---
		_BumpMap2("Normal Texture 2", 2D) = "bump" {}
		_BumpScale2("Normal Strength 2", Range(0,2)) = 1.0
		_NormalBlend("Normal Blend (2nd map influence)", Range(0,1)) = 0.5

		// --- Metallic ---
		_MetallicTex("Metallic Texture", 2D) = "white" {}
		_Metallic("Metallic Intensity", Range(0,1)) = 1.0

		// --- Specular ---
		_SpecularTex("Specular Texture", 2D) = "white" {}
		_SpecularIntensity("Specular Intensity", Range(0,1)) = 1.0

		// --- Smoothness ---
		_Glossiness("Smoothness", Range(0,1)) = 0.5

		// --- Alpha (AlbedoのAlphaチャンネルを使用) ---
		_AlphaIntensity("Alpha Strength (from Albedo Alpha)", Range(0,1)) = 1.0

		// --- Alpha Mode 切り替え ---
		[Toggle(_ALPHATEST_ON)] _UseCutout("Use Cutout (OFF = Alpha Blend)", Float) = 0
		_Cutoff("Cutout Alpha Threshold", Range(0,1)) = 0.5

		// --- Emission ---
		_EmissionTex("Emission Texture", 2D) = "black" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_EmissionIntensity("Emission Intensity", Range(0,5)) = 1.0

		// --- Ambient Occlusion ---
		_AOTex("AO Texture", 2D) = "white" {}
		_AOIntensity("AO Intensity", Range(0,1)) = 1.0
	}

	SubShader{
		// ※実際のレンダーキュー番号はマテリアルのInspector下部
		//   「Advanced Options > Render Queue」からいつでも上書き変更可能。
		//   Cutoutモード使用時は "AlphaTest"(2450) にしておくと
		//   不透明オブジェクトとのソートがより正確になります。
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 300

		CGPROGRAM
		#pragma shader_feature_local _ALPHATEST_ON
		#pragma target 3.0

		#if defined(_ALPHATEST_ON)
			// Cutout: 深度バッファに書き込むためソート崩れが起きにくい
			#pragma surface surf StandardSpecular fullforwardshadows alpha:test:_Cutoff
		#else
			// Alpha Blend: 滑らかな半透明表現が可能だが重なりに弱い
			#pragma surface surf StandardSpecular fullforwardshadows alpha:fade
		#endif

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _BumpMap2;
		sampler2D _MetallicTex;
		sampler2D _SpecularTex;
		sampler2D _EmissionTex;
		sampler2D _AOTex;

		fixed4 _Color;
		half _BumpScale;
		half _BumpScale2;
		half _NormalBlend;
		half _Metallic;
		half _SpecularIntensity;
		half _Glossiness;
		half _AlphaIntensity;
		fixed4 _EmissionColor;
		half _EmissionIntensity;
		half _AOIntensity;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandardSpecular o) {

			// --- Albedo & Alpha ---
			fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = albedo.rgb;
			o.Alpha = albedo.a * _AlphaIntensity;

			// --- Normal (Whiteout Blendで2枚を合成) ---
			half3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			normal1.xy *= _BumpScale;

			half3 normal2 = UnpackNormal(tex2D(_BumpMap2, IN.uv_MainTex));
			normal2.xy *= _BumpScale2 * _NormalBlend;
			normal2.z = lerp(1.0, normal2.z, _NormalBlend);

			half3 blendedNormal = half3(normal1.xy + normal2.xy, normal1.z * normal2.z);
			o.Normal = normalize(blendedNormal);

			// --- Metallic（誘電体反射率とAlbedoをブレンドしてSpecularのベースにする） ---
			half metallicValue = tex2D(_MetallicTex, IN.uv_MainTex).r * _Metallic;
			fixed3 dielectricSpec = fixed3(0.04, 0.04, 0.04);
			fixed3 baseSpecular = lerp(dielectricSpec, albedo.rgb, metallicValue);

			// --- Specular（Metallicベースの反射色に、Specularテクスチャと強度を掛け合わせる） ---
			half specularTexValue = tex2D(_SpecularTex, IN.uv_MainTex).r;
			o.Specular = baseSpecular * specularTexValue * _SpecularIntensity;

			o.Smoothness = _Glossiness;

			// --- Emission ---
			fixed4 emissionTex = tex2D(_EmissionTex, IN.uv_MainTex);
			o.Emission = emissionTex.rgb * _EmissionColor.rgb * _EmissionIntensity;

			// --- Ambient Occlusion ---
			half aoValue = tex2D(_AOTex, IN.uv_MainTex).r;
			o.Occlusion = lerp(1.0, aoValue, _AOIntensity);
		}
		ENDCG
	}

	FallBack "Standard"
}
