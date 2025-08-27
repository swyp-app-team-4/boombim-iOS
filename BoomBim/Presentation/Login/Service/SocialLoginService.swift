//
//  SocialLoginService.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import RxSwift

protocol SocialLoginService {
//    func login() -> Observable<SocialToken>  // accessToken or idToken
    /// 소셜 로그인 후 우리 서버에서 access/refresh를 발급 받아 TokenPair를 돌려줌
        func loginAndIssueBackendToken() -> Single<TokenPair>
}
