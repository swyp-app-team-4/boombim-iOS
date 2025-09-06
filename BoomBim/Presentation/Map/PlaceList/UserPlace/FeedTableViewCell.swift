//
//  FeedTableViewCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/6/25.
//

import UIKit

final class FeedTableViewCell: UITableViewCell {
    static let identifier = "FeedTableViewCell"
    
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let badge = UIImageView()
    private let contentLabel = UILabel()
    private let reportButton = UIButton(type: .system)
    
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
        
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        timeLabel.font = .systemFont(ofSize: 13); timeLabel.textColor = .gray
        
        badge.contentMode = .scaleAspectFit
//        NSLayoutConstraint.activate([
//            badge.heightAnchor.constraint(equalToConstant: 32),
//            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 72)
//        ])
        
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 16)
        
        reportButton.setTitle("신고하기", for: .normal)
        reportButton.setTitleColor(.gray, for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        reportButton.contentEdgeInsets = .init(top: 6, left: 10, bottom: 6, right: 10)
        
        let topRow = UIStackView(arrangedSubviews: [
            avatar,
            VStack([nameLabel, timeLabel], spacing: 2),
            UIView(),
            badge
        ])
        topRow.alignment = .center; topRow.spacing = 12
        
        let v = UIStackView(arrangedSubviews: [topRow, contentLabel, reportButton])
        v.axis = .vertical; v.spacing = 10
        
        contentView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func apply(_ item: FeedItem) {
        nameLabel.text = "\(item.memberCongestionId)"
        timeLabel.text = "1분전" // 타이머 계산
        contentLabel.text = item.congestionLevelMessage
        
        badge.image = CongestionLevel.init(ko: item.congestionLevelName)?.badge
    }
}

// 작은 헬퍼
fileprivate func VStack(_ views: [UIView], spacing: CGFloat) -> UIStackView {
    let s = UIStackView(arrangedSubviews: views)
    s.axis = .vertical; s.spacing = spacing
    return s
}
