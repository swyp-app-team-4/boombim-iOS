//
//  KeychainTokenStore.swift
//  BoomBim
//
//  Created by 조영현 on 8/27/25.
//

import Foundation
import Security

/// Keychain에서 항목을 구분하기 위한 키(네임스페이스 역할)
/// - service/account 쌍으로 식별합니다.
/// - 필요 시 accessGroup으로 App/Extension 간 공유 가능(프로젝트에 Keychain Sharing 활성화 필요).
public struct KeychainKey {
    public let service: String   // 보통 번들ID 유사 네임스페이스 (ex: com.boombim.auth)
    public let account: String   // 항목 이름 (ex: backend_token_pair_prod)
    public let accessGroup: String?  // 공유 필요 시 사용

    public init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
}

/// 어떤 Codable 타입이든 저장/로드 가능한 범용 Keychain 스토어
/// - TokenPair 뿐 아니라, String(FCM 토큰) 같은 것도 저장 가능
public final class KeychainTokenStore<T: Codable> {
    private let key: KeychainKey
    private let accessibility: CFString
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// - accessibility: 기본은 AfterFirstUnlock (앱 최초 잠금해제 후 접근 가능)
    public init(key: KeychainKey, accessibility: CFString = kSecAttrAccessibleAfterFirstUnlock) {
        self.key = key
        self.accessibility = accessibility
    }

    /// 값 저장(upsert). 동일 키가 있으면 먼저 삭제 후 추가.
    public func save(_ value: T) throws {
        let data = try encoder.encode(value)

        // 공통 질의(키)
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, // 일반 비밀번호(임의 데이터) 유형
            kSecAttrService as String: key.service,
            kSecAttrAccount as String: key.account
        ]
        if let group = key.accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }

        // 동일 키 삭제(업서트 형태)
        SecItemDelete(query as CFDictionary)

        // 추가 요청
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = accessibility

        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    /// 값 로드 (없으면 nil)
    public func load() -> T? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.service,
            kSecAttrAccount as String: key.account,
            kSecReturnData as String: true,            // Data로 반환
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        if let group = key.accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }

        var out: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &out)
        guard status == errSecSuccess, let data = out as? Data else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    /// 항목 삭제(로그아웃 등)
    public func clear() {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.service,
            kSecAttrAccount as String: key.account
        ]
        if let group = key.accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        SecItemDelete(query as CFDictionary)
    }
}
