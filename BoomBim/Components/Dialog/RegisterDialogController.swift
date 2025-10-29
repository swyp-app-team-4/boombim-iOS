//
//  RegisterDialog.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit

import UIKit

final class RegisterDialogController: UIViewController {
    // MARK: - Input / Callback
    private let place: String
    var onConfirm: (() -> Void)?

    // MARK: - Init
    init(place: String) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.isAccessibilityElement = true
        v.accessibilityLabel = "dim_view"
        return v
    }()

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = true
        // (선택) 그림자
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = .init(width: 0, height: 8)
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale9
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Typography.Body01.medium.font
        label.textColor = .grayScale7
        label.text = "dialog.label.subtitle".localized()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .illustrationCongratulation
        iv.contentMode = .scaleAspectFit
        iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Typography.Body01.medium.font
        label.textColor = .grayScale9
        label.text = "dialog.label.description".localized()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let okButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("dialog.button.confirm".localized(), for: .normal) // "확인"
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = Typography.Body02.semiBold.font
        b.backgroundColor = .main
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        b.accessibilityLabel = "confirm_button"
        return b
    }()

    private let vStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 20
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 30, left: 24, bottom: 30, right: 24)
        return s
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        bindActions()
        applyTexts()
    }

    // MARK: - Build
    private func buildUI() {
        view.backgroundColor = .clear

        view.addSubview(dimView)
        dimView.frame = view.bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        // 카드 중앙 배치 + 최대 폭 제한(아이패드 대응)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30)
        ])

        card.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        // 이미지 높이 상한(콘텐츠가 너무 커지지 않도록)
        let imageMax = imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 160)
        imageMax.priority = .required
        imageMax.isActive = true

        // 스택 구성
        [titleLabel, subtitleLabel, imageView, descriptionLabel, okButton].forEach { vStack.addArrangedSubview($0) }
        
         vStack.setCustomSpacing(2, after: titleLabel)
    }

    private func bindActions() {
        okButton.addTarget(self, action: #selector(onTapOK), for: .touchUpInside)
        // 뒷배경 탭으로 닫기 원하면:
        // let tap = UITapGestureRecognizer(target: self, action: #selector(onTapDim))
        // dimView.addGestureRecognizer(tap)
        // dimView.isUserInteractionEnabled = true
    }

    private func applyTexts() {
        titleLabel.text = place
    }

    // MARK: - Actions
    @objc private func onTapOK() {
        okButton.isEnabled = false
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }

    @objc private func onTapDim() {
        // 필요 시 배경 탭으로 닫기
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - 작은 유틸 (옵션)
private extension String {
    func localized(default fallback: String) -> String {
        let s = NSLocalizedString(self, comment: "")
        return s == self ? fallback : s
    }
}


//final class RegisterDialogController: UIViewController {
//    private let nickname: String
//    var onConfirm: (() -> Void)?
//    
//    init(nickname: String) {
//        self.nickname = nickname
//        super.init(nibName: nil, bundle: nil)
//        modalPresentationStyle = .overFullScreen
//        modalTransitionStyle = .crossDissolve
//    }
//    
//    required init?(coder: NSCoder) { fatalError() }
//
//    private let dimView: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        return v
//    }()
//    private let card = UIView()
//    private let titleLabel = UILabel()
//    private let imageView = UIImageView(image: UIImage(named: "celebration")) // 폭죽 이미지
//    private let okButton = UIButton(type: .system)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(dimView)
//        dimView.frame = view.bounds
//        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        card.backgroundColor = .white
//        card.layer.cornerRadius = 18
//        card.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(card)
//
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 0
//        titleLabel.font = Typography.Body01.medium.font
//        titleLabel.textColor = .grayScale7
//        titleLabel.text = "혼잡도 알리기 완료!"
//
//        imageView.image = .illustrationCongratulation
//        imageView.contentMode = .scaleAspectFit
//
//        okButton.setTitle("확인", for: .normal)
//        okButton.setTitleColor(.white, for: .normal)
//        okButton.backgroundColor = UIColor.systemOrange
//        okButton.layer.cornerRadius = 12
//        okButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
//
//        let stack = UIStackView(arrangedSubviews: [titleLabel, imageView, okButton])
//        stack.axis = .vertical
//        stack.spacing = 20
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        card.addSubview(stack)
//
//        NSLayoutConstraint.activate([
//            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
//            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
//
//            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 30),
//            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
//            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
//            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -30),
//
//            imageView.heightAnchor.constraint(equalToConstant: 114),
//            okButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
//
//    @objc private func dismissSelf() {
//        dismiss(animated: true) { [weak self] in
//            self?.onConfirm?()
//        }
//    }
//}
