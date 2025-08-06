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

    // child coordinator 참조
    private var loginCoordinator: LoginCoordinator?
    private var tabBarCoordinator: MainTabBarCoordinator?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        // ✅ 로그인 여부 체크
        if isLoggedIn() {
            showMainTabBar()
        } else {
            showLogin()
        }
    }

    private func isLoggedIn() -> Bool {
        // access token 존재 여부 등으로 판단
        return UserDefaults.standard.string(forKey: "access_token") != nil
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
