//
//  VoteViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import RxSwift
import RxCocoa

final class VoteViewModel {
    struct Output {
        let items: Driver<[MyAnswer]>
    }
    
    let output: Output
    
    init(items: Driver<[MyAnswer]>) {
        self.output = .init(items: items)
    }
}
