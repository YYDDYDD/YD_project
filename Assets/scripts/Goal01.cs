using UnityEngine;

public class Goal01 : MonoBehaviour
{
    void OnTriggerEnter(Collider other)
    {
        // Goalタグのオブジェクトに触れたら
        if(other.gameObject.CompareTag("Goal"))
        {
            // 自分がプレイヤーにくっついているか確認
            if(transform.parent != null && transform.parent.CompareTag("Player"))
            {
                Destroy(gameObject);
            }
        }
    }


}