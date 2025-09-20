//
//  Profanity.swift
//  BoomBim
//
//  Created by 조영현 on 9/20/25.
//

import Foundation

struct Profanity {
    // 운영은 서버/원격 플래그에서 받아 캐시하는 걸 권장
    static var banned: [String] = [
        // 영어 예시
        "fuck","shit","bitch","asshole","bastard",
        // 한국어 예시
        "시발","씨발","ㅅㅂ","개새끼","닥쳐","미친놈"
    ]
    
    /// 공백/기호 끼워넣기 우회까지 잡는 정규식 패턴 생성 (f*u c k, 시  발 등)
    private static func noisePattern(for w: String) -> String {
        let glue = "[^\\p{L}\\p{Nd}]*" // 문자/숫자 외 임의 문자 허용
        let escaped = w.map { NSRegularExpression.escapedPattern(for: String($0)) }
        return escaped.joined(separator: glue)
    }
    
    private static var regexes: [NSRegularExpression] = {
        banned.compactMap { word in
            let isAscii = word.canBeConverted(to: .ascii)
            let pattern = isAscii
            ? "\\b" + noisePattern(for: word) + "\\b"
            : noisePattern(for: word)
            return try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        }
    }()
    
    /// 금칙어 포함 여부 (매치된 원본문구를 반환)
    static func contains(in text: String) -> String? {
        let norm = normalize(text)
        for (i, rx) in regexes.enumerated() {
            let range = NSRange(location: 0, length: (norm as NSString).length)
            if rx.firstMatch(in: norm, range: range) != nil {
                return banned[i]
            }
        }
        return nil
    }
    
    /// 소문자화 + 호환분해 + 악센트 제거 + leetspeak 일부 치환
    private static func normalize(_ s: String) -> String {
        var x = s.precomposedStringWithCompatibilityMapping.lowercased()
        x = x.folding(options: .diacriticInsensitive, locale: .current)
        let leet: [Character: Character] = ["0":"o","1":"i","3":"e","4":"a","5":"s","7":"t","@":"a","$":"s","!":"i"]
        x = String(x.map { leet[$0] ?? $0 })
        return x
    }
}
