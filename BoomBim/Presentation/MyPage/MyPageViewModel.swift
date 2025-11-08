//
//  MyPageViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa

final class MyPageViewModel {
    struct Input {
        let appear: Signal<Void> // viewDidAppear 등에서 트리거
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let profile: Driver<UserProfile>
        let point: Driver<UserPoint>
        let favorite: Driver<[MyFavorite]>
        let history: Driver<[MyHistory]>
        let answer: Driver<[MyAnswer]>
        let question: Driver<[MyQuestion]>
    }
    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let profileRelay = BehaviorRelay<UserProfile?>(value: nil)
    private let pointRelay = BehaviorRelay<UserPoint?>(value: nil)
    private let favoriteRelay = BehaviorRelay<[MyFavorite]?>(value: nil)
    private let historyRelay = BehaviorRelay<[MyHistory]?>(value: nil)
    private let answerRelay = BehaviorRelay<[MyAnswer]?>(value: nil)
    private let questionRelay = BehaviorRelay<[MyQuestion]?>(value: nil)
    private let disposeBag = DisposeBag()
    
    var goToSettingsView: (() -> Void)?
    var goToProfileView: (() -> Void)?
    var goToPointView: ((UserPoint) -> Void)?
    
    private var pointData: UserPoint?
    
    func didTapSettings() { goToSettingsView?() }
    func didTapProfile() { goToProfileView?() }
    func didTapPoint() {
        guard let p = pointData else {
            // 아직 로딩 중이거나 실패한 상태 → 토스트/로딩 유도
            loading.accept(true) // 선택
            return
        }
        goToPointView?(p)
    }
    
    func transform(_ input: Input) -> Output {
        input.appear
            .emit(onNext: { [weak self] in self?.load() })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            profile: profileRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            point: pointRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            favorite: favoriteRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            history: historyRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            answer: answerRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            question: questionRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func load() {
        loading.accept(true)
        AuthService.shared.getProfile()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.profileRelay.accept(p)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        AuthService.shared.getPoint()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.pointData = p
                self?.pointRelay.accept(p)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        PlaceService.shared.getFavoritePlace()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.favoriteRelay.accept(p.data)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        PlaceService.shared.getReportHistory()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] p in
                self?.loading.accept(false)
                self?.historyRelay.accept(p)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.errorRelay.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
        
//        AuthService.shared.getMyAnswer()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onSuccess: { [weak self] p in
//                self?.loading.accept(false)
//                self?.answerRelay.accept(p)
//            }, onFailure: { [weak self] err in
//                self?.loading.accept(false)
//                self?.errorRelay.accept(err.localizedDescription)
//            })
//            .disposed(by: disposeBag)
//        
//        AuthService.shared.getMyQuestion()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onSuccess: { [weak self] p in
//                self?.loading.accept(false)
//                self?.questionRelay.accept(p)
//            }, onFailure: { [weak self] err in
//                self?.loading.accept(false)
//                self?.errorRelay.accept(err.localizedDescription)
//            })
//            .disposed(by: disposeBag)
    }
}
