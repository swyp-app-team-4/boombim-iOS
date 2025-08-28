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
import KakaoMapsSDK
import NidThirdPartyLogin
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Keychain Token Manager
        TokenManager.configure(store: KeychainTokenStore(key: KeychainIDs.backendTokenPair(env: AppEnvironment.current)))
        
        // Kakao
        if let kakaoNativeAppKey = Bundle.main.object(forInfoDictionaryKey: "KakaoAppKey") as? String {
            print("kakao SDK 설정 완료")
            RxKakaoSDK.initSDK(appKey: kakaoNativeAppKey)
            SDKInitializer.InitSDK(appKey: kakaoNativeAppKey)
        } else {
            print("kakao native app key missing")
        }
        
        // Naver
        NidOAuth.shared.initialize()
//        NidOAuth.shared.setLoginBehavior(.app)
//        NidOAuth.shared.setLoginBehavior(.inAppBrowser)
//        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback) // default
        
        // Firebase
        FirebaseApp.configure()
        // 알림 권한
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Notification permission:", granted)
        }
        
        // 원격 알림 등록
        UIApplication.shared.registerForRemoteNotifications()
        
        // FCM 토큰 콜백
        Messaging.messaging().delegate = self
        
        // Image
        ImageBootstrap.configure()
        
        return true
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

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM token:", token)
        
//        TokenManager.shared.fcmToken = token
    }
}
