//
//  MyPageCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    var navigationController: UINavigationController
    var settingsCoordinator: SettingCoordinator?

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
        let coordinator = SettingCoordinator(navigationController: navigationController)
        
        self.settingsCoordinator = coordinator
        coordinator.start()
        
//        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showProfile() {
        let viewModel = ProfileViewModel()
        let viewController = ProfileViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
