//
//  PointFilterBarView.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit

enum PointFilter: CaseIterable {
    case all, earn, use
    
    var title: String {
        switch self {
        case .all:        return "전체"
        case .earn:       return "적립내역"
        case .use:          return "사용내역"
        }
    }
}

final class PointFilterBarView: UIView {
    var onChange: ((PointFilter) -> Void)?
    private var buttons: [PointFilter: DefaultChipButton] = [:]

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
//            heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
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
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),

            // 스택의 높이를 스크롤뷰 높이에 맞춰서(세로로는 스크롤 안 하도록)
            stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])

        // 3) 버튼 추가
        PointFilter.allCases.forEach { filter in
            let b = DefaultChipButton(title: filter.title)
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)

            // 칩이 가로로 절대 줄지 않게
            b.setContentHuggingPriority(.required, for: .horizontal)
            b.setContentCompressionResistancePriority(.required, for: .horizontal)

            buttons[filter] = b
            stack.addArrangedSubview(b)
        }

        select(.all)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tap(_ sender: DefaultChipButton) {
        guard let (filter, _) = buttons.first(where: { $0.value === sender }) else { return }
        select(filter)
        onChange?(filter)
    }

    func select(_ filter: PointFilter) {
        buttons.forEach { $0.value.isSelected = ($0.key == filter) }
    }
}
