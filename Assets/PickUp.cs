using UnityEngine;

public class PickUp : MonoBehaviour
{
    void Update()
    {
        // オブジェクトを継続的に回転させる
        transform.Rotate(new Vector3(15, 30, 45) * Time.deltaTime);
    }

    void OnTriggerEnter(Collider other)
    {
        // Player または Mob タグを持つオブジェクトかどうかを確認
        if(other.CompareTag("Player") || other.CompareTag("Mob"))
        {
            // 対象がPlayerまたはMobだった場合、このPickupオブジェクトを破棄（収集）
            Destroy(gameObject);

            // スコア加算やサウンド再生などの追加処理をここに書けるよ
        }
    }
}
