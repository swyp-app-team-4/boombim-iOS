//
//  AppLocationManager.swift
//  BoomBim
//
//  Created by 조영현 on 8/10/25.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

public final class AppLocationManager: NSObject, LocationProviding {
    public static let shared = AppLocationManager()

    // MARK: - Observables
    public let authorization = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    public let currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    public let locationError = PublishRelay<Error>()
    
    public let heading = BehaviorRelay<CLHeading?>(value: nil)                  // 최신 CLHeading 보관
    public let headingDegrees = PublishRelay<CLLocationDirection>()             // degree(0~360) 스트림

    // MARK: - Private
    private let manager = CLLocationManager()
    private let disposeBag = DisposeBag()

    private var pendingOneShot: ((Result<CLLocation, Error>) -> Void)?
    private var oneShotTimer: Timer?

    private override init() {
        super.init()
        manager.delegate = self
        // 필요 정확도/소모 고려해서 설정
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 30 // 30m 이상 이동 시 업데이트
        updateAuthRelay()
    }

    // MARK: - Public API 현재 위치
    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation() {
        // 권한 허용일 때만 시작
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    public func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    /// 현재 좌표를 1회만 가져오고 끝내는 편의 함수
    public func requestOneShotLocation(timeout: TimeInterval = 5) -> Single<CLLocation> {
        return Single<CLLocation>.create { [weak self] single in
            guard let self else { return Disposables.create() }

            // 이미 최신 위치가 있으면 즉시 반환
            if let loc = self.currentLocation.value,
               Date().timeIntervalSince(loc.timestamp) < 10 {
                single(.success(loc))
                return Disposables.create()
            }

            // 권한 체크
            let status = self.manager.authorizationStatus
            if status == .notDetermined { self.manager.requestWhenInUseAuthorization() }

            // 콜백 래치
            self.pendingOneShot = { result in
                switch result {
                case .success(let loc): single(.success(loc))
                case .failure(let err): single(.failure(err))
                }
            }

            // 타임아웃
            self.oneShotTimer?.invalidate()
            self.oneShotTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                self?.finishOneShot(.failure(LocationError.timeout))
            }

            // 실제 요청
            self.manager.requestLocation() // 한 번만 요청
            return Disposables.create { [weak self] in
                self?.oneShotTimer?.invalidate()
                self?.pendingOneShot = nil
            }
        }
    }
    
    // MARK: - Public API Heading 방향
    public func startUpdatingHeading(filter: CLLocationDegrees = 5,
                                     orientation: CLDeviceOrientation? = nil) {
        guard CLLocationManager.headingAvailable() else { return }
        if let orientation { manager.headingOrientation = orientation }
        manager.headingFilter = filter
        manager.startUpdatingHeading()
    }

    public func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
    }

    /// 화면 회전 시 호출해 주면 좋습니다.
    public func setHeadingOrientation(_ orientation: CLDeviceOrientation) {
        manager.headingOrientation = orientation
    }


    // MARK: - Helpers
    private func updateAuthRelay() {
        authorization.accept(manager.authorizationStatus)
    }

    private func finishOneShot(_ result: Result<CLLocation, Error>) {
        oneShotTimer?.invalidate()
        oneShotTimer = nil
        pendingOneShot?(result)
        pendingOneShot = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension AppLocationManager: CLLocationManagerDelegate {
    // iOS 14+
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthRelay()
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            // 필요 시 자동 시작
            manager.startUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        currentLocation.accept(latest)
        finishOneShot(.success(latest))
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError.accept(error)
        finishOneShot(.failure(error))
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // 정확도 음수면 무시
        guard newHeading.headingAccuracy >= 0 else { return }

        // trueHeading(진북) 우선, 없으면 magneticHeading(자북)
        let deg = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading

        heading.accept(newHeading)
        headingDegrees.accept(deg)
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // 보정 화면이 자주 뜨면 UX상 좋지 않으니 기본 false 권장
        return false
    }
}

// MARK: - Errors
public enum LocationError: LocalizedError {
    case timeout
    public var errorDescription: String? {
        switch self {
        case .timeout: return "현재 위치를 가져오지 못했습니다. (시간 초과)"
        }
    }
}
