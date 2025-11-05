//
//  PlaceHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

final class PlaceHeaderView: UIView {
    private var place: Place?
    var onTapReport: ((Place) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
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
        imageView.image = .iconRecycleTime.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .grayScale9
        
        return imageView
    }()
    
    private let updateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let bulletImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .iconBullet
        
        return imageView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let statusBadge = UIImageView()
    
    private let reportButton: UIButton = {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .main
        config.cornerStyle = .capsule
        config.contentInsets = .init(top: 11, leading: 20, bottom: 11, trailing: 20)

        let font = Typography.Body03.medium.font
        let color = UIColor.grayScale1
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let s = NSMutableAttributedString(string: "혼잡도 알리기  ", attributes: attrs)

        let icon = UIImage.iconPointMain
        let iconSize = font.pointSize * 1.0
        let att = NSTextAttachment()
        att.image = icon
        att.bounds = CGRect(x: 0, y: (font.capHeight - iconSize)/2 - 1, width: iconSize, height: iconSize)
        s.append(NSAttributedString(attachment: att))
        s.append(NSAttributedString(string: " 10", attributes: attrs))

        config.attributedTitle = AttributedString(s)
        button.configuration = config
       
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        
//        titleLabel.text = title
//        updateLabel.text = update
//        addressLabel.text = address
        
        [timeImageView, updateLabel, bulletImageView, addressLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            updateStackView.addArrangedSubview(view)
        }
        
        // 레이아웃
        let headerTop = UIStackView(arrangedSubviews: [titleLabel, updateStackView])
        headerTop.axis = .vertical
        headerTop.alignment = .leading
        headerTop.distribution = .fill
        headerTop.spacing = 4
        
        let v = UIStackView(arrangedSubviews: [headerTop, reportButton])
        v.axis = .vertical
        v.spacing = 14
        
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
    
    @objc private func didTapReport() {
        guard let place else { return }
        onTapReport?(place)
    }

    func update(title: String, update: String, address: String, level: CongestionLevel, place: Place) {
        titleLabel.text = title
        updateLabel.text = update
        addressLabel.text = address
        statusBadge.image = level.badge
        self.place = place
    }
}

