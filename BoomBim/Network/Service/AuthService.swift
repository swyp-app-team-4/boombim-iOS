//
//  AuthService.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import Foundation
import RxSwift
import Alamofire

// MARK: - Request & Response DTO
// Login 및 Logout
typealias LoginRequest = SocialLoginPayload

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let nameFlag: Bool
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

typealias LogoutRequest = RefreshRequest

struct WithdrawRequest: Encodable {
    let leaveReason: String
}

// Profile
struct NicknameRequest: Encodable { let name: String }
struct ProfileImageRequest: Encodable { let image: String } // 서버 스펙에 맞춰 키명 수정

typealias ProfileResponse = UserProfile

final class AuthService: Service {
    static let shared = AuthService()
    private override init() {}
    
    // MARK: - Login & Logout
    func socialLogin(provider: SocialProvider, body: LoginRequest) -> Single<LoginResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.login + provider.rawValue
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        
        return request(url, method: .post, header: headers, body: body)
    }

    func refresh(_ refreshToken: String) -> Single<TokenPair> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.refresh
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        
        return request(url, method: .post, header: headers, body: RefreshRequest(refreshToken: refreshToken))
    }
    
    func logout(refreshToken: String) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.logout
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        
        return requestVoid(url, method: .post, header: headers, body: LogoutRequest(refreshToken: refreshToken))
    }
    
    func withdraw(accessToken: String, leaveReason: String) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.withdraw
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        headers["Authorization"] = "Bearer \(accessToken)"
        
        return requestVoid(url, method: .delete, header: headers, body: WithdrawRequest(leaveReason: leaveReason))
    }
    
    func logoutAndClear() -> Single<Void> {
        print("logoutAndClear")
        // (a) 현재 refreshToken 확보 (없으면 서버 호출 생략)
        let rt = TokenManager.shared.currentRefreshToken()

        let serverCall: Single<Void>
        if let rt {
            // 서버 실패해도 로컬은 반드시 비운다
            serverCall = logout(refreshToken: rt).catchAndReturn(())
        } else {
            serverCall = .just(())
        }

        // (b) 서버 호출 끝나면 로컬 정리 & (선택) 소셜 SDK 로그아웃
        return serverCall.do(onSuccess: { _ in
            TokenManager.shared.clear(type: .loggedOut)
        })
    }
    
    func withdrawAndClear(leaveReason: String) -> Single<Void> {
        print("withdrawAndClear")
        let at = TokenManager.shared.currentAccessToken()

        let serverCall: Single<Void>
        if let at {
            serverCall = withdraw(accessToken: at, leaveReason: leaveReason).catchAndReturn(())
        } else {
            serverCall = .just(())
        }

        return serverCall.do(onSuccess: { _ in
            TokenManager.shared.clear(type: .withdraw)
        })
    }
    
    // MARK: - Profile
    func setNickname(_ name: String) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Profile.nickname
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestVoid(url, method: .patch, header: headers, body: NicknameRequest(name: name))
    }
    
    func setProfileImage(_ image: Data) -> Single<String> {
        let url = NetworkDefine.apiHost + NetworkDefine.Profile.image
        let fileName = "profile.jpg"
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        print("image : \(image)")
        
        return requestMultipartFormData(url, data: image, fileName: fileName, method: .patch, header: headers)
    }
    
    func getProfile() -> Single<ProfileResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Profile.profile
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestGet(url, method: .get, header: headers)
    }
}
