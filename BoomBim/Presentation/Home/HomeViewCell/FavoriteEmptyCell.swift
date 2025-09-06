//
//  FavoriteEmptyCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/6/25.
//

import UIKit

final class FavoriteEmptyCell: UICollectionViewCell {
    static let identifier = "FavoriteEmptyCell"

    private let box = UIView()
    private let label: UILabel = {
        let l = UILabel()
        l.text = "관심 장소를 등록해 주세요!"
        l.textAlignment = .center
        l.textColor = .grayScale7
        l.font = Typography.Body02.semiBold.font
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        box.backgroundColor = .white
        box.layer.cornerRadius = 16
        box.layer.shadowColor = UIColor.black.cgColor
        box.layer.shadowOpacity = 0.06
        box.layer.shadowOffset = .init(width: 0, height: 2)
        box.layer.shadowRadius = 8

        contentView.addSubview(box)
        box.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: contentView.topAnchor),
            box.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            box.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            box.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        box.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: box.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: box.trailingAnchor, constant: -16),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: 76) // 카드 높이
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
