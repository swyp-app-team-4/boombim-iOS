//
//  VoteQuestionCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class VoteQuestionCell: UITableViewCell {
    static let identifier = "VoteQuestionCell"
    
    private let placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        return imageView
    }()

    private let placeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale9
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()

    private let congestionLabel: StatusLabel = {
        let lb = StatusLabel()
        
        return lb
    }()

    private let countLabel: StatusLabel = {
        let lb = StatusLabel()
        
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureView()
        configureRightStackView()
    }

    private func configureView() {
        [placeImageView, placeLabel, rightStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        rightStackView.setContentHuggingPriority(.required, for: .horizontal)
        rightStackView.setContentCompressionResistancePriority(.required, for:  .horizontal)

        NSLayoutConstraint.activate([
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeImageView.widthAnchor.constraint(equalToConstant: 30),
            placeImageView.heightAnchor.constraint(equalToConstant: 30),

            placeLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 8),
            placeLabel.trailingAnchor.constraint(equalTo: rightStackView.leadingAnchor, constant: -8),
            placeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            congestionLabel.heightAnchor.constraint(equalToConstant: 22),
            countLabel.heightAnchor.constraint(equalToConstant: 22),
            
            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
    }
    
    private func configureRightStackView() {
        [congestionLabel, countLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            rightStackView.addArrangedSubview(label)
        }
    }

    func configure(_ item: VoteItem) {
        placeImageView.image = item.image
        placeLabel.text = item.title
        congestionLabel.text = item.congestion.description
        countLabel.text = "\(item.people)명"
        
        congestionLabel.backgroundColor = item.isVoting ? .grayScale7 : .white
        congestionLabel.textColor = item.isVoting ? .grayScale1 : .grayScale7
        countLabel.backgroundColor = item.isVoting ? .grayScale7 : .white
        countLabel.textColor = item.isVoting ? .grayScale1 : .grayScale7
    }
    
    func configure(_ item: QuestionItem) {
        placeImageView.image = item.image
        placeLabel.text = item.title
        congestionLabel.text = item.congestion.description
        countLabel.text = "\(item.people)명"
        
        congestionLabel.backgroundColor = item.isQuesting ? .grayScale7 : .white
        congestionLabel.textColor = item.isQuesting ? .grayScale1 : .grayScale7
        countLabel.backgroundColor = item.isQuesting ? .grayScale7 : .white
        countLabel.textColor = item.isQuesting ? .grayScale1 : .grayScale7
    }
}

