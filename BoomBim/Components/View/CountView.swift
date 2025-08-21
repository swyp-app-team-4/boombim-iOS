//
//  CountView.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class CountView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.medium.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .divider
        
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.medium.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .grayScale3
        layer.cornerRadius = 11
        layer.cornerCurve = .continuous
        
        configureView()
    }
    
    private func configureView() {
        [titleLabel, divider, countLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            divider.centerYAnchor.constraint(equalTo: centerYAnchor),
            divider.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 9),
            
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            countLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            countLabel.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            self.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configure(title: String, count: String) {
        titleLabel.text = title
        countLabel.text = count
    }
}
