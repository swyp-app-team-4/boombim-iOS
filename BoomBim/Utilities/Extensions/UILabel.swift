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
}
