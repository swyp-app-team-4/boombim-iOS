//
//  AppDelegate.swift
//  SwypTeam4
//
//  Created by 조영현 on 7/31/25.
//

import UIKit
import RxKakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth
import NidThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Kakao
        let NATIVE_APP_KEY: String = "b9ee6084b39af730b1819a79e3e29d65"
        RxKakaoSDK.initSDK(appKey: NATIVE_APP_KEY)
        
        // Naver
        NidOAuth.shared.initialize()
//        NidOAuth.shared.setLoginBehavior(.app)
//        NidOAuth.shared.setLoginBehavior(.inAppBrowser)
//        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback) // default
        
        return true
    }
    
    /* Kakao */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.rx.handleOpenUrl(url: url)
        }
        
        if (NidOAuth.shared.handleURL(url) == true) { // 네이버앱에서 전달된 Url인 경우
          return true
        }
        
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

