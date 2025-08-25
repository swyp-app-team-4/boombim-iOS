//
//  AppDateFormatter.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import Foundation
import UIKit

enum AppDateFormatter {
    static let koChatDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")            // 오전/오후
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy.MM.dd a h시"                 // 예: 2025.09.02 오후 2시
        return formatter
    }()
}
