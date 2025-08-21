//
//  NewsHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class NewsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        return stackView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale10
        
        return label
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
    }
    
    private func configureStackView() {
        [dateLabel, readButton].forEach { button in
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
            stackView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(date: String, buttonHandler: @escaping () -> Void) {
        dateLabel.text = date
        readButton.addAction(UIAction { _ in
            buttonHandler()
        }, for: .touchUpInside)
    }
}
