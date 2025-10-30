//
//  FeedChipButton.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

final class FeedChipButton: UIButton {
    override var isSelected: Bool { didSet { applyStyle() } }
    override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.7 : 1 } }
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
        layer.cornerRadius = 20
        layer.borderWidth = 1
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
