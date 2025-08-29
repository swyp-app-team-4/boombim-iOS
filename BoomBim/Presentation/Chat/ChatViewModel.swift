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
    }
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let voteList: Driver<[VoteItemResponse]>
        let myVoteList: Driver<[VoteItemResponse]>
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
            .combineLatest(triggerD, input.location) { _, loc in
                print("combineLatest(triggerD, input.location)")
                return loc
            }
        
        triggerD.do(onNext: { _ in print("VM: trigger!") })
        coordD.do(onNext: { c in print("VM: coord ready", c) })
        // 3) 네트워크 호출
        let shared: Driver<VoteListResponse> = coordD
            .do(onNext: { [loading] _ in loading.accept(true) })
            .flatMapLatest { coord -> Driver<VoteListResponse> in
                let req = VoteListRequest(latitude: coord.latitude, longitude: coord.longitude)
                print("fetchVote Reqeust : \(req)")
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

        // 한 번 호출해서 결과를 공유 (두 페이지가 구독해도 네트워크 1회)
//        let shared: Driver<VoteListResponse> = trigger
//            .withLatestFrom(input.location)
//            .do(onNext: { [loading] _ in loading.accept(true) })
//            .flatMapLatest { coord -> Driver<VoteListResponse> in
//                let request: VoteListRequest = .init(latitude: coord.latitude, longitude: coord.longitude)
//                print("fetchVote Reqeust : \(request)")
//                return VoteService.shared.fetchVoteList(request)
//                    .asObservable()
//                    .do(onError: { [weak self] error in
//                        self?.loading.accept(false)
//                        self?.errorRelay.accept(error.localizedDescription)
//                    })
//                    .catch { _ in .empty() }               // 에러를 빈 스트림으로 대체
//                    .asDriver(onErrorDriveWith: .empty())  // Driver로 승격
//            }
//            .do(onNext: { [loading] _ in loading.accept(false) })

        let voteList = shared.map { $0.voteResList }
        let myVoteList = shared.map { $0.myVoteResList }

        return Output(
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            voteList: voteList,
            myVoteList: myVoteList
        )
    }
}
