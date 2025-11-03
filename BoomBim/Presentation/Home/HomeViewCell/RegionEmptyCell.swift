//
//  RegionEmptyCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/6/25.
//

import UIKit

final class RegionEmptyCell: UICollectionViewCell {
    static let identifier = "RegionEmptyCell"

    private let box = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let illustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .illustrationNoIssue
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let label: UILabel = {
        let l = UILabel()
        l.setText("오늘은 특별한 이슈가 없습니다.", style: Typography.Body03.regular)
        l.textAlignment = .center
        l.textColor = .grayScale8

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
        
        configureStackView()
    }
    
    private func configureStackView() {
        [illustrationImageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            stackView.topAnchor.constraint(equalTo: box.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -10),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: 62) // 카드 높이
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
