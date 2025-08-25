//
//  PollListHeaderView.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

enum PollFilter: Int { case all = 0, ongoing, closed }
enum PollSort:   Int { case latest = 0, closedOrder }

final class PollListHeaderView: UIView {
    // 외부로 이벤트 전달
    var onFilterChange: ((PollFilter) -> Void)?
    var onSortChange:   ((PollSort)   -> Void)?

    // UI
    private let allBtn = ChipButton()
    private let onBtn  = ChipButton()
    private let offBtn = ChipButton()
    private let sortBtn = UIButton(type: .system)

    private lazy var chipStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [allBtn, onBtn, offBtn])
        s.axis = .horizontal; s.spacing = 12; s.alignment = .center
        return s
    }()
    private lazy var root: UIStackView = {
        let s = UIStackView(arrangedSubviews: [chipStack, UIView(), sortBtn])
        s.axis = .horizontal; s.alignment = .center
        return s
    }()

    // 상태
    private(set) var currentFilter: PollFilter = .all
    private(set) var currentSort: PollSort = .latest

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        allBtn.setTitle("전체", for: .normal)
        onBtn.setTitle("진행중", for: .normal)
        offBtn.setTitle("종료", for: .normal)

        [allBtn, onBtn, offBtn].enumerated().forEach { idx, b in
            b.tag = idx
            b.addTarget(self, action: #selector(didTapChip(_:)), for: .touchUpInside)
        }

        sortBtn.setTitle("최신순 ▾", for: .normal)
        sortBtn.setTitleColor(.grayScale9, for: .normal)
        sortBtn.titleLabel?.font = Typography.Body03.medium.font
        sortBtn.showsMenuAsPrimaryAction = true
        applySortMenu() // 드롭다운 구성

        addSubview(root)
        root.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            root.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        // 기본 선택
        setFilter(.all, send: false)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Actions
    @objc private func didTapChip(_ sender: UIButton) {
        guard let f = PollFilter(rawValue: sender.tag) else { return }
        setFilter(f, send: true)
    }

    func setFilter(_ f: PollFilter, send: Bool) {
        currentFilter = f
        allBtn.isSelected = (f == .all)
        onBtn.isSelected  = (f == .ongoing)
        offBtn.isSelected = (f == .closed)
        if send { onFilterChange?(f) }
    }

    func setSort(_ s: PollSort, send: Bool) {
        currentSort = s
        let title = (s == .latest) ? "최신순 ▾" : "종료순 ▾"
        sortBtn.setTitle(title, for: .normal)
        applySortMenu() // 체크 상태 갱신
        if send { onSortChange?(s) }
    }

    private func applySortMenu() {
        // iOS14+ 드롭다운
        let latest = UIAction(
            title: "최신순",
            state: currentSort == .latest ? .on : .off
        ) { [weak self] _ in self?.setSort(.latest, send: true) }

        let closed = UIAction(
            title: "종료순",
            state: currentSort == .closedOrder ? .on : .off
        ) { [weak self] _ in self?.setSort(.closedOrder, send: true) }

        sortBtn.menu = UIMenu(children: [latest, closed])
    }
}
