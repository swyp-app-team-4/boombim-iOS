//
//  SettingsModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

enum SettingsRow: Int, CaseIterable {
    case profile // 개인정보 관리
    case push // 알림 설정
    case terms // 이용약관
    case privacy // 개인 정보 처리 방침
    case guide // 서비스 이용안내
    case support // 고객센터 / 문의
    case faq // 건의사항 남기기
    
    var title: String {
        switch self {
        case .profile: return "settings.label.profile".localized()
        case .push: return "settings.label.push".localized()
        case .terms: return "settings.label.terms".localized()
        case .privacy: return "settings.label.privacy".localized()
        case .guide: return "settings.label.guide".localized()
        case .support: return "settings.label.support".localized()
        case .faq: return "settings.label.faq".localized()
        }
    }
}
