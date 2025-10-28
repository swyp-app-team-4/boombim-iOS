//
//  ChartModel.swift
//  BoomBim
//
//  Created by 조영현 on 10/28/25.
//

import SwiftUI

struct HourPoint: Identifiable {
    let id = UUID()
    let hour: Int        // 6~24
    let level: CrowdLevel
    let value: Double    // 0~100 등 상대 지표
}

enum CrowdLevel: Int, CaseIterable {
    case relaxed = 0     // 여유
    case normal          // 보통
    case crowdedLite     // 약간 붐빔
    case crowded         // 붐빔
    
    var name: String {
        switch self {
        case .relaxed: return "여유"
        case .normal: return "보통"
        case .crowdedLite: return "약간 붐빔"
        case .crowded: return "붐빔"
        }
    }
    
    var bandColor: Color {
        switch self {
        case .relaxed: return Color(hex: 0xEAF6E5)     // 연한 초록
        case .normal:  return Color(hex: 0xE9F0FF)     // 연한 파랑
        case .crowdedLite: return Color(hex: 0xFFF3CD) // 연한 노랑
        case .crowded: return Color(hex: 0xFFE2E0)     // 연한 빨강
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8) & 0xFF) / 255.0,
                  blue: Double(hex & 0xFF) / 255.0,
                  opacity: alpha)
    }
}
