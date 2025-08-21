//
//  NotificationHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/20/25.
//

import UIKit

final class NotificationHeaderView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let newsButton: UIButton = {
        let button = UIButton()
        button.setTitle("notification.page.header.news".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.semiBold.font
        button.setTitleColor(.grayScale10, for: .normal)
        
        return button
    }()
    
    private let noticeButton: UIButton = {
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
            newsBadge.centerXAnchor.constraint(equalTo: newsButton.centerXAnchor),
            newsBadge.topAnchor.constraint(equalTo: newsButton.topAnchor),
            
            noticeBadge.centerXAnchor.constraint(equalTo: noticeButton.centerXAnchor),
            noticeBadge.topAnchor.constraint(equalTo: noticeButton.topAnchor),
        ])
    }
    
    private func configureButton() {
        [newsButton, noticeButton].forEach { button in
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
            underline.widthAnchor.constraint(equalTo: newsButton.widthAnchor),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 2),
        ])
    }
    
    // MARK: - Action
    private func setupAction(){
        newsButton.addTarget(self, action: #selector(tapNews), for: .touchUpInside)
        noticeButton.addTarget(self, action: #selector(tapNotice), for: .touchUpInside)
    }

    @objc private func tapNews()   {
        onSelectIndex?(0)
    }
    
    @objc private func tapNotice() {
        onSelectIndex?(1)
    }

    func updateSelection(index: Int, animated: Bool) {
        let isNews = (index == 0)
        newsButton.setTitleColor(isNews ? .grayScale10 : .grayScale8, for: .normal)
        newsButton.titleLabel?.font = isNews ? Typography.Body02.semiBold.font : Typography.Body02.medium.font
        noticeButton.setTitleColor(isNews ? .grayScale8 : .grayScale10, for: .normal)
        noticeButton.titleLabel?.font = isNews ? Typography.Body02.medium.font : Typography.Body02.semiBold.font

        let target = isNews ? newsButton : noticeButton
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
}
