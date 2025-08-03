//
//  LoginCoordinator.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = LoginViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
