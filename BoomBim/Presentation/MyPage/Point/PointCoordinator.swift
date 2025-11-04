//
//  PointCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit

final class PointCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let initialPoint: UserPoint

    init(navigationController: UINavigationController, initialPoint: UserPoint) {
        self.navigationController = navigationController
        self.initialPoint = initialPoint
    }
    
    var pointViewModel: PointViewModel?

    func start() {
        let viewModel = PointViewModel(initialPoint: initialPoint)
        let viewController = PointViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        
        self.pointViewModel = viewModel
        
        viewModel.goToEventInfoView = { [weak self] in
            self?.pushEventView()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func pushEventView() {
        let viewModel = EventViewModel()
        let viewController = EventViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
