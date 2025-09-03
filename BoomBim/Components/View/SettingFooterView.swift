//
//  SettingFooterView.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import UIKit

final class SettingsFooterView: UIView {
    
    let spaceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6
        
        return stackView
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("settings.button.logout".localized(), for: .normal)
        button.setTitleColor(.grayScale7, for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        
        return button
    }()
    
    let withdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle("settings.button.withdraw".localized(), for: .normal)
        button.setTitleColor(.grayScale7, for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        [spaceView, buttonStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        [logoutButton, withdrawButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            spaceView.topAnchor.constraint(equalTo: topAnchor),
            spaceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            spaceView.trailingAnchor.constraint(equalTo: trailingAnchor),
            spaceView.heightAnchor.constraint(equalToConstant: 24),
            
            buttonStackView.topAnchor.constraint(equalTo: spaceView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 22),
            withdrawButton.heightAnchor.constraint(equalToConstant: 22),
            
            heightAnchor.constraint(equalToConstant: 74)
        ])
    }
}

