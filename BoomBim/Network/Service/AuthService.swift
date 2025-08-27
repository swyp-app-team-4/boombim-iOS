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
}
