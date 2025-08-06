//
//  TokenManager.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.Auth.accessToken) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.Auth.accessToken) }
    }
    
    var isLoggedIn: Bool {
        guard let token = accessToken, !token.isEmpty else { return false }
        return true
    }
}
