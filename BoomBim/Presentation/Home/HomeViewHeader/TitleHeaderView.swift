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
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconRefresh, for: .normal)
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [imageView, label, rightButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            
            rightButton.topAnchor.constraint(equalTo: topAnchor),
            rightButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, image: UIImage? = nil, button: Bool? = nil, buttonHandler: (() -> Void)? = nil) {
        if let image = image {
            print("image : \(image)")
            imageView.image = image
        } else {
            imageView.image = nil
        }
        
        if button == true {
            rightButton.isHidden = false
            if let handler = buttonHandler {
                self.rightButton.addAction(UIAction { _ in
                    handler()
                }, for: .touchUpInside)
            }
        } else {
            rightButton.isHidden = true
        }
        
        label.text = text
    }
}
