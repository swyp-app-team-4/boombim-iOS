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
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.06
//        layer.shadowRadius = 6
//        layer.shadowOffset = .init(width: 0, height: 2)
        
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fillProportionally
        
        FeedFilter.allCases.forEach { filter in
            let b = FeedChipButton(title: filter.title)
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            buttons[filter] = b
            stack.addArrangedSubview(b)
        }
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56) // 고정 높이 가이드
        ])
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
