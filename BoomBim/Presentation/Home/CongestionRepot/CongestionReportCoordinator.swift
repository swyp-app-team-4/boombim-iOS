//
//  CongestionReportCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit

final class CongestionReportCoordinator: Coordinator {
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("CongestionReportCoordinator start")
        let viewModel = CongestionReportViewModel()
        let viewController = CongestionReportViewController(viewModel: viewModel)
        
        viewModel.goToMapPickerView = { [weak self] in
            print("goToMapPickerView")
            self?.showMapPicker()
        }
        
        viewModel.backToHome = { [weak self] in
            print("backToHome")
            self?.onFinish?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
        debugPrint(navigationController)
    }
    
    func showMapPicker() {
        print("showMapPicker")
        let viewModel = MapPickerViewModel()
        let viewController = MapPickerViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
