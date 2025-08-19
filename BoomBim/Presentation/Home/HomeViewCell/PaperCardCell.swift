//
//  PaperCardCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/19/25.
//

import UIKit

final class PagerCardCell: UICollectionViewCell {
    static let reuseID = "PagerCardCell"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground

        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) {
        label.text = title
    }
}
