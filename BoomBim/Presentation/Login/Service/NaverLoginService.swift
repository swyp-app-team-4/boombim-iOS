//
//  NaverLoginService.swift
//  BoomBim
//
//  Created by 조영현 on 8/5/25.
//

import Foundation
import RxSwift
import NidThirdPartyLogin

/// 네이버 로그인 흐름:
/// 1) NidOAuth SDK로 로그인 → accessToken/refreshToken(+만료시각) 획득
/// 2) 서버 소셜 로그인 API에 provider=.naver, body(accessToken 등) 요청
/// 3) 서버가 발급한 TokenPair(access/refresh) 반환
final class NaverLoginService: SocialLoginService {

    func loginAndIssueBackendToken() -> Single<TokenPair> {
        return naverSDKLogin() // 1) SDK 로그인
            .map { token in
                LoginRequest(
                    accessToken: token.accessToken.tokenString,
                    refreshToken: token.refreshToken.tokenString,
                    expiresIn: 3600,
                    idToken: "") // idToken 보류
            }
            .flatMap { body in
                AuthService.shared.socialLogin(provider: .naver, body: body)
            }
    }

    // MARK: - Naver SDK 로그인 (Single로 1회성 결과 전달)
    private func naverSDKLogin() -> Single<LoginResult> {
        return Single<LoginResult>.create { single in
            NidOAuth.shared.requestLogin { sdkResult in
                switch sdkResult {
                case .success(let token):
                    let result = LoginResult(accessToken: token.accessToken, refreshToken: token.refreshToken)
                    single(.success(result))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}


//import Foundation
//import RxSwift
//import NidThirdPartyLogin
//
//final class NaverLoginService: SocialLoginService {
//    // TODO: Login token 유효성 구현
//    func login() -> Observable<SocialToken> {
//        return Observable.create { observer in
//            NidOAuth.shared.requestLogin { result in
//                switch result {
//                case .success(let loginResult):
//                    let tokenInfo = SocialToken(
//                        accessToken: loginResult.accessToken.tokenString,
//                        refreshToken: loginResult.refreshToken.tokenString,
//                        expiresIn: 3600, // 발급시간으로 + 3600초
//                        idToken: "") // idToken 보류
//                    observer.onNext(tokenInfo)
//                    observer.onCompleted()
//                case .failure(let error):
//                    observer.onError(error)
//                }
//            }
//            return Disposables.create()
//        }
//    }
//}
