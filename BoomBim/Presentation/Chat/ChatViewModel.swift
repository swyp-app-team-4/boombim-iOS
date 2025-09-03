//
//  ChatViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class ChatViewModel {
    struct Input {
        let appear: Signal<Void>                 // viewDidAppear 등
        let refresh: Signal<Void>                // 당겨서 새로고침 or 상단 버튼
        let location: Driver<CLLocationCoordinate2D>   // (lat, lng)
//        let vote: Signal<Void>
    }
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let voteList: Driver<[VoteItemResponse]>
        let myVoteList: Driver<[MyVoteItemResponse]>
    }

    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    var goToQuestionView: (() -> Void)?
    
    func didTapFloating() {
        goToQuestionView?()
    }

    func transform(_ input: Input) -> Output {
        // 1) 트리거를 Driver로 올림
        let appearD  = input.appear.asDriver(onErrorDriveWith: .empty())
        let refreshD = input.refresh.asDriver(onErrorDriveWith: .empty())
        let triggerD = Driver.merge(appearD, refreshD)
        
        appearD.drive(onNext: { print("VM: appear!") }).disposed(by: disposeBag)
        refreshD.drive(onNext: { print("VM: refresh!") }).disposed(by: disposeBag)
        
        let coordD: Driver<CLLocationCoordinate2D> = Driver
            .combineLatest(triggerD, input.location) { _, loc in loc }
        
        // 3) 네트워크 호출
        let shared: Driver<VoteListResponse> = coordD
            .do(onNext: { [loading] _ in loading.accept(true) })
            .flatMapLatest { coord -> Driver<VoteListResponse> in
                let req = VoteListRequest(latitude: coord.latitude, longitude: coord.longitude)
                return VoteService.shared.fetchVoteList(req)
                    .asObservable()
                    .do(onError: { [weak self] err in
                        self?.loading.accept(false)
                        self?.errorRelay.accept(err.localizedDescription)
                    })
                    .catch { _ in .empty() }
                    .asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { [loading] _ in loading.accept(false) })

        let voteList = shared.map { Array($0.voteResList.reversed()) }
        let myVoteList = shared.map { Array($0.myVoteResList.reversed()) }

        return Output(
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            voteList: voteList,
            myVoteList: myVoteList
        )
    }
}
