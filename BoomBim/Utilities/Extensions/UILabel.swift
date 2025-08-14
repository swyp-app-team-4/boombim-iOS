//
//  UILabel.swift
//  BoomBim
//
//  Created by 조영현 on 8/14/25.
//

import UIKit

extension UILabel {
    func setText(_ text: String, style: TextStyle, color: UIColor) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight
        self.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: style.font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: color
            ]
        )
    }
}
