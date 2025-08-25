//
//  AppSearchTextField.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit

/// 왼쪽 돋보기 + 입력 시 클리어(X) 아이콘이 있는 검색 필드
final class AppSearchTextField: UISearchTextField {

    // 흐림 없는 "진짜" 배경을 그릴 래퍼용 배경 뷰 (선택)
    private let bgView = UIView()

    init(height: CGFloat = 44) {
        super.init(frame: .zero)
        setup(height: height)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(height: 44)
    }

    private func setup(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true

        // 1) 텍스트필드 자체 배경/경계 제거 (시스템 블러 영향 최소화)
        background = nil
        borderStyle = .none
        backgroundColor = .clear
        isOpaque = false   // 투명 처리에 더 안전

        // 2) 커스텀 배경을 별도 뷰로 깔기 (흐림 없이 선명한 흰색/보더)
        insertSubview(bgView, at: 0)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        bgView.backgroundColor = .white               // 원하는 배경색
        bgView.layer.cornerRadius = 10
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.grayScale4.cgColor
        bgView.isUserInteractionEnabled = false       // 터치 방해 X

        // 텍스트/커서 색
        textColor = .grayScale9
        tintColor = .grayScale8

        // 폰트/플레이스홀더
        font = Typography.Body03.medium.font
        attributedPlaceholder = NSAttributedString(
            string: "약속된 장소를 검색해보세요.",
            attributes: [.foregroundColor: UIColor.placeholder]
        )

        // 키보드/클리어
        returnKeyType = .search
        clearButtonMode = .whileEditing   // 시스템 기본 X 버튼 사용

        // 왼쪽 돋보기 아이콘
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .grayScale8

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: height))
        icon.frame = CGRect(x: 8, y: (height - 18)/2, width: 18, height: 18)
        container.addSubview(icon)
        leftView = container
        leftViewMode = .always
        
        rightView?.tintColor = .grayScale8

        // 시스템이 내부 블러를 그리기 전에 한 번 정리
        stripSystemBackground()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // iOS가 편집 전/후 등 상태 전환 때 내부 효과뷰를 다시 깔 수 있어 반복적으로 숨김
        stripSystemBackground()
    }

    /// 내부에 삽입되는 블러/채움 효과 뷰(UIVisualEffectView 등)를 투명화/숨김
    private func stripSystemBackground() {
        // 재귀적으로 모든 서브뷰 순회
        func walk(_ v: UIView) {
            for s in v.subviews {
                // 1) 블러(효과) 뷰 무력화
                if let eff = s as? UIVisualEffectView {
                    eff.effect = nil
                    eff.isHidden = true
                    eff.alpha = 0
                }
                // 2) 사설 배경 뷰(이름이 바뀌어도 "SearchFieldBackground" 문자열이 포함되는 경우가 많음)
                let name = String(describing: type(of: s))
                if name.contains("SearchFieldBackground") {
                    s.isHidden = true
                    s.alpha = 0
                    s.backgroundColor = .clear
                }
                walk(s)
            }
        }
        walk(self)
    }
}
