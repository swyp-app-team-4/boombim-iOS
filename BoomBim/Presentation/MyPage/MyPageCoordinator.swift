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
    var pointCoordinator: PointCoordinator?

    private let router: ReportRouting

    init(navigationController: UINavigationController, router: ReportRouting) {
        self.navigationController = navigationController
        self.router = router
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
        viewModel.goToPointView = { [weak self] point in
            self?.showPoint(point: point)
        }
        viewModel.goToCongestionReportView = { [weak self] in
            self?.router.showCongestionReport(selectedPlace: nil, origin: .myPage)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showSettings() {
//        let viewModel = SettingsViewModel()
//        let viewController = SettingsViewController(viewModel: viewModel)
        let coordinator = SettingCoordinator(navigationController: navigationController)
        
        self.settingsCoordinator = coordinator
        coordinator.start()
    }
    
    private func showProfile() {
        let viewModel = ProfileViewModel()
        let viewController = ProfileViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showPoint(point: UserPoint) {
        let coordinator = PointCoordinator(navigationController: navigationController, initialPoint: point, router: self.router)
        
        self.pointCoordinator = coordinator
        coordinator.start()
    }
}
