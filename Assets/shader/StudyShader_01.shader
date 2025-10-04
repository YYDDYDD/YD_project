Shader "Unlit/StudyShader_Emissive" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
	    _BaseColor("Base Color", Color) = (1,1,1,1)
		_EmissionTex("Emission Texture", 2D) = "black" {}
    	_EmissionColor("Emission Color", Color) = (0,0,0,0)
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		Pass{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _BaseColor;

	sampler2D _EmissionTex;
	float4 _EmissionTex_ST;
	fixed4 _EmissionColor;

	struct appdata {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f {
		float2 uvMain : TEXCOORD0;
		float2 uvEmission : TEXCOORD1;
		float4 vertex : SV_POSITION;
	};

	v2f vert(appdata v) {
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
		o.uvEmission = TRANSFORM_TEX(v.uv, _EmissionTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target{
	fixed4 baseCol = tex2D(_MainTex, i.uvMain) * _BaseColor;
	fixed4 emission = tex2D(_EmissionTex, i.uvEmission) * _EmissionColor;
	return baseCol + emission;
	}
		ENDCG
	}
	}
}
