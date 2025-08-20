//
//  NewsTableViewCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/20/25.
//

import UIKit

final class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 12
        
        return stackView
    }()
    
    private lazy var infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.medium.font
        label.textColor = .grayScale10
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        return label
    }()
    
    private let date: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private lazy var button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .main
        config.baseForegroundColor = .grayScale1
        config.cornerStyle = .capsule   // 둥근 모서리
        
        config.attributedTitle = AttributedString(
            "notification.button.money".localized(),
            attributes: AttributeContainer([.font: Typography.Body02.medium.font])
        )
        
        config.image = .iconWon
        config.imagePlacement = .trailing
        config.imagePadding = 2
        
        // 패딩 (상하 inset만 조절)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        
        let button = UIButton(configuration: config)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureStackView()
        configureInfoStackView()
        configureTextStackView()
    }
    
    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        [infoStackView, button].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 38),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureInfoStackView() {
        [infoImageView, textStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            infoStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            infoImageView.heightAnchor.constraint(equalToConstant: 48),
            infoImageView.widthAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    private func configureTextStackView() {
        [title, date].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(label)
        }
        
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        date.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func configure(_ item: NewsItem) {
        infoImageView.image = item.image
        title.text = item.title
        date.text = item.date
        button.isHidden = !item.isNoti
    }
}
