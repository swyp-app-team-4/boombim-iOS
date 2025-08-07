//
//  LoginViewModel.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import RxSwift
import RxCocoa

final class LoginViewModel {
    struct Input {
        let kakaoTap: Observable<Void>
        let naverTap: Observable<Void>
        let appleTap: Observable<Void>
    }

    struct Output {
        let loginResult: Observable<Result<TokenResponse, Error>>
    }
    
    var didLoginSuccess: (() -> Void)?

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let kakao = input.kakaoTap
            .flatMapLatest {
                KakaoLoginService().login()
                    .flatMapLatest({ tokenInfo in
                        AuthService.shared.requestLogin(type: .kakao, tokenInfo: tokenInfo)
                    })
                .catch { .just(.failure($0)) } }
        
        let naver = input.naverTap
            .flatMapLatest {
                NaverLoginService().login()
                    .flatMapLatest({ tokenInfo in
                        AuthService.shared.requestLogin(type: .naver, tokenInfo: tokenInfo)
                    })
                .catch { .just(.failure($0)) } }
        
        let apple = input.appleTap
            .flatMapLatest {
                AppleLoginService().login()
                    .flatMapLatest({ tokenInfo in
                        AuthService.shared.requestLogin(type: .apple, tokenInfo: tokenInfo)
                    })
                .catch { .just(.failure($0)) } }

        let merged = Observable.merge(kakao, naver, apple)

        return Output(loginResult: merged)
    }
}
