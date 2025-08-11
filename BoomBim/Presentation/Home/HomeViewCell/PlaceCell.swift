//
//  PlaceCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class PlaceCell: UICollectionViewCell {
    static let reuseID = "PlaceCell"
    private let hstack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let badge = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12

        hstack.axis = .horizontal
        hstack.spacing = 10
        hstack.alignment = .center

        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 4

        titleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel

        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textColor = .white
        badge.backgroundColor = .systemBlue
        badge.layer.cornerRadius = 8
        badge.clipsToBounds = true
        badge.textAlignment = .center
        badge.setContentHuggingPriority(.required, for: .horizontal)
        badge.isHidden = true

        contentView.addSubview(hstack)
        hstack.translatesAutoresizingMaskIntoConstraints = false

        v.addArrangedSubview(titleLabel)
        v.addArrangedSubview(subtitleLabel)
        hstack.addArrangedSubview(v)
        hstack.addArrangedSubview(badge)

        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 54),
            badge.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: PlaceItem) {
        titleLabel.text = item.name
        subtitleLabel.text = item.detail
        badge.text = "  \(item.congestion)  "
    }
}
