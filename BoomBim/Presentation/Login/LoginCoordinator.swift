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
    // 부모가 주입한 내비게이션 (Login 흐름 전용)
    var navigationController: UINavigationController

    // 부모(AppCoordinator)에게 “로그인 플로우 완료”를 알려줄 시그널
    private let finishedRelay = PublishRelay<Void>()
    var finished: Signal<Void> { finishedRelay.asSignal() }

    private let disposeBag = DisposeBag()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // 1) 뷰모델 생성 (필요시 DI 주입 가능)
        let viewModel = LoginViewModel()

        // 2) 라우팅 신호 구독은 ‘오직 코디네이터에서만’
        //    (VC에서 route를 구독하면 이중 네비게이션 위험)
        viewModel.route
            .emit(onNext: { [weak self] route in
                guard let self = self else { return }
                switch route {
                case .nickname:
                    // 신규/온보딩 사용자: 닉네임 화면으로
                    self.showNickname()
                case .mainTab:
                    // 바로 메인으로: 부모에게 “끝났다” 알림 → 부모가 메인 탭 전환
                    self.finishedRelay.accept(())
                }
            })
            .disposed(by: disposeBag)

        // 3) VC를 만들어 뷰모델 주입 후 표시
        //    (VC는 isLoading/error 바인딩만 하고, 라우팅은 안함)
        let vc = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    /// 닉네임 화면으로 push
    private func showNickname() {
        let viewModel = NicknameViewModel()

        // 닉네임 완료 → 부모에게 완료 알림
        viewModel.signupCompleted
            .emit(onNext: { [weak self] in
                // 닉네임까지 끝났으면 로그인 흐름 종료
                self?.finishedRelay.accept(())
            })
            .disposed(by: disposeBag)

        let vc = NicknameViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}


//final class LoginCoordinator: Coordinator {
//    var navigationController: UINavigationController
//    private let disposeBag = DisposeBag()
//
//    private let finishedRelay = PublishRelay<Void>()
//    var finished: Signal<Void> { finishedRelay.asSignal() }
//
//    init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//    }
//    
//    func start() {
//        let viewModel = LoginViewModel()
//        
//        viewModel.route
//            .emit(onNext: { [weak self] route in
//                switch route {
//                case .nickname:
//                    print("route .nickname")
//                    self?.showNickname()
//                case .mainTab:
//                    print("route .home")
//                    self?.finishedRelay.accept(())
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        let vc = LoginViewController(viewModel: viewModel)
//        navigationController.setViewControllers([vc], animated: false)
//    }
//    
//    func showNickname() {
//        let viewModel = NicknameViewModel()
//        
//        viewModel.signupCompleted
//            .emit(onNext: { [weak self] in
//                self?.finishedRelay.accept(())
//            })
//            .disposed(by: disposeBag)
//        
//        let viewController = NicknameViewController(viewModel: viewModel)
//        navigationController.pushViewController(viewController, animated: true)
//    }
//}
