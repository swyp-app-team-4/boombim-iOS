//
//  PlaceInfoCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import UIKit
import Nuke

// MARK: - Model

struct PlaceListItem: Hashable {
    enum Congestion: String, Hashable {
        case relaxed    // 여유
        case normal     // 보통
        case busy       // 약간 붐빔 (또는 붐빔)

        var title: String {
            switch self {
            case .relaxed: return "여유"
            case .normal:  return "보통"
            case .busy:    return "약간 붐빔"
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .relaxed: return UIColor.systemGreen.withAlphaComponent(0.2)
            case .normal:  return UIColor.systemBlue.withAlphaComponent(0.2)
            case .busy:    return UIColor.systemOrange.withAlphaComponent(0.25)
            }
        }

        var textColor: UIColor {
            switch self {
            case .relaxed: return UIColor.systemGreen
            case .normal:  return UIColor.systemBlue
            case .busy:    return UIColor.systemOrange
            }
        }
    }

    let id: String
    let title: String
    let minutesAgo: Int
    let address: String
    let imageURLs: [URL]
    let congestion: Congestion
    let isBookmarked: Bool
}

// MARK: - PaddingLabel for pill badge
final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

// MARK: - Cell
final class PlaceInfoCell: UITableViewCell {
    static let reuseID = "PlaceInfoCell"

    // Container
    private let card = UIView()

    // Top row
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
//    private let badgeLabel = UIImageView()
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    // Meta row
//    private let metaIcon = UIImageView(image: UIImage(systemName: "clock.fill"))
//    private let metaLabel = UILabel()

    // Images
    private let imagesStack = UIStackView()
    private var imageViews: [UIImageView] = []

    private let favoriteBadge = UIImageView()

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
        #if canImport(Nuke)
        imageTasks.forEach { $0?.cancel() }
        imageTasks.removeAll()
        #endif
        imageViews.forEach { $0.image = nil }
        favoriteBadge.isHidden = true
    }

    // MARK: Public
    func configure(with item: OfficialPlaceItem) {
        titleLabel.text = item.name
        congestionImageView.image = CongestionLevel(ko: item.congestionLevelName)?.badge
    }
    
    func configure(with item: UserPlaceItem) {
        titleLabel.text = item.name
        congestionImageView.image = CongestionLevel(ko: item.congestionLevelName)?.badge
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

        // Title
        titleLabel.font = Typography.Body02.semiBold.font
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .grayScale10

        // Meta
//        metaIcon.tintColor = .secondaryLabel
//        metaIcon.contentMode = .scaleAspectFit
//        metaLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
//        metaLabel.textColor = .secondaryLabel
//        metaLabel.adjustsFontForContentSizeCategory = true

        // Images
        imagesStack.axis = .horizontal
        imagesStack.alignment = .fill
        imagesStack.distribution = .fillEqually
        imagesStack.spacing = 8

        for _ in 0..<3 {
            let iv = UIImageView()
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 12
            iv.contentMode = .scaleAspectFill
            iv.backgroundColor = UIColor.secondarySystemFill
            imageViews.append(iv)
            imagesStack.addArrangedSubview(iv)
        }

        // Favorite badge on the last image
        if let last = imageViews.last {
            favoriteBadge.translatesAutoresizingMaskIntoConstraints = false
            favoriteBadge.image = starBadgeImage()
            favoriteBadge.contentMode = .scaleAspectFit
            last.addSubview(favoriteBadge)
            NSLayoutConstraint.activate([
                favoriteBadge.trailingAnchor.constraint(equalTo: last.trailingAnchor, constant: -6),
                favoriteBadge.bottomAnchor.constraint(equalTo: last.bottomAnchor, constant: -6),
                favoriteBadge.widthAnchor.constraint(equalToConstant: 28),
                favoriteBadge.heightAnchor.constraint(equalTo: favoriteBadge.widthAnchor)
            ])
        }

        // Add subviews to card
        [titleLabel, congestionImageView, imagesStack].forEach { v in
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
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            congestionImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            congestionImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            congestionImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])

        // Images row (1:1 aspect)
        NSLayoutConstraint.activate([
            imagesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            imagesStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            imagesStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            imagesStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            imagesStack.heightAnchor.constraint(equalToConstant: 88) // adjust to taste
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
