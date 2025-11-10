//
//  HistoryViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 11/7/25.
//

import RxSwift
import RxCocoa

final class HistoryViewModel {
    
    var goToCongestionReportView: (() -> Void)?
    
    struct Output {
        let items: Driver<[MyHistory]>
    }
    
    let output: Output
    
    init(items: Driver<[MyHistory]>) {
        self.output = .init(items: items)
    }
}
