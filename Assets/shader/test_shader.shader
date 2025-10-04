Shader "Unlit/test_shader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "gray" {}
        [Space]_FloatValue("Float", Float) = 0.5
        _IntValue("Int (as Float)", Float) = 1
        _RangedFloat("Float with Range", Range(0.5,1.0)) = 0.75
        _SecondaryColor("Secondary Color", Color) = (1,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            // プロパティ
            sampler2D _MainTex;//←インスペクターで表示されるテクスチャ入れ物
            float4 _MainTex_ST;//←インスペクターで表示されるUVスクロールバー
            fixed4 _SecondaryColor;

            // 頂点入力構造体
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // 頂点→フラグメント構造体
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            // 頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                return texColor * _SecondaryColor;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}