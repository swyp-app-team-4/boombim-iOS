//
//  AuthService.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import Foundation
import RxSwift
import Alamofire

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func requestLogin(type: SocialProvider, tokenInfo: TokenInfo) -> Observable<Result<TokenResponse, Error>> {
        return Observable.create { observer in
            let url = NetworkDefine.API_HOST + NetworkDefine.Auth.login + type.rawValue
            
            var headers:HTTPHeaders = ["Content-Type": "application/json"]
            headers["Accept"] = "application/json"
            
            let params: [String: Any] = [
                "accessToken": tokenInfo.accessToken,
                "refreshToken": tokenInfo.refreshToken,
                "expiresIn": tokenInfo.expiresIn,
                "idToken": tokenInfo.idToken,
            ]
            
            print("params: \(params)")
            
            CommonRequest.shared.request(
                url: url,
                method: .post,
                parameters: params,
                headers: headers,
                encoding: JSONEncoding.default,
                responseType: TokenResponse.self
            ) { result in
                
                debugPrint(result)
                
                switch result {
                    case .success(let token):
                        // TokenResponse 디코딩 성공
                        observer.onNext(.success(token))
                        
                    case .failure(let error):
                        // error가 ServerErrorResponse 기반이면 디코딩된 NSError가 올 수 있음
                        observer.onNext(.failure(error))
                    }

                    observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
