//
//  LocationProviding.swift
//  BoomBim
//
//  Created by 조영현 on 8/10/25.
//

import CoreLocation
import RxSwift
import RxCocoa

public protocol LocationProviding {
    var authorization: BehaviorRelay<CLAuthorizationStatus> { get }
    var currentLocation: BehaviorRelay<CLLocation?> { get }
    var locationError: PublishRelay<Error> { get }

    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()

    /// 한 번만 받아오는 원샷 API (타임아웃 포함)
    func requestOneShotLocation(timeout: TimeInterval) -> Single<CLLocation>
}
