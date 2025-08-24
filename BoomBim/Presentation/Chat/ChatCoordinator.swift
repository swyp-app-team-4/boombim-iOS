//
//  ChatCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class ChatCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = ChatViewModel()
        let viewController = ChatViewController(viewModel: viewModel)
        
        viewModel.goToQuestionView = { [weak self] in
            self?.showQuestionReport()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showQuestionReport() {
        let service = KakaoLocalService()
        let viewModel = AskQuestionViewModel(service: service)
        let viewController = AskQuestionViewController(viewModel: viewModel)
//        navigationController.pushViewController(viewController, animated: true)
        
        
        
        // 모달 형식 구현시 사용 예정
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let childCoordinator = AskQuestionViewCoordinator(navigationController: navigationController)
        childCoordinator.service = service
        childCoordinator.onFinish = { [weak self, weak childCoordinator] in
            guard let self, let childCoordinator else { return }
            self.childCoordinators.removeAll { $0 === childCoordinator }
            self.navigationController.presentedViewController?.dismiss(animated: true)
        }
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
        
        navigationController.modalPresentationStyle = .fullScreen
        
        self.navigationController.present(navigationController, animated: true)
    }
    
    @objc private func didTapClose() {
        self.navigationController.presentedViewController?.dismiss(animated: true)
    }
}
