//
//  VoteChatViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/29/25.
//

import RxSwift
import RxCocoa

final class VoteChatViewModel {
    let items: Driver<[VoteItemResponse]>

    init(items: Driver<[VoteItemResponse]>) {
        self.items = items
    }

    struct Input {
        let endVoteTap: Signal<Int>  // ✅ 종료 버튼 탭(voteId)
    }
    struct Output {
        let isLoading: Driver<Bool>
        let toast: Signal<String>
        let ended: Signal<Int>       // 종료 성공한 voteId
        let items: Driver<[VoteItemResponse]> // 그대로 전달
    }

    private let loading = BehaviorRelay<Bool>(value: false)
    private let toastRelay = PublishRelay<String>()
    private let endedRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()

    func transform(_ input: Input) -> Output {
        input.endVoteTap
            .throttle(.milliseconds(500))
            .do(onNext: { [loading] _ in loading.accept(true) })
            .flatMapLatest { id -> Signal<Int> in
                // 파라미터 이름과 다른 이름 사용
                let body = VoteFinishRequest(voteId: id)

                // return 명시 + 에러를 Signal로 처리
                return VoteService.shared.finishVote(body)   // Single<Void> 가정
                    .asSignal(onErrorRecover: { [weak self] error in
                        self?.loading.accept(false)
                        if let e = error as? EndVoteError {
                            self?.toastRelay.accept(e.localizedDescription ?? "오류가 발생했어요.")
                        } else {
                            self?.toastRelay.accept(error.localizedDescription)
                        }
                        return .empty() // Signal<Void>
                    })
                    // 최종적으로 Signal<Int>로 맞춤: 성공 시 원래 id 방출
                    .map { _ in id }
            }
            .emit(onNext: { [weak self] id in
                self?.loading.accept(false)
                self?.toastRelay.accept("투표를 종료했어요.")
                self?.endedRelay.accept(id)
            })
            .disposed(by: disposeBag)


        return Output(
            isLoading: loading.asDriver(),
            toast: toastRelay.asSignal(),
            ended: endedRelay.asSignal(),
            items: items
        )
    }
}
