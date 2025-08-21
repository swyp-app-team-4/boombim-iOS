//
//  NoticeHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class NoticeHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NoticeHeaderView"
    
    private enum Tab {
        case notice, event
    }
    private var selected: Tab = .notice { didSet { applySelection() } }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let noticeButton: UIButton = {
        let button = UIButton()
        button.setTitle("notification.button.notice".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        button.setTitleColor(.main, for: .normal)
        button.backgroundColor = .mainSelected
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.main.cgColor
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        return button
    }()
    
    private let eventButton: UIButton = {
        let button = UIButton()
        button.setTitle("notification.button.event".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        button.setTitleColor(.grayScale9, for: .normal)
        button.backgroundColor = .grayScale1
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.grayScale4.cgColor
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        return button
    }()
    
    private let readButton: UIButton = {
        let button = UIButton()
        button.setTitle("notification.button.read".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        button.setTitleColor(.grayScale8, for: .normal)
        
        return button
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        backgroundColor = .white
        
        configureStackView()
        configureButtonStackView()
    }
    
    private func configureStackView() {
        [buttonStackView, readButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            stackView.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func configureButtonStackView() {
        [noticeButton, eventButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            noticeButton.heightAnchor.constraint(equalToConstant: 34),
            eventButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func applySelection() {
        style(button: noticeButton, selected: selected == .notice)
        style(button: eventButton,  selected: selected == .event)
    }
    
    private func style(button: UIButton, selected: Bool) {
        if selected {
            button.setTitleColor(.main, for: .normal)
            button.backgroundColor = .mainSelected
            button.layer.borderColor = UIColor.main.cgColor
        } else {
            button.setTitleColor(.grayScale9, for: .normal)
            button.backgroundColor = .grayScale1
            button.layer.borderColor = UIColor.grayScale4.cgColor
        }
    }
    
    func configure(noticeButtonHandler: @escaping () -> Void, eventButtonHandler: @escaping () -> Void, readButtonHandler: @escaping () -> Void) {
            noticeButton.addAction(UIAction { _ in
                self.selected = .notice
                noticeButtonHandler()
            }, for: .touchUpInside)
            
            eventButton.addAction(UIAction { _ in
                self.selected = .event
                eventButtonHandler()
            }, for: .touchUpInside)
            
            readButton.addAction(UIAction { _ in
                readButtonHandler()
            }, for: .touchUpInside)
    }
}
