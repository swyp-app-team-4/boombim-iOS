//
//  OnboardingCoordinator.swift
//  BoomBim
//
//  Created by 조영현 on 9/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingCoordinator {
    let finished = PublishRelay<Void>()
    let rootViewController: UIViewController

    init() {
        let models: [OnboardingPageModel] = [
            .init(titleKey: "onboarding.label.title.first".localized(),
                  subtitleKey: nil,
                  image: .onboarding1),
            .init(titleKey: "onboarding.label.title.second".localized(),
                  subtitleKey: "onboarding.label.subtitle.second".localized(),
                  image: .onboarding2),
            .init(titleKey: "onboarding.label.title.third".localized(),
                  subtitleKey: "onboarding.label.subtitle.third".localized(),
                  image: .onboarding3),
            .init(titleKey: "onboarding.label.title.fourth".localized(),
                  subtitleKey: "onboarding.label.subtitle.fourth".localized(),
                  image: .onboarding4),
            .init(titleKey: "onboarding.label.title.fifth".localized(),
                  subtitleKey: "onboarding.label.subtitle.fifth".localized(),
                  image: .onboarding5),
            .init(titleKey: "onboarding.label.title.sixth".localized(),
                  subtitleKey: "onboarding.label.subtitle.sixth".localized(),
                  image: .onboarding6),
        ]
        
        let vm = OnboardingViewModel(totalPages: models.count)
        let vc = OnboardingViewController(models: models, pageFactory: DefaultOnboardingPageFactory(), viewModel: vm)
        
        self.rootViewController = vc
        // onFinish를 받아서 finished로 릴레이
        vc.onFinish = { [weak self] in
            self?.finished.accept(())
        }
    }

    func start() { /* 필요시 초기 설정 */ }
}
