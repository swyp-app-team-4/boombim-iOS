//
//  AppCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//
import UIKit
import RxSwift
import RxCocoa

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let disposeBag = DisposeBag()
    
    private let window: UIWindow

    private var loginCoordinator: LoginCoordinator?
    private var tabBarCoordinator: MainTabBarCoordinator?
    private var onboardingCoordinator: OnboardingCoordinator?   // ✅ 추가
    
    private var currentRoot: Root = .splash
    
    enum Root { case splash, login, main }
    
    // 👇 추가
    private let splashVC = SplashViewController()
    // ✅ “스플래시가 최소로 보여질 시간”
    private let splashMinDuration: RxTimeInterval = .milliseconds(700)
    
    // ✅ 온보딩 1회 여부
    private enum Keys { static let hasSeenOnboarding = "hasSeenOnboarding" }
    private var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasSeenOnboarding) }
    }
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let accessValid  = TokenManager.shared.isAccessValid()
        let refreshValid = TokenManager.shared.isRefreshValid()
        
        // 1) 시작은 스플래시
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        // 2) 최소 노출 시간 스트림
        let minDelay = Observable.just(())
            .delay(splashMinDuration, scheduler: MainScheduler.instance)
            .take(1)
        
        // 3) 첫 실행이면 → 온보딩 최우선 (토큰 상태와 무관)
        if hasSeenOnboarding == false {
            minDelay
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] in
                    self?.showOnboarding()
                })
                .disposed(by: disposeBag)
            return
        }
        
        // 먼저 "토큰 상태 정규화"를 끝낸 뒤에 구독을 잡습니다.
        normalizeAuthState()
        
        // 초기 1회 라우팅 (스플래시 통과용)
        let initialAuth = TokenManager.shared.authState
            .distinctUntilChanged()
            .filter { $0 != .refreshing }
            .take(1)                            // ← 초기 한 번만
            .timeout(.seconds(8), scheduler: MainScheduler.instance)
            .catchAndReturn(.loggedOut)
            .share(replay: 1)
        
        bindAuthStateChanges()
        
        // 최소 노출 + 확정 상태 동시 충족 시 라우팅
        Observable.zip(initialAuth, minDelay)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state, _ in
                guard let self else { return }
                switch state {
                case .loggedIn:
                    self.showMainTabBar()     // ✅ 5. 이미 로그인 → 메인 탭바
                case .loggedOut, .refreshing, .withdraw:
                    self.showLogin()          // ✅ 4. 두 번째 이후엔 온보딩 없이 로그인
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 토큰 상태를 '먼저' 정규화: access/refresh 체크 → 갱신 시도 or 명시 로그아웃
    private func normalizeAuthState() {
        let accessValid  = TokenManager.shared.isAccessValid()
        let refreshValid = TokenManager.shared.isRefreshValid()
        
        if accessValid {
            // 이미 유효 → 아무 것도 안 해도 됨 (authState는 곧 .loggedIn이어야 함)
            return
        }
        if refreshValid {
            _ = TokenManager.shared.ensureValidAccessToken { rt in
                AuthService.shared.refresh(rt)
            }
            .subscribe() // 결과는 authState로 반영됨(.loggedIn or .loggedOut)
            return
        }
        // 둘 다 무효 → 확실히 로그아웃 상태를 밀어 넣어 초기값 오염 방지
        TokenManager.shared.clear(type: .loggedOut)
    }
    
    private func bindAuthStateChanges() {
        TokenManager.shared.authState
            .distinctUntilChanged()
            .skip(1) // 초기 라우팅에서 이미 처리한 첫 값은 건너뜀
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                // 🔴 로그인/닉네임 플로우 진행 중이면, 전역 라우팅을 건너뜁니다.
                if self?.loginCoordinator != nil {
                     print("authState \(state) ignored while login flow is active")
                    return
                }
                
                self?.route(for: state)
            })
            .disposed(by: disposeBag)
    }
    
    private func route(for state: AuthState) {
        switch state {
        case .loggedIn:
            // 로그인 플로우(닉네임 포함)가 아직 끝나지 않았으면 건너뜀
            guard loginCoordinator == nil else { return }
            guard currentRoot != .main else { return }
            currentRoot = .main
            showMainTabBar()
            
        case .loggedOut, .withdraw:
            guard currentRoot != .login else { return }
            currentRoot = .login
            showLogin()
            
        case .refreshing:
            break
        }
    }
    
    private func resetRoot(_ vc: UIViewController, animated: Bool = true) {
        // 떠 있는 모달 닫기
        window.rootViewController?.presentedViewController?.dismiss(animated: false)
        let apply = { self.window.rootViewController = vc }
        guard animated else { apply(); return }
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) { apply() }
    }
    
    private func showOnboarding() {
           // ✅ 온보딩은 항상 스플래시 다음에 한 번만
           let coordinator = OnboardingCoordinator()
           self.onboardingCoordinator = coordinator

           coordinator.finished
               .subscribe(onNext: { [weak self] in
                   guard let self else { return }
                   self.hasSeenOnboarding = true       // ✅ 2→3. 완료 표시
                   self.onboardingCoordinator = nil
                   self.showLogin()                    // ✅ 3. 온보딩 끝나면 무조건 로그인으로
               })
               .disposed(by: disposeBag)

           coordinator.start()
           resetRoot(coordinator.rootViewController)   // 온보딩 루트를 윈도우에 세팅
       }

    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        
        loginCoordinator.finished
            .emit(onNext: { [weak self] in
                print("appCoordinator: login finished")
                self?.loginCoordinator = nil
                self?.showMainTabBar()
            })
            .disposed(by: disposeBag)
        
        self.loginCoordinator = loginCoordinator
        loginCoordinator.start()
        resetRoot(navigationController)
    }

    private func showMainTabBar() {
        // 로그인 되기 전에 TabBar로 가는 것을 방지하는 안전장치
        guard TokenManager.shared.isAccessValid() else {
            showLogin()
            return
        }
        
        let tabBarCoordinator = MainTabBarCoordinator()
        
        self.tabBarCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarController
        resetRoot(tabBarCoordinator.tabBarController)
        
        self.upsertFcmIfNeeded()
    }
    
    private func upsertFcmIfNeeded() {
        guard let token = TokenManager.shared.fcmToken,
              let userToken = TokenManager.shared.currentAccessToken() else { return }

        FcmService.shared.registerFcmToken(userToken: userToken, token: token)
//            .timeout(.seconds(3), scheduler: MainScheduler.instance) // 너무 느리면 스킵
            .subscribe(onNext: { result in
                print("FCM register result:", result)
            }, onError: { err in
                print("FCM register failed:", err)
            })
            .disposed(by: disposeBag)
    }
}
