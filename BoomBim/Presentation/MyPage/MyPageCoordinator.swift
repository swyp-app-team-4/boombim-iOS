//
//  MyPageCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = MyPageViewModel()
        let viewController = MyPageViewController(viewModel: viewModel)
        
        viewModel.goToSettingsView = { [weak self] in
            self?.showSettings()
        }
        viewModel.goToProfileView = { [weak self] in
            self?.showProfile()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showSettings() {
        let viewModel = SettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showProfile() {
        let viewModel = ProfileViewModel()
        let viewController = ProfileViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
