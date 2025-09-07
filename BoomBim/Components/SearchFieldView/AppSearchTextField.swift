//
//  AppSearchTextField.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit

/// 왼쪽 돋보기 + 입력 시 클리어(X) 아이콘이 있는 검색 필드
final class AppSearchTextField: UISearchTextField {

    // 흐림 없는 배경
    private let bgView = UIView()

    var placeholderColor: UIColor = .placeholder { didSet { applyPlaceholderStyle() } }
    var placeholderFont: UIFont = Typography.Body03.medium.font { didSet { applyPlaceholderStyle() } }
    
    override var placeholder: String? {
        didSet { applyPlaceholderStyle() }   // 사용자가 placeholder 바꾸면 스타일 재적용
    }
    
    // ✅ 탭 전용 모드 & 콜백
    var tapOnly: Bool = false { didSet { updateTapMode() } }
    var onTap: (() -> Void)?

    private lazy var tapGR: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        g.cancelsTouchesInView = true
        g.delaysTouchesBegan = true // 테이블셀 등과 섞일 때 안전
        return g
    }()

    init(height: CGFloat = 44) {
        super.init(frame: .zero)
        setup(height: height)
        if placeholder == nil {              // 기본 문구는 필요할 때만
            placeholder = "약속된 장소를 검색해보세요."
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(height: 44)
    }

    private func setup(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true

        background = nil
        borderStyle = .none
        backgroundColor = .clear
        isOpaque = false

        insertSubview(bgView, at: 0)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 10
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.grayScale4.cgColor
        bgView.isUserInteractionEnabled = false

        textColor = .grayScale9
        tintColor = .grayScale8

        font = Typography.Body03.medium.font
        attributedPlaceholder = NSAttributedString(
            string: "약속된 장소를 검색해보세요.",
            attributes: [.foregroundColor: UIColor.placeholder]
        )

        returnKeyType = .search
        clearButtonMode = .whileEditing

        // 왼쪽 아이콘
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .grayScale8

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: height))
        icon.frame = CGRect(x: 8, y: (height - 18)/2, width: 18, height: 18)
        container.addSubview(icon)
        container.isUserInteractionEnabled = false // ✅ 제스처 방해 X
        leftView = container
        leftViewMode = .always

        rightView?.tintColor = .grayScale8

        stripSystemBackground()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stripSystemBackground()
    }
    
    private func applyPlaceholderStyle() {
        let text = placeholder ?? ""
        attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: placeholderFont
            ]
        )
    }

    // MARK: - Tap-only mode
    private func updateTapMode() {
        if tapOnly {
            // 키보드/편집 차단
            clearButtonMode = .never
            rightViewMode = .never
            tintColor = .clear // 캐럿 숨김

            if gestureRecognizers?.contains(tapGR) != true {
                addGestureRecognizer(tapGR)
            }

            // 접근성: 버튼처럼 읽히게
            accessibilityTraits.insert(.button)
            accessibilityHint = "탭하면 다음 화면으로 이동"
        } else {
            clearButtonMode = .whileEditing
            rightViewMode = .always
            tintColor = .grayScale8
            if gestureRecognizers?.contains(tapGR) == true {
                removeGestureRecognizer(tapGR)
            }
            accessibilityTraits.remove(.button)
            accessibilityHint = nil
        }
    }

    @objc private func handleTap() {
        // 혹시 외부에서 becomeFirstResponder를 호출했을 수 있으니 방지
        _ = resignFirstResponder()
        onTap?()
        sendActions(for: .primaryActionTriggered) // 필요시 외부 Target-Action도 사용 가능
    }

    // 편집 진입 자체를 막아 안전장치 (tapOnly일 때)
    override var canBecomeFirstResponder: Bool {
        tapOnly ? false : super.canBecomeFirstResponder
    }
    override func becomeFirstResponder() -> Bool {
        tapOnly ? false : super.becomeFirstResponder()
    }

    // 내부 블러 제거
    private func stripSystemBackground() {
        func walk(_ v: UIView) {
            for s in v.subviews {
                if let eff = s as? UIVisualEffectView {
                    eff.effect = nil; eff.isHidden = true; eff.alpha = 0
                }
                let name = String(describing: type(of: s))
                if name.contains("SearchFieldBackground") {
                    s.isHidden = true; s.alpha = 0; s.backgroundColor = .clear
                }
                walk(s)
            }
        }
        walk(self)
    }
}

