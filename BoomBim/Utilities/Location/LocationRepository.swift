//
//  LocationRepository.swift
//  BoomBim
//
//  Created by 조영현 on 8/31/25.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

public typealias Coordinate = CLLocationCoordinate2D

public protocol LocationRepositoryType {
    /// 권한 상태 스트림
    var authorization: Observable<CLAuthorizationStatus> { get }

    /// 좌표 스트림(옵셔널). 앱 시작 직후엔 캐시(있으면) 먼저 흘려주고, 이후 실시간 업데이트.
    var coordinate: Observable<Coordinate?> { get }

    /// TTL 기준 좌표 가져오기 (캐시 우선 → 부족하면 원샷 요청)
    func getCoordinate(ttl: TimeInterval) -> Single<Coordinate>

    /// 사용자 액션(현재 위치 버튼) 등 명시적 재조회
    func refreshCoordinate(timeout: TimeInterval) -> Single<Coordinate>

    /// 권한 없으면 한 번 요청 (필요 시 온보딩/알럿은 VC에서)
    func requestAuthorizationIfNeeded()
}

public final class LocationRepository: LocationRepositoryType {
    private let lm = AppLocationManager.shared
    private let store = LocationStore.shared

    public init() {}

    public var authorization: Observable<CLAuthorizationStatus> {
        lm.authorization.asObservable().distinctUntilChanged()
    }

    public var coordinate: Observable<Coordinate?> {
        // 1) 캐시를 첫 값으로 방출
        // 2) AppLocationManager의 currentLocation 갱신을 좌표로 변환하여 이어 방출
        let cachedFirst = Observable.just(store.load()?.coordinate)

        let live = lm.currentLocation
            .compactMap { $0?.coordinate }
            // 과한 연속 업데이트 방지(약 100m 격자)
            .distinctUntilChanged { a, b in
                func bucket(_ x: Double) -> Int { Int((x * 1000).rounded()) } // 0.001° ≈ 111m
                return bucket(a.latitude) == bucket(b.latitude) &&
                       bucket(a.longitude) == bucket(b.longitude)
            }
            .do(onNext: { [weak self] coord in
                guard let self else { return }
                let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                self.store.save(loc)
            })
            .map { Optional($0) }

        return Observable.merge(cachedFirst, live)
            .share(replay: 1, scope: .whileConnected)
    }

    public func getCoordinate(ttl: TimeInterval = 180) -> Single<Coordinate> {
        // 1) 메모리 최신값(10초 내) 또는 캐시가 TTL 내면 즉시 반환
        if let mem = lm.currentLocation.value,
           Date().timeIntervalSince(mem.timestamp) < ttl {
            return .just(mem.coordinate)
        }
        if let cache = store.load(),
           Date().timeIntervalSince(cache.date) < ttl {
            return .just(cache.coordinate)
        }
        // 2) 아니면 원샷 요청
        return lm.requestOneShotLocation()
            .do(onSuccess: { [weak self] in self?.store.save($0) })
            .map { $0.coordinate }
    }

    public func refreshCoordinate(timeout: TimeInterval = 5) -> Single<Coordinate> {
        lm.requestOneShotLocation(timeout: timeout)
            .do(onSuccess: { [weak self] in self?.store.save($0) })
            .map { $0.coordinate }
    }

    public func requestAuthorizationIfNeeded() {
        lm.requestWhenInUseAuthorizationIfNeeded()
    }
}
