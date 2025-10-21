//
//  PersonalInfoCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class PersonalInfoCell: UITableViewCell {
    static let identifier = "PersonalInfoCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale10
        label.numberOfLines = 1
        
        return label
    }()
    
    private let loginStateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let loginStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let loginStateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale8
        label.numberOfLines = 1
        
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .tableViewDivider
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        
        setupStackView()
        
        [titleLabel, loginStateStackView, separatorView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            loginStateStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loginStateStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
    }
    
    private func setupStackView() {
        [loginStateImageView, loginStateLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            loginStateStackView.addArrangedSubview(view)
        }
    }

    func configure(title: String, state: LoginStateInfo) {
        titleLabel.text = title
        
        if state == .none {
            loginStateImageView.isHidden = true
        }
        
        loginStateImageView.image = state.image
        loginStateLabel.text = state.title
    }
}
