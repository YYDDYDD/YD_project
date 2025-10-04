Shader "Custom/moon" {
	Properties{
		_MainTex("Texture",2D) = "white"{}          // テクスチャプロパティ追加
		_BaseColor("Base Color", Color) = (1,1,1,1) // カラープロパティ追加
		_Emission("Emission Texture", 2D) = "black" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0)
		_TintColor("Tint Color", Color) = (0, 0, 1, 1)
		_ScrollSpeed("Scroll Speed", Float) = 1.0

	}
		SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #pragma target 3.0

		 sampler2D _MainTex;
		 sampler2D _Emission;
		
		 float _ScrollSpeed;
		 fixed4 _BaseColor;
		 fixed4 _EmissionColor;
		 fixed4 _TintColor;

		 struct Input {
			 float2 uv_MainTex;
			 float2 uv_Emission;
		 };

		 void surf(Input IN, inout SurfaceOutputStandard o) {
			 float speed = 15;
			 float wave = sin(_Time.x * speed) * 0.5 + 0.5;

			 float2 scrollUV = IN.uv_MainTex;
			 scrollUV.x += _Time.x * _ScrollSpeed;

			 fixed4 texColor = tex2D(_MainTex, scrollUV) * _BaseColor;
			 fixed4 e = tex2D(_Emission, scrollUV) * _EmissionColor;

			 fixed3 tint = _TintColor.rgb * wave;
			 fixed3 tinted = texColor.rgb + tint;

			 o.Albedo = saturate(tinted);
			 o.Emission = e.rgb;


		 }

		ENDCG
		}

			Fallback "Standard"

}