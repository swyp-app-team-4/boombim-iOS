//
//  PollInfoView.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

final class PollInfoView: UIControl {
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let gauge: PollGaugeView = {
        let gauge = PollGaugeView()
//        gauge.resetToEmpty()
//        gauge.animationBehavior = .fromZero
        gauge.trackColor = .grayScale3
        
        return gauge
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = Typography.Caption.medium.font
        countLabel.font = Typography.Caption.medium.font

        let header = UIStackView(arrangedSubviews: [titleLabel, UIView(), countLabel])
        header.axis = .horizontal
        header.alignment = .center

        let stack = UIStackView(arrangedSubviews: [header, gauge])
        stack.axis = .vertical
        stack.spacing = 8

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            gauge.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    /// 값 세팅 + 애니메이션
    func update(text: String, textColor: UIColor, count: Int, countColor: UIColor, total: Int, color: UIColor, animated: Bool, delay: CFTimeInterval = 3) {
        titleLabel.text = text
        titleLabel.textColor = textColor
        countLabel.text = "\(count)명"
        countLabel.textColor = countColor
        
        gauge.fillColor  = color
        
        if (total == 0 && count == 0) {
            gauge.setProgress(0, animated: true)
        } else {
            gauge.setProgress(CGFloat(count) / CGFloat(total), animated: true)
        }
    }
}
