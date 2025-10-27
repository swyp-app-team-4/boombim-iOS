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
        let accessibilityLabel: String?
        public init(_ title: String, style: Style = .primary, accessibilityLabel: String? = nil, handler: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
            self.accessibilityLabel = accessibilityLabel
        }
    }

    struct Config {
        var title: String?
        var message: String?
        var customView: UIView? = nil                     // 커스텀 콘텐츠(옵션)
        var actions: [Action] = [Action("확인", style: .primary, handler: nil)]
        var dismissOnBackgroundTap: Bool = false
        var isDismissOnAction: Bool = true                // 버튼 탭 시 자동 dismiss
        var preferredActionIndex: Int? = nil              // 기본 강조/포커스 액션 인덱스
        var maxWidth: CGFloat = 320
        var useHaptic: Bool = true                        // 액션 시 가벼운 햅틱

        static func ok(title: String? = nil, message: String? = nil, okTitle: String = "확인", onOK: (() -> Void)? = nil) -> Config {
            return Config(title: title, message: message, customView: nil, actions: [Action(okTitle, style: .secondary, handler: onOK)], dismissOnBackgroundTap: false, isDismissOnAction: true, preferredActionIndex: 0, maxWidth: 320, useHaptic: true)
        }

        static func yesNo(title: String? = nil, message: String? = nil, yesTitle: String = "예", noTitle: String = "아니오", onYes: (() -> Void)? = nil, onNo: (() -> Void)? = nil) -> Config {
            let no = Action(noTitle, style: .secondary, handler: onNo)
            let yes = Action(yesTitle, style: .primary, handler: onYes)
            return Config(title: title, message: message, customView: nil, actions: [no, yes], dismissOnBackgroundTap: false, isDismissOnAction: true, preferredActionIndex: 1, maxWidth: 320, useHaptic: true)
        }
    }

    // 편의 생성자
    static func show(on presenter: UIViewController, config: Config, animated: Bool = true) {
        let vc = AppDialogController(config: config)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presenter.present(vc, animated: animated)
    }

    static func showOK(on presenter: UIViewController, title: String? = nil, message: String? = nil, okTitle: String = "확인", animated: Bool = true, onOK: (() -> Void)? = nil) {
        show(on: presenter, config: .ok(title: title, message: message, okTitle: okTitle, onOK: onOK), animated: animated)
    }

    static func showYesNo(on presenter: UIViewController, title: String? = nil, message: String? = nil, yesTitle: String = "예", noTitle: String = "아니오", animated: Bool = true, onYes: (() -> Void)? = nil, onNo: (() -> Void)? = nil) {
        show(on: presenter, config: .yesNo(title: title, message: message, yesTitle: yesTitle, noTitle: noTitle, onYes: onYes, onNo: onNo), animated: animated)
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
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowRadius = 20
        container.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        let width = min(config.maxWidth, UIScreen.main.bounds.width - 48)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            container.widthAnchor.constraint(lessThanOrEqualToConstant: width),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

        // VStack
        vstack.axis = .vertical
        vstack.spacing = 22
        vstack.alignment = .fill
        
        container.addSubview(vstack)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            vstack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            vstack.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
            vstack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -22)
        ])

        // Title / Message
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = Typography.Body01.semiBold.font
        titleLabel.textColor = .grayScale9

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = Typography.Caption.medium.font
        messageLabel.textColor = .grayScale7

        // Buttons
        buttonStack.axis = config.actions.count <= 2 ? .horizontal : .vertical
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        buttonStack.isLayoutMarginsRelativeArrangement = false
    }

    private func applyConfig() {
        if let t = config.title, !t.isEmpty {
            titleLabel.text = t
            vstack.addArrangedSubview(titleLabel)
        }
        if let m = config.message, !m.isEmpty {
            messageLabel.text = m
            vstack.addArrangedSubview(messageLabel)
            
            vstack.setCustomSpacing(4, after: titleLabel)
        }
        
        if let custom = config.customView {
            vstack.addArrangedSubview(custom)
        }

        // Buttons
        if !config.actions.isEmpty {
            vstack.addArrangedSubview(buttonStack)

            let actions: [Action]
            if config.actions.count == 2 {
                // iOS 관례: 보조(취소/secondary)가 왼쪽, 주요(primary)가 오른쪽
                let leftFirst = config.actions.sorted { a, b in
                    // primary를 뒤로 보내기
                    switch (a.style, b.style) {
                    case (.primary, .primary): return false
                    case (.primary, _): return false
                    case (_, .primary): return true
                    default: return false
                    }
                }
                actions = leftFirst
            } else {
                actions = config.actions
            }

            for action in actions {
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
        if let label = action.accessibilityLabel { b.accessibilityLabel = label } else { b.accessibilityLabel = action.title }
        b.accessibilityTraits = .button

        b.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if self.config.useHaptic { UIImpactFeedbackGenerator(style: .light).impactOccurred() }

            // Wrap optional handler so the type is `() -> Void` and only call if non-nil
            let performHandler: (() -> Void)? = action.handler

            if self.config.isDismissOnAction {
                if let performHandler {
                    self.dismiss(animated: true, completion: performHandler)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                performHandler?()
            }
        }, for: .touchUpInside)
        return b
    }

    private func style(button: UIButton, style: Action.Style) {
        switch style {
        case .primary:
            button.setTitleColor(.main, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 22
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.main.cgColor
        case .secondary:
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .main
            button.layer.cornerRadius = 22
        case .destructive:
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemRed
            button.layer.cornerRadius = 22
        }
    }

    // MARK: - Actions
    @objc private func tapBackground() {
        guard config.dismissOnBackgroundTap else { return }
        dismiss(animated: true)
    }

    // MARK: - Helpers
    var preferredActionButton: UIButton? {
        guard let index = config.preferredActionIndex, index < buttonStack.arrangedSubviews.count else { return nil }
        return buttonStack.arrangedSubviews[index] as? UIButton
    }
}

