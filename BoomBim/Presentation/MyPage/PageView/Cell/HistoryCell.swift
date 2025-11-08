//
//  HistoryCell.swift
//  BoomBim
//
//  Created by 조영현 on 11/7/25.
//

import UIKit

final class HistoryCell: UITableViewCell {
    static let reuseID = "HistoryCell"
    
    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(contentStackView)
        
        [titleLabel, timeLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(label)
        }
        
        [textStackView, congestionImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            
            contentStackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            contentStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            contentStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
    }
    
    func apply(title: String, timeText: String, level: String) {
        titleLabel.setText(title, style: Typography.Body02.semiBold)
        timeLabel.setText(timeText, style: Typography.Caption.regular)
        congestionImageView.image = CongestionLevel.init(ko: level)?.badge
    }
}
