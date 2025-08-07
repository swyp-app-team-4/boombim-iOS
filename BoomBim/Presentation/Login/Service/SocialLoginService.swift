//
//  SocialLoginService.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import RxSwift

protocol SocialLoginService {
    func login() -> Observable<TokenInfo>  // accessToken or idToken
}
