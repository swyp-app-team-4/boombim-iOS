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
    
    // Text 높이를 조절하기 위하여 적용
    func setTitle(_ title: String?,
                  style: TextStyle,
                  for state: UIControl.State,
                  color: UIColor? = nil,
                  kern: CGFloat? = nil) {
        let raw = title ?? ""
        
        // 버튼의 horizontalAlignment를 NSTextAlignment로 매핑
        let align: NSTextAlignment = {
            switch self.contentHorizontalAlignment {
            case .left, .leading:  return .left
            case .right, .trailing: return .right
            default: return .center
            }}()
        
        let attr = style.attributed(raw, color: color ?? self.titleColor(for: state), alignment: align, kern: kern)
        
        setAttributedTitle(attr, for: state)
        titleLabel?.numberOfLines = 1
    }
}
