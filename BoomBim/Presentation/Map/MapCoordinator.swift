//
//  MapCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MapCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let service = KakaoLocalService()
        let officialService = OfficialPlaceService()
        let viewModel = MapViewModel(service: service, officialService: officialService)
        let viewController = MapViewController(viewModel: viewModel)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
