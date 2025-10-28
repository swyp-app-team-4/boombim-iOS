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
    let value: Double    // 0~100 등 상대 지표
}

extension CongestionLevel {
    // SwiftUI Color로 노출
    var bandColor: Color { Color(self.color) }

    // Chart용 0-based 인덱스
    var bandIndex: Double { Double(self.rawValue - 1) }
}
