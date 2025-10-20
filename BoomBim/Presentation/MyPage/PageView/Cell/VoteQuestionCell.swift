//
//  VoteQuestionCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class VoteQuestionCell: UITableViewCell {
    static let identifier = "VoteQuestionCell"
    
    // 외부에서 토글 이벤트를 받기 위한 콜백
    var onToggle: (() -> Void)?
    // 펼침 상태 (tableView에서 주입)
    private(set) var isExpanded: Bool = false
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = .grayScale1
        
        return view
    }()
    
    private let cardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        
        return label
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.medium.font
        label.textColor = .grayScale6
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .right
        
        return label
    }()
    
    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let arrowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(.iconBottomArrow, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.tintColor = .grayScale6
        b.contentHorizontalAlignment = .fill
        b.contentVerticalAlignment   = .fill
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return b
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
    
    private let spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        contentView.backgroundColor = .white
        
        configureView()
        configureTextView()
        configureImageView()
        configureGaugeView()
        
        configureCardStackView()
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
//            cardView.bottomAnchor.constraint(equalTo: spacerView.topAnchor),
            
            spacerView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    private func configureTextView() {
        [placeLabel, peopleLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(view)
        }
        
//        textStackView.translatesAutoresizingMaskIntoConstraints = false
//        cardStackView.addArrangedSubview(textStackView)

        NSLayoutConstraint.activate([
//            textStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
//            textStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            textStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureImageView() {
        let spacer = UIView()
        
        [congestionImageView, spacer, arrowButton].forEach { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageStackView.addArrangedSubview(imageView)
        }
        
        // 가운데 스페이서가 쭉 늘어나도록
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // 양끝 아이템은 늘어나지 않도록(자기 크기 유지)
        congestionImageView.setContentHuggingPriority(.required, for: .horizontal)
        congestionImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        arrowButton.setContentHuggingPriority(.required, for: .horizontal)
        arrowButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
//        imageStackView.translatesAutoresizingMaskIntoConstraints = false
//        cardStackView.addArrangedSubview(imageStackView)
        
        NSLayoutConstraint.activate([
//            congestionImageView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 12),
//            congestionImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            arrowView.centerYAnchor.constraint(equalTo: congestionImageView.centerYAnchor),
//            arrowView.trailingAnchor.constraint(equalTo: headerButton.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureGaugeView() {
        [relaxedPollView, normalPollView, busyPollView, crowdedPollView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            pollGaugeStackView.addArrangedSubview(view)
        }
    }
    
    private func configureCardStackView() {
        [textStackView, imageStackView, pollGaugeStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            cardStackView.addArrangedSubview(view)
        }
        
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStackView)
        
        NSLayoutConstraint.activate([
            cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
        
        arrowButton.addTarget(self, action: #selector(didTapHeader), for: .touchUpInside)
        
        // 기본: 접힘
        pollGaugeStackView.isHidden = true
        arrowButton.transform = .identity
    }
    
    @objc func didTapHeader() {
        onToggle?() // 상태 변경은 VC에서 관리
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        isExpanded = expanded
        let changes = {
            self.pollGaugeStackView.isHidden = !expanded
            self.arrowButton.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.layoutIfNeeded()
        }
        animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
    }

    func configure(_ item: VoteItem) {
        placeLabel.text = item.title
        peopleLabel.text = "\(item.people)명 참여"
        congestionImageView.image = item.congestion.badge
        
        let pollTotal = item.people
        relaxedPollView.update(text: CongestionLevel.relaxed.description, textColor: .grayScale9, count: item.relaxedCnt, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.relaxed.color, animated: true)
        normalPollView.update(text: CongestionLevel.normal.description, textColor: .grayScale9, count: item.commonly, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.normal.color, animated: true)
        busyPollView.update(text: CongestionLevel.busy.description, textColor: .grayScale9, count: item.slightlyBusyCnt, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.busy.color, animated: true)
        crowdedPollView.update(text: CongestionLevel.crowded.description, textColor: .grayScale9, count: item.crowedCnt, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.crowded.color, animated: true)
    }
    
    func configure(_ item: QuestionItem) {
        placeLabel.text = item.title
        peopleLabel.text = "\(item.people)명 참여"
        congestionImageView.image = item.congestion.badge
        
        let pollTotal = item.people
        relaxedPollView.update(text: CongestionLevel.relaxed.description, textColor: .grayScale9, count: item.relaxedCnt, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.relaxed.color, animated: true)
        normalPollView.update(text: CongestionLevel.normal.description, textColor: .grayScale9, count: item.commonly, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.normal.color, animated: true)
        busyPollView.update(text: CongestionLevel.busy.description, textColor: .grayScale9, count: item.slightlyBusyCnt, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.busy.color, animated: true)
        crowdedPollView.update(text: CongestionLevel.crowded.description, textColor: .grayScale9, count: item.crowedCnt, countColor: .grayScale8, total: pollTotal, color: CongestionLevel.crowded.color, animated: true)
    }
}

