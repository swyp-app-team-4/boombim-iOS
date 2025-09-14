//
//  AppDialogController.swift
//  BoomBim
//
//  Created by 조영현 on 9/14/25.
//

import UIKit

final class AppDialogController: UIViewController {

    // MARK: - Public API
    struct Action {
        enum Style { case primary, secondary, destructive }
        let title: String
        let style: Style
        let handler: (() -> Void)?
        public init(_ title: String, style: Style = .primary, handler: (() -> Void)? = nil) {
            self.title = title; self.style = style; self.handler = handler
        }
    }

    struct Config {
        var title: String?
        var message: String?
        var customView: UIView? = nil                     // 커스텀 콘텐츠(옵션)
        var actions: [Action] = [Action("확인", style: .primary, handler: nil)]
        var dismissOnBackgroundTap: Bool = false
        var maxWidth: CGFloat = 320
    }

    // 편의 생성자
    static func show(on presenter: UIViewController, config: Config, animated: Bool = true) {
        let vc = AppDialogController(config: config)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presenter.present(vc, animated: animated)
    }

    // MARK: - Init
    private let config: Config

    init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let dimView = UIView()
    private let container = UIView()
    private let vstack = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildUI()
        applyConfig()
    }

    private func buildUI() {
        // Dim
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if config.dismissOnBackgroundTap {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapBackground))
            dimView.addGestureRecognizer(tap)
        }
        isModalInPresentation = !config.dismissOnBackgroundTap

        // Container
        container.backgroundColor = .white
        container.layer.cornerRadius = 24
        container.clipsToBounds = true
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        let width = min(config.maxWidth, UIScreen.main.bounds.width - 48)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: width),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        // VStack
        vstack.axis = .vertical
        vstack.spacing = 20
        vstack.alignment = .fill
        container.addSubview(vstack)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            vstack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            vstack.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
            vstack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24)
        ])

        // Title / Message
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = Typography.Heading03.semiBold.font
        titleLabel.textColor = .grayScale10

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = Typography.Body03.regular.font
        messageLabel.textColor = .grayScale8

        // Buttons
        buttonStack.axis = config.actions.count <= 2 ? .horizontal : .vertical
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
    }

    private func applyConfig() {
        if let t = config.title, !t.isEmpty {
            titleLabel.text = t
            vstack.addArrangedSubview(titleLabel)
        }
        if let m = config.message, !m.isEmpty {
            messageLabel.text = m
            vstack.addArrangedSubview(messageLabel)
        }
        if let custom = config.customView {
            vstack.addArrangedSubview(custom)
        }

        // Buttons
        if !config.actions.isEmpty {
            vstack.addArrangedSubview(buttonStack)
            for action in config.actions {
                let btn = makeButton(for: action)
                buttonStack.addArrangedSubview(btn)
            }
        }
    }

    private func makeButton(for action: Action) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(action.title, for: .normal)
        b.titleLabel?.font = Typography.Body02.medium.font
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        style(button: b, style: action.style)
        // Capture handler
        b.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true) {
                action.handler?()
            }
        }, for: .touchUpInside)
        return b
    }

    private func style(button: UIButton, style: Action.Style) {
        switch style {
        case .primary:
            button.setTitleColor(.grayScale1, for: .normal)
            button.backgroundColor = .main
            button.layer.cornerRadius = 22
        case .secondary:
            button.setTitleColor(.main, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 22
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.main.cgColor
        case .destructive:
            button.setTitleColor(.grayScale1, for: .normal)
            button.backgroundColor = .systemRed
            button.layer.cornerRadius = 22
        }
    }

    // MARK: - Actions
    @objc private func tapBackground() { dismiss(animated: true) }
}
