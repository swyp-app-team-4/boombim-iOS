//
//  LiveGaugeView.swift
//  BoomBim
//
//  Created by 조영현 on 9/3/25.
//

import UIKit

final class LiveGaugeView: UIControl {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale9
        label.textAlignment = .left
        label.text = "place.detail.label.title".localized()
        
        return label
    }()
    
    private let resideStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let resideTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.text = "place.detail.label.reside".localized()
        
        return label
    }()
    
    private let resideGauge: GaugeView = {
        let gauge = GaugeView()
        gauge.trackColor = .grayScale3
        gauge.fillColor = .resideGauge
        
        return gauge
    }()
    
    private let residePercentLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .right
        
        return label
    }()
    
    private let nonresideStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let nonresideTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.text = "place.detail.label.nonreside".localized()
        
        return label
    }()
    
    private let nonresideGauge: GaugeView = {
        let gauge = GaugeView()
        gauge.trackColor = .grayScale3
        gauge.fillColor = .nonresideGauge
        
        return gauge
    }()
    
    private let nonresidePercentLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .right
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        configureView()
        configureGaugeStackView()
    }
    
    private func configureView() {
        [titleLabel, resideStackView, nonresideStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            resideStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            resideStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            resideStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            nonresideStackView.topAnchor.constraint(equalTo: resideStackView.bottomAnchor, constant: 4),
            nonresideStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nonresideStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func configureGaugeStackView() {
        [resideTitleLabel, resideGauge, residePercentLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            resideStackView.addArrangedSubview(view)
        }
        
        [nonresideTitleLabel, nonresideGauge, nonresidePercentLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            nonresideStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            resideTitleLabel.widthAnchor.constraint(equalToConstant: 40),
            residePercentLabel.widthAnchor.constraint(equalToConstant: 40),
            
            resideTitleLabel.widthAnchor.constraint(equalToConstant: 40),
            residePercentLabel.widthAnchor.constraint(equalToConstant: 40),
        ])
    }

    func update(residePercent: Double, nonresidePercent: Double) {
        residePercentLabel.text = "\(residePercent)%"
        nonresidePercentLabel.text = "\(nonresidePercent)%"
        
        if residePercent == 0 {
            resideGauge.setProgress(0, animated: true)
        } else {
            let percent = CGFloat(residePercent) / 100
            resideGauge.setProgress(percent, animated: true)
        }
        
        if nonresidePercent == 0 {
            nonresideGauge.setProgress(0, animated: true)
        } else {
            let percent = CGFloat(nonresidePercent) / 100
            nonresideGauge.setProgress(percent, animated: true)
        }
    }
}
