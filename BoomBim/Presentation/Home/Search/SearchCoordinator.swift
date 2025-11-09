//
//  SearchCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import UIKit
import CoreLocation

final class SearchCoordinator: Coordinator {
    var navigationController: UINavigationController
    var userCoordinate: CLLocationCoordinate2D?
    var onFinish: ((Place) -> Void)?
    
    init(navigationController: UINavigationController, coord: CLLocationCoordinate2D?) {
        self.navigationController = navigationController
        self.userCoordinate = coord
    }

    func start() {
        let service = KakaoLocalService()
        let viewModel = SearchViewModel(service: service, coord: userCoordinate)
        let viewController = SearchViewController(viewModel: viewModel)
        
        viewController.onPlaceSelected = { [weak self] place in
            guard let self else { return }
            navigationController.dismiss(animated: true) {
                self.onFinish?(place)
            }
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}
