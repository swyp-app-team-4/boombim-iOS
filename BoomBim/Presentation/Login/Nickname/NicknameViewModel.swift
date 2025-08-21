//
//  NicknameViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import RxSwift
import RxCocoa
import Foundation

final class NicknameViewModel {
    struct Input {
        let nicknameText: Driver<String>
        let signupTap: Signal<Void>
    }
    
    struct Output {
        let isSignupEnabled: Driver<Bool>
    }
    
    private let signupCompletedRelay = PublishRelay<Void>()
    var signupCompleted: Signal<Void> {
        signupCompletedRelay.asSignal()
    }
    
    private let disposeBag = DisposeBag()
    
    private func validate(_ text: String) -> Bool {
        print("text: \(text)")
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...12).contains(trimmed.count) else { return false }
        // 한글/영문/숫자/밑줄만 허용 예시
        let regex = "^[0-9A-Za-z가-힣_]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }
    
    func tansform(input: Input) -> Output {
        let isSignupEnabled = input.nicknameText
            .map(validate)
            .distinctUntilChanged()
        
        input.signupTap
            .emit(onNext: { [weak self] _ in
                print("tap!")
                self?.signupCompletedRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            isSignupEnabled: isSignupEnabled
        )
    }
}
