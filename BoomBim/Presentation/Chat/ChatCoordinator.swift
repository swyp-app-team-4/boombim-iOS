//
//  ChatCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class ChatCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = ChatViewModel()
        let viewController = ChatViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
