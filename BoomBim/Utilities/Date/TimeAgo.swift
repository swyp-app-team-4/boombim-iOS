//
//  TimeAgo.swift
//  BoomBim
//
//  Created by 조영현 on 9/7/25.
//

import Foundation

enum TimeAgo {
    /// observedAt: "yyyy-MM-dd'T'HH:mm:ss" 또는 ISO8601(+09:00, Z 등 포함) 지원
    static func minutes(from observedAt: String,
                        defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> Int? {
        // 1) ISO8601 (타임존/초 단위 유무 모두 시도)
        let iso1 = ISO8601DateFormatter()
        iso1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso1.date(from: observedAt) {
            return max(0, Int(Date().timeIntervalSince(d) / 60))
        }
        let iso2 = ISO8601DateFormatter()
        iso2.formatOptions = [.withInternetDateTime]
        if let d = iso2.date(from: observedAt) {
            return max(0, Int(Date().timeIntervalSince(d) / 60))
        }

        // 2) 타임존이 없는 형태면 KST 등 기본 타임존으로 해석
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = defaultTimeZone
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = df.date(from: observedAt) {
            return max(0, Int(Date().timeIntervalSince(d) / 60))
        }

        return nil // 파싱 실패
    }

    /// "방금 전 / N분 전 / N시간 전 ..." 같은 표시가 필요할 때
    static func displayString(from observedAt: String,
                              defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> String {
        guard let mins = minutes(from: observedAt, defaultTimeZone: defaultTimeZone) else {
            return "-"
        }
        if mins < 1 { return "방금 전" }
        if mins < 60 { return "\(mins)분 전" }
        let hours = mins / 60
        if hours < 24 { return "\(hours)시간 전" }
        let days = hours / 24
        return "\(days)일 전"
    }
}
