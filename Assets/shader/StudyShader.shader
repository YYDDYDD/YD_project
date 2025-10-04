Shader "Unlit/StudyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)// カラープロパティ追加
    }
   SubShader
{
    Tags { "RenderType" = "Opaque" }
    LOD 100

            Pass
        {
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #include "UnityCG.cginc"

         sampler2D _MainTex;// テクスチャサンプラ
         float4 _MainTex_ST;// Tiling/Offset 情報
         fixed4 _BaseColor;// Inspector から設定される色


            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };


            struct v2f
           {
             float2 uv : TEXCOORD0;
             float4 vertex : SV_POSITION;
           };



            v2f vert (appdata v )	
            {	
           	v2f o;
	        o.vertex = UnityObjectToClipPos(v.vertex);
	        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	        return o;
            }	

            fixed4 frag(v2f i) : SV_Target {
            fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
            return col;
            


            }
            ENDCG
        }
    }
}


