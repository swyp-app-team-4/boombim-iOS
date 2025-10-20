//
//  BaseModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/19/25.
//

import UIKit

enum CongestionLevel: Int, CaseIterable {
    case relaxed = 1   // 여유
    case normal        // 보통
    case busy          // 약간 붐빔
    case crowded       // 붐빔
    
    init?(ko name: String) {
        switch name {
        case "여유":   self = .relaxed
        case "보통":   self = .normal
        case "약간 붐빔": self = .busy
        case "붐빔":   self = .crowded
        default: return nil
        }
    }
    
    init?(index: Int) {
        guard index >= 0 && index < CongestionLevel.allCases.count else { return nil }
        self = CongestionLevel.allCases[index]
    }
    
    var description: String {
        switch self {
        case .relaxed: return "base.congestion.relaxed".localized()
        case .normal:  return "base.congestion.normal".localized()
        case .busy:    return "base.congestion.busy".localized()
        case .crowded: return "base.congestion.crowded".localized()
        }
    }
    
    var color: UIColor {
        switch self {
        case .relaxed: return .congestionRelaxed
        case .normal:  return .congestionNormal
        case .busy:    return .congestionBusy
        case .crowded: return .congestionCrowded
        }
    }
    
    var icon: UIImage {
        switch self {
        case .relaxed: return .iconCongestionRelaxed
        case .normal:  return .iconCongestionNormal
        case .busy:    return .iconCongestionBusy
        case .crowded: return .iconCongestionCrowded
        }
    }
    
    var badge: UIImage {
        switch self {
        case .relaxed: return .badgeCongestionRelaxed
        case .normal:  return .badgeCongestionNormal
        case .busy:    return .badgeCongestionBusy
        case .crowded: return .badgeCongestionCrowded
        }
    }
    
    static func fromCounts(relaxed: Int, normal: Int, busy: Int, crowded: Int) -> CongestionLevel {
        let pairs: [(CongestionLevel, Int)] = [
            (.relaxed, relaxed),
            (.normal,  normal),
            (.busy,    busy),
            (.crowded, crowded)
        ]
        return pairs.max(by: { $0.1 < $1.1 })?.0 ?? .normal
    }
}
