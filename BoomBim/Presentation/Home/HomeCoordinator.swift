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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        
        viewModel.goToCongestionReportView = { [weak self] in
            self?.showCongestionReport()
        }
        
        viewModel.goToSearchView = { [weak self] in
            self?.showSearch()
        }
        
        viewModel.goToNotificationView = { [weak self] in
            self?.showNotification()
        }
        
//        viewModel.goToPlaceView = { [weak self] place in
//            self?.showPlaceDetail(place)
//        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showCongestionReport() {
        let service = KakaoLocalService()
        let locationRepo = LocationRepository()
        let viewModel = CongestionReportViewModel(service: service)
        let viewController = CongestionReportViewController(viewModel: viewModel)
//        navigationController.pushViewController(viewController, animated: true)
        
        // 모달 형식 구현시 사용 예정
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let childCoordinator = CongestionReportCoordinator(navigationController: navigationController)
        childCoordinator.service = service
        childCoordinator.locationRepo = locationRepo
        childCoordinator.onFinish = { [weak self, weak childCoordinator] in
            guard let self, let childCoordinator else { return }
            self.childCoordinators.removeAll { $0 === childCoordinator }
            self.navigationController.presentedViewController?.dismiss(animated: true)
        }
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
        
        navigationController.modalPresentationStyle = .fullScreen
        
        self.navigationController.present(navigationController, animated: true)
    }
    
    func showSearch() {
        let viewModel = SearchViewModel()
        let viewController = SearchViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showNotification() {
        let service = FcmService()
        let viewModel = NotificationViewModel(service: service)
        let viewController = NotificationViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPlaceDetail(_ place: PlaceItem) {
        let viewModel = PlaceViewModel(place: place)
        let viewController = PlaceViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
