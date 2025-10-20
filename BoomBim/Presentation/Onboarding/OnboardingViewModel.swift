//
//  OnboardingViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 9/18/25.
//

import Foundation
import RxSwift
import RxCocoa


final class OnboardingViewModel {
    struct Input {
        let tapNext: Observable<Void>
        let tapSkip: Observable<Void>
        let tapStart: Observable<Void>
        let swipedTo: Observable<Int>
    }
    
    struct Output {
        let pageIndex: Driver<Int>
        let isLastPage: Driver<Bool>
        let finish: Signal<Void>
    }
    
    private let totalPages: Int
    private let bag = DisposeBag()
    
    init(totalPages: Int) {
        self.totalPages = max(totalPages, 1)
    }
    
    func transform(_ input: Input) -> Output {
        let indexRelay = BehaviorRelay<Int>(value: 0)
        
        
        // 스와이프/어댑터로부터 인덱스 갱신
        input.swipedTo
            .bind(to: indexRelay)
            .disposed(by: bag)
        
        
        // 다음 버튼 → 인덱스 +1 (상한 보장)
        input.tapNext
            .withLatestFrom(indexRelay)
            .map { min($0 + 1, self.totalPages - 1) }
            .bind(to: indexRelay)
            .disposed(by: bag)
        
        
        let pageIndex = indexRelay.asDriver()
        let isLastPage = pageIndex.map { $0 == self.totalPages - 1 }
        
        
        let finish = Observable.merge(input.tapSkip, input.tapStart)
            .asSignal(onErrorSignalWith: .empty())
        
        
        return Output(pageIndex: pageIndex, isLastPage: isLastPage, finish: finish)
    }
}
