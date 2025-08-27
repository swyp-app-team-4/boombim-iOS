//
//  UserDefaultsKeys.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

enum UserDefaultsKeys {
    enum Auth {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let expiresIn = "expiresIn"
        static let idToken = "idToken"
    }
    
    enum Fcm {
        static let fcmToken = "fcmToken"
        static let fcmTokenUpdate = "fcmTokenUpdate"
    }
}
