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

public enum LocationError: LocalizedError {
    case timeout
    case deniedOrRestricted
    public var errorDescription: String? {
        switch self {
        case .timeout: return "현재 위치를 가져오지 못했습니다. (시간 초과)"
        case .deniedOrRestricted: return "위치 권한이 없어 현재 위치를 사용할 수 없습니다."
        }
    }
}

public final class AppLocationManager: NSObject {
    public static let shared = AppLocationManager()

    // MARK: - Relays (외부 구독용)
    public let authorization = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    public let currentLocation = BehaviorRelay<CLLocation?>(value: nil)

    public let heading = BehaviorRelay<CLHeading?>(value: nil)          // 최신 Heading
    public let headingDegrees = PublishRelay<CLLocationDirection>()      // 0~360

    // MARK: - Private
    private let manager = CLLocationManager()
    private var pendingOneShot: ((Result<CLLocation, Error>) -> Void)?
    private var oneShotTimer: Timer?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 30 // 30m 이상 이동 시 업데이트
        authorization.accept(manager.authorizationStatus)
    }
}

// MARK: - Public API
public extension AppLocationManager {

    func requestWhenInUseAuthorizationIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    /// 현재 좌표 1회 요청 (권한 OK + 타임아웃 관리)
    func requestOneShotLocation(timeout: TimeInterval = 5) -> Single<CLLocation> {
        Single<CLLocation>.create { [weak self] single in
            guard let self else { return Disposables.create() }

            let status = self.manager.authorizationStatus
            guard status == .authorizedWhenInUse || status == .authorizedAlways else {
                if status == .notDetermined { self.manager.requestWhenInUseAuthorization() }
                single(.failure(LocationError.deniedOrRestricted))
                return Disposables.create()
            }

            // 최신값이 아주 최근이라면 즉시 반환(10초 내)
            if let loc = self.currentLocation.value,
               Date().timeIntervalSince(loc.timestamp) < 10 {
                single(.success(loc))
                return Disposables.create()
            }

            // 콜백 세팅
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

            // 실제 한 번 요청
            self.manager.requestLocation()

            return Disposables.create { [weak self] in
                self?.oneShotTimer?.invalidate()
                self?.pendingOneShot = nil
            }
        }
    }

    // MARK: Heading (나침반)
    func startUpdatingHeading(filter: CLLocationDegrees = 5,
                              orientation: CLDeviceOrientation? = nil) {
        guard CLLocationManager.headingAvailable() else { return }
        if let orientation { manager.headingOrientation = orientation }
        manager.headingFilter = filter
        manager.startUpdatingHeading()
    }

    func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
    }

    func setHeadingOrientation(_ orientation: CLDeviceOrientation) {
        manager.headingOrientation = orientation
    }
}

// MARK: - Private Helpers
private extension AppLocationManager {
    func finishOneShot(_ result: Result<CLLocation, Error>) {
        oneShotTimer?.invalidate()
        oneShotTimer = nil
        pendingOneShot?(result)
        pendingOneShot = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension AppLocationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization.accept(manager.authorizationStatus)
        // 권한 허용 시 백그라운드 지속 추적은 하지 않고, 필요 시 원샷으로만 사용
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        currentLocation.accept(latest)
        finishOneShot(.success(latest))
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishOneShot(.failure(error))
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        let deg = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        heading.accept(newHeading)
        headingDegrees.accept(deg)
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // 필요할 때 VC에서 UX적으로 안내 후 true로 열어도 됨
        return false
    }
}

