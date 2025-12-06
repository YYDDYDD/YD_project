using UnityEngine;

public class ChasePlayer_go : MonoBehaviour
{
    public Transform player;   // プレイヤーの Transform を Inspector で指定
    public float speed = 3f;   // 追いかける速度
    public float stopDistance = 1.5f; // プレイヤーに近づきすぎない距離
    public float forwardOffset = 2f;  // プレイヤーの前方どれくらい先を目指すか

    void Update()
    {
        if(player == null)
            return;

        // プレイヤーの前方ターゲット位置を計算
        Vector3 targetPosition = player.position + player.forward * forwardOffset;

        // ターゲットとの距離を計算
        float distance = Vector3.Distance(transform.position, targetPosition);

        // 一定距離より遠ければ追いかける
        if(distance > stopDistance)
        {
            // ターゲット方向のベクトル
            Vector3 direction = (targetPosition - transform.position).normalized;

            // 移動
            transform.position += direction * speed * Time.deltaTime;

            // ターゲットの方向を向く
            transform.rotation = Quaternion.LookRotation(direction);
        }
    }
}