shader "Unlit/Lesson6"		
{					
	Properties				
	{				
		_MainTex("Texture",2D) = "white"{}			
	     _Alpha("Alpha",Range(0,1)) = 1	
		 [Toggle] _ZWrite ("ZWrite", Float)=0
		}			
SubShader
{
    Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
    Blend SrcAlpha OneMinusSrcAlpha
        ZWrite [_ZWrite]
    LOD 100					
		Pass			
		{			
			CGPROGRAM		
#pragma vertex vert					
#pragma fragment frag					
#pragma multi_compile_fog					
#include "UnityCG.cginc"					
			struct appdata		
	{				
		float4 vertex : POSITION;			
		float2 uv : TEXCOORD0;			
	};				
	struct v2f				
	{				
		float2 uv : TEXCOORD0;			
		float4 vertex : SV_POSITION;			
		UNITY_FOG_COORDS(1)			
	};				
					
	sampler2D _MainTex;				
	float4 _MainTex_ST;				
					
	half _Alpha;				
					
		v2f vert(appdata v)			
	{				
		v2f o;			
		o.vertex = UnityObjectToClipPos(v.vertex);			
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);			
		return o;			
	}				
	fixed4 frag(v2f i) : SV_Target				
	{				
		half4 col = tex2D(_MainTex, i.uv);			
		col.a *= _Alpha; // アルファは見た目だけに使う			
			UNITY_APPLY_FOG(i.fogCoord, col);		
		return col;			
	}				
		ENDCG			
		}			
		}			
		FallBack "Diffuse"			
}					
