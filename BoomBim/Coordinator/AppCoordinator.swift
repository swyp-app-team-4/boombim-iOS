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
    
    // 👇 추가
    private let splashVC = SplashViewController()
    // ✅ “스플래시가 최소로 보여질 시간”
    private let splashMinDuration: RxTimeInterval = .milliseconds(700)
    
    private var hasRouted = false

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        // 1) 시작은 스플래시
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        // 2) 최종 인증 상태 스트림 (refreshing 제외, 최초 1번만)
        let finalAuthState = TokenManager.shared.authState
            .distinctUntilChanged()
            .filter { $0 != .refreshing }
            .take(1)
        // 혹시 인증이 너무 오래 걸리면(네트워크 등) 스플래시에 갇히지 않도록 안전장치
            .timeout(.seconds(8), scheduler: MainScheduler.instance)
            .catchAndReturn(.loggedOut)
            .share()
        
        // 3) 최소 노출 시간 스트림
        let minDelay = Observable.just(())
            .delay(splashMinDuration, scheduler: MainScheduler.instance)
            .take(1)
        
        // 4) “최종 상태 도착” 과 “최소 노출 시간 경과”를 동시에 만족하면 라우팅
        Observable.zip(finalAuthState, minDelay)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state, _ in
                guard let self else { return }
                switch state {
                case .loggedIn:
                    self.showMainTabBar()
                case .loggedOut, .refreshing:
                    // refreshing은 여기 안 오지만, 방어적으로 분기
                    self.showLogin()
                }
            })
            .disposed(by: disposeBag)
        
        // 5) 앱 시작 시 사일런트 검사/갱신 (루트 교체는 여기서 직접 하지 않음)
        if TokenManager.shared.isAccessValid() {
            // 이미 .loggedIn이면 finalAuthState가 곧 방출 → zip 조건 충족 시 전환
        } else if TokenManager.shared.isRefreshValid() {
            _ = TokenManager.shared.ensureValidAccessToken { rt in
                AuthService.shared.refresh(rt)
            }.subscribe()
        } else {
            TokenManager.shared.clear() // -> authState = .loggedOut 방출 → 위 zip이 처리
        }

//        TokenManager.shared.authState
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] state in
//                guard let self = self else { return }
//                switch state {
//                case .loggedOut:
//                    print("AppCoordinator loggedOut")
//                    self.showLogin()
//                case .loggedIn, .refreshing:
//                    print("AppCoordinator loggedIn, refreshing")
//                    // ✅ 로그인 코디네이터가 진행 중이라면, 여기서 메인으로 넘기지 않음
//                    guard self.loginCoordinator == nil else { return }
//                    self.showMainTabBar()
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        // 앱 시작 시 사일런트 검사/갱신
//        if TokenManager.shared.isAccessValid() {
//            // 이미 메인 진입 가능
//        } else if TokenManager.shared.isRefreshValid() {
//            _ = TokenManager.shared.ensureValidAccessToken { rt in
//                AuthService.shared.refresh(rt)
//            }.subscribe()
//        } else {
//            TokenManager.shared.clear() // 로그인 화면으로
//        }
    }
    
    private func resetRoot(_ vc: UIViewController, animated: Bool = true) {
        // 떠 있는 모달 닫기
        window.rootViewController?.presentedViewController?.dismiss(animated: false)
        let apply = { self.window.rootViewController = vc }
        guard animated else { apply(); return }
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) { apply() }
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
