//
//  PollListSectionHeader.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

// 칩 + 드롭다운을 이미 만든 PollListHeaderView를 재사용한다고 가정
final class PollListSectionHeader: UITableViewHeaderFooterView {
    static let identifier = "PollListSectionHeader"

    let header = PollListHeaderView()   // 앞서 만든 헤더(칩/메뉴 포함)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        contentView.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            header.topAnchor.constraint(equalTo: contentView.topAnchor),
            header.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    // 외부에서 상태/콜백 주입
    func configure(filter: PollFilter, sort: PollSort, onFilter: @escaping (PollFilter) -> Void, onSort:   @escaping (PollSort)   -> Void) {
        header.setFilter(filter, send: false)
        header.setSort(sort, send: false)
        
        header.onFilterChange = onFilter
        header.onSortChange   = onSort
    }
}
