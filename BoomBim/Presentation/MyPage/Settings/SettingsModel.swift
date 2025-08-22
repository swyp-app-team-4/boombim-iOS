//
//  SettingsModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

enum SettingsRow: Int, CaseIterable {
    case profile
    case push
    case terms
    case loginInfo
    case guide
    case support
    case faq
    
    var title: String {
        switch self {
        case .profile: return "settings.label.profile".localized()
        case .push: return "settings.label.push".localized()
        case .terms: return "settings.label.terms".localized()
        case .loginInfo: return "settings.label.loginInfo".localized()
        case .guide: return "settings.label.guide".localized()
        case .support: return "settings.label.support".localized()
        case .faq: return "settings.label.faq".localized()
        }
    }
}
