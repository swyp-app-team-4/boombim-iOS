//
//  QuestionViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import RxSwift
import RxCocoa

final class QuestionViewModel {
    struct Output {
        let items: Driver<[MyQuestion]>
    }
    
    let output: Output
    
    init(items: Driver<[MyQuestion]>) {
        self.output = .init(items: items)
    }
}
