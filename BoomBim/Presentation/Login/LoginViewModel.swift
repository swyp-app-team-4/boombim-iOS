//
//  LoginViewModel.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import RxSwift
import RxCocoa

final class LoginViewModel {
    enum LoginRoute {
        case nickname
        case mainTab
    }
    
    struct Input {
        let kakaoTap: Observable<Void>
        let naverTap: Observable<Void>
        let appleTap: Observable<Void>
        let withoutLoginTap: Signal<Void>
    }

    struct Output {
        let loginResult: Observable<Result<TokenResponse, Error>>
//        let continueWithoutLogin: Observable<Void>
        let route: Signal<LoginRoute>
    }
    
    private let routeRelay = PublishRelay<LoginRoute>()
    var route: Signal<LoginRoute> {
        routeRelay.asSignal()
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let kakao = input.kakaoTap
            .flatMapLatest {
                KakaoLoginService().login()
                    .flatMapLatest({ tokenInfo in
                        AuthService.shared.requestLogin(type: .kakao, tokenInfo: tokenInfo)
                    })
                    .do(onNext: { _ in
                        self.routeRelay.accept(.nickname)
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
        
        input.withoutLoginTap
            .emit(onNext: { [routeRelay] in
                routeRelay.accept(.mainTab)
            })
            .disposed(by: disposeBag)

        return Output(loginResult: merged,
                      route: routeRelay.asSignal())
    }
}
