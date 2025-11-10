//
//  EventViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import RxSwift
import RxCocoa

final class EventViewModel {
    var goToCongestionReportView: (() -> Void)?
    
    struct Input {
        let appear: Signal<Void> // viewDidAppear 등에서 트리거
        let purchaseTap: Signal<Void>
    }
    
    struct Output {
        let completed: Signal<Int>
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let purchaseFail: Signal<Int>
        let event: Driver<UserEventInfo>
    }
    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let purchaseFailRelay = PublishRelay<Int>()
    private let eventRelay = BehaviorRelay<UserEventInfo?>(value: nil)
    private let completedRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        input.appear
            .emit(onNext: { [weak self] in self?.load() })
            .disposed(by: disposeBag)
        
        input.purchaseTap
            .withLatestFrom(eventRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty()))
            .throttle(.milliseconds(800)) // 중복탭 방지 (선택)
            .emit(onNext: { [weak self] event in
                self?.purchase(eventInfo: event)
            })
            .disposed(by: disposeBag)
        
        return Output(
            completed: completedRelay.asSignal(),
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            purchaseFail: purchaseFailRelay.asSignal(),
            event: eventRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func load() {
        loading.accept(true)
        AuthService.shared.getEvent()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.eventRelay.accept(p)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func purchase(eventInfo: UserEventInfo) {
        loading.accept(true)
        
        let request: EventTicketRequest = .init(eventCampaignId: eventInfo.eventCampaignId, amount: 20)
        
        AuthService.shared.purchaseTicket(body: request)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                guard let self else { return }
                self.loading.accept(false)
                
                if response.status == 200 {
                    self.completedRelay.accept((eventInfo.currentTicket + 1))
                    self.load()
                } else {
                    self.purchaseFailRelay.accept(response.code)
                }
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
