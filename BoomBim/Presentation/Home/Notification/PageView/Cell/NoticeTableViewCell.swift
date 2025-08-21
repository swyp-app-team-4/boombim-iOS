//
//  NoticeTableViewCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class NoticeTableViewCell: UITableViewCell {
    static let identifier = "NoticeTableViewCell"
    
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
        stackView.alignment = .fill
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
        
        [infoStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
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
    
    func configure(_ item: NoticeItem) {
        infoImageView.image = .iconNotiBell
        title.text = item.title
        date.text = item.date
    }
}
