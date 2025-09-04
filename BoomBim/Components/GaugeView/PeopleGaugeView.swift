//
//  PeopleGaugeView.swift
//  BoomBim
//
//  Created by 조영현 on 9/3/25.
//

import UIKit

final class PeopleGaugeView: UIControl {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale9
        label.textAlignment = .left
        label.text = "place.detail.label.people.title".localized()
        
        return label
    }()
    
    private let manStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let manTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.text = "place.detail.label.man".localized()
        
        return label
    }()
    
    private let manGauge: GaugeView = {
        let gauge = GaugeView()
        gauge.trackColor = .grayScale3
        gauge.fillColor = .manGauge
        
        return gauge
    }()
    
    private let manPercentLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .right
        
        return label
    }()
    
    private let womanStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let womanTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.text = "place.detail.label.woman".localized()
        
        return label
    }()
    
    private let womanGauge: GaugeView = {
        let gauge = GaugeView()
        gauge.trackColor = .grayScale3
        gauge.fillColor = .womanGauge
        
        return gauge
    }()
    
    private let womanPercentLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .right
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        setupView()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        configureGaugeStackView()
    }
    
    private func configureView() {
        [titleLabel, manStackView, womanStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            manStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            manStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            manStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            womanStackView.topAnchor.constraint(equalTo: manStackView.bottomAnchor, constant: 4),
            womanStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            womanStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func configureGaugeStackView() {
        [manTitleLabel, manGauge, manPercentLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            manStackView.addArrangedSubview(view)
        }
        
        [womanTitleLabel, womanGauge, womanPercentLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            womanStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            manTitleLabel.widthAnchor.constraint(equalToConstant: 40),
            manPercentLabel.widthAnchor.constraint(equalToConstant: 40),
            
            womanTitleLabel.widthAnchor.constraint(equalToConstant: 40),
            womanPercentLabel.widthAnchor.constraint(equalToConstant: 40),
        ])
    }

    func update(manPercent: Double, womanPercent: Double) {
        manPercentLabel.text = "\(manPercent)%"
        womanPercentLabel.text = "\(womanPercent)%"
        
        if manPercent == 0 {
            manGauge.setProgress(0, animated: true)
        } else {
            let percent = CGFloat(manPercent) / 100
            manGauge.setProgress(percent, animated: true)
        }
        
        if womanPercent == 0 {
            womanGauge.setProgress(0, animated: true)
        } else {
            let percent = CGFloat(womanPercent) / 100
            womanGauge.setProgress(percent, animated: true)
        }
    }
}
