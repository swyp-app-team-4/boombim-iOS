//
//  CheckBoxRowView.swift
//  BoomBim
//
//  Created by 조영현 on 10/2/25.
//

import UIKit

final class CheckBoxRowView: UIView {
#if DEBUG
    private let debugName = "CheckBoxRowView"
#endif
    
    // 콜백
    var onToggleCheck: ((Bool) -> Void)?
    
    // 상태
    private(set) var isChecked = false
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let checkBoxButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonUnchecked, for: .normal)
        button.setImage(.buttonChecked, for: .selected)
        button.addTarget(self, action: #selector(tapCheckbox), for: .touchUpInside)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale9
        label.textAlignment = .left
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [checkBoxButton, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        self.isUserInteractionEnabled = true
        checkBoxButton.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
    
    func configure(title: String) {
#if DEBUG
        print("[DEBUG] CheckBoxRowView.configure title=\(title)")
#endif
        titleLabel.setText(title, style: Typography.Body02.semiBold)
    }
    
    // 프로그램/사용자 공통 세터 (emit 옵션)
    func setChecked(_ new: Bool, emit: Bool = false) {
#if DEBUG
        print("[DEBUG] \(debugName).setChecked from=\(isChecked) to=\(new) emit=\(emit)")
#endif
        guard isChecked != new else { return }
        isChecked = new
        updateCheckboxImage()
        if emit { 
            onToggleCheck?(new) 
#if DEBUG
            print("[DEBUG] \(debugName).onToggleCheck fired value=\(new)")
#endif
        }
    }
    
    private func updateCheckboxImage() {
        checkBoxButton.isSelected = isChecked
#if DEBUG
        print("[DEBUG] \(debugName).updateCheckboxImage selected=\(checkBoxButton.isSelected)")
#endif
    }
    
    @objc private func tapCheckbox() {
#if DEBUG
        print("[DEBUG] \(debugName).tapCheckbox isChecked(before)=\(isChecked)")
#endif
        setChecked(!isChecked, emit: true) // 사용자 탭 → 콜백 발화
    }
    
#if DEBUG
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        if inside { print("[DEBUG] \(debugName).point(inside:) point=\(point) inside=\(inside)") }
        return inside
    }
#endif
}
