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

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        TokenManager.shared.authState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loggedOut:
                    print("AppCoordinator loggedOut")
                    self?.showLogin()
                case .loggedIn, .refreshing:
                    self?.showMainTabBar()
                }
            })
            .disposed(by: disposeBag)
        
        // 앱 시작 시 사일런트 검사/갱신
        if TokenManager.shared.isAccessValid() {
            // 이미 메인 진입 가능
        } else if TokenManager.shared.isRefreshValid() {
            _ = TokenManager.shared.ensureValidAccessToken { rt in
                AuthService.shared.refresh(rt)
            }.subscribe()
        } else {
            TokenManager.shared.clear() // 로그인 화면으로
        }
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
