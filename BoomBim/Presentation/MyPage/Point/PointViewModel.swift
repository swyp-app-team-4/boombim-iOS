//
//  PointViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import RxSwift
import RxRelay

final class PointViewModel {
    var goToCongestionReportView: (() -> Void)?
    var goToEventInfoView: (() -> Void)?
    
    let pointRelay: BehaviorRelay<UserPoint>
    
    init(initialPoint: UserPoint) {
        self.pointRelay = .init(value: initialPoint)
    }
}
