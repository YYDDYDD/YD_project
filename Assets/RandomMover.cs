using UnityEngine;

public class RandomMover : MonoBehaviour
{
    public float speed = 3f;          // 移動速度
    public float changeInterval = 2f; // 方向を変える間隔（秒）

    private Vector3 direction;        // 現在の移動方向
    private float timer;              // 経過時間

    void Start()
    {
        // 初期のランダム方向を決定
        SetRandomDirection();
    }

    void Update()
    {
        // 一定時間ごとに方向を変える
        timer += Time.deltaTime;
        if(timer >= changeInterval)
        {
            SetRandomDirection();
            timer = 0f;
        }

        // 移動処理（XZ平面のみ）
        transform.Translate(direction * speed * Time.deltaTime, Space.World);
    }

    void SetRandomDirection()
    {
        // XZ平面上のランダムな方向ベクトル
        float x = Random.Range(-1f, 1f);
        float z = Random.Range(-1f, 1f);
        direction = new Vector3(x, 0f, z).normalized;
    }
}