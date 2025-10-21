//
//  LoginViewModel.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import RxSwift
import RxCocoa

final class LoginViewModel {
    // 로그인 이후 라우팅 목적지
    enum LoginRoute {
        case nickname     // 닉네임/온보딩
        case mainTab      // 메인 탭
    }

    struct Input {
        let kakaoTap: Observable<Void>
        let naverTap: Observable<Void>
        let appleTap: Observable<Void>
        let withoutLoginTap: Signal<Void>
    }

    struct Output {
        // 뷰에서 로딩 인디케이터 제어용
        let isLoading: Driver<Bool>
        // 에러 토스트/알럿용
        let error: Signal<String>
    }

    // MARK: - Private
    private let routeRelay = PublishRelay<LoginRoute>()
    var route: Signal<LoginRoute> { routeRelay.asSignal() }
    
    private let errorRelay = PublishRelay<String>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)

    private let disposeBag = DisposeBag()

    // DI: 필요 시 외부에서 주입 가능 (테스트 편의)
    private let authService: AuthService
    private let kakaoService: KakaoLoginService
    private let naverService: NaverLoginService
    private let appleService: AppleLoginService

    init(authService: AuthService = .shared,
         kakaoService: KakaoLoginService = .init(),
         naverService: NaverLoginService = .init(),
         appleService: AppleLoginService = .init()) {
        self.authService = authService
        self.kakaoService = kakaoService
        self.naverService = naverService
        self.appleService = appleService
    }

    func transform(input: Input) -> Output {
        // Kakao
        input.kakaoTap
            .flatMapLatest { [unowned self] in
                self.runLoginFlow(provider: .kakao) { self.kakaoService.loginAndIssueBackendToken() }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
         input.naverTap
            .flatMapLatest { [unowned self] in
                self.runLoginFlow(provider: .naver) { self.naverService.loginAndIssueBackendToken() }
            }
         .subscribe().disposed(by: disposeBag)
         
         input.appleTap
            .flatMapLatest { [unowned self] in
                self.runLoginFlow(provider: .apple) { self.appleService.loginAndIssueBackendToken() }
            }
         .subscribe().disposed(by: disposeBag)
        
        input.withoutLoginTap
            .emit(onNext: { [routeRelay] in
                routeRelay.accept(.mainTab) })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }
    
    /// 공통 로그인 흐름: 서비스에서 TokenPair 받고 저장 + 라우트
    private func runLoginFlow(provider: SocialProvider, _ issue: @escaping () -> Single<LoginResponse>) -> Observable<Void> {
        loadingRelay.accept(true)
        return issue()
            .observe(on: MainScheduler.instance) // UI 업데이트는 메인 스레드
            .do(onSuccess: { resp in
                // Keychain 저장 + 상태 전이(.loggedIn)
                // 1) 토큰 저장
                let pair = TokenPair(accessToken: resp.accessToken, refreshToken: resp.refreshToken)
                TokenManager.shared.set(pair: pair)
                
                // 항상 최신 로그인 타입으로 저장 (덮어쓰기)
                LoginProviderStore.shared.setCurrentLoginProvider(provider)
                
                // 2) nameFlag로 분기
                if resp.nameFlag {
                    self.routeRelay.accept(.mainTab)   // 바로 메인
                } else {
                    self.routeRelay.accept(.nickname)  // 닉네임 필요
                }
            }, onError: { [weak self] err in
                self?.errorRelay.accept(err.localizedDescription)
            }, onDispose: { [weak self] in
                self?.loadingRelay.accept(false)
            })
            .map { _ in () }
            .asObservable()
    }
}

