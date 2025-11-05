using UnityEngine;

public class SticKTo : MonoBehaviour
{
    private bool isAttached = false;

    void Update()
    {
        // 回転はくっついた後も続ける
        transform.Rotate(new Vector3(15, 30, 45) * Time.deltaTime);

        // プレイヤーにくっついたら、位置を固定（オプション）
        if(isAttached && transform.parent != null)
        {
            transform.localPosition = new Vector3(0, 0, 1); // プレイヤーの頭上に固定する例
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.CompareTag("Player") && !isAttached)
        {
            // プレイヤーにくっつける
            transform.SetParent(other.transform);
            isAttached = true;



            // Rigidbodyがあるなら、物理挙動も止める
            if(TryGetComponent<Rigidbody>(out Rigidbody rb))
            {
                rb.isKinematic = true;
            }

            // スコア加算やサウンド再生もここでできるよ！
        }
    }
}
