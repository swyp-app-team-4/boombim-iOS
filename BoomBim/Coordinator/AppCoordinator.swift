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

               // 4) 첫 실행이 아니면 → 토큰 상태로 로그인/메인 분기
               let finalAuthState = TokenManager.shared.authState
                   .distinctUntilChanged()
                   .filter { $0 != .refreshing } // 확정 상태만
                   .take(1)
                   .timeout(.seconds(8), scheduler: MainScheduler.instance)
                   .catchAndReturn(.loggedOut)
                   .share()

               // Silent refresh 시도(루트 전환은 여기서 하지 않음)
               if TokenManager.shared.isAccessValid() {
                   // 바로 .loggedIn 이 나올 것 → 아래 zip이 처리
               } else if TokenManager.shared.isRefreshValid() {
                   _ = TokenManager.shared.ensureValidAccessToken { rt in
                       AuthService.shared.refresh(rt)
                   }.subscribe()
               } else {
                   TokenManager.shared.clear() // → authState = .loggedOut 방출
               }

               // 최소 노출 + 확정 상태 동시 충족 시 라우팅
               Observable.zip(finalAuthState, minDelay)
                   .observe(on: MainScheduler.instance)
                   .subscribe(onNext: { [weak self] state, _ in
                       guard let self else { return }
                       switch state {
                       case .loggedIn:
                           self.showMainTabBar()     // ✅ 5. 이미 로그인 → 메인 탭바
                       case .loggedOut, .refreshing:
                           self.showLogin()          // ✅ 4. 두 번째 이후엔 온보딩 없이 로그인
                       }
                   })
                   .disposed(by: disposeBag)
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
