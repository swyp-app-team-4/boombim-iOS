//
//  VoteChatCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class VoteChatCell: UITableViewCell {
    static let identifier = "VoteChatCell"
    
    private let profileImageView = ProfileImageView()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.medium.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let updateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale10
        label.numberOfLines = 0
        
        return label
    }()
    
    private let roadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .dummy
        
        return imageView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let relaxedButton = makeButton(off: .buttonUnselectedRelaxed, on: .buttonSelectedRelaxed)
    private let normalButton  = makeButton(off: .buttonUnselectedNormal,  on: .buttonSelectedNormal)
    private let busyButton   = makeButton(off: .buttonUnselectedBusy,  on: .buttonSelectedBusy)
    private let crowdedButton = makeButton(off: .buttonUnselectedCrowded,   on: .buttonSelectedCrowded)
    
    private let voteButton: UIButton = {
        let button = UIButton()
        button.setTitle("chat.button.vote".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale1, for: .normal) // grayScale7
        button.backgroundColor = .main // grayScale4
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    private lazy var buttons: [UIButton] = [relaxedButton, normalButton, busyButton, crowdedButton]
    
    private(set) var selectedIndex: Int? = nil
//    var onChange: ((Int?) -> Void)?
//    var onVote: ((Bool?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.grayScale3.cgColor
        contentView.clipsToBounds = true
        
        configureView()
        configureButton()
    }
    
    private func configureView() {
        [profileImageView, peopleLabel, updateLabel, titleLabel, roadImageView, buttonStackView, voteButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            
            peopleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
            peopleLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            updateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            updateLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            
            roadImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            roadImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            roadImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            
            buttonStackView.topAnchor.constraint(equalTo: roadImageView.bottomAnchor, constant: 12),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            
            voteButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 12),
            voteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            voteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            voteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
        ])
    }
    
    private func configureButton() {
        buttons.forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
    }

    private func handleTap(index: Int) {
        selectedIndex = index
        
        for (i, b) in buttons.enumerated() {
            b.isSelected = (i == selectedIndex)
        }
//        onChange?(selectedIndex)
    }
    
    func setSelected(index: Int?) { // 외부에서 설정할 때
        selectedIndex = index
        for (i, b) in buttons.enumerated() { b.isSelected = (i == index) }
    }
    
    private static func makeButton(off: UIImage, on: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(off, for: .normal)
        button.setImage(on,  for: .selected)
        button.setImage(on,  for: [.selected, .highlighted])
        
        button.adjustsImageWhenHighlighted = false
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }
}
