//
//  PointCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit

final class PointCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let router: ReportRouting
    
    init(navigationController: UINavigationController, router: ReportRouting) {
        self.navigationController = navigationController
        self.router = router
    }
    
    var pointViewModel: PointViewModel?

    func start() {
        let viewModel = PointViewModel()
        let viewController = PointViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        
        self.pointViewModel = viewModel
        
        viewModel.goToCongestionReportView = { [weak self] in
            self?.router.showCongestionReport(selectedPlace: nil, origin: .myPagePoint)
        }
        
        viewModel.goToEventInfoView = { [weak self] in
            self?.pushEventView()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func pushEventView() {
        let viewModel = EventViewModel()
        viewModel.goToCongestionReportView = { [weak self] in
            print("point Coordinator")
            self?.router.showCongestionReport(selectedPlace: nil, origin: .myPageEvent)
        }
        
        let viewController = EventViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
