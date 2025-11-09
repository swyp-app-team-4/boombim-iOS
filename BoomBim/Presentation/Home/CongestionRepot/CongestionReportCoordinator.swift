//
//  CongestionReportCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import CoreLocation

final class CongestionReportCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    var childCoordinators: [Coordinator] = []
    
    let origin: ReportOrigin
    
    private let selectedPlace: Place?
    private let service: KakaoLocalService
    private let locationRepo: LocationRepository
    private var rootViewModel: CongestionReportViewModel?
    
    init(origin: ReportOrigin,
        navigationController: UINavigationController,
         selectedPlace: Place?,
         service: KakaoLocalService,
         locationRepo: LocationRepository) {
        self.origin = origin
        self.navigationController = navigationController
        self.selectedPlace = selectedPlace
        self.service = service
        self.locationRepo = locationRepo
    }
    
    func start() {
        let viewModel = CongestionReportViewModel(service: service, selectedPlace: selectedPlace)
        let viewController = CongestionReportViewController(viewModel: viewModel)
        rootViewModel = viewModel
        
        if selectedPlace == nil {
            viewModel.goToMapPickerView = { [weak self] coord in self?.showMapPicker(coord) }
            viewModel.goToSearchPlaceView = { [weak self] in self?.showSearchPlace() }
        } else {
            viewModel.goToMapPickerView = nil
            viewModel.goToSearchPlaceView = nil
        }
        
        viewModel.backToHome = { [weak self] in
            print("backToHome")
            self?.onFinish?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showMapPicker(_ currentLocation: CLLocationCoordinate2D) {
        print("showMapPicker")
        let viewModel = MapPickerViewModel(currentLocation: currentLocation)
        let viewController = MapPickerViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSearchPlace() {
        print("showSearchPlace")
        let childCoordinator = SearchPlaceCoordinator(navigationController: navigationController)
        childCoordinator.service = service
        childCoordinator.locationRepo = locationRepo
        
        // 결과 전달
        childCoordinator.onPlaceComplete = { [weak self, weak childCoordinator] place, id in
            guard let self else { return }

            // 먼저 child coordinator 정리 (추가 콜백 방지)
            if let childCoordinator {
                self.childCoordinators.removeAll { $0 === childCoordinator }
            }

            // 루트로 복귀
            self.navigationController.popToRootViewController(animated: true)

            // 전환 완료 후 루트 뷰모델에 값 전달
            if let coordinator = self.navigationController.transitionCoordinator {
                coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                    self?.rootViewModel?.setSelectedPlace(place: place, id: id)
                }
            } else {
                // 애니메이션이 없거나 transitionCoordinator가 없는 경우 안전하게 메인 큐에서 전달
                DispatchQueue.main.async { [weak self] in
                    self?.rootViewModel?.setSelectedPlace(place: place, id: id)
                }
            }
        }
        
        // child 종료 시 정리
        childCoordinator.onFinish = { [weak self, weak childCoordinator] in
            guard let self, let childCoordinator else { return }
            self.childCoordinators.removeAll { $0 === childCoordinator }
        }
        
        childCoordinators.append(childCoordinator)
        
        childCoordinator.start()
    }
}
