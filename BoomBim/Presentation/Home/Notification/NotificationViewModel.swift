//
//  NotificationViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/8/25.
//

import RxSwift
import RxCocoa

final class NotificationViewModel {
    private let service: FcmService
    private let disposeBag = DisposeBag()
    
    let tokenResult = PublishSubject<Result<FcmTokenResponse, Error>>()
    let alarmResult = PublishSubject<Result<[AlarmItem], Error>>()
    
    init(service: FcmService) {
        self.service = service
    }
    
    func setFcmToken() {
        guard let token = TokenManager.shared.fcmToken,
              let userToken = TokenManager.shared.currentAccessToken() else { return }
        
        service.registerFcmToken(userToken: userToken, token: token)
        // 성공/실패에 따른 부가 상태 업데이트
            .do(onNext: { result in
                switch result {
                case .success:
                    print("success")
                    TokenManager.shared.fcmTokenUploadState = true
                case .failure:
                    print("failure")
                    TokenManager.shared.fcmTokenUploadState = false
                }
            })
        // 스트림 에러를 Result.failure로 치환하여 onNext로 전달
            .catch { error in
                TokenManager.shared.fcmTokenUploadState = false
                return .just(.failure(error))
            }
        // 결과를 tokenResult로 전달
            .bind(to: tokenResult)
            .disposed(by: disposeBag)
    }
    
    func fetchAlarm() {
        guard let userToken = TokenManager.shared.currentAccessToken() else { return }
        
        service.fetchAlarm(userToken: userToken)
            .bind(to: alarmResult)
            .disposed(by: disposeBag)
    }
}
