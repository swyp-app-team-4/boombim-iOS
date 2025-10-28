//
//  FavoriteCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class FavoriteCell: UICollectionViewCell {
    // MVVM: Output event callback to be assigned by the ViewModel/Controller
    var onTapFavorite: (() -> Void)?
    
    static let identifier = "FavoriteCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        
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
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        label.numberOfLines = 1
        
        return label
    }()
    
    private let updateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        
        return stackView
    }()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .iconRecycleTime
        
        return imageView
    }()
    
    private let update: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconNonfavoriteStar, for: .normal)
        button.setImage(.iconFavoriteStar, for: .selected)
        button.contentMode = .scaleAspectFit
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupAction()
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
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
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func configureImageView() {
        congestionImageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(congestionImageView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 180),
            imageView.widthAnchor.constraint(equalToConstant: 180),
            
            congestionImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            congestionImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10)
        ])
    }
    
    private func configureTextStackView() {
        [timeImageView, update, spacerView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            updateStackView.addArrangedSubview(view)
        }
        
        [title, updateStackView].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(label)
        }
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -4),
            
            favoriteButton.topAnchor.constraint(equalTo: textStackView.topAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupAction() {
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }
    
    @objc private func didTapFavorite() {
        onTapFavorite?()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: FavoritePlaceItem) {
        imageView.setImage(from: item.image, placeholder: .imageDummyPlace)
        
        if let congestionImageName = item.congestion {
            congestionImageView.image = congestionImageName.badge
        }
        
        favoriteButton.isSelected = true /// Home에서 사용하는 관심장소 cell은 애초에 관심장소만 조회
        
        title.text = item.title
        update.text = item.update
    }
}

