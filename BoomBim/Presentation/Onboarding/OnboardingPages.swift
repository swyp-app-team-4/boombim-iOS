//
//  OnboardingPages.swift
//  BoomBim
//
//  Created by 조영현 on 9/18/25.
//

import UIKit

/// 온보딩 1장에 대한 데이터 모델 (로컬라이즈 키를 들고 있음)
struct OnboardingPageModel {
    let titleKey: String
    let subtitleKey: String?
    let image: UIImage
}

/// 모델을 실제 화면(ViewController)로 바꿔주는 팩토리
protocol OnboardingPageFactory {
    func make(from model: OnboardingPageModel) -> UIViewController
}

/// 기본 구현: 로컬라이즈 키 → String.localized() 적용 + 이미지 주입
final class DefaultOnboardingPageFactory: OnboardingPageFactory {
    func make(from model: OnboardingPageModel) -> UIViewController {
        OnboardingPageViewController(
            title: model.titleKey.localized(),
            subTitle: model.subtitleKey?.localized(),
            image: model.image
        )
    }
}
