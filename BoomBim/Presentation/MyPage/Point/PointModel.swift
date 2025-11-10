//
//  PointModel.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import Foundation

struct PointHistoryItem: Hashable {
    let date: Date          // 전체 날짜
    let title: String       // 예: "혼잡도 알리기", "이벤트 응모"
    let delta: Int          // +10 / -20 (부호 포함 정수)
    let balance: Int        // 32020 같은 누적 잔액
}
