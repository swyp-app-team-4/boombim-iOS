//
//  RegionCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/19/25.
//

import UIKit

final class RegionCell: UICollectionViewCell {
    static let identifier = "RegionCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let iconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let organization: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.medium.font
        label.textColor = .grayScale8
        label.numberOfLines = 1
        
        return label
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let content: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.numberOfLines = 0
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureStackView()
        configureIcon()
    }
    
    private func configureStackView() {
        [iconStackView, title, content].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        stackView.setCustomSpacing(3, after: title)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
        ])
    }
    
    private func configureIcon() {
        [icon, organization].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            iconStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 16),
            icon.widthAnchor.constraint(equalToConstant: 16),
        ])
    }

    func configure(_ item: RegionItem) {
        icon.image = item.iconImage
        organization.text = item.organization
        
        title.setText(item.title, style: Typography.Body02.semiBold)
        content.setText(item.description,
                        base: Typography.Body03.regular,
                        baseColor: .grayScale8,
                        highlight: [item.time, item.location],
                        highlightStyle: Typography.Body03.medium,
                        highlightColor: .grayScale9)
    }
}
