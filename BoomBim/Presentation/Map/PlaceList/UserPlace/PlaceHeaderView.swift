//
//  PlaceHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

final class PlaceHeaderView: UIView {
    private let titleLabel = UILabel()
    private let metaLabel  = UILabel()
    private let statusBadge = UIImageView()
    let reportButton = UIButton(type: .system) // “붐빔 알리기”
    
    init(title: String, meta: String, currentLevel: CongestionLevel) {
        super.init(frame: .zero)
        backgroundColor = .white
        
        titleLabel.text = title
        titleLabel.font = Typography.Body02.semiBold.font
        titleLabel.textColor = .grayScale10
        
        metaLabel.text = meta
        metaLabel.font = Typography.Caption.regular.font
        metaLabel.textColor = .grayScale8
        
        // 붐빔 알리기 버튼 (가로 크게)
        reportButton.setTitle("＋ 붐빔 알리기", for: .normal)
        reportButton.setTitleColor(.white, for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        reportButton.backgroundColor = UIColor(red: 1.00, green: 0.66, blue: 0.19, alpha: 1)
        reportButton.layer.cornerRadius = 12
        reportButton.contentEdgeInsets = .init(top: 18, left: 16, bottom: 18, right: 16)
        
        // 레이아웃
        let headerTop = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
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
    
    func update(title: String, meta: String, level: CongestionLevel) {
        titleLabel.text = title
        metaLabel.text  = meta
        statusBadge.image = level.badge
    }
}

