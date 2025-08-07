//
//  NaverLoginService.swift
//  BoomBim
//
//  Created by 조영현 on 8/5/25.
//

import Foundation
import RxSwift
import NidThirdPartyLogin

final class NaverLoginService: SocialLoginService {
    // TODO: Login token 유효성 구현
    func login() -> Observable<TokenInfo> {
        return Observable.create { observer in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case .success(let loginResult):
                    let tokenInfo = TokenInfo(
                        accessToken: loginResult.accessToken.tokenString,
                        refreshToken: loginResult.refreshToken.tokenString,
                        expiresIn: 3600, // 발급시간으로 + 3600초
                        idToken: "") // idToken 보류
                    observer.onNext(tokenInfo)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
