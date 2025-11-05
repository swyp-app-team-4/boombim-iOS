//
//  HomeCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

protocol HomeCoordinating: AnyObject {
    func makeUserPlaceDetailViewController() -> UserPlaceDetailViewController
    func showCongestionReport(selectedPlace: Place)
}

final class HomeCoordinator: Coordinator, HomeCoordinating {
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
            self?.router?.showCongestionReport(selectedPlace: nil)
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
    
    // MARK: - 사용자 공유 장소에서 사용하기 위해 팩토리 메서드 사용
    func makeUserPlaceDetailViewController() -> UserPlaceDetailViewController {
        let vc = UserPlaceDetailViewController()               // ← 내부에서 세팅
        return vc
    }
    
    func showCongestionReport(selectedPlace: Place) {
        showCongestionReport(selectedPlace: selectedPlace)
    }
    
//    func showCongestionReport(selectedPlace: Place? = nil) {
//        let service = KakaoLocalService()
//        let locationRepo = LocationRepository()
//        let viewModel = CongestionReportViewModel(service: service, selectedPlace: selectedPlace)
//        let viewController = CongestionReportViewController(viewModel: viewModel)
////        navigationController.pushViewController(viewController, animated: true)
//        
//        // 모달 형식 구현시 사용 예정
//        let navigationController = UINavigationController(rootViewController: viewController)
//        
//        let childCoordinator = CongestionReportCoordinator(navigationController: navigationController,
//                                                           selectedPlace: selectedPlace,
//                                                           service: service,
//                                                           locationRepo: locationRepo)
//        
//        childCoordinator.onFinish = { [weak self, weak childCoordinator] in
//            guard let self, let childCoordinator else { return }
//            self.childCoordinators.removeAll { $0 === childCoordinator }
//            self.navigationController.presentedViewController?.dismiss(animated: true)
//        }
//        childCoordinators.append(childCoordinator)
//        childCoordinator.start()
//        
//        navigationController.modalPresentationStyle = .fullScreen
//        
//        self.navigationController.present(navigationController, animated: true)
//    }
    
    func showSearch() {
        let service = KakaoLocalService()
        let viewModel = SearchViewModel(service: service)
        let viewController = SearchViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
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
