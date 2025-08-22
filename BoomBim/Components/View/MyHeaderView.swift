//
//  MyHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class MyHeaderView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setTitle("my.page.header.favorite".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.semiBold.font
        button.setTitleColor(.grayScale10, for: .normal)
        
        return button
    }()
    
    private let voteButton: UIButton = {
        let button = UIButton()
        button.setTitle("my.page.header.vote".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale8, for: .normal)
        
        return button
    }()
    
    private let questionButton: UIButton = {
        let button = UIButton()
        button.setTitle("my.page.header.question".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale8, for: .normal)
        
        return button
    }()
    
    private let underline: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale10
        
        return view
    }()
    
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale2
        
        return view
    }()

    var onSelectIndex: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupAction()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        backgroundColor = .white
        
        configureButton()
        configureLine()
    }
    
    private func configureButton() {
        [favoriteButton, voteButton, questionButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func configureLine() {
        [line, underline].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),
            line.bottomAnchor.constraint(equalTo: bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            
            underline.leadingAnchor.constraint(equalTo: leadingAnchor),
            underline.widthAnchor.constraint(equalTo: favoriteButton.widthAnchor),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 2),
        ])
    }
    
    // MARK: - Action
    private func setupAction(){
        favoriteButton.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
        voteButton.addTarget(self, action: #selector(tapVote), for: .touchUpInside)
        questionButton.addTarget(self, action: #selector(tapQuestion), for: .touchUpInside)
    }

    @objc private func tapFavorite()   {
        onSelectIndex?(0)
    }
    
    @objc private func tapVote() {
        onSelectIndex?(1)
    }
    
    @objc private func tapQuestion() {
        onSelectIndex?(2)
    }

    func updateSelection(index: Int, animated: Bool) {
        let buttons: [UIButton] = [favoriteButton, voteButton, questionButton]
        
        for (i, button) in buttons.enumerated() {
            let isSelected = (i == index)
            button.setTitleColor(isSelected ? .grayScale10 : .grayScale8, for: .normal)
            button.titleLabel?.font = isSelected ? Typography.Body02.semiBold.font : Typography.Body02.medium.font
        }

        let target = buttons[index]
        let changes = {
            self.underline.center.x = target.center.x
            self.underline.bounds.size.width = target.bounds.width
            self.layoutIfNeeded()
        }
        animated ? UIView.animate(withDuration: 0.22, animations: changes) : changes()
    }
}
