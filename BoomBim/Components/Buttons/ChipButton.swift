//
//  ChipButton.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

final class ChipButton: UIButton {
    override var isSelected: Bool { didSet { applyStyle() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        applyStyle()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func applyStyle() {
        if isSelected {
            backgroundColor = .mainSelected
            layer.borderColor = UIColor.main.cgColor
            setTitleColor(.main, for: .normal)
        } else {
            backgroundColor = .grayScale1
            layer.borderColor = UIColor.grayScale4.cgColor
            setTitleColor(.grayScale9, for: .normal)
        }
    }
}
