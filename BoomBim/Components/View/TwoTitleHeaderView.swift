//
//  NotificationHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/20/25.
//

import UIKit

final class TwoTitleHeaderView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("notification.page.header.news".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.semiBold.font
        button.setTitleColor(.grayScale10, for: .normal)
        
        return button
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("notification.page.header.notice".localized(), for: .normal)
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
    
    private lazy var newsBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .newEvent
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var noticeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .newEvent
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        
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
    
    private func configureBadge() {
        [newsBadge, noticeBadge].forEach { badge in
            badge.translatesAutoresizingMaskIntoConstraints = false
            addSubview(badge)
        }
        
        NSLayoutConstraint.activate([
            newsBadge.centerXAnchor.constraint(equalTo: leftButton.centerXAnchor),
            newsBadge.topAnchor.constraint(equalTo: leftButton.topAnchor),
            
            noticeBadge.centerXAnchor.constraint(equalTo: rightButton.centerXAnchor),
            noticeBadge.topAnchor.constraint(equalTo: rightButton.topAnchor),
        ])
    }
    
    private func configureButton() {
        [leftButton, rightButton].forEach { button in
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
            underline.widthAnchor.constraint(equalTo: leftButton.widthAnchor),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 2),
        ])
    }
    
    // MARK: - Action
    private func setupAction(){
        leftButton.addTarget(self, action: #selector(tapLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(tapRight), for: .touchUpInside)
    }

    @objc private func tapLeft()   {
        onSelectIndex?(0)
    }
    
    @objc private func tapRight() {
        onSelectIndex?(1)
    }

    func updateSelection(index: Int, animated: Bool) {
        let isNews = (index == 0)
        leftButton.setTitleColor(isNews ? .grayScale10 : .grayScale8, for: .normal)
        leftButton.titleLabel?.font = isNews ? Typography.Body02.semiBold.font : Typography.Body02.medium.font
        rightButton.setTitleColor(isNews ? .grayScale8 : .grayScale10, for: .normal)
        rightButton.titleLabel?.font = isNews ? Typography.Body02.medium.font : Typography.Body02.semiBold.font

        let target = isNews ? leftButton : rightButton
        let changes = {
            self.underline.center.x = target.center.x
            self.underline.bounds.size.width = target.bounds.width
            self.layoutIfNeeded()
        }
        animated ? UIView.animate(withDuration: 0.22, animations: changes) : changes()
    }

    func setBadgeVisible(_ visible: Bool) {
        noticeBadge.isHidden = !visible
    }
    
    func setButtonTitle(left: String, right: String) {
        leftButton.setTitle(left, for: .normal)
        rightButton.setTitle(right, for: .normal)
    }
}
