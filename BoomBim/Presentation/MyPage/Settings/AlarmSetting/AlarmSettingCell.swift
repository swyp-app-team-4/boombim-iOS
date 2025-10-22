//
//  AlarmSettingCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class AlarmSettingCell: UITableViewCell {
    static let identifier = "AlarmSettingCell"
    
    var onToggle: ((Bool) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale10
        label.numberOfLines = 1
        
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = .main
        
        return toggleSwitch
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .tableViewDivider
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setSwitchAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        [titleLabel, toggleSwitch, separatorView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            toggleSwitch.widthAnchor.constraint(equalToConstant: 49),
//            toggleSwitch.heightAnchor.constraint(equalToConstant: 30),
            
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
    }
    
    private func setSwitchAction() {
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }

    func configure(title: String, isOn: Bool, onToggle: ((Bool) -> Void)?) {
        titleLabel.text = title
        
        toggleSwitch.setOn(isOn, animated: false)
        self.onToggle = onToggle
    }
}
