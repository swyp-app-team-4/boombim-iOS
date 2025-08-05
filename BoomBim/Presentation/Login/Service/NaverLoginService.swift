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
    func login() -> Observable<String> {
        return Observable.create { observer in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case .success(let loginResult):
                    let accessToken = loginResult.accessToken.tokenString
                    observer.onNext(accessToken)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
