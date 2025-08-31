//
//  SearchPlaceCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import UIKit
import CoreLocation

final class SearchPlaceCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onComplete: (() -> Void)?
    var onPlaceComplete: ((Place) -> Void)?
    var onFinish: (() -> Void)?
    
    var service: KakaoLocalService?
    var locationRepo: LocationRepository?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("SearchPlaceCoordinator start")
        guard let service = self.service, let locationRepo = self.locationRepo else { return }
        let viewModel = SearchPlaceViewModel(service: service, locationRepo: locationRepo)
        let viewController = SearchPlaceViewController(viewModel: viewModel)
        
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
        
        navigationController.pushViewController(viewController, animated: true)
//        navigationController.setViewControllers([viewController], animated: false)
//        debugPrint(navigationController)
    }
    
    func showMapPicker(_ currentLocation: CLLocationCoordinate2D) {
        print("showMapPicker")
        let viewModel = MapPickerViewModel(currentLocation: currentLocation)
        let viewController = MapPickerViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCheckPlace(_ place: Place) {
        print("showCheckPlace")
        let viewModel = CheckPlaceViewModel(place: place, userLocation: .init(latitude: 15, longitude: 53), mode: .returnPlace)
        
        viewModel.onPlaceComplete = { [weak self] place in
            self?.onPlaceComplete?(place)
        }
        
        let viewController = CheckPlaceViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
