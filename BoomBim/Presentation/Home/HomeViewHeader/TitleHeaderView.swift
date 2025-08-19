//
//  TitleHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class TitleHeaderView: UICollectionReusableView {
    static let elementKind = UICollectionView.elementKindSectionHeader
    static let reuseID = "TitleHeaderView"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [imageView, label].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(image: UIImage? = nil, text: String) {
        if let image = image {
            imageView.image = image
        }
        
        label.text = text
    }
}
