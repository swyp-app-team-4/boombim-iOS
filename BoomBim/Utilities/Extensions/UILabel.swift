//
//  UILabel.swift
//  BoomBim
//
//  Created by 조영현 on 8/14/25.
//

import UIKit

extension UILabel {
    func setStyledText(
            fullText: String,
            highlight: String,
            baseStyle: TextStyle,
            highlightFont: UIFont,
            baseColor: UIColor? = nil,
            highlightColor: UIColor,
            alignment: NSTextAlignment? = nil,
            kern: CGFloat? = nil,
            caseInsensitive: Bool = false, // 대소문자 구분 없이 찾을지 여부
            applyToAllOccurrences: Bool = false // 하이라이트 Text가 여러번 등장 시 적용
        ) {
            // 1) 전체에 lineHeight + baselineOffset + (선택)kern + 색상 적용
            let baseAttr = baseStyle.attributed(
                fullText,
                color: baseColor ?? self.textColor,
                alignment: alignment ?? self.textAlignment,
                kern: kern
            )
            let result = NSMutableAttributedString(attributedString: baseAttr)

            // 2) 하이라이트 범위 찾기
            guard !highlight.isEmpty, fullText.contains(highlight) else {
                self.numberOfLines = 0
                self.attributedText = result
                return
            }

            let searchOptions: NSString.CompareOptions = caseInsensitive ? [.caseInsensitive] : []
            let nsText = fullText as NSString
            var searchRange = NSRange(location: 0, length: nsText.length)

            func apply(on range: NSRange) {
                result.addAttributes([
                    .font: highlightFont,
                    .foregroundColor: highlightColor
                ], range: range)
            }

            if applyToAllOccurrences {
                while true {
                    let found = nsText.range(of: highlight, options: searchOptions, range: searchRange)
                    if found.location == NSNotFound { break }
                    apply(on: found)
                    let nextLoc = found.location + found.length
                    searchRange = NSRange(location: nextLoc, length: nsText.length - nextLoc)
                }
            } else {
                let first = nsText.range(of: highlight, options: searchOptions, range: searchRange)
                if first.location != NSNotFound { apply(on: first) }
            }

            self.numberOfLines = 0
            self.attributedText = result
        }
    
    // Text 높이를 조절하기 위하여 적용
    func setText(_ text: String?,
                 style: TextStyle,
                 color: UIColor? = nil,
                 alignment: NSTextAlignment? = nil,
                 kern: CGFloat? = nil) {
        let raw = text ?? ""
        let attr = style.attributed(raw, color: color ?? self.textColor, alignment: alignment ?? self.textAlignment, kern: kern)
        
        numberOfLines = 0
        attributedText = attr
    }
    
    // 특정 문자열에 별도 폰트 적용
    func setText(_ text: String,
                 base: TextStyle,
                 baseColor: UIColor,
                 highlight substrings: [String],
                 highlightStyle: TextStyle,
                 highlightColor: UIColor,
                 allOccurrences: Bool = true,
                 options: NSString.CompareOptions = [.caseInsensitive]) {
        let attr = base.attributed(text, color: baseColor, alignment: self.textAlignment, kern: nil)
        let m = NSMutableAttributedString(attributedString: attr)

        let hl = highlightStyle.attributed(" ", color: highlightColor, alignment: self.textAlignment, kern: nil)
            .attributes(at: 0, effectiveRange: nil)

        let ns = text as NSString
        for s in substrings {
            var searchRange = NSRange(location: 0, length: ns.length)
            while true {
                let r = ns.range(of: s, options: options, range: searchRange)
                guard r.location != NSNotFound else { break }
                m.addAttributes(hl, range: r)
                if !allOccurrences { break }
                let nextLoc = r.location + r.length
                if nextLoc >= ns.length { break }
                searchRange = NSRange(location: nextLoc, length: ns.length - nextLoc)
            }
        }
        numberOfLines = 0
        attributedText = m
    }
    
    func setPoints(
            _ value: Int,
            numberStyle: TextStyle,
            numberColor: UIColor,
            suffix: String = " P",
            suffixStyle: TextStyle = Typography.Body03.medium,
            suffixColor: UIColor = .grayScale8,
            alignment: NSTextAlignment? = nil,
            kern: CGFloat? = nil,
            includeSign: Bool = false,     // ✅ 부호 출력 여부
            zeroSign: String = "+"        // ✅ 0일 때 부호(원하면 "" 로)
        ) {
            // 부호 결정 (+, −, 0일 때는 zeroSign)
            let sign: String = {
                guard includeSign else { return "" }
                if value < 0 { return "−" }     // 대시 대신 U+2212
                if value > 0 { return "+" }
                return zeroSign
            }()

            // 절댓값으로 3자리 콤마 포맷
            let nf = NumberFormatter()
            nf.locale = Locale(identifier: "en_US_POSIX")
            nf.numberStyle = .decimal
            nf.usesGroupingSeparator = true
            nf.groupingSeparator = ","
            nf.groupingSize = 3
            nf.maximumFractionDigits = 0
            let absValue = abs(value)
            let grouped = nf.string(from: NSNumber(value: absValue)) ?? "\(absValue)"

            // 최종 숫자 문자열 = 부호 + 포맷된 숫자
            let signedNumberText = sign + grouped
            // print("signedNumberText:", signedNumberText) // 예: +32,020 / −20

            // 스타일 적용
            let align = alignment ?? self.textAlignment
            let numberAttr = numberStyle.attributed(
                signedNumberText,
                color: numberColor,
                alignment: align,
                kern: kern
            )
            let pAttr = suffixStyle.attributed(
                suffix,
                color: suffixColor,
                alignment: align,
                kern: kern
            )

            // 합치기
            let result = NSMutableAttributedString()
            result.append(numberAttr)
            result.append(pAttr)

            numberOfLines = 1
            attributedText = result
        }
}
