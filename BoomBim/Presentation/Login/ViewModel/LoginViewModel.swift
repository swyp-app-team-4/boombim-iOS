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
        let loginResult: Observable<Result<String, Error>>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let kakao = input.kakaoTap
            .flatMapLatest { KakaoLoginService().login().map(Result.success).catch { .just(.failure($0)) } }

        let naver = input.naverTap
            .flatMapLatest { NaverLoginService().login().map(Result.success).catch { .just(.failure($0)) } }

//        let apple = input.appleTap
//            .flatMapLatest { AppleLoginService().login().map(Result.success).catch { .just(.failure($0)) } }

        let merged = Observable.merge(kakao/*, naver, apple*/)

        return Output(loginResult: merged)
    }
}
