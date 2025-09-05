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
        
        // 초기 1회 라우팅 (스플래시 통과용)
        let initialAuth = TokenManager.shared.authState
            .distinctUntilChanged()
            .filter { $0 != .refreshing }
            .take(1)                            // ← 초기 한 번만
            .timeout(.seconds(8), scheduler: MainScheduler.instance)
            .catchAndReturn(.loggedOut)
            .share(replay: 1)
        
        bindAuthStateChanges()
        
        // Silent refresh 시도(루트 전환은 여기서 하지 않음)
        if TokenManager.shared.isAccessValid() {
            // 바로 .loggedIn 이 나올 것 → 아래 zip이 처리
        } else if TokenManager.shared.isRefreshValid() {
            _ = TokenManager.shared.ensureValidAccessToken { rt in
                AuthService.shared.refresh(rt)
            }.subscribe()
        } else {
            TokenManager.shared.clear(type: .loggedOut) // → authState = .loggedOut 방출
        }
        
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
        let tabBarCoordinator = MainTabBarCoordinator()
        
        self.tabBarCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarController
        resetRoot(tabBarCoordinator.tabBarController)
    }
}
