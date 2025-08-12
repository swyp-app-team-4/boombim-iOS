//
//  CongestionReportCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit

final class CongestionReportCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = CongestionReportViewModel()
        let viewController = CongestionReportViewController(viewModel: viewModel)
        
        viewModel.goToMapPickerView = { [weak self] in
            self?.showMapPicker()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showMapPicker() {
        let viewModel = MapPickerViewModel()
        let viewController = MapPickerViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
