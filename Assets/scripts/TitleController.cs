using UnityEngine;
using UnityEngine.SceneManagement;

public class TitleController : MonoBehaviour
{
    public void onClickStartButton()
    {
        SceneManager.LoadScene("ant_Scenes01");
    }
}
