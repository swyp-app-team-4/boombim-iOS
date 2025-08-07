//
//  TokenManager.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    private let defaults = UserDefaults.standard
    
    var accessToken: String? {
        get { defaults.string(forKey: UserDefaultsKeys.Auth.accessToken) }
        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.accessToken) }
    }
    
    var refreshToken: String? {
        get { defaults.string(forKey: UserDefaultsKeys.Auth.refreshToken) }
        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.refreshToken) }
    }

    var expiresIn: TimeInterval? {
        get { defaults.double(forKey: UserDefaultsKeys.Auth.expiresIn) }
        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.expiresIn) }
    }

    var idToken: String? {
        get { defaults.string(forKey: UserDefaultsKeys.Auth.idToken) }
        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.idToken) }
    }
    
    var isLoggedIn: Bool {
        guard let token = accessToken, !token.isEmpty else { return false }
        return true
    }

    func save(tokenInfo: TokenInfo) {
        accessToken = tokenInfo.accessToken
        refreshToken = tokenInfo.refreshToken
        expiresIn = tokenInfo.expiresIn
        idToken = tokenInfo.idToken
    }

    // 추후 로그아웃 적용하고 UserDefaults 해제할 때 사용
    func logout() {
        defaults.removeObject(forKey: UserDefaultsKeys.Auth.accessToken)
        defaults.removeObject(forKey: UserDefaultsKeys.Auth.refreshToken)
        defaults.removeObject(forKey: UserDefaultsKeys.Auth.expiresIn)
        defaults.removeObject(forKey: UserDefaultsKeys.Auth.idToken)
    }
}

