//
//  LoginCoordinator.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController
    var didFinish: (() -> Void)? // 로그인 성공 시 호출 콜백

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = LoginViewModel()
        
        viewModel.didLoginSuccess = { [weak self] in
            self?.didFinish?()
        }
        
        let vc = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }
}
