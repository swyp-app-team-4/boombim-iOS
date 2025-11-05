//
//  MainTabBarCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

protocol ReportRouting: AnyObject {
    func showCongestionReport(selectedPlace: Place?)
}

final class MainTabBarCoordinator: Coordinator, ReportRouting {
    var navigationController = UINavigationController()
    let tabBarController = UITabBarController()
    
    private var homeCoordinator: HomeCoordinator?
    private var mapCoordinator: MapCoordinator?
//    private var chatCoordinator: ChatCoordinator?
    private var myPageCoordinator: MyPageCoordinator?
    
    var childCoordinators: [Coordinator] = []

    func start() {
        let homeNC = UINavigationController()
        let mapNC = UINavigationController()
//        let chatNC = UINavigationController()
        let myPageNC = UINavigationController()

        let homeCoordinator = HomeCoordinator(navigationController: homeNC, router: self)
        let mapCoordinator = MapCoordinator(navigationController: mapNC, router: self)
//        let chatCoordinator = ChatCoordinator(navigationController: chatNC)
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNC)
        
        self.homeCoordinator = homeCoordinator
        self.mapCoordinator = mapCoordinator
//        self.chatCoordinator = chatCoordinator
        self.myPageCoordinator = myPageCoordinator
        
        homeNC.tabBarItem = UITabBarItem(title: "", image: UIImage.iconHome, selectedImage: UIImage.iconHome)
        mapNC.tabBarItem = UITabBarItem(title: "", image: UIImage.iconMap, selectedImage: UIImage.iconMap)
//        chatNC.tabBarItem = UITabBarItem(title: "", image: UIImage.iconChat, selectedImage: UIImage.iconChat)
        myPageNC.tabBarItem = UITabBarItem(title: "", image: UIImage.iconProfile, selectedImage: UIImage.iconProfile)

        homeCoordinator.start()
        mapCoordinator.start()
//        chatCoordinator.start()
        myPageCoordinator.start()

        tabBarController.viewControllers = [homeNC, mapNC, /*chatNC,*/ myPageNC]
    }
    // ✅ 공용 라우터 구현 (탭 어디서든 호출)
    func showCongestionReport(selectedPlace: Place? = nil) {
        // 1) Report 전용 내비 + Coordinator 생성
        let reportNav = UINavigationController()
        let reportCoord = CongestionReportCoordinator(
            navigationController: reportNav,
            selectedPlace: selectedPlace,
            service: KakaoLocalService(),
            locationRepo: LocationRepository()
        )
        
        // 2) 해제 처리
        reportCoord.onFinish = { [weak self, weak reportCoord] in
            guard let self, let reportCoord else { return }
            self.childCoordinators.removeAll { $0 === reportCoord }
            // 현재 선택 탭 위에서 dismiss
            self.tabBarController.selectedViewController?.presentedViewController?.dismiss(animated: true)
        }
        
        // 3) 보관 + 시작
        childCoordinators.append(reportCoord)
        reportCoord.start()
        
        // 4) 현재 선택된 탭 위에서 present (⭐ 핵심)
        reportNav.modalPresentationStyle = .fullScreen
        (tabBarController.selectedViewController ?? tabBarController).present(reportNav, animated: true)
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
}
