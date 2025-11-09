//
//  PointViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import RxSwift
import RxCocoa
import RxRelay

final class PointViewModel {
    var goToCongestionReportView: (() -> Void)?
    var goToEventInfoView: (() -> Void)?
    
    struct Input {
        let appear: Signal<Void> // viewDidAppear 등에서 트리거
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let point: Driver<UserPoint>
    }
    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let pointRelay = BehaviorRelay<UserPoint?>(value: nil)
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        input.appear
            .emit(onNext: { [weak self] in self?.load() })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            point: pointRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
        )
    }
    
    private func load() {
        loading.accept(true)
        
        AuthService.shared.getPoint()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.pointRelay.accept(p)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
