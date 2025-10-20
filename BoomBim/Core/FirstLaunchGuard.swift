//
//  FirstLaunchGuard.swift
//  BoomBim
//
//  Created by 조영현 on 9/30/25.
//

import Foundation

enum FirstLaunchGuard {
    private static let flagKey = "install.marker.v1"

    static func handleFirstLaunchAndWipeKeychainIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: flagKey) == nil {
            // ✅ 첫 실행(= 재설치)로 판단 → 세션 관련 키체인 정리
            KeychainTokenStore<TokenPair>(
                key: KeychainIDs.backendTokenPair(env: AppEnvironment.current)
            ).clear()
            // 필요시 레거시 키들 추가 정리…

            defaults.set(UUID().uuidString, forKey: flagKey)
            defaults.synchronize()
        }
    }
}
