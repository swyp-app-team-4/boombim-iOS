//
//  StatusLabel.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class StatusLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }
    
    private func setupLabel() {
        backgroundColor = .white
        
        font = Typography.Caption.medium.font
        textColor = .grayScale7
        textAlignment = .center
        
        layer.borderColor = UIColor.grayScale3.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds.inset(by: contentInsets), limitedToNumberOfLines: numberOfLines)
        // inset의 반대값을 적용해 프레임을 확장
        let inv = UIEdgeInsets(top: -contentInsets.top, left: -contentInsets.left,
                               bottom: -contentInsets.bottom, right: -contentInsets.right)
        return rect.inset(by: inv)
    }
    
    // 3) 고유 크기에 패딩 더하기
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + contentInsets.left + contentInsets.right,
                      height: s.height + contentInsets.top + contentInsets.bottom)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let target = CGSize(width: size.width - contentInsets.left - contentInsets.right,
                            height: size.height - contentInsets.top - contentInsets.bottom)
        let s = super.sizeThatFits(target)
        return CGSize(width: s.width + contentInsets.left + contentInsets.right,
                      height: s.height + contentInsets.top + contentInsets.bottom)
    }
}
