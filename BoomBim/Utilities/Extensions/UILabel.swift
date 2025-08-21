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
}
