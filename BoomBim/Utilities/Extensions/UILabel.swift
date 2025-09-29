//
//  UILabel.swift
//  BoomBim
//
//  Created by 조영현 on 8/14/25.
//

import UIKit

extension UILabel {
    func setStyledText(fullText: String,
                       highlight: String,
                       font: UIFont,
                       highlightFont: UIFont,
                       color: UIColor,
                       highlightColor: UIColor) {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .font: font,
            .foregroundColor: color
        ], range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: highlight) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .font: highlightFont,
                .foregroundColor: highlightColor
            ], range: nsRange)
        }
        
        self.attributedText = attributedString
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
