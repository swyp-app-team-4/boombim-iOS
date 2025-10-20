//
//  PlaceInfoCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import UIKit
import Nuke

// MARK: - Cell
final class OfficialPlaceInfoCell: UITableViewCell {
    static let reuseID = "PlaceInfoCell"

    var onFavoriteTapped: (() -> Void)?
    
    // Container
    private let card = UIView()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
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
    
    private let updateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let bulletImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .iconBullet
        
        return imageView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    // Meta row
//    private let metaIcon = UIImageView(image: UIImage(systemName: "clock.fill"))
//    private let metaLabel = UILabel()

    // Images
//    private let imagesStack = UIStackView()
//    private var imageViews: [UIImageView] = []
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        return imageView
    }()

//    private let favoriteBadge = UIImageView()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconNonfavoriteStar, for: .normal)
        button.setImage(.iconFavoriteStar, for: .selected)
        button.contentMode = .scaleAspectFit
        
        return button
    }()

    // Image tasks (for Nuke)
    #if canImport(Nuke)
    private var imageTasks: [ImageTask?] = []
    #endif

    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        onFavoriteTapped = nil
        favoriteButton.removeTarget(nil, action: nil, for: .touchUpInside)
    }

    // MARK: Public
    func configure(with item: OfficialPlaceItem) {
        titleLabel.setText(item.officialPlaceName, style: Typography.Body02.semiBold)
        
        timeImageView.isHidden = true
        updateLabel.isHidden = true
        bulletImageView.isHidden = true
        
        addressLabel.setText(item.legalDong, style: Typography.Caption.regular)
        
        congestionImageView.image = CongestionLevel(ko: item.congestionLevelName)?.badge
        placeImageView.setImage(from: item.imageUrl)
        favoriteButton.isSelected = item.isFavorite
        
        favoriteButton.removeTarget(nil, action: nil, for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }
    
    @objc private func didTapFavorite() {
        print("didTapFavorite")
        onFavoriteTapped?()
    }
    
    func setFavoriteSelected(_ selected: Bool) {
        favoriteButton.isSelected = selected
    }

    // MARK: Private
    private func setupViews() {
        // Card
        contentView.addSubview(card)
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        [timeImageView, updateLabel, bulletImageView, addressLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            updateStackView.addArrangedSubview($0)
        }
        
        [titleLabel, updateStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview($0)
        }

        // Add subviews to card
        [textStackView, congestionImageView, placeImageView, favoriteButton].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(v)
        }
    }

    private func setupLayout() {
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // Title + badge
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            congestionImageView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor),
            congestionImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            congestionImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])

        // Images row (1:1 aspect)
        
        NSLayoutConstraint.activate([
            placeImageView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 10),
            placeImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            placeImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            placeImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            placeImageView.heightAnchor.constraint(equalToConstant: 88),
            
            favoriteButton.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: -5),
            favoriteButton.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -5)
        ])
    }

    private func placeholderImage() -> UIImage? {
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let img = UIImage(systemName: "photo", withConfiguration: cfg)
        return img
    }

    private func starBadgeImage() -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let circlePath = UIBezierPath(ovalIn: rect)
            UIColor.systemYellow.setFill()
            circlePath.fill()

            let starCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            let star = UIImage(systemName: "star.fill", withConfiguration: starCfg)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            star?.draw(in: rect.insetBy(dx: 6, dy: 6))
        }
    }
}
