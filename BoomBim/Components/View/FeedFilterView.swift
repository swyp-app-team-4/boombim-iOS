//
//  FeedFilterView.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

enum FeedFilter: CaseIterable {
    case latest, crowded, busy, normal, relaxed
    
    var title: String {
        switch self {
        case .latest:        return "최신순"
        case .crowded:       return "붐빔"
        case .busy:          return "약간 붐빔"
        case .normal:        return "보통"
        case .relaxed:       return "여유"
        }
    }
}

final class FilterBarView: UIView {
    var onChange: ((FeedFilter) -> Void)?
    private var buttons: [FeedFilter: FeedChipButton] = [:]

    private let scroll = UIScrollView()
    private let stack  = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        // 1) ScrollView
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])

        // 2) StackView inside scroll (❗️contentLayoutGuide/ frameLayoutGuide 사용)
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill            // ← 줄임 방지: 비율 분배 금지
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -8),

            // 스택의 높이를 스크롤뷰 높이에 맞춰서(세로로는 스크롤 안 하도록)
            stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor, constant: -16)
        ])

        // 3) 버튼 추가
        FeedFilter.allCases.forEach { filter in
            let b = FeedChipButton(title: filter.title)
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)

            // 칩이 가로로 절대 줄지 않게
            b.setContentHuggingPriority(.required, for: .horizontal)
            b.setContentCompressionResistancePriority(.required, for: .horizontal)

            buttons[filter] = b
            stack.addArrangedSubview(b)
        }

        select(.latest)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tap(_ sender: FeedChipButton) {
        guard let (filter, _) = buttons.first(where: { $0.value === sender }) else { return }
        select(filter)
        onChange?(filter)
    }

    func select(_ filter: FeedFilter) {
        buttons.forEach { $0.value.isSelected = ($0.key == filter) }
    }
}

