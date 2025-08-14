//
//  AppCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//
import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
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

//        if isLoggedIn() {
//            showMainTabBar()
//        } else {
            showLogin()
//        }
    }

    private func isLoggedIn() -> Bool {
        return TokenManager.shared.isLoggedIn
    }

    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        
        loginCoordinator.didFinish = { [weak self] in
            self?.loginCoordinator = nil
            self?.showMainTabBar()
        }
        
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
