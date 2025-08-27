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

        // TODO: 로그인 정보 값을 가진 상태에서 로그인 상태 유지 기능 필요
//        if isLoggedIn() {
//            showMainTabBar()
//        } else {
            showLogin()
//        }
    }

//    private func isLoggedIn() -> Bool {
//        return TokenManager.shared.isLoggedIn
//    }

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
    }

    private func showMainTabBar() {
        let tabBarCoordinator = MainTabBarCoordinator()
        
        self.tabBarCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarController
    }
}
