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
    
    private let colorOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .imageOverlay
        
        return view
    }()
    
    private let imageGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.8, 1]
        gradient.opacity = 0.2
        
        return gradient
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
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
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
        imageView.image = .iconRecycleTimeWhite
        
        return imageView
    }()
    
    private let update: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale1
        
        return label
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        
        return view
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageGradient.frame = imageView.bounds
        imageGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        imageGradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureImageView()
        configureTextStackView()
    }
    
    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        [colorOverlay, congestionImageView, textStackView, favoriteImageView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            colorOverlay.topAnchor.constraint(equalTo: imageView.topAnchor),
            colorOverlay.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            colorOverlay.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            colorOverlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            congestionImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            congestionImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            
            textStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12),
            textStackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 11),
            
            favoriteImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12),
            favoriteImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 34),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 34)
        ])
        
        imageView.layer.insertSublayer(imageGradient, above: colorOverlay.layer)
        
        // zPosition으로 계층 고정
        colorOverlay.layer.zPosition = 0         // 이미지 바로 위
        imageGradient.zPosition = 1              // 오버레이 위
        congestionImageView.layer.zPosition = 2  // 컨트롤들 맨 위
        textStackView.layer.zPosition = 2
        favoriteImageView.layer.zPosition = 2
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
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: FavoritePlaceItem) {
        imageView.setImage(from: item.image, placeholder: .imageDummyPlace)
        
        if let congestion = item.congestion {
            congestionImageView.image = congestion.badge
        }
        
        title.text = item.title
        update.text = "\(item.update)"
    }
}
