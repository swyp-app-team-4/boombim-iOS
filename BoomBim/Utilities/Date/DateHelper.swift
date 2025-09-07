//
//  TimeAgo.swift
//  BoomBim
//
//  Created by 조영현 on 9/7/25.
//

import Foundation

enum DateHelper {
    static func minutes(from observedAt: String, defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> Int? {
        guard let date = parseObservedAt(observedAt, tz: defaultTimeZone) else { return nil }
        let diff = Date().timeIntervalSince(date)
        return max(0, Int(diff / 60.0)) // 미래 시간이면 0으로 클램프
    }
    
    private static func parseObservedAt(_ s: String, tz: TimeZone) -> Date? {
        // 1) ISO8601 + (옵션)분수초
        let iso = ISO8601DateFormatter()
        iso.timeZone = tz
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: s) { return d }
        
        // 2) 타임존 표기가 전혀 없는 로컬 형태들(서버가 나이브 문자열을 줄 때)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = tz
        
        // 마이크로초(6자리)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let d = df.date(from: s) { return d }
        
        // 밀리초(3자리)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let d = df.date(from: s) { return d }
        
        // 분수초 없음
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df.date(from: s)
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
    
    static let iso6: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0) // 전부 같은 TZ면 정렬 순서엔 영향 없음
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return df
    }()
    static let iso0: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }()
    
    static func parse(_ s: String) -> Date? {
        // 1) 마이크로초 시도
        if let d = iso6.date(from: s) { return d }
        // 2) 소수점 잘라서 재시도
        if let dot = s.firstIndex(of: ".") {
            let base = String(s[..<dot])
            if let d = iso0.date(from: base) { return d }
        }
        // 3) 그냥 초 단위 포맷 시도
        return iso0.date(from: s)
    }
}
