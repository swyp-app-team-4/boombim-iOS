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
    let level: CongestionLevel
    // level에 의해 자동 계산
    var value: Double {
        level.bandCenterValue
    }
}

extension CongestionLevel {
    var bandCenterValue: Double {
        (Double(rawValue) - 0.5) * 25.0
    }
    
    // SwiftUI Color로 노출
    var bandColor: Color { Color(self.color) }

    // Chart용 0-based 인덱스
    var bandIndex: Double { Double(self.rawValue - 1) }
}
