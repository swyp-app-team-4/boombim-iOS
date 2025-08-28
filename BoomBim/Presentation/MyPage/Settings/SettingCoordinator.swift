//
//  SettingCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import UIKit

final class SettingCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    var settingsViewModel: SettingsViewModel?

    func start() {
        let viewModel = SettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        self.settingsViewModel = viewModel
        
        viewModel.goToFeedbackView = { [weak self] in
            self?.showFeedback()
        }
        
        navigationController.pushViewController(viewController, animated: true)
//        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showFeedback() {
        let viewModel = FeedbackViewModel()
        let viewController = FeedbackViewController(viewModel: viewModel)
        
        viewModel.onSubmit = { [weak self] reason in
            guard let self, let settingsVM = self.settingsViewModel else { return }
            
            // pop 완료 후에 알럿을 띄우도록 VM에 reason 전달
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                settingsVM.setWithdrawReason(reason) // → VC가 알럿을 띄우는 트리거
            }
            self.navigationController.popViewController(animated: true)
            CATransaction.commit()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
