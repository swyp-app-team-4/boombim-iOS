//
//  CongestionReportCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import CoreLocation

final class CongestionReportCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    var childCoordinators: [Coordinator] = []
    
    var service: KakaoLocalService?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("CongestionReportCoordinator start")
        guard let service = self.service else { return }
        let viewModel = CongestionReportViewModel(service: service)
        let viewController = CongestionReportViewController(viewModel: viewModel)
        
        viewModel.goToMapPickerView = { [weak self] location in
            print("goToMapPickerView")
            self?.showMapPicker(location)
        }
        
        viewModel.backToHome = { [weak self] in
            print("backToHome")
            self?.onFinish?()
        }
        
        viewModel.goToSearchPlaceView = { [weak self] in
            print("goToSearchPlaceView")
            self?.showSearchPlace()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
        debugPrint(navigationController)
    }
    
    func showMapPicker(_ currentLocation: CLLocationCoordinate2D) {
        print("showMapPicker")
        let viewModel = MapPickerViewModel(currentLocation: currentLocation)
        let viewController = MapPickerViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSearchPlace() {
        print("showSearchPlace")
 
        guard let service = self.service else { return }
        
        let coordinator = SearchPlaceCoordinator(navigationController: navigationController)
        coordinator.service = service
        coordinator.onPlaceComplete = { [weak self] place in
            self?.navigationController.popToRootViewController(animated: true)
        }
        
        let viewModel = SearchPlaceViewModel(service: service)
        let viewController = SearchPlaceViewController(viewModel: viewModel)
        
        coordinator.start()
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
