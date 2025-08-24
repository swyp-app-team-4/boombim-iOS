//
//  QuestionChatCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class QuestionChatCell: UITableViewCell {
    static let identifier = "QuestionChatCell"
    
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
    
    private let pollGaugeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let relaxedPollView = PollInfoView()
    private let normalPollView = PollInfoView()
    private let busyPollView = PollInfoView()
    private let crowdedPollView = PollInfoView()
    
    private let participationLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale9
        label.textAlignment = .right
        
        return label
    }()
    
    private let voteButton: UIButton = {
        let button = UIButton()
        button.setTitle("chat.button.vote.end".localized(), for: .normal)
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
    
    private lazy var pollViews: [PollInfoView] = [relaxedPollView, normalPollView, busyPollView, crowdedPollView]
    
    private var voteUIAction: UIAction?
    var onVote: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .tableViewBackground
        
        configureView()
        configureCardView()
        configurePollGaugeView()
        
        setButtonActions()
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
        [profileImageView, peopleLabel, updateLabel, titleLabel, pollGaugeStackView, participationLabel, voteButton].forEach { view in
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
            
            pollGaugeStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            pollGaugeStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            pollGaugeStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
            participationLabel.topAnchor.constraint(equalTo: pollGaugeStackView.bottomAnchor, constant: 12),
            participationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            participationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
            voteButton.topAnchor.constraint(equalTo: pollGaugeStackView.bottomAnchor, constant: 12),
            voteButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            voteButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            voteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            voteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configurePollGaugeView() {
        pollViews.forEach { pollView in
            pollView.translatesAutoresizingMaskIntoConstraints = false
            pollGaugeStackView.addArrangedSubview(pollView)
        }
    }
    
    private func setButtonActions() {
        voteUIAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.onVote?()
        }
        if let action = voteUIAction {
            voteButton.addAction(action, for: .touchUpInside)
        }
    }
    
    func configure(_ item: QuestionChatItem) {
        profileImageView.configure(with: item.profileImage) // TODO: URL로 이미지 가져오기
        peopleLabel.text = "\(item.people)명이 궁금해하고 있어요" // TODO: Text 효과
        updateLabel.text = "\(item.update)분 전" // TODO: 시간 계산해서 몇분전으로 보여줘야함.
        
        titleLabel.text = "지금 '\(item.title)' 어때요?"
        let pollTotal = item.relaxed + item.normal + item.busy + item.crowded
        relaxedPollView.update(text: CongestionLevel.relaxed.description, textColor: .grayScale9, count: item.relaxed, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.relaxed.color, animated: true)
        normalPollView.update(text: CongestionLevel.normal.description, textColor: .grayScale9, count: item.normal, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.normal.color, animated: true)
        busyPollView.update(text: CongestionLevel.busy.description, textColor: .grayScale9, count: item.busy, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.busy.color, animated: true)
        crowdedPollView.update(text: CongestionLevel.crowded.description, textColor: .grayScale9, count: item.crowded, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.crowded.color, animated: true)
        
        voteButton.backgroundColor = item.isVoting ? .main : .grayScale4
        voteButton.setTitleColor(item.isVoting ? .grayScale1 : .grayScale7, for: .normal)
        
        // 투표 여부에 따른 버튼 활성화
        voteButton.isEnabled = item.isVoting
        
        if item.isVoting {
            setButtonActions()
        } else {
            print("button Actions disable")
        }
    }
}
