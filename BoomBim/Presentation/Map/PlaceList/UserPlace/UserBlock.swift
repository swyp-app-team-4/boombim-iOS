//
//  UserBlock.swift
//  BoomBim
//
//  Created by 조영현 on 9/21/25.
//

import Foundation
import RxSwift
import RxCocoa

/// 심사용 최소 구현: memberName 기반 차단
/// ⚠️ 실서비스에서는 고유한 memberId(숫자/UUID)로 전환 권장
final class UserBlock {
    static let shared = UserBlock()
    private init() {
        // 초기 로드
        let set = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        blockedNamesRelay.accept(set)
    }

    private let key = "blocked_member_names"
    private let blockedNamesRelay = BehaviorRelay<Set<String>>(value: [])

    var blockedNamesDriver: Driver<Set<String>> { blockedNamesRelay.asDriver() }
    var blockedNames: Set<String> { blockedNamesRelay.value }

    func isBlocked(name: String) -> Bool {
        blockedNamesRelay.value.contains(normalize(name))
    }

    func block(name: String) {
        var s = blockedNamesRelay.value
        s.insert(normalize(name))
        blockedNamesRelay.accept(s)
        UserDefaults.standard.set(Array(s), forKey: key)
    }

    func unblock(name: String) {
        var s = blockedNamesRelay.value
        s.remove(normalize(name))
        blockedNamesRelay.accept(s)
        UserDefaults.standard.set(Array(s), forKey: key)
    }

    private func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
