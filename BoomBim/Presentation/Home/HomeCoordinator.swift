//
//  HomeCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    weak var router: ReportRouting?

    init(navigationController: UINavigationController, router: ReportRouting) {
        self.navigationController = navigationController
        self.router = router
    }

    func start() {
        let locationRepo = LocationRepository()
        let viewModel = HomeViewModel(locationRepo: locationRepo)
        let viewController = HomeViewController(viewModel: viewModel)
        
        viewModel.goToCongestionReportView = { [weak self] in
//            self?.showCongestionReport()
            self?.router?.showCongestionReport(selectedPlace: nil, origin: .home)
        }
        
        viewModel.goToSearchView = { [weak self] in
            self?.showSearch()
        }
        
        viewModel.goToNotificationView = { [weak self] in
            self?.showNotification()
        }
        
        viewController.makeUserPlaceDetailViewController = { [weak self] in
            let vc = UserPlaceDetailViewController()
            vc.reportRouter = self?.router
            return vc
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showSearch() {
//        let service = KakaoLocalService()
//        let viewModel = SearchViewModel(service: service)
//        let viewController = SearchViewController(viewModel: viewModel)
//        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showNotification() {
        let service = FcmService()
        let viewModel = NotificationViewModel(service: service)
        let viewController = NotificationViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPlaceDetail(_ place: PlaceItem) {
        let viewModel = PlaceViewModel(place: place)
        let viewController = PlaceViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
