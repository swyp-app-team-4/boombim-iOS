//
//  UIButton.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import UIKit

extension UIButton {
    func setUnderline(
        underlineColor: UIColor = .black,
        spacing: CGFloat = 0
    ) {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        
        // 밑줄 스타일
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count))
        
        // 밑줄 색상 지정
        attributedString.addAttribute(.underlineColor,
                                      value: underlineColor,
                                      range: NSRange(location: 0, length: title.count))
        
        // 밑줄과 텍스트 간격 조절
        attributedString.addAttribute(.baselineOffset,
                                      value: spacing,
                                      range: NSRange(location: 0, length: title.count))
        
        setAttributedTitle(attributedString, for: .normal)
    }
}
