//
//  SectionSpacerView.swift
//  BoomBim
//
//  Created by 조영현 on 9/6/25.
//

import UIKit

final class SectionSpacerView: UICollectionReusableView {
    static let elementKind = "SectionSpacerView"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .viewDivider
        layer.cornerRadius = 0
    }
    required init?(coder: NSCoder) { fatalError() }
}
