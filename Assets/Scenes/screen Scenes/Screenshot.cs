using System;
using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// ゲーム画面をスクリーンショットとして撮影・保存するコンポーネント。
/// 空のGameObjectにアタッチし、Inspectorから各項目を設定してください。
/// </summary>
public class ScreenshotCapture : MonoBehaviour
{
    [Header("保存設定")]
    [Tooltip("Application.persistentDataPath 配下に作成するフォルダ名")]
    [SerializeField] private string folderName = "Screenshots";

    [Tooltip("解像度の倍率。1が実画面解像度、2なら縦横2倍で保存")]
    [SerializeField] private int superSize = 1;

    [Header("UI連携（任意）")]
    [Tooltip("押すと撮影される撮影ボタン")]
    [SerializeField] private Button captureButton;

    [Tooltip("撮影結果をその場でプレビュー表示したい場合に設定")]
    [SerializeField] private RawImage previewImage;

    [Header("撮影時に隠したいUI（任意）")]
    [Tooltip("撮影の瞬間だけ非表示にしたいCanvasやUIのGameObjectをここに入れる（複数可）")]
    [SerializeField] private GameObject[] uiToHideWhileCapturing;

    private string SaveDirectory => Path.Combine(Application.persistentDataPath, folderName);

    private void Awake()
    {
        if(!Directory.Exists(SaveDirectory))
        {
            Directory.CreateDirectory(SaveDirectory);
        }

        if(captureButton != null)
        {
            captureButton.onClick.AddListener(CaptureAndSave);
        }
    }

    /// <summary>
    /// 画面全体（UI含む）をそのままPNGとして保存する簡易版。
    /// ボタンのonClickに直接割り当て可能。
    /// UIを隠したい場合はこちらではなく CaptureAndSaveWithoutUI を使用。
    /// </summary>
    public void CaptureAndSave()
    {
        string fileName = $"screenshot_{DateTime.Now:yyyyMMdd_HHmmss}.png";
        string fullPath = Path.Combine(SaveDirectory, fileName);

        ScreenCapture.CaptureScreenshot(fullPath, superSize);
        Debug.Log($"[ScreenshotCapture] 保存しました: {fullPath}");
    }

    /// <summary>
    /// uiToHideWhileCapturing に登録したUIを一瞬だけ非表示にしてから撮影する版。
    /// ボタンのonClickにはこちらを割り当てる。
    /// </summary>
    public void CaptureAndSaveWithoutUI()
    {
        StartCoroutine(CaptureWithoutUIRoutine());
    }

    private IEnumerator CaptureWithoutUIRoutine()
    {
        // 1. 対象UIを非表示にする
        SetUIActive(false);

        // 2. UIが消えた状態の描画が反映されるまで1フレーム待つ
        yield return new WaitForEndOfFrame();

        // 3. Texture2Dとして撮影
        Texture2D screenTexture = ScreenCapture.CaptureScreenshotAsTexture();

        // 4. UIを元に戻す（撮影処理より先に戻してOK）
        SetUIActive(true);

        if(previewImage != null)
        {
            previewImage.texture = screenTexture;
        }

        // 5. PNGとして保存
        SaveTextureToPNG(screenTexture);

        // Texture2Dはプレビューに使わないなら解放してメモリを節約
        if(previewImage == null)
        {
            Destroy(screenTexture);
        }
    }

    private void SetUIActive(bool isActive)
    {
        if(uiToHideWhileCapturing == null)
            return;

        foreach(GameObject ui in uiToHideWhileCapturing)
        {
            if(ui != null)
            {
                ui.SetActive(isActive);
            }
        }
    }

    /// <summary>
    /// 撮影結果をTexture2Dとして受け取りたい場合に使用。
    /// プレビュー表示や、保存前の加工をしたいときに便利。
    /// 呼び出し例: StartCoroutine(CaptureToTexture(tex => { ... }));
    /// </summary>
    public IEnumerator CaptureToTexture(Action<Texture2D> onCaptured)
    {
        // UIの描画も含めて撮影するため、フレーム末尾まで待つ
        yield return new WaitForEndOfFrame();

        Texture2D screenTexture = ScreenCapture.CaptureScreenshotAsTexture();

        if(previewImage != null)
        {
            previewImage.texture = screenTexture;
        }

        onCaptured?.Invoke(screenTexture);
    }

    /// <summary>
    /// Texture2DをPNGファイルとして保存するユーティリティ。
    /// CaptureToTextureで取得した画像を、確認後に保存したい場合などに使う。
    /// </summary>
    public void SaveTextureToPNG(Texture2D texture, string fileName = null)
    {
        fileName ??= $"screenshot_{DateTime.Now:yyyyMMdd_HHmmss}.png";
        string fullPath = Path.Combine(SaveDirectory, fileName);

        byte[] pngData = texture.EncodeToPNG();
        File.WriteAllBytes(fullPath, pngData);

        Debug.Log($"[ScreenshotCapture] 保存しました: {fullPath}");
    }
}
