//
//  PlaceHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

final class PlaceHeaderView: UIView {
    private let titleLabel = UILabel()
    
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
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let addressLabel  = UILabel()
    private let statusBadge = UIImageView()
    let reportButton = UIButton(type: .system) // “붐빔 알리기”
    
    init(title: String, update: String, address: String, currentLevel: CongestionLevel) {
        super.init(frame: .zero)
        backgroundColor = .white
        
        titleLabel.text = title
        titleLabel.font = Typography.Body02.semiBold.font
        titleLabel.textColor = .grayScale10
        
        updateLabel.text = update
        
        addressLabel.text = address
        addressLabel.font = Typography.Caption.regular.font
        addressLabel.textColor = .grayScale8
        
        [timeImageView, updateLabel, addressLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            updateStackView.addArrangedSubview(view)
        }
        
        // 붐빔 알리기 버튼 (가로 크게)
        reportButton.setTitle("＋ 혼잡도 질문하기", for: .normal)
        reportButton.setTitleColor(.white, for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        reportButton.backgroundColor = UIColor(red: 1.00, green: 0.66, blue: 0.19, alpha: 1)
        reportButton.layer.cornerRadius = 12
        reportButton.contentEdgeInsets = .init(top: 18, left: 16, bottom: 18, right: 16)
        reportButton.alpha = 0            // 보이지 않음 (공간은 그대로)
        reportButton.isUserInteractionEnabled = false  // 탭 방지
        reportButton.isAccessibilityElement = false 
        
        // 레이아웃
        let headerTop = UIStackView(arrangedSubviews: [titleLabel, updateStackView])
        headerTop.axis = .vertical
        headerTop.alignment = .leading
        headerTop.distribution = .fill
        headerTop.spacing = 4
        
        let v = UIStackView(arrangedSubviews: [headerTop, reportButton])
        v.axis = .vertical
        v.spacing = 10
        
        addSubview(v)
        addSubview(statusBadge)
        v.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: topAnchor),
            v.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            statusBadge.centerYAnchor.constraint(equalTo: headerTop.centerYAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            reportButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func update(title: String, update: String, address: String, level: CongestionLevel) {
        titleLabel.text = title
        updateLabel.text = update
        addressLabel.text = address
        statusBadge.image = level.badge
    }
}

