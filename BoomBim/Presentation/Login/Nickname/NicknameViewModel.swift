//
//  NicknameViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import RxSwift
import RxCocoa
import Foundation
import UIKit

final class NicknameViewModel {
    struct Input {
        let nicknameText: Driver<String>     // 닉네임 입력값
        let pickedImage: Driver<UIImage?>    // 선택 이미지(옵션)
        let signupTap: Signal<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let isSignupEnabled: Driver<Bool>
    }
    
    private let signupCompletedRelay = PublishRelay<Void>()
    var signupCompleted: Signal<Void> {
        signupCompletedRelay.asSignal()
    }
    
    private let errorRelay = PublishRelay<String>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    
    private func validate(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // 2~20자, 한글(가-힣) / 영문 / 숫자만 허용
        let pattern = "^[0-9A-Za-z가-힣]{2,20}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: trimmed)
    }
    
    func transform(input: Input) -> Output {
        let isSignupEnabled = input.nicknameText
            .map(validate)
            .distinctUntilChanged()
        
        let latest = Driver.combineLatest(input.nicknameText, input.pickedImage)
        
        input.signupTap
            .withLatestFrom(latest)
            .emit(onNext: { [weak self] (name, image) in
                self?.submit(name: name, image: image)
            })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            isSignupEnabled: isSignupEnabled
        )
    }
    
    private func submit(name: String, image: UIImage?) {
        loadingRelay.accept(true)
        // (1) 닉네임 저장 (필수)
        let nickCall: Single<Void> = AuthService.shared.setNickname(name)
        
        // (2) 프로필 업로드 (선택)
        let photoCall: Single<Void> = {
            guard let image = image,
                  let data = image.uploadPayload(maxBytes: 900_000, maxDimension: 1080, baseName: "profile") else {
                return .just(()) // 이미지 없으면 스킵
            }
            
            return AuthService.shared.setProfileImage(data.data)
                .do(onSuccess: { savedPath in
                    // 필요 시 로컬 캐시/모델 반영
                    UserDefaults.standard.set(savedPath, forKey: "profileImagePath")
                })
                .map { _ in () }
        }()
        
        // (3) 병렬 실행 후 완료
        Single.zip(nickCall, photoCall)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _, _ in
                self?.loadingRelay.accept(false)
                self?.signupCompletedRelay.accept(())
            }, onFailure: { [weak self] err in
                self?.loadingRelay.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
