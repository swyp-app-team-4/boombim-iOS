//
//  VoteChatCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class VoteChatCell: UITableViewCell {
    static let identifier = "VoteChatCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        
        return view
    }()
    
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
    
    private lazy var roadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
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
        button.layer.cornerRadius = 22
        
        return button
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var buttons: [UIButton] = [relaxedButton, normalButton, busyButton, crowdedButton]
    
    private(set) var selectedIndex: Int? = nil
//    var onChange: ((Int?) -> Void)?
    
    private var voteUIAction: UIAction?
    var onVote: ((Int?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        
//        setButtonActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onVote = nil                 // 외부 핸들러 초기화
        selectedIndex = nil          // 필요 시 초기화
    }

    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureView()
        configureCardView()
        configureButton()
    }
    
    private func configureView() {
        [cardView, spacerView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: spacerView.topAnchor),
            
            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func configureCardView() {
        [profileImageView, peopleLabel, updateLabel, titleLabel, roadImageView, buttonStackView, voteButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            
            peopleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
            peopleLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            updateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            updateLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
            roadImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            roadImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            roadImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            roadImageView.heightAnchor.constraint(equalToConstant: 116),
            
            buttonStackView.topAnchor.constraint(equalTo: roadImageView.bottomAnchor, constant: 12),
            buttonStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            buttonStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
            voteButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 12),
            voteButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            voteButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            voteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            voteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureButton() {
        buttons.forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
    }
    
    private func setButtonActions() {
        for (i, btn) in buttons.enumerated() {
            btn.tag = i
            btn.addAction(UIAction { [weak self] _ in
                self?.handleTap(index: i)
            }, for: .touchUpInside)
        }
        
        voteUIAction = UIAction { [weak self] _ in
            guard let self else { return }
            
            // TODO: 버튼으로 어떤 상태인지 선택한 경우에만 투표하게 진행
            self.onVote?(self.selectedIndex)   // <- 선택 인덱스 전달
            print("selectedIndex:", self.selectedIndex as Any)
        }
        if let action = voteUIAction {
            voteButton.addAction(action, for: .touchUpInside)
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
        for (i, b) in buttons.enumerated() {
            b.isSelected = (i == index)
        }
    }
    
    private static func makeButton(off: UIImage, on: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(off, for: .normal)
        button.setImage(on,  for: .selected)
        button.setImage(on,  for: [.selected, .highlighted])
        
//        button.adjustsImageWhenHighlighted = false
//        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }
    
    func configure(_ item: VoteChatItem) {
        profileImageView.configure(with: item.profileImage) // TODO: URL로 이미지 가져오기
        peopleLabel.text = "\(item.people)명이 궁금해하고 있어요" // TODO: Text 효과
        updateLabel.text = item.update // TODO: 시간 계산해서 몇분전으로 보여줘야함.
        
        titleLabel.text = "지금 '\(item.title)' 어때요?"
        
//        roadImageView - // TODO: URL로 이미지 가져오기
        
        setSelected(index: item.congestion.rawValue)
        
        voteButton.backgroundColor = item.isVoting ? .main : .grayScale4
        voteButton.setTitleColor(item.isVoting ? .grayScale1 : .grayScale7, for: .normal)
        
        // 투표 여부에 따른 버튼 활성화
        voteButton.isEnabled = item.isVoting
        
//        buttons.forEach { button in
//            button.isEnabled = item.isVoting
//        }
        if item.isVoting {
            setButtonActions()
        } else {
            print("button Actions disable")
        }
    }
}

