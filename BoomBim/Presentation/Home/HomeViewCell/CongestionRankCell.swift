//
//  CongestionRankCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/19/25.
//

import UIKit

final class CongestionRankCell: UICollectionViewCell {
    static let identifier = "CongestionRankCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .main
        label.font = Typography.Caption.medium.font
        label.textColor = .grayScale1
        label.textAlignment = .center
        
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        
        label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
//        stackView.spacing = 2
        
        return stackView
    }()
    
    private let address: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// 업데이트 시간이 모두 동일하게 적용되어 해당 부분 제거
//    private let update: UILabel = {
//        let label = UILabel()
//        label.font = Typography.Caption.regular.font
//        label.textColor = .grayScale7
//        label.textAlignment = .right
//        
//        return label
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        
        configureStackView()
        configureImageView()
        configureTextStackView()
    }
    
    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        [imageView, infoStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15) // SeparatorView로 간격을 보여주기 위해서 추가
        ])
    }
    
    private func configureImageView() {
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(rankLabel)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 90),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            
            rankLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            rankLabel.heightAnchor.constraint(equalToConstant: 22),
            rankLabel.widthAnchor.constraint(equalToConstant: 22),
        ])
    }
    
    private func configureTextStackView() {
        [textStackView, congestionImageView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            infoStackView.addArrangedSubview(view)
        }
        
        [title, address].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(view)
        }
    }

    func configure(_ item: CongestionRankPlaceItem) {
        imageView.setImage(from: item.image, placeholder: .imageDummyPlace)
        rankLabel.text = "\(item.rank)"
        
        if item.rank < 4 {
            rankLabel.backgroundColor = .main
        } else {
            rankLabel.backgroundColor = .grayScale7
        }
        
        congestionImageView.image = item.congestion.badge
//        title.text = item.title
//        address.text = item.address
        
        title.setText(item.title, style: Typography.Body02.semiBold)
        address.setText(item.address, style: Typography.Caption.regular)
    }
}
