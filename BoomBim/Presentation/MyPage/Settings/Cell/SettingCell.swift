//
//  SettingCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class SettingCell: UITableViewCell {
    static let identifier = "SettingCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale10
        label.numberOfLines = 1
        
        return label
    }()
    
    private let rightArrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconRightArrow
        imageView.contentMode = .scaleAspectFit

        return imageView
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
        [titleLabel, rightArrowView, separatorView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Chevron
            rightArrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightArrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightArrowView.widthAnchor.constraint(equalToConstant: 22),
            rightArrowView.heightAnchor.constraint(equalToConstant: 22),
            
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
