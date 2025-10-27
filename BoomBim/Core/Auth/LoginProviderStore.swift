//
//  LoginProviderStore.swift
//  BoomBim
//
//  Created by 조영현 on 10/21/25.
//

import Foundation

protocol LoginProviderStoring {
    var currentLoginProvider: SocialProvider? { get }
    func setCurrentLoginProvider(_ provider: SocialProvider)
    func resetLoginProvider()
}

final class LoginProviderStore: LoginProviderStoring {
    static let shared = LoginProviderStore()
    
    private let key = UserDefaultsKeys.Auth.loginProvider
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentLoginProvider: SocialProvider? {
        guard let raw = defaults.string(forKey: key) else { return nil }
        return SocialProvider(rawValue: raw)
    }

    func setCurrentLoginProvider(_ provider: SocialProvider) {
        defaults.set(provider.rawValue, forKey: key)
    }

    func resetLoginProvider() {
        defaults.removeObject(forKey: key)
    }
}
