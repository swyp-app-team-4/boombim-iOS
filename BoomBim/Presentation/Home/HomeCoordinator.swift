//
//  HomeCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        
        viewModel.goToSearchView = { [weak self] in
            self?.showSearch()
        }
        
        viewModel.goToNotificationView = { [weak self] in
            self?.showNotification()
        }
        
        viewModel.goToPlaceView = { [weak self] place in
            self?.showPlaceDetail(place)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showSearch() {
        let viewModel = SearchViewModel()
        let viewController = SearchViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showNotification() {
        let viewModel = NotificationViewModel()
        let viewController = NotificationViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPlaceDetail(_ place: PlaceItem) {
        let viewModel = PlaceViewModel(place: place)
        let viewController = PlaceViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
