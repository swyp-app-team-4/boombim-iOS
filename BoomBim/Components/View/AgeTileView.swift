//
//  AgeTileView.swift
//  BoomBim
//
//  Created by 조영현 on 9/3/25.
//

import UIKit

final class AgeTileView: UIView {
    private let percentContainer = UIView()
    private let percentLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        percentContainer.backgroundColor = .grayScale3
        percentContainer.layer.cornerRadius = 12

        percentLabel.font = Typography.Heading03.medium.font
        percentLabel.textColor = .grayScale10
        percentLabel.textAlignment = .center

        titleLabel.font = Typography.Body02.regular.font
        titleLabel.textColor = .grayScale7
        titleLabel.textAlignment = .center

        let v = UIStackView(arrangedSubviews: [percentContainer, titleLabel])
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = 4

        addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        percentContainer.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false

        percentContainer.addSubview(percentLabel)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: topAnchor),
            v.leadingAnchor.constraint(equalTo: leadingAnchor),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),

            percentContainer.heightAnchor.constraint(equalToConstant: 46), // 타일 상단 박스 높이
            percentLabel.centerXAnchor.constraint(equalTo: percentContainer.centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: percentContainer.centerYAnchor)
        ])
    }

    func configure(percentText: String, title: String) {
        percentLabel.setText(percentText, style: Typography.Body02.medium)
        titleLabel.setText(title, style: Typography.Body03.medium)
    }
}
