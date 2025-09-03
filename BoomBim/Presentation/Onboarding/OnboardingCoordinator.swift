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
        let vc = OnboardingViewController()
        self.rootViewController = vc
        // ✅ onFinish를 받아서 finished로 릴레이
        vc.onFinish = { [weak self] in self?.finished.accept(()) }
    }

    func start() { /* 필요시 초기 설정 */ }
}
