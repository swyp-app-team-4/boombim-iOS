//
//  MyProfileView.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class MyProfileView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var profieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconEmptyProfile
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 29
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(.iconEdit, for: .normal)
        
        return button
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let voteView = CountView()
    private let questionView = CountView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        backgroundColor = .clear
        
        configureStackView()
        configureTextStackView()
    }
    
    private func configureStackView() {
        [profieImageView, textStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        [stackView, editButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            profieImageView.widthAnchor.constraint(equalToConstant: 58),
            profieImageView.heightAnchor.constraint(equalToConstant: 58),
            
            editButton.trailingAnchor.constraint(equalTo: profieImageView.trailingAnchor),
            editButton.bottomAnchor.constraint(equalTo: profieImageView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func configureTextStackView() {
        [nameLabel, countStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(view)
        }
        
        [voteView, questionView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            countStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(name: String, profile: String?, email: String, socialProvider: String, vote: Int, question: Int) {
        print("profile : \(profile)")
        print("vote : \(vote)")
        print("question : \(question)")
        
        nameLabel.text = name
        
        profieImageView.setImage(from: profile)
        
        voteView.configure(title: "my.label.vote".localized(), count: vote)
        questionView.configure(title: "my.label.question".localized(), count: question)
    }
}
