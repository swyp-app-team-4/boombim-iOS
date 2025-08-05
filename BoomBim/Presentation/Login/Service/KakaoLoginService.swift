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
    func login() -> Observable<String> {
        return Observable.create { observer in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let token = token {
                        observer.onNext(token.accessToken)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError(domain: "Kakao", code: -1))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let token = token {
                        observer.onNext(token.accessToken)
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
