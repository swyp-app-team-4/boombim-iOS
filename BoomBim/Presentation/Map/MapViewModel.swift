//
//  MapViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class MapViewModel {
    struct Input {
        let cameraRect: Observable<ViewportRect>
        let zoomLevel: Observable<Int>
        let didTapMyLocation: Observable<Void> // 현재 위치 버튼
    }
    struct Output {
        let places: Observable<[Place]>
        let officialPlace: Observable<OfficialPlace>
        let myCoordinate: Observable<Coordinate?> // 뷰에서 카메라 이동 등에 활용
    }
    
    private(set) var currentCoordinate: CLLocationCoordinate2D?
    
    private let service: KakaoLocalService
    private let officialService: OfficialPlaceServiceType
    private let locationRepo: LocationRepositoryType
    private let disposeBag = DisposeBag()
    
    init(service: KakaoLocalService,
         officialService: OfficialPlaceServiceType,
         locationRepo: LocationRepositoryType) {
        self.service = service
        self.officialService = officialService
        self.locationRepo = locationRepo
    }
    
    func transform(input: Input) -> Output {
        // 1) 권한 요청(미결정이면)
        locationRepo.requestAuthorizationIfNeeded()
        // 초기 프리워밍(필요 시)
        locationRepo.getCoordinate(ttl: 180).subscribe().disposed(by: disposeBag)
        
        let rectWhenZoomOK = Observable
            .combineLatest(input.cameraRect, input.zoomLevel.startWith(14))
            .filter { _, zoom in zoom >= 11 }
            .map { rect, _ in rect }
            .distinctUntilChanged { a, b in
                func r6(_ d: Double) -> Double { (d * 1e6).rounded() / 1e6 }
                return r6(a.left) == r6(b.left) &&
                r6(a.right) == r6(b.right) &&
                r6(a.top) == r6(b.top) &&
                r6(a.bottom) == r6(b.bottom)
            }
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
        
        // 현재 위치 버튼 → 강제 새로고침
        let refreshTap = input.didTapMyLocation
            .flatMapLatest { [locationRepo] in
                locationRepo.refreshCoordinate(timeout: 120).asObservable().map { Optional($0) }
            }
        
        let myCoord = Observable
            .merge(locationRepo.coordinate, refreshTap)
            .share(replay: 1, scope: .whileConnected)
        
        let places = rectWhenZoomOK
            .flatMapLatest { [service] rect in
                service.searchStarbucks(in: rect).asObservable() // TEST를 위한 스타벅스 조회 API
                    .catchAndReturn([])
            }
            .share(replay: 1, scope: .whileConnected)
        
        let officialPlace = Observable
            .combineLatest(rectWhenZoomOK, myCoord)
            .flatMapLatest { [officialService] rect, memberOpt in
                let member = memberOpt ?? rect.centerCoord
                return officialService.fetchOfficialPlace(
                    topLeft: rect.topLeftCoord,
                    bottomRight: rect.bottomRightCoord,
                    member: member
                )
                .asObservable()
                .catch { _ in .empty() }
            }
            .share(replay: 1, scope: .whileConnected)
        
        return .init(places: places,
                     officialPlace: officialPlace,
                     myCoordinate: myCoord)
    }
}
