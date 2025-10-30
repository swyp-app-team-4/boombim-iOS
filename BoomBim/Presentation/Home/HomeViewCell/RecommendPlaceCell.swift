//
//  RecommendPlaceCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class RecommendPlaceCell: UICollectionViewCell {
    static let identifier = "RecommendPlaceCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
//        stackView.spacing = 2
        
        return stackView
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let address: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        label.numberOfLines = 2
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        
        configureStackView()
        configureImageView()
        configureTextStackView()
    }
    
    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        [imageView, textStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    private func configureImageView() {
        congestionImageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(congestionImageView)
        
        NSLayoutConstraint.activate([
            congestionImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            congestionImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10)
        ])
    }
    
    private func configureTextStackView() {
        [title, address].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(label)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: RecommendPlaceItem) {
        imageView.setImage(from: item.image, placeholder: .imageDummyPlace)
        congestionImageView.image = item.congestion.badge
        title.text = item.title
        address.text = item.address
    }
}
