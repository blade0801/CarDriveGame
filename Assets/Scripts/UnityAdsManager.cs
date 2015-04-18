using UnityEngine;
using System.Collections;
using UnityEngine.Advertisements;

public class UnityAdsManager : MonoBehaviour
{
    static UnityAdsManager instanse;

    [SerializeField]
    string appId = "26555";

    public static UnityAdsManager GetInstance()
    {
        if(null == instanse)
        {
            GameObject obj = new GameObject("UnityAdsManager");
            instanse = obj.AddComponent<UnityAdsManager>();
        }
        return instanse;
    }

    private void Awake()
    {
        if(Advertisement.isSupported)
        {
            Advertisement.allowPrecache = true;
            Advertisement.Initialize(appId);
        }else
        {
            Debug.Log("Platform not supported");
        }
    }

    public void ShowAds()
    {
        if(Advertisement.isReady())
        {
            Advertisement.Show(null, new ShowOptions {
                pause = true,
                resultCallback = result =>
                {
                    Debug.Log("AdsShowResult:" + result.ToString());
                }
            });
        }
    }
}