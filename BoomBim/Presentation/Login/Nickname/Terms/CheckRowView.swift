//
//  CheckRowView.swift
//  BoomBim
//
//  Created by 조영현 on 10/2/25.
//

import UIKit
import SafariServices

final class CheckRowView: UIView {
    // 콜백
    var onToggleCheck: ((Bool) -> Void)?
    
    // 상태
    private(set) var isChecked = false
    
    private let url: URL?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 3
        
        return stackView
    }()
    
    private let checkBoxButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonCheckUnchecked, for: .normal)
        button.setImage(.buttonCheckChecked, for: .selected)
        button.addTarget(self, action: #selector(tapCheckbox), for: .touchUpInside)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale9
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let linkUrlButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconRightArrow, for: .normal)
        
        return button
    }()
    
    init(info: TermsModel) {
        self.url = info.url
        super.init(frame: .zero)
        titleLabel.setText(info.title, style: Typography.Body03.regular)
        
        setupView()
        linkUrlButton.addTarget(self, action: #selector(tapOpen), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [checkBoxButton, titleLabel, spacerView, linkUrlButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // 프로그램/사용자 공통 세터 (emit 옵션)
    func setChecked(_ new: Bool, emit: Bool = false) {
        guard isChecked != new else { return }
        isChecked = new
        updateCheckboxImage()
        if emit { onToggleCheck?(new) }
    }
    
    private func updateCheckboxImage() {
        checkBoxButton.isSelected = isChecked
    }
    
    @objc private func tapCheckbox() {
        setChecked(!isChecked, emit: true) // 사용자 탭 → 콜백 발화
    }
    
    @objc private func tapOpen() {
        guard let url = url else { return }
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .formSheet
        nearestViewController?.present(safari, animated: true)
    }
    
    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}
