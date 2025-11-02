using UnityEngine;
using TMPro;

public class ScoreManager : MonoBehaviour
{
    // スコアを表示するTextMeshPro
    private TextMeshProUGUI scoreText;

    // ゲームクリアを表示するTextMeshPro
    public TextMeshProUGUI gameClearText;

    // 初期のアイテム数
    private int initialItemCount;

    // 現在のアイテム数
    private int currentItemCount;

    // スコア
    private int score = 0;

    // 経過時間
    private float elapsedTime = 0f;

    // ゲームが終了したかどうか
    private bool isGameFinished = false;

    void Start()
    {
        // スコアを表示するTextMeshProコンポーネントを取得
        scoreText = GetComponent<TextMeshProUGUI>();

        // 'Item'タグの付いたオブジェクトの初期数を数える
        initialItemCount = GameObject.FindGameObjectsWithTag("Item").Length;
        currentItemCount = initialItemCount;

        // ゲームクリアテキストを非表示にする
        gameClearText.gameObject.SetActive(false);

        // 初期スコアを表示
        UpdateScoreDisplay();
    }

    void Update()
    {
        if(!isGameFinished)
        {
            // 経過時間を更新
            elapsedTime += Time.deltaTime;

            // 現在のアイテム数を数える
            int newItemCount = GameObject.FindGameObjectsWithTag("Item").Length;

            // アイテムが減っていたらスコアを増やす
            if(newItemCount < currentItemCount)
            {
                score += currentItemCount - newItemCount;
                currentItemCount = newItemCount;
            }

            // スコア表示を更新
            UpdateScoreDisplay();

            // すべてのアイテムが回収されたらゲーム終了
            if(currentItemCount == 0)
            {
                isGameFinished = true;
                gameClearText.gameObject.SetActive(true);
            }
        }
    }

    void UpdateScoreDisplay()
    {
        // スコアと時間を別々の行に表示
        scoreText.text = $"Score: {score}\nTime: {elapsedTime:000.00}";
    }
}