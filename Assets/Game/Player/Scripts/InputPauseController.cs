using NaughtyAttributes;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

/// <summary>
/// Controls the pausing system with input
/// music for pause menu here
/// </summary>

public class InputPauseController : InputController<GameObject>
{
    [SerializeField, Scene] private string targetScene;
    
    [Space(20f)]
    [SerializeField] private UnityEvent onPause;
    [SerializeField] private UnityEvent onResume;
    
    private static bool _gameIsPaused;

    private void Update()
    {
        if (Input.GetKeyDown(controls.pause)) 
        {
            if (_gameIsPaused)
                Resume();

            else Pause();
        }
    }

    public void Resume()
    {
        // resumes the speed
        system.SetActive(false);
        Time.timeScale = 1f;
        _gameIsPaused = false;
        
        onPause.Invoke();
    }

    public void Pause()
    {
        // stop time
        system.SetActive(true);
        Time.timeScale = 0f;
        _gameIsPaused = true;

        onResume.Invoke();
    }

    public void LoadMenu()
    {
        Resume();
        SceneManager.LoadScene(targetScene);
    }
}