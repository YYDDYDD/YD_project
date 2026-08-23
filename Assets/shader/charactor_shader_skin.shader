Shader "Custom/charactor_shader_skin" {
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

		// --- Lighting Control Texture (ライティングの影響度を調整) ---
		// R: ライトの減衰率調整   (0=通常通り減衰する / 1に近いほど減衰しない)
		// G: 自身に掛かる陰の調整 (0=通常通り陰が乗る / 1に近いほど陰が乗らない)
		// B: ステージ反射の調整   (0=通常通り反射が乗る / 1に近いほど反射の色が乗らない)
		_LightControlTex("Lighting Control Texture (R:Atten G:SelfShade B:Reflection)", 2D) = "black" {}
		_LightAttenInfluence("  R: Light Atten Influence", Range(0,1)) = 1.0
		_SelfShadeInfluence("  G: Self Shade Influence", Range(0,1)) = 1.0
		_ReflectionInfluence("  B: Reflection Influence", Range(0,1)) = 1.0

		// --- Toon Shadow (アニメ風に影の影響を受けにくくするパラメーター) ---
		[Toggle(_TOON_SHADING_ON)] _UseToonShading("Use Toon Shadow (Anime Style)", Float) = 0
		_ToonShadowThreshold("Toon Shadow Threshold", Range(0,1)) = 0.5
		_ToonShadowSoftness("Toon Shadow Edge Softness", Range(0.001,0.5)) = 0.05
		_ToonShadowStrength("Toon Shadow Strength (0=Realistic / 1=Flat Anime)", Range(0,1)) = 1.0
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
		#pragma shader_feature_local _TOON_SHADING_ON
		#pragma target 3.0

		#if defined(_ALPHATEST_ON)
			// Cutout: 深度バッファに書き込むためソート崩れが起きにくい
			#pragma surface surf CharacterSpecular fullforwardshadows alpha:test:_Cutoff
		#else
			// Alpha Blend: 滑らかな半透明表現が可能だが重なりに弱い
			#pragma surface surf CharacterSpecular fullforwardshadows alpha:fade
		#endif

		// UnityGI / UnityGlobalIllumination など、カスタムライティング関数に必要な定義を読み込む
		#include "UnityPBSLighting.cginc"

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _BumpMap2;
		sampler2D _MetallicTex;
		sampler2D _SpecularTex;
		sampler2D _EmissionTex;
		sampler2D _AOTex;
		sampler2D _LightControlTex;

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

		half _LightAttenInfluence;
		half _SelfShadeInfluence;
		half _ReflectionInfluence;

		half _ToonShadowThreshold;
		half _ToonShadowSoftness;
		half _ToonShadowStrength;

		struct Input {
			float2 uv_MainTex;
		};

		// SurfaceOutputStandardSpecular に、ライティング制御用のパラメーターを追加した独自の構造体
		struct SurfaceOutputCharacter {
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			fixed3 Specular;
			half Smoothness;
			half Occlusion;
			fixed Alpha;

			half LightAtten;         // R: ライト減衰の影響度   (0=通常 / 1=減衰なし)
			half SelfShade;          // G: 自己陰影の影響度     (0=通常 / 1=陰なし)
			half ReflectionSuppress; // B: 環境反射の影響度     (0=通常 / 1=反射なし)
		};

		// --- カスタムライティング関数 ---
		// Diffuse(拡散反射) / Specular(鏡面反射, Blinn-Phong近似) を自前で計算することで、
		// 以下の3点を独立してコントロールできるようにしている。
		//   ・ライトの減衰(atten)の影響
		//   ・自身のNdotLに起因する陰の影響
		//   ・環境(ステージ)の反射の影響
		// あわせて、トゥーン(アニメ風)の階調のない陰にも対応。
		// ※Unity標準のGGXベースSpecularそのものではなく簡易的なBlinn-Phong近似のため、
		//   ハイライトの見え方は元のStandardSpecularと完全には一致しない点に注意。
		inline half4 LightingCharacterSpecular(SurfaceOutputCharacter s, half3 viewDir, UnityGI gi)
		{
			half3 N = normalize(s.Normal);
			half3 V = normalize(viewDir);
			half3 L = gi.light.dir;

			// --- R: ライトの減衰率調整 ---
			// gi.light.color は "_LightColor0.rgb * atten(シャドウ・距離減衰)" が
			// 既に乗算された状態で渡ってくる。減衰前の色(_LightColor0.rgb)へ向けて
			// 補間することで、減衰(影を含む)の影響を弱める＝ライトが乗りやすくなる。
			half rAmount = saturate(s.LightAtten * _LightAttenInfluence);
			half3 lightColor = lerp(gi.light.color, _LightColor0.rgb, rAmount);

			// 幾何学的に正しいNdotL（裏面判定・スペキュラのマスク用。陰の調整の影響を受けない）
			half ndotlReal = saturate(dot(N, L));

			// --- G: 自身に掛けている陰(自己遮蔽)の調整 ---
			// 1に近づくほどNdotLが1(真正面から光を受けている状態)へ寄っていき、
			// 自身の形状による陰の落ち込みが目立たなくなる。
			half gAmount = saturate(s.SelfShade * _SelfShadeInfluence);
			half ndotlDiffuse = lerp(ndotlReal, 1.0, gAmount);

			// --- アニメ風トゥーンシャドウ（影の影響を受けにくくするパラメーター） ---
			#if defined(_TOON_SHADING_ON)
				half toonMask = smoothstep(_ToonShadowThreshold - _ToonShadowSoftness, _ToonShadowThreshold + _ToonShadowSoftness, ndotlDiffuse);
				ndotlDiffuse = lerp(ndotlDiffuse, toonMask, _ToonShadowStrength);
			#endif

			// --- 拡散反射 (Diffuse) ---
			half3 directDiffuse = s.Albedo * lightColor * ndotlDiffuse;
			half3 indirectDiffuse = s.Albedo * gi.indirect.diffuse * s.Occlusion;

			// --- 鏡面反射 (Specular / Blinn-Phong近似) ---
			half smoothness = saturate(s.Smoothness);
			half specPower = exp2(10.0 * smoothness + 1.0);
			half3 H = normalize(L + V);
			half ndoth = saturate(dot(N, H));
			half specNormalize = (specPower + 2.0) * 0.125; // エネルギー保存の簡易近似
			half3 directSpecular = s.Specular * lightColor * (pow(ndoth, specPower) * specNormalize) * ndotlReal;

			// --- B: ステージ(環境)反射の調整 ---
			half bAmount = saturate(s.ReflectionSuppress * _ReflectionInfluence);
			half3 indirectSpecular = s.Specular * gi.indirect.specular * (1.0 - bAmount);

			half3 color = directDiffuse + indirectDiffuse + directSpecular + indirectSpecular;

			half4 c;
			c.rgb = color;
			c.a = s.Alpha;
			return c;
		}

		inline void LightingCharacterSpecular_GI(
			SurfaceOutputCharacter s,
			UnityGIInput data,
			inout UnityGI gi)
		{
			gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
		}

		void surf(Input IN, inout SurfaceOutputCharacter o) {

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

			// --- Lighting Control (R:減衰 G:自己陰影 B:反射) ---
			fixed4 lightControl = tex2D(_LightControlTex, IN.uv_MainTex);
			o.LightAtten = lightControl.r;
			o.SelfShade = lightControl.g;
			o.ReflectionSuppress = lightControl.b;
		}
		ENDCG
	}

	FallBack "Standard"
}
