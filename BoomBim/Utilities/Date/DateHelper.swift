//
//  TimeAgo.swift
//  BoomBim
//
//  Created by 조영현 on 9/7/25.
//

import Foundation

enum DateHelper {
    // MARK: - Public: 문자열을 Date로 (권장 진입점)
    /// 서버에서 오는 ISO-8601 계열 문자열을 Date로 파싱합니다.
    /// - naive(타임존 없는) 문자열은 기본적으로 UTC로 해석합니다.
    static func parseServerDate(_ s: String,
                                naiveTimeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) -> Date? {
        // 1) 타임존 명시(Z, ±HH:MM/±HHMM/±HH)가 있으면 ISO8601 파서
        if hasExplicitTimeZone(in: s) {
            if let d = iso8601FS.date(from: s) { return d }
            if let d = iso8601.date(from: s)   { return d }
            return nil
        }
        
        // 2) 타임존이 없으면(naive) 분수초(소수부) 자릿수를 6자리로 정규화 후, 지정 TZ로 파싱
        let normalized = normalizeFractionTo6Digits(s)
        return posixNaive(naiveTimeZone).date(from: normalized)
    }
    
    // MARK: - 기존 공개 API (그대로 유지 가능)
    static func minutes(from observedAt: String,
                        defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> Int? {
        // observedAt 은 서버 측 ISO 문자열이라고 가정
        guard let date = parseServerDate(observedAt, naiveTimeZone: TimeZone(secondsFromGMT: 0)!) else { return nil }
        let diff = Date().timeIntervalSince(date)
        return max(0, Int(diff / 60.0)) // 미래 시간이면 0으로 클램프
    }
    
    static func getHour(from forecastTime: String) -> Int? {
        // "2025-10-30T18:00:00" ← 타임존 표기 없음 → 정책에 맞춰 해석(여기서는 UTC로 가정)
        guard let date = parseServerDate(forecastTime, naiveTimeZone: TimeZone(secondsFromGMT: 0)!) else { return nil }
        return Calendar.current.component(.hour, from: date)
    }
    
    /// "방금 전 / N분 전 / N시간 전 / N일 전"
    static func displayString(from observedAt: String,
                              defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> String {
        guard let mins = minutes(from: observedAt, defaultTimeZone: defaultTimeZone) else { return "-" }
        if mins < 1 { return "방금 전" }
        if mins < 60 { return "\(mins)분 전" }
        let hours = mins / 60
        if hours < 24 { return "\(hours)시간 전" }
        let days = hours / 24
        return "\(days)일 전"
    }
    
    // 필요시 유지: 고정 포맷 파서들
    static let iso6: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return df
    }()
    static let iso0: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }()
    
    static func parse(_ s: String) -> Date? {
        if let d = iso6.date(from: s) { return d }
        if let dot = s.firstIndex(of: ".") {
            let base = String(s[..<dot])
            if let d = iso0.date(from: base) { return d }
        }
        return iso0.date(from: s)
    }
    
    /// "2025-09-07T00:00:00" → "2025년 9월 7일 (일)"
    static func koreanFullDate(_ isoString: String,
                               defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> String {
        // 먼저 Date로 파싱: 타임존 있으면 그대로, 없으면 defaultTimeZone로 해석하고자 한다면:
        let date: Date? = {
            if hasExplicitTimeZone(in: isoString) {
                return iso8601FS.date(from: isoString) ?? iso8601.date(from: isoString)
            } else {
                // naive → defaultTimeZone 기준의 '현지 시각'으로 해석 후 절대시각 생성
                return posixNaive(defaultTimeZone).date(from: normalizeFractionTo6Digits(isoString))
            }
        }()
        
        guard let d = date else { return "-" }
        
        let out = DateFormatter()
        out.locale = Locale(identifier: "ko_KR")
        out.timeZone = defaultTimeZone
        out.calendar = Calendar(identifier: .gregorian)
        out.dateFormat = "yyyy년 M월 d일 (E)"
        return out.string(from: d)
    }
    
    /// "2025-09-07T00:00:00" → "yyyy-MM-dd HH:mm"
    static func fullDate(_ isoString: String,
                         defaultTimeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> String {
        let date: Date? = {
            if hasExplicitTimeZone(in: isoString) {
                return iso8601FS.date(from: isoString) ?? iso8601.date(from: isoString)
            } else {
                return posixNaive(defaultTimeZone).date(from: normalizeFractionTo6Digits(isoString))
            }
        }()
        
        guard let d = date else { return "-" }
        
        let out = DateFormatter()
        out.locale = Locale(identifier: "ko_KR")
        out.timeZone = defaultTimeZone
        out.calendar = Calendar(identifier: .gregorian)
        out.dateFormat = "yyyy-MM-dd HH:mm"
        return out.string(from: d)
    }
    
    // MARK: - Private helpers/formatters
    
    /// 타임존 표기(Z, +09:00, -0300 등) 감지
    private static func hasExplicitTimeZone(in s: String) -> Bool {
        if s.hasSuffix("Z") { return true }
        // +09:00 / -0300 / +09  같은 패턴
        let pattern = #"([+-]\d{2}(:?\d{2})?)$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
    
    /// 소수부(분수초) 자릿수를 6자리(마이크로초)로 정규화
    private static func normalizeFractionTo6Digits(_ s: String) -> String {
        guard let dot = s.firstIndex(of: ".") else {
            return s + ".000000"
        }
        let head = String(s[..<dot])
        let tail = String(s[s.index(after: dot)...])
        let digits = tail.prefix { $0.isNumber }
        var frac = String(digits)
        if frac.count >= 6 {
            frac = String(frac.prefix(6))
        } else {
            frac = frac.padding(toLength: 6, withPad: "0", startingAt: 0)
        }
        return head + "." + frac
    }
    
    /// ISO8601 파서(분수초 포함)
    private static let iso8601FS: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    /// ISO8601 파서(분수초 없음)
    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    
    /// naive(타임존 없는) 문자열을 특정 타임존 기준 현지시각으로 해석하는 포맷터
    private static func posixNaive(_ tz: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale   = Locale(identifier: "en_US_POSIX")
        f.timeZone = tz
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return f
    }
    
    // MARK: - KST 표기용 공통 자원
    private static let kstTZ = TimeZone(identifier: "Asia/Seoul")!
    private static let gregorian = Calendar(identifier: .gregorian)
    
    /// 섹션 헤더: "yyyy. MM. dd (E)"
    static let headerKST: DateFormatter = {
        let f = DateFormatter()
        f.locale   = Locale(identifier: "ko_KR")
        f.calendar = gregorian
        f.timeZone = kstTZ
        f.dateFormat = "yyyy. MM. dd (E)"
        return f
    }()
    
    /// 셀 시간: "HH:mm"
    static let timeKST: DateFormatter = {
        let f = DateFormatter()
        f.locale   = Locale(identifier: "ko_KR")
        f.calendar = gregorian
        f.timeZone = kstTZ
        f.dateFormat = "HH:mm"
        return f
    }()
    
    /// 날짜 → "yyyy. MM. dd (E)"
    static func formatHeaderKST(_ date: Date) -> String {
        headerKST.string(from: date)
    }
    
    /// 날짜 → "HH:mm"
    static func formatTimeKST(_ date: Date) -> String {
        timeKST.string(from: date)
    }
    
    /// 서버 ISO 문자열 → "yyyy. MM. dd (E)"
    static func formatHeaderKST(from isoString: String) -> String {
        guard let d = parseServerDate(isoString) else { return "-" }
        return headerKST.string(from: d)
    }
    
    /// 서버 ISO 문자열 → "HH:mm"
    static func formatTimeKST(from isoString: String) -> String {
        guard let d = parseServerDate(isoString) else { return "-" }
        return timeKST.string(from: d)
    }
    
    /// KST 기준으로 해당 날짜의 00:00:00
    static func startOfDayKST(for date: Date) -> Date {
        var cal = gregorian
        cal.timeZone = kstTZ
        return cal.startOfDay(for: date)
    }
}
