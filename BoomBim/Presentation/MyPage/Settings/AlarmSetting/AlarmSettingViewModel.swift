//
//  AlarmSettingViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 10/21/25.
//

import Foundation
import UserNotifications
import RxSwift

final class AlarmSettingViewModel {
    // Output: VC로 전달
    var onStateChange: ((Bool) -> Void)?     // 스위치 표시값(= 서버 구독값)
    var onNeedOpenSettings: (() -> Void)?   // 권한 거부 → 설정 이동 안내
    var onError: ((String) -> Void)?

    // 내부
    private let bag = DisposeBag()
    private(set) var systemAuthorized: Bool = false
    private var serverEnabled: Bool {
        get { AlarmStore.shared.currentAlarmState ?? false }
        set { AlarmStore.shared.setCurrentAlarmState(newValue) }
    }

    /// VC에서 초기 표시값으로 쓸 수 있음(서버 구독값)
    var alarmState: Bool { serverEnabled }

    // MARK: - Lifecycle
    func loadInitialState() {
        readSystemPermission { [weak self] authorized in
            guard let self else { return }
            self.systemAuthorized = authorized
            self.publish()
        }
    }

    /// 설정 앱 갔다가 돌아왔을 때 호출 (조건 3 반영)
    func appDidBecomeActive() {
        readSystemPermission { [weak self] authorized in
            guard let self else { return }
            let wasAuthorized = self.systemAuthorized
            self.systemAuthorized = authorized

            // ✅ 자동 ON 조건:
            //  - 권한이 허용 상태이고
            //  - 서버가 아직 OFF이며
            //  - 사용자가 "ON 의도"를 남겼던 경우(스위치 ON 시도했던 흔적)
            if authorized,
               self.serverEnabled == false,
               AlarmStore.shared.pendingEnableAfterPermission == true {
                AuthService.shared.setAlarm()
                    .subscribe(onSuccess: { [weak self] in
                        // 일회성 처리 → 플래그 해제
                        AlarmStore.shared.pendingEnableAfterPermission = false
                        self?.serverEnabled = true
                        self?.publish()
                    }, onFailure: { [weak self] _ in
                        self?.onError?("알림 상태 동기화에 실패했습니다.")
                        self?.publish()
                    })
                    .disposed(by: self.bag)
            } else if wasAuthorized != authorized {
                // 권한 상태만 바뀐 경우 UI 갱신
                self.publish()
            }
        }
    }

    // MARK: - User Action
    func handleToggle(_ newValue: Bool) {
        print("handleToggle : \(newValue)")
        if newValue == false {
            // 사용자가 명시적으로 OFF → 의도 플래그도 해제
            AlarmStore.shared.pendingEnableAfterPermission = false
            
            AuthService.shared.setAlarm()
                .subscribe(onSuccess: { [weak self] in
                    self?.serverEnabled = false
                    self?.publish()
                }, onFailure: { [weak self] _ in
                    self?.onError?("알림을 끌 수 없습니다. 네트워크 상태를 확인해 주세요.")
                    self?.publish() // 롤백(서버 값 유지)
                })
                .disposed(by: bag)
            return
        }

        // newValue == true
        if systemAuthorized {
            // 권한 OK → 서버만 ON, 의도 플래그는 필요 없음
            AlarmStore.shared.pendingEnableAfterPermission = false
            
            AuthService.shared.setAlarm()
                .subscribe(onSuccess: { [weak self] in
                    self?.serverEnabled = true
                    self?.publish()
                }, onFailure: { [weak self] _ in
                    self?.onError?("알림을 켤 수 없습니다. 잠시 후 다시 시도해 주세요.")
                    self?.publish() // 롤백
                })
                .disposed(by: bag)
        } else {
            // 권한 OK → 서버만 ON, 의도 플래그는 필요 없음
            AlarmStore.shared.pendingEnableAfterPermission = false
            
            currentPermissionStatus { [weak self] status in
                guard let self else { return }
                switch status {
                case .notDetermined:
                    self.requestPermission { granted in
                        self.systemAuthorized = granted
                        if granted {
                            // 권한 허용됨 → 서버 enable
                            AuthService.shared.setAlarm()
                                .subscribe(onSuccess: { [weak self] in
                                    self?.serverEnabled = true
                                    self?.publish()
                                }, onFailure: { [weak self] _ in
                                    self?.onError?("알림을 켤 수 없습니다.")
                                    self?.publish()
                                })
                                .disposed(by: self.bag)
                        } else {
                            // 거부 → 스위치 롤백 + 설정 유도
                            self.publish(overrideSwitchOn: false)
                            self.onNeedOpenSettings?()
                        }
                    }
                case .denied:
                    // 이미 거부됨 → 스위치 롤백 + 설정 유도
                    self.publish(overrideSwitchOn: false)
                    self.onNeedOpenSettings?()

                case .authorized:
                    // 방어적 처리(드문 케이스)
                    AuthService.shared.setAlarm()
                        .subscribe(onSuccess: { [weak self] in
                            self?.serverEnabled = true
                            self?.publish()
                        }, onFailure: { [weak self] _ in
                            self?.onError?("알림을 켤 수 없습니다.")
                            self?.publish()
                        })
                        .disposed(by: self.bag)
                }
            }
        }
    }

    // MARK: - Permission helpers
    private enum Perm { case authorized, notDetermined, denied }

    private func readSystemPermission(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            let ok: Bool
            switch s.authorizationStatus {
            case .authorized, .provisional, .ephemeral: ok = true
            default: ok = false
            }
            DispatchQueue.main.async { completion(ok) }
        }
    }

    private func currentPermissionStatus(_ completion: @escaping (Perm) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            let st: Perm
            switch s.authorizationStatus {
            case .authorized, .provisional, .ephemeral: st = .authorized
            case .notDetermined: st = .notDetermined
            default: st = .denied
            }
            DispatchQueue.main.async { completion(st) }
        }
    }

    private func requestPermission(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { ok, _ in
            DispatchQueue.main.async { completion(ok) }
        }
    }

    // MARK: - Publish
    /// 스위치 UI에 표시할 값은 항상 "서버 구독값"으로 일관
    private func publish(overrideSwitchOn: Bool? = nil) {
        let switchValue = overrideSwitchOn ?? serverEnabled
        print("switchValue : \(switchValue)")
        onStateChange?(switchValue)
    }
}
