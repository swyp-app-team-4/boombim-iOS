//
//  KakaoLoginService.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import Foundation
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser

final class KakaoLoginService: SocialLoginService {
    func login() -> Observable<TokenInfo> {
        return Observable.create { observer in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let token = token {
                        let tokenInfo = TokenInfo(
                            accessToken: token.accessToken,
                            refreshToken: token.refreshToken,
                            expiresIn: Int(token.expiresIn),
                            idToken: "") // idToken 보류
                        print("tokenInfo : \(tokenInfo)")
                        print("accessToken : \(token.accessToken)")
                        print("refreshToken : \(token.refreshToken)")
                        print("expiresIn : \(token.expiresIn)")
                        print("idToken : \(token.idToken ?? "")")
                        observer.onNext(tokenInfo)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError(domain: "Kakao", code: -1))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let token = token {
                        let tokenInfo = TokenInfo(
                            accessToken: token.accessToken,
                            refreshToken: token.refreshToken,
                            expiresIn: Int(token.expiresIn),
                            idToken: "")
                        observer.onNext(tokenInfo)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError(domain: "Kakao", code: -1))
                    }
                }
            }
            return Disposables.create()
        }
    }
}
