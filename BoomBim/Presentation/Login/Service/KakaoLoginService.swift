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
    func loginAndIssueBackendToken() -> Single<LoginResponse> {
        // 1) 카카오 SDK로 로그인 → OAuthToken
        kakaoSDKLogin()
            // 2) OAuthToken → SocialLoginBody
            .map { token in
                LoginRequest(
                    accessToken: token.accessToken,
                    refreshToken: token.refreshToken,
                    expiresIn: Int(token.expiresIn),
                    idToken: "") // idToken 보류
            }
            // 3) 서버에 전달 → TokenPair 발급
            .flatMap { body in
                AuthService.shared.socialLogin(provider: .kakao, body: body)
            }
    }

    // 내부: Kakao SDK 로그인만 담당 (Single로 1회성 결과)
    private func kakaoSDKLogin() -> Single<OAuthToken> {
        return Single<OAuthToken>.create { single in
            let sendSuccess: (OAuthToken) -> Void = { token in
                single(.success(token))
            }
            let sendError: (Error?) -> Void = { error in
                single(.failure(error ?? NSError(domain: "KakaoLogin", code: -1)))
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                // 카카오톡 앱으로 로그인
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let token { sendSuccess(token) } else { sendError(error) }
                }
            } else {
                // 카카오 계정(ID/PW) 로그인
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let token { sendSuccess(token) } else { sendError(error) }
                }
            }

            return Disposables.create()
        }
    }
}

//final class KakaoLoginService: SocialLoginService {
//    func login() -> Observable<SocialToken> {
//        return Observable.create { observer in
//            if UserApi.isKakaoTalkLoginAvailable() {
//                UserApi.shared.loginWithKakaoTalk { token, error in
//                    if let token = token {
//                        let tokenInfo = SocialToken(
//                            accessToken: token.accessToken,
//                            refreshToken: token.refreshToken,
//                            expiresIn: Int(token.expiresIn),
//                            idToken: "") // idToken 보류
//                        observer.onNext(tokenInfo)
//                        observer.onCompleted()
//                    } else {
//                        observer.onError(error ?? NSError(domain: "Kakao", code: -1))
//                    }
//                }
//            } else {
//                UserApi.shared.loginWithKakaoAccount { token, error in
//                    if let token = token {
//                        let tokenInfo = SocialToken(
//                            accessToken: token.accessToken,
//                            refreshToken: token.refreshToken,
//                            expiresIn: Int(token.expiresIn),
//                            idToken: "")
//                        observer.onNext(tokenInfo)
//                        observer.onCompleted()
//                    } else {
//                        observer.onError(error ?? NSError(domain: "Kakao", code: -1))
//                    }
//                }
//            }
//            return Disposables.create()
//        }
//    }
//}
