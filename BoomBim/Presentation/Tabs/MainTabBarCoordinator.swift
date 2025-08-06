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
        let mapNC = UINavigationController()
        let chatNC = UINavigationController()
        let myPageNC = UINavigationController()

        let homeCoordinator = HomeCoordinator(navigationController: homeNC)
        let mapCoordinator = MapCoordinator(navigationController: mapNC)
        let chatCoordinator = ChatCoordinator(navigationController: chatNC)
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNC)
        
        homeNC.tabBarItem = UITabBarItem(title: "홈", image: UIImage.iconHome, selectedImage: UIImage.iconHome)
        mapNC.tabBarItem = UITabBarItem(title: "지도", image: UIImage.iconMap, selectedImage: UIImage.iconMap)
        chatNC.tabBarItem = UITabBarItem(title: "소통", image: UIImage.iconChat, selectedImage: UIImage.iconChat)
        myPageNC.tabBarItem = UITabBarItem(title: "마이", image: UIImage.iconProfile, selectedImage: UIImage.iconProfile)

        homeCoordinator.start()
        mapCoordinator.start()
        chatCoordinator.start()
        myPageCoordinator.start()

        tabBarController.viewControllers = [homeNC, mapNC, chatNC, myPageNC]
    }
}

