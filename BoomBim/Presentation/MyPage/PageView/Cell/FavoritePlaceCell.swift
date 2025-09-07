//
//  FavoritePlaceCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class FavoritePlaceCell: UICollectionViewCell {
    static let identifier = "FavoritePlaceCell"
    
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
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale1
        
        return label
    }()
    
    private let update: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.medium.font
        label.textColor = .grayScale1
        
        return label
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconFavoriteStar
        
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureImageView()
        configureTextStackView()
    }
    
    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        [congestionImageView, textStackView, favoriteImageView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            congestionImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            congestionImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            
            textStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12),
            textStackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 11),
            
            favoriteImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12),
            favoriteImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 34),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func configureTextStackView() {
        [title, update].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(label)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: FavoritePlaceItem) {
        imageView.setImage(from: item.image, placeholder: .imageDummyPlace)
        
        if let congestion = item.congestion {
            congestionImageView.image = congestion.badge
        }
        
        title.text = item.title
        update.text = "오늘 \(item.update)"
    }
}
