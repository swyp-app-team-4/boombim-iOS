//
//  FeedbackViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import RxSwift
import RxCocoa

protocol AuthServicing {
    func withdrawAndClear(leaveReason: String) -> Single<Void>
}
extension AuthService: AuthServicing {}   // AuthService.shared 그대로 사용

final class FeedbackViewModel {

    struct Input {
        let keepTap: Signal<Void>
        let withdrawTap: Signal<Void>
        let selectedReasons: Driver<Set<WithdrawReason>>
        let otherText: Driver<String>
    }

    struct Output {
        let isWithdrawEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let dismiss: Signal<Void>          // "계속 이용하기" → 뒤로가기
        let withdrawSuccess: Signal<Void>  // 탈퇴 성공
    }

    private let service: AuthServicing
    private let disposeBag = DisposeBag()

    init(service: AuthServicing = AuthService.shared) {
        self.service = service
    }

    func transform(_ input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay   = PublishRelay<String>()
        let successRelay = PublishRelay<Void>()

        // 버튼 활성화 규칙: 사유 1개 이상 && (기타 선택 시 텍스트 존재)
        let isEnabled = Driver.combineLatest(input.selectedReasons, input.otherText)
            .map { reasons, other -> Bool in
                guard !reasons.isEmpty else { return false }
                if reasons.contains(.other) {
                    return !other.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                return true
            }
            .distinctUntilChanged()

        // 탈퇴 실행
        input.withdrawTap
            .withLatestFrom(Driver.combineLatest(input.selectedReasons, input.otherText))
            .flatMapLatest { [service] (reasons, other) -> Driver<Void> in
                let payload = Self.makeLeaveReason(reasons: reasons, otherText: other)
                loadingRelay.accept(true)
                return service.withdrawAndClear(leaveReason: payload)
                    .asDriver { err in
                        errorRelay.accept(err.localizedDescription)
                        return .empty()
                    }
                    .do(onCompleted: { successRelay.accept(()) },
                        onDispose:   { loadingRelay.accept(false) })
            }
            .drive() // 실행만
            .disposed(by: disposeBag)

        return Output(
            isWithdrawEnabled: isEnabled,
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            dismiss: input.keepTap,                 // keepTap == 바로 뒤로가기
            withdrawSuccess: successRelay.asSignal()
        )
    }

    // API로 보낼 문자열 만들기 (예: "자주 이용하지 않아요, 기능이 불편해요, 기타: ...")
    private static func makeLeaveReason(
        reasons: Set<WithdrawReason>,
        otherText: String
    ) -> String {
        var parts = reasons
            .filter { $0 != .other }
            .map { $0.title }                       // ← WithdrawReason.title 사용
            .sorted()

        if reasons.contains(.other) {
            let trimmed = otherText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { parts.append("기타: \(trimmed)") }
        }
        return parts.joined(separator: ", ")
    }
}
