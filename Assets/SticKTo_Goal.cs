using UnityEngine;

public class SticKTo_Goal : MonoBehaviour
{
    private bool isAttached = false;
    private bool moveToGoal = false;

    public Transform goal;     // InspectorでGoalオブジェクトを指定
    public float moveSpeed = 3f;

    void Update()
    {
        // 常に回転

        // くっ付いた後にGoalへ移動開始
        if(moveToGoal && goal != null)
        {
            // 親を外して自分で動く
            transform.SetParent(null);

            // Goal方向へ移動
            Vector3 direction = (goal.position - transform.position).normalized;
            transform.position += direction * moveSpeed * Time.deltaTime;

            // Goalの方向を向く
            transform.rotation = Quaternion.LookRotation(direction);
        }
    }

    void OnTriggerEnter(Collider other)
    {
        // 何らかのオブジェクトにくっ付く（タグ指定なし）
        if(!isAttached)
        {
            transform.SetParent(other.transform);
            isAttached = true;

            // Rigidbodyがあるなら物理挙動を止める
            if(TryGetComponent<Rigidbody>(out Rigidbody rb))
            {
                rb.isKinematic = true;
            }

            // くっ付いたらGoalへ向かうフラグを立てる
            moveToGoal = true;
        }
    }
}