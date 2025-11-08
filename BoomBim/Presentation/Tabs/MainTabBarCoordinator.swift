//
//  MainTabBarCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

protocol ReportRouting: AnyObject {
    func showCongestionReport(selectedPlace: Place?, origin: ReportOrigin)
}

final class MainTabBarCoordinator: Coordinator, ReportRouting {
    var navigationController = UINavigationController()
    let tabBarController = UITabBarController()
    
    private var homeCoordinator: HomeCoordinator?
    private var mapCoordinator: MapCoordinator?
//    private var chatCoordinator: ChatCoordinator?
    private var myPageCoordinator: MyPageCoordinator?
    
    private let homeTabIndex = 0
    private let mapTabIndex  = 1
    private let myPageTabIndex  = 2
    
    var childCoordinators: [Coordinator] = []

    func start() {
        let homeNC = UINavigationController()
        let mapNC = UINavigationController()
//        let chatNC = UINavigationController()
        let myPageNC = UINavigationController()

        let homeCoordinator = HomeCoordinator(navigationController: homeNC, router: self)
        let mapCoordinator = MapCoordinator(navigationController: mapNC, router: self)
//        let chatCoordinator = ChatCoordinator(navigationController: chatNC)
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNC, router: self)
        
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
    
    func showCongestionReport(selectedPlace: Place? = nil, origin: ReportOrigin) {
        let origin: ReportOrigin = origin
        
        let reportNav = UINavigationController()
        let reportCoord = CongestionReportCoordinator(
            origin: origin,
            navigationController: reportNav,
            selectedPlace: selectedPlace,
            service: KakaoLocalService(),
            locationRepo: LocationRepository()
        )
        
        reportCoord.onFinish = { [weak self, weak reportCoord] in
            guard let self, let reportCoord else { return }
            self.childCoordinators.removeAll { $0 === reportCoord }

            let presented = self.tabBarController.presentedViewController ?? self.tabBarController.selectedViewController?.presentedViewController

            presented?.dismiss(animated: true, completion: { [weak self] in
                guard let self else { return }

                switch reportCoord.origin {
                case .map:
                    break
                case .home, .myPage, .myPagePoint, .myPageEvent:
                    self.tabBarController.selectedIndex = self.mapTabIndex
                    
                    if let nav = self.tabBarController.viewControllers?[self.mapTabIndex] as? UINavigationController,
                       let mapVC = nav.viewControllers.first(where: { $0 is MapViewController }) as? MapViewController {
                        mapVC.setPreferredInitialMode(.user) // 현장피드로 시작
                    }
                }
                
                // (옵션) 마이페이지 스택도 리셋
                if let myNav = self.tabBarController.viewControllers?[self.myPageTabIndex] as? UINavigationController {
                    myNav.popToRootViewController(animated: false)
                }
            })
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
