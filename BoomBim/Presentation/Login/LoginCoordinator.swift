//
//  LoginCoordinator.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let disposeBag = DisposeBag()

    private let finishedRelay = PublishRelay<Void>()
    var finished: Signal<Void> { finishedRelay.asSignal() }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = LoginViewModel()
        
        viewModel.route
            .emit(onNext: { [weak self] route in
                switch route {
                case .nickname:
                    print("route .nickname")
                    self?.showNickname()
                case .mainTab:
                    print("route .home")
                    self?.finishedRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        let vc = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func showNickname() {
        let viewModel = NicknameViewModel()
        
        viewModel.signupCompleted
            .emit(onNext: { [weak self] in
                self?.finishedRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        let viewController = NicknameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
