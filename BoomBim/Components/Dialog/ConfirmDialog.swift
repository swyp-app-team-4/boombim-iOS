//
//  ConfirmDialog.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

final class ConfirmDialogController: UIViewController {

    // MARK: Public API
    private let titleText: String
    private let messageText: String?
    private let confirmTitle: String
    private let cancelTitle: String
    private let allowTapOutsideToDismiss: Bool
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

    init(title: String, message: String? = nil, confirmTitle: String = "예", cancelTitle: String = "아니요", allowTapOutsideToDismiss: Bool = true, onConfirm: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.titleText = title
        self.messageText = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.allowTapOutsideToDismiss = allowTapOutsideToDismiss
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle   = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: UI
    private let dim = UIControl()
    private let card = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dim
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dim.alpha = 0
        if allowTapOutsideToDismiss {
            dim.addTarget(self, action: #selector(tapOutside), for: .touchUpInside)
        }

        // Card
        card.backgroundColor = .white
        card.layer.cornerRadius = 22
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowRadius = 20
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)

        // Labels
        titleLabel.text = titleText
        titleLabel.font = Typography.Body01.semiBold.font
        titleLabel.textColor = .grayScale9
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.text = messageText
        messageLabel.font = Typography.Caption.medium.font
        messageLabel.textColor = .grayScale7
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        // Buttons
        cancelButton.setTitle(cancelTitle, for: .normal)
        styleOutline(cancelButton)

        confirmButton.setTitle(confirmTitle, for: .normal)
        styleFilled(confirmButton)
        confirmButton.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)

        // Layout
        view.addSubview(dim)
        view.addSubview(card)
        dim.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 30),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 170),
            card.widthAnchor.constraint(greaterThanOrEqualToConstant: 315)
        ])

        // Card contents
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 6
        buttonStack.distribution = .fillEqually

        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.isLayoutMarginsRelativeArrangement = true
        
        let contentStack = UIStackView(arrangedSubviews: [textStack, buttonStack])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .init(top: 30, left: 24, bottom: 30, right: 24)

        card.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: card.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        // 접근성
        view.accessibilityViewIsModal = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.dim.alpha = 1
            self.card.alpha = 1
            self.card.transform = .identity
        }
    }

    // MARK: Actions
    @objc private func tapOutside() { dismiss(animated: true) }

    @objc private func tapCancel() {
        onCancel?()
        dismiss(animated: true)
    }
    @objc private func tapConfirm() {
        onConfirm?()
        dismiss(animated: true)
    }

    // MARK: Style helpers
    private func styleFilled(_ b: UIButton) {
        b.titleLabel?.font = Typography.Body02.medium.font
        b.setTitleColor(.grayScale1, for: .normal)
        b.backgroundColor = .main
        b.layer.cornerRadius = 22
        b.contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    private func styleOutline(_ b: UIButton) {
        b.titleLabel?.font = Typography.Body02.medium.font
        b.setTitleColor(.main, for: .normal)
        b.backgroundColor = .grayScale1
        b.layer.borderColor = UIColor.main.cgColor
        b.layer.borderWidth = 1
        b.layer.cornerRadius = 22
        b.contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
    }
}
