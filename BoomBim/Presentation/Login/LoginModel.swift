//
//  SocialProvider.swift
//  SwypTeam4
//
//  Created by 조영현 on 7/31/25.
//

import Foundation
import AuthenticationServices

enum SocialProvider: String, Codable {
    case apple
    case kakao
    case naver
}

/** 소셜 로그인으로부터 받아오는 Token 정보 */ 
struct SocialToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let idToken: String
}

// MARK: - 로그인 화면에서 사용되는 Model
struct LoginViewState: Equatable {
    var isLoggingIn: Bool = false
    var errorMessage: String? = nil
    var canProceed: Bool { !isLoggingIn && errorMessage == nil }
}

// 화면 내부에서만 쓰는 “소셜 진행 결과” (SDK 결과를 바로 들고 있어도 OK)
enum SocialAuthResult {
    case kakao(KakaoSDKToken)
    case apple(AppleSDKCredential)
    case naver(NaverSDKToken)
}

// MARK: - 서버 요청용 Model
struct SocialLoginPayload: Encodable {
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int?
    let idToken: String?
}

// MARK: - 각 social마다 Response되는 응답
struct KakaoSDKToken {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int?
    let idToken: String? // 카카오도 OIDC 설정 시 id_token을 받을 수 있음
    
    func toPayload() -> SocialLoginPayload {
        SocialLoginPayload(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn, idToken: idToken)
    }
}

struct AppleSDKCredential {
    let identityToken: String?
    let authorizationCode: String?
    let user: String
    let email: String?
    let fullName: PersonNameComponents?
    
    func toPayload() -> SocialLoginPayload {
        SocialLoginPayload(accessToken: "", refreshToken: "", expiresIn: 3600, idToken: identityToken)
    }
}

struct NaverSDKToken {
    let accessToken: String
    let refreshToken: String?
    
    func toPayload() -> SocialLoginPayload {
        SocialLoginPayload(accessToken: accessToken, refreshToken: refreshToken, expiresIn: 3600, idToken: "")
    }
}
