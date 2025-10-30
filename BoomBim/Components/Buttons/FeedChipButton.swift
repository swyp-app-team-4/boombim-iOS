//
//  FeedChipButton.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

final class FeedChipButton: UIButton {
    override var isSelected: Bool { didSet { applyStyle() } }
    
    init(title: String) {
        super.init(frame: .zero)
        
        // 1) 베이스 속성(폰트/커닝 등)만 가진 AttributedString 만들기
        let attr = Typography.Body03.regular
            .attributed(title,
                        color: nil,                 // ← 색은 넣지 말고
                        alignment: .center,
                        kern: nil)

        // 2) 버튼에 상태별 타이틀로 설정
        setAttributedTitle(attr, for: .normal)
        setAttributedTitle(attr, for: .selected)   // 동일 폰트 유지

        // 3) 레이아웃/외형
        titleLabel?.numberOfLines = 1
        contentEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
        layer.cornerRadius = 17
        layer.borderWidth = 1
        heightAnchor.constraint(equalToConstant: 34).isActive = true

        applyStyle()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func applyStyle() {
        if isSelected {
            backgroundColor = .grayScale4
            setTitleColor(.grayScale9, for: .normal)
            layer.borderColor = UIColor.grayScale7.cgColor
        } else {
            backgroundColor = .grayScale1
            setTitleColor(.grayScale8, for: .normal)
            layer.borderColor = UIColor.grayScale6.cgColor
        }
    }
}
