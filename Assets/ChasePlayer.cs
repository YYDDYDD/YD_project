using UnityEngine;

public class ChasePlayer : MonoBehaviour
{
    public Transform player;             // プレイヤーの Transform を Inspector で指定
    public float speed = 3f;             // 追いかける速度
    public float stopDistance = 1.5f;    // プレイヤーに近づきすぎない距離
    public float chaseStartDistance = 5f; // 追いかけを開始する距離

    private bool isChasing = false;      // 追いかけ中かどうか

    void Update()
    {
        if(player == null)
            return;

        float distance = Vector3.Distance(transform.position, player.position);

        // 追いかけ開始条件をチェック
        if(!isChasing && distance <= chaseStartDistance)
        {
            isChasing = true;
        }

        // 追いかけ中のみ移動処理
        if(isChasing && distance > stopDistance)
        {
            Vector3 direction = (player.position - transform.position).normalized;
            transform.position += direction * speed * Time.deltaTime;
            transform.rotation = Quaternion.LookRotation(direction);
        }
    }
}
