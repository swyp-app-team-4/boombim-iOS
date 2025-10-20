//
//  AuthModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/27/25.
//

import Foundation

import Foundation

/// 우리 백엔드에서 발급해 주는 토큰 한 세트.
/// - 앱 전역(Auth 도메인)에서 사용하는 표준 모델입니다.
/// - Keychain에 저장/로드되는 타입이라 Codable 채택.
public struct TokenPair: Codable, Equatable {
    /// API 호출 시 Authorization: Bearer {accessToken} 으로 붙는 토큰
    public let accessToken: String
    /// access 갱신(refresh API)에 사용하는 토큰
    public let refreshToken: String
    /// accessToken 만료 시각 (서버가 내려주면 그대로 사용; 없으면 JWT에서 추출)
    public var accessExp: Date?
    /// refreshToken 만료 시각 (서버가 내려주면 그대로 사용; 없으면 JWT에서 추출)
    public var refreshExp: Date?

    public init(accessToken: String, refreshToken: String, accessExp: Date? = nil, refreshExp: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessExp = accessExp
        self.refreshExp = refreshExp
    }
}

public extension String {
    /// JWT의 payload에서 exp(Unix seconds)를 꺼내 Date로 파싱합니다.
    /// - leeway: 시계 오차/네트워크 지연을 고려해 약간 뺀 값으로 만료 판정.
    func jwtExpDate(leeway: TimeInterval = 30) -> Date? {
        // JWT는 "header.payload.signature" 3부분인데, payload에 exp가 들어갑니다.
        let parts = split(separator: ".")
        guard parts.count >= 2 else { return nil }

        // base64url → base64 디코딩
        func b64url(_ s: Substring) -> Data? {
            var str = String(s)
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            // base64 패딩 보정
            let pad = 4 - (str.count % 4)
            if pad < 4 { str += String(repeating: "=", count: pad) }
            return Data(base64Encoded: str)
        }

        guard let payload = b64url(parts[1]),
              let json = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
              let exp = json["exp"] as? TimeInterval
        else { return nil }

        // 만료 시각 - leeway
        return Date(timeIntervalSince1970: exp - leeway)
    }
}
