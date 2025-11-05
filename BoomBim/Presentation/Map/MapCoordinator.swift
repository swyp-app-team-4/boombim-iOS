//
//  MapCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MapCoordinator: Coordinator {
    var navigationController: UINavigationController

    weak var router: ReportRouting?

    init(navigationController: UINavigationController, router: ReportRouting) {
        self.navigationController = navigationController
        self.router = router
    }

    func start() {
        let service = KakaoLocalService()
        let locationRepo = LocationRepository()
        let viewModel = MapViewModel(service: service, locationRepo: locationRepo)
        
        viewModel.goToSearchView = { [weak self] in
            self?.showSearch()
        }
        
        let viewController = MapViewController(viewModel: viewModel)
        
        viewController.makeUserPlaceDetailViewController = { [weak self] in
            let vc = UserPlaceDetailViewController()
            vc.reportRouter = self?.router
            return vc
        }
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showSearch() {
        let service = KakaoLocalService()
        let viewModel = SearchViewModel(service: service)
        let viewController = SearchViewController(viewModel: viewModel)
        
        navigationController.present(viewController, animated: true)
    }
}
