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
        viewController.hidesBottomBarWhenPushed = true
        self.settingsViewModel = viewModel
        
        viewModel.goToPersonalInfoView = { [weak self] in
            self?.pushPersonalnfo()
        }
        
        viewModel.goToAlarmSettingView = { [weak self] in
            self?.pushAlarmSetting()
        }
        
        viewModel.goToFeedbackView = { [weak self] in
            self?.pushFeedback()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func pushPersonalnfo() {
        let viewModel = PersonalInfoViewModel()
        let viewController = PersonalInfoViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func pushAlarmSetting() {
        let viewModel = AlarmSettingViewModel()
        let viewController = AlarmSettingViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func pushFeedback() {
        let viewModel = FeedbackViewModel()
        let viewController = FeedbackViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
