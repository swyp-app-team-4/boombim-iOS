//
//  PlaceTableViewCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit

final class PlaceTableViewCell: UITableViewCell {
    static let identifier = "PlaceTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .tableViewDivider
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        [titleLabel, divider].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 1),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
