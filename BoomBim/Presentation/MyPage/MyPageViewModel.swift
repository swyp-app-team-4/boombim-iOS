//
//  MyPageViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa

final class MyPageViewModel {
    struct Input { let appear: Signal<Void> } // viewDidAppear 등에서 트리거
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let profile: Driver<UserProfile>
    }
    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let profileRelay = BehaviorRelay<UserProfile?>(value: nil)
    private let disposeBag = DisposeBag()
    
    var goToSettingsView: (() -> Void)?
    var goToProfileView: (() -> Void)?
    
    func didTapSettings() {
        goToSettingsView?()
    }
    
    func didTapProfile() {
        goToProfileView?()
    }
    
    func transform(_ input: Input) -> Output {
        input.appear
            .emit(onNext: { [weak self] in self?.load() })
            .disposed(by: bag)
        
        return Output(
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            profile: profileRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func load() {
        loading.accept(true)
        AuthService.shared.fetchMyProfile()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.profileRelay.accept(p)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: bag)
    }
}
