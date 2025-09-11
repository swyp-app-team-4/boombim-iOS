//
//  TermRowView.swift
//  BoomBim
//
//  Created by 조영현 on 9/11/25.
//

import UIKit

final class TermRowView: UIControl {
    // 콜백
    var onToggleCheck: ((Bool) -> Void)?
    var onOpenURL: (() -> Void)?
    
    // UI
    private let checkbox = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let openButton = UIButton(type: .system) // chevron
    
    // 상태
    private(set) var isChecked = false
    
    init(title: String, checked: Bool, showChevron: Bool = true) {
        super.init(frame: .zero)
        isChecked = checked
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        // checkbox
        checkbox.setContentHuggingPriority(.required, for: .horizontal)
        checkbox.addTarget(self, action: #selector(tapCheckbox), for: .touchUpInside)
        checkbox.tintColor = .label
        updateCheckboxImage()
        
        // title
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // chevron
        if showChevron {
            openButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            openButton.tintColor = .tertiaryLabel
            openButton.setContentHuggingPriority(.required, for: .horizontal)
            openButton.addTarget(self, action: #selector(tapOpen), for: .touchUpInside)
        } else {
            openButton.isHidden = true
        }
        
        // layout
        let h = UIStackView(arrangedSubviews: [checkbox, titleLabel, openButton])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            h.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
        
        // 행 탭 → URL 열기
        addTarget(self, action: #selector(tapOpen), for: .touchUpInside)
        
        // 하단 1px 구분선
        let line = UIView()
        line.backgroundColor = .separator
        addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),
            line.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setChecked(_ new: Bool) {
        guard isChecked != new else { return }
        isChecked = new
        updateCheckboxImage()
        onToggleCheck?(new)
    }
    
    private func updateCheckboxImage() {
        let name = isChecked ? "checkmark.square.fill" : "square"
        checkbox.setImage(UIImage(systemName: name), for: .normal)
    }
    
    @objc private func tapCheckbox() {
        setChecked(!isChecked)
    }
    
    @objc private func tapOpen() {
        onOpenURL?()
    }
}
