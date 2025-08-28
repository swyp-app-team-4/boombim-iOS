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
typealias LoginRequest = SocialLoginPayload

struct RefreshRequest: Encodable {
    let refreshToken: String
}

typealias LogoutRequest = RefreshRequest

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func socialLogin(provider: SocialProvider, body: LoginRequest) -> Single<TokenPair> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.login + provider.rawValue
        
        return request(url, method: .post, body: body)
    }

    func refresh(_ refreshToken: String) -> Single<TokenPair> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.refresh
        
        return request(url, method: .post, body: RefreshRequest(refreshToken: refreshToken))
    }
    
    func logout(refreshToken: String) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Auth.logout
        
        return requestVoid(url, method: .post, body: LogoutRequest(refreshToken: refreshToken))
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
    
    private func request<T: Decodable, B: Encodable>(_ url: String, method: HTTPMethod, body: B) -> Single<T> {
        
        var headers:HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        
        return Single.create { single in
            let req = AF.request(url, method: method, parameters: body, encoder: JSONParameterEncoder.default, headers: headers)
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
    private func requestVoid<B: Encodable>(_ url: String,
                                           method: HTTPMethod,
                                           body: B) -> Single<Void> {
        var headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        return Single.create { single in
            let req = AF.request(url,
                                 method: method,
                                 parameters: body,
                                 encoder: JSONParameterEncoder.default,
                                 headers: headers)
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
}
