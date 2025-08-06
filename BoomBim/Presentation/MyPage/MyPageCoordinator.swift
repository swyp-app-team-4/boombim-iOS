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
        navigationController.setViewControllers([viewController], animated: false)
    }
}
