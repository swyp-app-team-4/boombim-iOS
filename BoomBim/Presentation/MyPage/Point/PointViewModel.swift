//
//  PointViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import RxSwift
import RxRelay

final class PointViewModel {
    // 초기값부터 가지고 있고, 이후 갱신도 가능
    let pointRelay: BehaviorRelay<UserPoint>
    
    init(initialPoint: UserPoint) {
        self.pointRelay = .init(value: initialPoint)
    }
}
