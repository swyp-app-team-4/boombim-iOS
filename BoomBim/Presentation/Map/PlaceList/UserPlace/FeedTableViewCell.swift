//
//  FeedTableViewCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/6/25.
//

import UIKit

final class FeedTableViewCell: UITableViewCell {
    static let identifier = "FeedTableViewCell"
    
    var onTapReport: (() -> Void)?
    
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let badge = UIImageView()
    private let contentLabel = UILabel()
    private let reportButton = UIButton(type: .system)
    private lazy var reportRow: UIStackView = {
        // 왼쪽 spacer + 버튼
        let row = UIStackView(arrangedSubviews: [UIView(), reportButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 0
        return row
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale5
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        
        avatar.layer.cornerRadius = 20
        avatar.backgroundColor = .lightGray
        avatar.clipsToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ avatar.widthAnchor.constraint(equalToConstant: 40),
                                      avatar.heightAnchor.constraint(equalToConstant: 40) ])
        
        badge.contentMode = .scaleAspectFit
        badge.clipsToBounds = true
        badge.setContentHuggingPriority(.required, for: .horizontal)
        badge.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nameLabel.font = Typography.Body02.semiBold.font
        nameLabel.textColor = .grayScale10
        timeLabel.font = Typography.Body03.medium.font
        timeLabel.textColor = .grayScale8
        
        contentLabel.font = Typography.Body03.medium.font
        contentLabel.textColor = .grayScale10
        contentLabel.numberOfLines = 0
        
        reportButton.setImage(.iconSiren, for: .normal)
        reportButton.tintColor = .grayScale8
        reportButton.setTitle("신고하기", for: .normal)
        reportButton.setTitleColor(.grayScale8, for: .normal)
        reportButton.titleLabel?.font = Typography.Caption.medium.font
        reportButton.titleEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 0)
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        
        let nameStack = VStack([nameLabel, timeLabel], spacing: 2)
        // 가운데 스택은 '잘 줄어들도록'
        nameStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let topRow = UIStackView(arrangedSubviews: [
            avatar,
            nameStack,
            UIView(),
            badge
        ])
        
        topRow.alignment = .center
        topRow.spacing = 12
        
        let v = UIStackView(arrangedSubviews: [topRow, contentLabel, reportRow])
        v.axis = .vertical; v.spacing = 10
        
        contentView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            reportButton.widthAnchor.constraint(equalToConstant: 60),
            
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func apply(_ item: FeedItem) {
        avatar.setImage(from: item.memberProfile)
        nameLabel.text = item.memberName
        timeLabel.text = TimeAgo.displayString(from: item.createdAt)
        print("item.createdAt : \(item.createdAt)")
        print("TimeAgo.displayString(from: item.createdAt) : \(TimeAgo.displayString(from: item.createdAt))")
        contentLabel.text = item.congestionLevelMessage
        
        badge.image = CongestionLevel.init(ko: item.congestionLevelName)?.badge
    }
    
    @objc private func didTapReport() {
        onTapReport?()
    }
}

// 작은 헬퍼
fileprivate func VStack(_ views: [UIView], spacing: CGFloat) -> UIStackView {
    let s = UIStackView(arrangedSubviews: views)
    s.axis = .vertical; s.spacing = spacing
    return s
}
