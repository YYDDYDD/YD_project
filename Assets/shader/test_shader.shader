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

            // �v���p�e�B
            sampler2D _MainTex;//���C���X�y�N�^�[�ŕ\�������e�N�X�`�����ꕨ
            float4 _MainTex_ST;//���C���X�y�N�^�[�ŕ\�������UV�X�N���[���o�[
            fixed4 _SecondaryColor;

            // ���_���͍\����
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // ���_���t���O�����g�\����
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            // ���_�V�F�[�_�[
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // �t���O�����g�V�F�[�_�[
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