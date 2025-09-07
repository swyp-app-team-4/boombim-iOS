//
//  HomeViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class HomeViewModel {
    var goToCongestionReportView: (() -> Void)?
    var goToSearchView: (() -> Void)?
    var goToNotificationView: (() -> Void)?
    var goToPlaceView: ((FavoritePlaceItem) -> Void)?
    
    func didTapFloating() {
        goToCongestionReportView?()
    }
    
    func didTapSearch() {
        goToSearchView?()
    }
    
    func didTapNotification() {
        goToNotificationView?()
    }
    
    func didSelectPlace(_ place: FavoritePlaceItem) {
        goToPlaceView?(place)
    }
    private let disposeBag = DisposeBag()
    
    struct Input {
        let appear: Observable<Void>        // 최초 1회
    }
    
    struct Output {
        let myCoordinate: Observable<Coordinate?>
        let regionNewsItems: Driver<[RegionItem]>
        let nearbyOfficialPlace: Driver<[RecommendPlaceItem]>
        let favoritePlace: Driver<[FavoritePlaceItem]>
        let rankOfficialPlace: Driver<[CongestionRankPlaceItem]>
        let isLoading: Driver<Bool>
        let isRegionNewsEmpty: Driver<Bool>
        let isEmpty: Driver<Bool>
        let errorMessage: Signal<String>
    }
    
    private let locationRepo: LocationRepositoryType
    
    init(locationRepo: LocationRepositoryType) {
        self.locationRepo = locationRepo
    }
    
    func transform(_ input: Input) -> Output {
        // 1) 권한 요청(미결정이면)
        locationRepo.requestAuthorizationIfNeeded()
        // 초기 프리워밍(필요 시)
        let authD: Driver<CLAuthorizationStatus> = locationRepo.authorization
            .asDriver(onErrorDriveWith: .empty())
        
        let isAuthorizedD: Driver<Bool> = authD
            .map { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse: return true
                default: return false
                }
            }
            .distinctUntilChanged()
        
        // 2) 권한이 허용된 "뒤에만" 프리워밍(캐시/메모리/원샷)
        isAuthorizedD
            .filter { $0 }
            .asObservable()
            .take(1)
            .asObservable()
            .flatMapLatest { [locationRepo] _ in
                locationRepo.getCoordinate(ttl: 180)
                    .asObservable()
                    .materialize() // 오류를 삼키며 로그용으로만
            }
            .subscribe(onNext: { event in
                if case .error(let e) = event { print("⚠️ prewarm error:", e) }
            })
            .disposed(by: disposeBag)
        
        let myCoord = Observable
            .merge(locationRepo.coordinate)
            .share(replay: 1, scope: .whileConnected)
        
        let trigger = input.appear.share()
        
        let loading = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()
        
        let response = trigger
            .flatMapLatest {  _ -> Observable<Event<[RegionNewsResponse]>> in
                PlaceService.shared.getRegionNews()
                    .asObservable()
                    .do(onSubscribe: { loading.accept(true) })
                    .materialize()
            }
            .do(onNext: { _ in loading.accept(false) },
                onError: { _ in loading.accept(false) })
            .share()
        
        let values = response.compactMap { $0.element }
        let errors = response.compactMap { $0.error }
        
        errors
            .map { $0.localizedDescription }
            .bind(to: errorRelay)
            .disposed(by: disposeBag)
        
        // 5) UI 아이템 매핑
        let regionNewsItems = values
            .map { list in
                list.map(Self.makeItem(_:))
            }
            .asDriver(onErrorJustReturn: [])
        
        let isRegionNewsEmpty = regionNewsItems.map { $0.isEmpty }
        
        let nearbyOfficialPlace: Driver<[RecommendPlaceItem]> = trigger
            .withLatestFrom(myCoord.compactMap { $0 })
            .flatMapLatest { coord in
                let requestBody: NearbyOfficialPlaceRequest = .init(latitude: coord.latitude, longitude: coord.longitude)
                
                return PlaceService.shared.getNearbyOfficialPlace(body: requestBody)
                    .map { $0.data.map(Self.makeItem(_:)) }
                    .asObservable()
                    .catchAndReturn([])
            }
            .asDriver(onErrorJustReturn: [RecommendPlaceItem]())
        
        let favoritePlace: Driver<[FavoritePlaceItem]> = trigger
            .flatMapLatest {  _ in
                PlaceService.shared.getFavoritePlace()
                    .map { $0.data.map(Self.makeItem(_:)) }
                    .asObservable()
                    .do(onSubscribe: { loading.accept(true) })
                    .materialize()
            }
            .do(onNext: { _ in loading.accept(false) },
                onError: { _ in loading.accept(false) })
            .compactMap { $0.element }
            .asDriver(onErrorJustReturn: [])
        
        let rankOfficialPlace: Driver<[CongestionRankPlaceItem]> = trigger
            .flatMapLatest {  _ in
                PlaceService.shared.getRankOfficialPlace()
                    .map { $0.data.enumerated().map { index, place in
                        Self.makeItem(place, rank: index)
                    } }
                    .asObservable()
                    .do(onSubscribe: { loading.accept(true) })
                    .materialize()
            }
            .do(onNext: { _ in loading.accept(false) },
                onError: { _ in loading.accept(false) })
            .compactMap { $0.element }
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            myCoordinate: myCoord,
            regionNewsItems: regionNewsItems,
            nearbyOfficialPlace: nearbyOfficialPlace,
            favoritePlace: favoritePlace,
            rankOfficialPlace: rankOfficialPlace,
            isLoading: loading.asDriver(),
            isRegionNewsEmpty: isRegionNewsEmpty,
            isEmpty: isRegionNewsEmpty,
            errorMessage: errorRelay.asSignal()
        )
    }
    
    private static func makeItem(_ r: RegionNewsResponse) -> RegionItem {
        let title = "\(r.area) 집회 예정"
        let timeRange: String
        if let s = parse("yyyy-MM-dd'T'HH:mm:ss", r.startTime),
           let e = parse("yyyy-MM-dd'T'HH:mm:ss", r.endTime) {
            let f = DateFormatter()
            f.locale = Locale(identifier: "ko_KR")
            f.timeZone = TimeZone(identifier: "Asia/Seoul")
            f.dateFormat = "HH:mm"
            timeRange = "\(f.string(from: s))–\(f.string(from: e))"
        } else {
            timeRange = "\(r.startTime) ~ \(r.endTime)"
        }
        
        let desc = "오늘 \(timeRange), \(r.posName)에서 약 \(r.peopleCnt)명 규모 집회 예정되어 있습니다. 해당 시간대 혼잡이 예상되니 이동시 유의하세요."
        
        return RegionItem(iconImage: .iconPolice,
                          organization: "서울경찰청 제공",
                          title: title,
                          description: desc)
    }
    
    private static func makeItem(_ r: NearbyOfficialPlaceInfo) -> RecommendPlaceItem {
        
        return RecommendPlaceItem(
            image: r.imageUrl,
            title: r.officialPlaceName,
            address: r.legalDong,
            congestion: CongestionLevel.init(ko: r.congestionLevelName) ?? .relaxed)
    }
    
    private static func makeItem(_ r: FavoritePlaceInfo) -> FavoritePlaceItem {
        
        if let congestion = r.congestionLevelName {
            return FavoritePlaceItem(
                image: r.imageUrl ?? "",
                title: r.name,
                update: TimeAgo.displayString(from: r.observedAt ?? ""),
                congestion: CongestionLevel.init(ko: congestion))
        } else {
            return FavoritePlaceItem(
                image: r.imageUrl ?? "",
                title: r.name,
                update: TimeAgo.displayString(from: r.observedAt ?? ""),
                congestion: nil)
        }
    }
    
    private static func makeItem(_ r: RankOfficialPlaceInfo, rank: Int) -> CongestionRankPlaceItem {
        
        return CongestionRankPlaceItem(
            rank: rank + 1,
            image: r.imageUrl,
            title: r.officialPlaceName,
            address: r.legalDong,
            update: TimeAgo.displayString(from: r.observedAt),
            congestion: CongestionLevel.init(ko: r.congestionLevelName) ?? .relaxed)
    }
    
    private static func parse(_ format: String, _ str: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = format
        return df.date(from: str)
    }
}
