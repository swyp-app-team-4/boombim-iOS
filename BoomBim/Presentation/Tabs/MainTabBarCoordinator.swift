//
//  MainTabBarCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {
    var navigationController = UINavigationController()
    let tabBarController = UITabBarController()

    func start() {
        let homeNC = UINavigationController()
        let communityNC = UINavigationController()
        let chatNC = UINavigationController()
        let myPageNC = UINavigationController()

        let homeCoordinator = HomeCoordinator(navigationController: homeNC)
        let communityCoordinator = MapCoordinator(navigationController: communityNC)
        let chatCoordinator = ChatCoordinator(navigationController: chatNC)
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNC)

        homeCoordinator.start()
        communityCoordinator.start()
        chatCoordinator.start()
        myPageCoordinator.start()

        tabBarController.viewControllers = [homeNC, communityNC, chatNC, myPageNC]
        
        tabBarController.tabBar.items?[0].title = "홈"
        tabBarController.tabBar.items?[1].title = "지도"
        tabBarController.tabBar.items?[2].title = "소통"
        tabBarController.tabBar.items?[3].title = "마이"
    }
}

