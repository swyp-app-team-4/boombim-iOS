//
//  PointHistoryCell.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit

final class PointHistoryCell: UITableViewCell {
    static let identifier = "PointHistoryCell"
    
    private let hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 20 // 12
        
        return stackView
    }()

    // 좌측: 날짜
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = Typography.Caption.regular.font
        l.textColor = .grayScale8
        
        return l
    }()
    
    // 중앙: 제목 / 시간
    private let centerVStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Typography.Body03.medium.font
        l.textColor = .grayScale9
        l.numberOfLines = 1
        
        return l
    }()
    
    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = Typography.Caption.regular.font
        l.textColor = .grayScale8
        
        return l
    }()

    // 우측: 증감 / 잔액
    private let rightVStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let deltaLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.numberOfLines = 1
        
        return l
    }()
    
    private let balanceLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.numberOfLines = 1
        
        return l
    }()

    // 구분선
    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .grayScale2
        
        return v
    }()

    // 포맷터
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM. dd"     // "10. 12"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH : mm"    // "10 : 32" (의도된 공백 포함)
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.layoutMargins = .init(top: 16, left: 22, bottom: 20, right: 22)
        
        [titleLabel, timeLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            centerVStack.addArrangedSubview(label)
        }

        [deltaLabel, balanceLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            rightVStack.addArrangedSubview(label)
        }
        
        [dateLabel, centerVStack, rightVStack].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            hStack.addArrangedSubview(view)
        }

        [hStack, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        hStack.setCustomSpacing(12, after: centerVStack)

        // 좌측 날짜: 내용만큼 차지 & 잘리지 않게
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 가운데 스택: 가로로 가장 많이 늘어나는 역할
        centerVStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        centerVStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // 우측 스택(증감/잔액): 잘리지 않도록 강하게
        rightVStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightVStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            separator.topAnchor.constraint(equalTo: contentView.topAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    /// 바인딩
    func configure(_ item: PointHistoryItem, showDate: Bool){
        // 좌
        dateLabel.setText(Self.dayFormatter.string(from: item.date), style: Typography.Caption.regular)
        dateLabel.alpha = showDate ? 1.0 : 0.0

        // 중앙
        titleLabel.setText(item.title, style: Typography.Body03.medium)
        timeLabel.setText(Self.timeFormatter.string(from: item.date), style: Typography.Caption.regular)

        // 우(증감)
        let isPlus = item.delta >= 0
        deltaLabel.setPoints(item.delta,
                             numberStyle: Typography.Body01.semiBold,
                             numberColor: isPlus ? .main : .grayScale8,
                             suffixStyle: Typography.Body02.medium,
                             suffixColor: .grayScale8,
                             includeSign: true)

        // 잔액
        balanceLabel.setPoints(item.balance,
                               numberStyle: Typography.Body03.regular,
                               numberColor: .grayScale8,
                               suffixStyle: Typography.Body03.regular,
                               suffixColor: .grayScale8)
    }
}
