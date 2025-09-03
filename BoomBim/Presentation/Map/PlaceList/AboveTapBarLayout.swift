//
//  AboveTapBarLayout.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import FloatingPanel
import Foundation

final class AboveTabBarLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition { .bottom }
    private let tabBarHeight: CGFloat
    init(tabBarHeight: CGFloat) { self.tabBarHeight = tabBarHeight }

    var initialState: FloatingPanelState { .tip }

    // 각 상태별 앵커(절대/비율 혼용)
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 120, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.45, edge: .bottom, referenceGuide: .superview),
            .tip:  FloatingPanelLayoutAnchor(absoluteInset: 35, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
}
