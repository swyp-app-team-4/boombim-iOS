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

// Profile
struct NicknameRequest: Encodable { let name: String }
struct ProfileImageRequest: Encodable { let image: String } // 서버 스펙에 맞춰 키명 수정

typealias ProfileResponse = UserProfile

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
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
            TokenManager.shared.clear()
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
    
    private func request<T: Decodable, B: Encodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders, body: B) -> Single<T> {
        
        return Single.create { single in
            let req = AF.request(url, method: method, parameters: body, encoder: JSONParameterEncoder.default, headers: header)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value): single(.success(value))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    // 서버가 바디 없는 2xx만 주는 엔드포인트용
    private func requestVoid<B: Encodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders, body: B) -> Single<Void> {
        return Single.create { single in
            let req = AF.request(url,
                                 method: method,
                                 parameters: body,
                                 encoder: JSONParameterEncoder.default,
                                 headers: header)
                .validate()
                .response { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success: single(.success(()))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    private func requestMultipartFormData<T: Decodable>(_ url: String, data: Data, fileName: String, method: HTTPMethod, header: HTTPHeaders) -> Single<T> {
        return Single.create { single in
            let req = AF.upload(
                multipartFormData: { form in
                    form.append(data, withName: "file", fileName: fileName, mimeType: "image/jpeg")},
                to: url,
                method: .post,
                headers: header)
                .validate()
                .responseString { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let pathString):
                        single(.success(pathString as! T))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { req.cancel() }
        }
    }
    
    private func requestGet<T: Decodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders) -> Single<T> {
        
        return Single.create { single in
            let req = AF.request(url, method: method, headers: header)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value): single(.success(value))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
}
