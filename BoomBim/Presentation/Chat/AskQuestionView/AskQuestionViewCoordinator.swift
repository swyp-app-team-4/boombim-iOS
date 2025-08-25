//
//  AskQuestionViewCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import CoreLocation

final class AskQuestionViewCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    var service: KakaoLocalService?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("AskQuestionViewCoordinator start")
        guard let service = self.service else { return }
        let viewModel = AskQuestionViewModel(service: service)
        let viewController = AskQuestionViewController(viewModel: viewModel)
        
        viewModel.goToMapPickerView = { [weak self] location in
            print("goToMapPickerView")
            self?.showMapPicker(location)
        }
        
        viewModel.backToHome = { [weak self] in
            print("backToHome")
            self?.onFinish?()
        }
        
        viewModel.goToCheckPlaceView = { [weak self] place in
            print("goToCheckPlaceView")
            self?.showCheckPlace(place)
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
    
    func showCheckPlace(_ place: Place) {
        print("showCheckPlace")
        let viewModel = CheckPlaceViewModel(place: place)
        let viewController = CheckPlaceViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
