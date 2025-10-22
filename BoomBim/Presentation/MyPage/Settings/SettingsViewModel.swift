//
//  SettingsViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    // 로그아웃 및 회원탈퇴
    enum LogoutWithDrawRoute {
        case login
    }
    
    private let disposeBag = DisposeBag()
    private let loading = BehaviorRelay<Bool>(value: false)
    private let error = PublishRelay<String>()
    private let reasonRelay = PublishRelay<String>()
    var reasonSelected: Signal<String> { reasonRelay.asSignal() }
    
    struct Input {
        let logoutTap: Signal<Void>
        let withdrawTap: Signal<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<String>
    }
    
    var goToPersonalInfoView: (() -> Void)?
    var goToAlarmSettingView: (() -> Void)?
    var goToFeedbackView: (() -> Void)?
    
    func didTapWithdraw() {
        goToFeedbackView?()
    }
    
    // Coordinator가 호출: 피드백화면에서 사유를 받았을 때
    func setWithdrawReason(_ reason: String) {
        reasonRelay.accept(reason) // → VC가 알럿을 띄우는 트리거로 사용
    }
    
    // VC 알럿에서 “확인” 눌렀을 때 호출
    func confirmWithdraw(reason: String) {
        performWithdraw(reason: reason)         // 내부 private 메서드 호출
    }
    
    func transform(_ input: Input) -> Output {
        input.logoutTap
            .emit(onNext: { [weak self] in self?.performLogout() })
            .disposed(by: disposeBag)
        
        input.withdrawTap
            .emit(onNext: { [weak self] in
                
                self?.didTapWithdraw()
            })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: loading.asDriver(),
            error: error.asSignal()
        )
    }
    
    private func performLogout() {
        loading.accept(true)
        AuthService.shared.logoutAndClear()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.loading.accept(false)
                // ✅ 라우팅 없음. TokenManager.clear()로 상태가 .loggedOut이 되어
                // AppCoordinator가 자동으로 로그인 화면으로 전환함.
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                // 서버 호출 실패해도 로컬은 이미 비워졌다면 화면은 어차피 로그인으로 전환됨.
                // 필요 시 에러 토스트만 표시.
                self?.error.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func performWithdraw(reason: String) {
        loading.accept(true)
        AuthService.shared.withdrawAndClear(leaveReason: reason)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.loading.accept(false)
            }, onFailure: { [weak self] err in
                self?.loading.accept(false)
                self?.error.accept(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
