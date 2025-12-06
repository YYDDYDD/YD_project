using UnityEngine;

public class ChasePlayer : MonoBehaviour
{
    public Transform player;   // プレイヤーの Transform を Inspector で指定
    public float speed = 3f;   // 追いかける速度
    public float stopDistance = 1.5f; // プレイヤーに近づきすぎない距離

    void Update()
    {
        if(player == null)
            return;

        // プレイヤーとの距離を計算
        float distance = Vector3.Distance(transform.position, player.position);

        // 一定距離より遠ければ追いかける
        if(distance > stopDistance)
        {
            // プレイヤー方向のベクトル
            Vector3 direction = (player.position - transform.position).normalized;

            // 移動
            transform.position += direction * speed * Time.deltaTime;

            // プレイヤーの方向を向く
            transform.rotation = Quaternion.LookRotation(direction);
        }
    }
}