//
//  CongestionGuideDialogController.swift
//  BoomBim
//
//  Created by 조영현 on 10/30/25.
//

import UIKit

final class CongestionGuideDialogController: UIViewController {

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
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = .init(width: 0, height: 8)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        let text = "혼잡도 기준 안내"
        l.setText(text, style: Typography.Body01.semiBold)
        l.textColor = .grayScale9
        l.textAlignment = .center
        l.numberOfLines = 0
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    private lazy var rowsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 24
        return s
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("닫기", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = Typography.Body02.semiBold.font
        b.backgroundColor = .main
        b.layer.cornerRadius = 22
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        return b
    }()

    private let vStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 24
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 26, left: 24, bottom: 26, right: 24)
        return s
    }()

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        fillRows()
        bind()
    }

    // MARK: - Build
    private func buildUI() {
        view.backgroundColor = .clear

        view.addSubview(dimView)
        dimView.frame = view.bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        card.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        // 구성
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(rowsStack)
        vStack.setCustomSpacing(8, after: titleLabel)
        vStack.addArrangedSubview(closeButton)
    }

    private func fillRows() {
        // 스샷 텍스트 그대로
        let items: [(String, String)] = [
            ("여유", "주변에 사람이 거의 없고 자유롭게 이동 가능해요"),
            ("보통", "공간이 어느 정도 채워져 있지만 불편함은 없어요"),
            ("약간 붐빔", "사람이 많아 조심히 움직이게 돼요"),
            ("붐빔", "공간이 꽉 차거나 붐벼서 불편함이 느껴져요")
        ]
        items.forEach { rowsStack.addArrangedSubview(makeRow(title: $0.0, desc: $0.1)) }
    }

    private func makeRow(title: String, desc: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.setText(title, style: Typography.Body03.semiBold)
        titleLabel.textColor = .grayScale9
        titleLabel.numberOfLines = 1

        let descLabel = UILabel()
        descLabel.setText(desc, style: Typography.Body03.regular)
        descLabel.textColor = .grayScale8
        descLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        // 자동 높이 계산 정확도 향상
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        return stack
    }

    // MARK: - Actions
    private func bind() {
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)

        // 배경 탭으로 닫기 원하면 주석 해제
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClose))
        dimView.addGestureRecognizer(tap)
        dimView.isUserInteractionEnabled = true
        dimView.accessibilityTraits = .button
    }

    @objc private func onClose() {
        dismiss(animated: true, completion: nil)
    }
}

