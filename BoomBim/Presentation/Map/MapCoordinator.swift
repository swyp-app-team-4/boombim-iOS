//
//  MapCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class MapCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var router: ReportRouting?
    
    private var mapViewModel: MapViewModel!

    init(navigationController: UINavigationController, router: ReportRouting) {
        self.navigationController = navigationController
        self.router = router
    }

    func start() {
        let service = KakaoLocalService()
        let locationRepo = LocationRepository()
        let viewModel = MapViewModel(service: service, locationRepo: locationRepo)
        self.mapViewModel = viewModel
        
        viewModel.goToSearchView = { [weak self] place in
            self?.showSearch(coord: place)
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
    
    func showSearch(coord: CLLocationCoordinate2D?) {
        let searchNavigation = UINavigationController()
        let searchCoordinator = SearchCoordinator(navigationController: searchNavigation, coord: coord)
        childCoordinators.append(searchCoordinator)
        
        searchCoordinator.onFinish = { [weak self, weak searchCoordinator] place in
            guard let self else { return }
            print("선택한 장소 : \(place)")
            self.mapViewModel.focusPlace.accept(place)
            
            if let searchCoordinator {
                self.childCoordinators.removeAll { $0 === searchCoordinator }
            }
        }
        
        searchCoordinator.start()
        
        searchNavigation.modalPresentationStyle = .fullScreen
        self.navigationController.present(searchNavigation, animated: true)
    }
}
