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
    var goToSearchView: (() -> Void)?
    
    struct Input {
        let cameraRect: Observable<ViewportRect>
        let zoomLevel: Observable<Int>
        let didTapMyLocation: Observable<Void> // 현재 위치 버튼
        let officialPoiTap: Signal<Int>
        let userPoiTap: Signal<Int>
        let reload: Signal<Void>
    }
    struct Output {
        let places: Observable<[UserPlaceEntry]>
        let userPlaceDetail: Signal<UserPlaceDetailInfo>
        let officialPlace: Observable<[OfficialPlaceItem]>
        let officialPlaceDetail: Signal<OfficialPlaceDetailInfo>
        let myCoordinate: Observable<Coordinate?> // 뷰에서 카메라 이동 등에 활용
        let isLoading: Driver<Bool>
        let error: Signal<String>
    }
    
    private(set) var currentCoordinate: CLLocationCoordinate2D?
    
    private let service: KakaoLocalService
    private let locationRepo: LocationRepositoryType
    private let disposeBag = DisposeBag()
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    init(service: KakaoLocalService,
         locationRepo: LocationRepositoryType) {
        self.service = service
        self.locationRepo = locationRepo
    }
    
    func transform(input: Input) -> Output {
        // 1) 권한 요청(미결정이면)
        locationRepo.requestAuthorizationIfNeeded()
        // 초기 프리워밍(필요 시)
        locationRepo.getCoordinate(ttl: 180).subscribe().disposed(by: disposeBag)
        
        // 현재 위치 버튼 → 강제 새로고침
        let refreshTap = input.didTapMyLocation
            .flatMapLatest { [locationRepo] in
                locationRepo.refreshCoordinate(timeout: 120).asObservable().map { Optional($0) }
            }
        
        let myCoord = Observable
            .merge(locationRepo.coordinate, refreshTap)
            .share(replay: 1, scope: .whileConnected)
            .do(onNext: { _ in
                print("😎 myCoord")
            })
        
        let rect = input.cameraRect
            .distinctUntilChanged { a, b in
                func r6(_ d: Double) -> Double { (d * 1e6).rounded() / 1e6 }
                return r6(a.left) == r6(b.left) &&
                       r6(a.right) == r6(b.right) &&
                       r6(a.top) == r6(b.top) &&
                       r6(a.bottom) == r6(b.bottom)
            }
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
            .do(onNext: { _ in
                print("😎 rect")
            })
        
        // 최신 줌값 스트림 (기본값 14)
        let zoom = input.zoomLevel
            .startWith(14)
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
            .do(onNext: { _ in
                print("😎 zoom")
            })
        
        // 최신 상태
        let state = Observable.combineLatest(myCoord, zoom) // (coord, z)
            .share(replay: 1, scope: .whileConnected)

        // rect가 멈췄을 때 트리거 (기존)
        let rectStopped = rect
            .withLatestFrom(state) { (rect: $0, coord: $1.0, z: $1.1) }

        // reload가 왔을 때도 동일한 형태로 트리거 생성
        let reloadTrigger = input.reload
            .asObservable()
            .withLatestFrom(Observable.combineLatest(rect, state)) { (_, combined) in
                let (rect, (coord, z)) = combined
                return (rect: rect, coord: coord, z: z)
            }

        // 두 트리거를 합치고 줌 조건 필터
        let trigger = Observable.merge(rectStopped, reloadTrigger)
            .filter { $0.z >= 10 }
            .share(replay: 1, scope: .whileConnected)
        
        let officialPlace: Observable<[OfficialPlaceItem]> =
        trigger
            .flatMapLatest { (rect, memberOpt, z) -> Observable<[OfficialPlaceItem]> in
                print("official 장소 요청")
                let member = memberOpt ?? rect.centerCoord
                let requestBody: OfficialPlaceRequest = .init(
                    topLeft: Coord(latitude: rect.top, longitude: rect.left),
                    bottomRight: Coord.init(latitude: rect.bottom, longitude: rect.right),
                    memberCoordinate: Coord(latitude: member.latitude, longitude: member.longitude),
                    zoomLevel: z)
                
                return PlaceService.shared.fetchOfficialPlace(body: requestBody)
                    .map{ $0.data }
                    .asObservable()
                    .catchAndReturn([]) // 에러시 빈 배열
            }
            .share(replay: 1, scope: .whileConnected)
        
        let userPlaces: Observable<[UserPlaceEntry]> =
        trigger
            .flatMapLatest { (rect, memberOpt, z) -> Observable<[UserPlaceEntry]> in
                
                let member = memberOpt ?? rect.centerCoord
                
                let requestBody: UserPlaceRequest = .init(
                    topLeft: Coord(latitude: rect.top, longitude: rect.left),
                    bottomRight: Coord.init(latitude: rect.bottom, longitude: rect.right),
                    memberCoordinate: Coord(latitude: member.latitude, longitude: member.longitude),
                    zoomLevel: z)
                
                return PlaceService.shared.fetchUserPlace(body: requestBody)
                    .map{ $0.data }
                    .asObservable()
                    .catchAndReturn([]) // 에러시 빈 배열
            }
            .share(replay: 1, scope: .whileConnected)
        
        let officialDetail: Signal<OfficialPlaceDetailInfo> = input.officialPoiTap
                .throttle(.milliseconds(500))                 // 빠른 중복 탭 방지
                .do(onNext: { _ in self.loadingRelay.accept(true) }) // 로딩 ON
                .flatMapLatest { id -> Signal<OfficialPlaceDetailInfo> in
                    return PlaceService.shared.getOfficialPlaceDetail(body: .init(officialPlaceId: id))
                        .map { $0.data }
                        .asSignal(onErrorRecover: { error in
                            self.loadingRelay.accept(false)                // 로딩 OFF
                            self.errorRelay.accept(error.localizedDescription)
                            return .empty()                           // 실패 시 방출 없음
                        })
                }
                .do(onNext: { _ in self.loadingRelay.accept(false) })
        
        let userDetail: Signal<UserPlaceDetailInfo> = input.userPoiTap
                .throttle(.milliseconds(500))                 // 빠른 중복 탭 방지
                .do(onNext: { _ in self.loadingRelay.accept(true) }) // 로딩 ON
                .flatMapLatest { id -> Signal<UserPlaceDetailInfo> in
                    return PlaceService.shared.getUserPlaceDetail(body: .init(memberPlaceId: id))
                        .map { $0.data }
                        .asSignal(onErrorRecover: { error in
                            self.loadingRelay.accept(false)                // 로딩 OFF
                            self.errorRelay.accept(error.localizedDescription)
                            return .empty()                           // 실패 시 방출 없음
                        })
                }
                .do(onNext: { _ in self.loadingRelay.accept(false) })
        
        return Output(
            places: userPlaces,
            userPlaceDetail: userDetail,
            officialPlace: officialPlace,
            officialPlaceDetail: officialDetail,
            myCoordinate: myCoord,
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal())
    }
    
    func registerFavoritePlace(body: RegisterFavoritePlaceRequest) -> Single<Bool> {
        return PlaceService.shared.registerFavoritePlace(body: body)
            .map { $0.code == 200 }
            .catch { _ in .just(false) }
    }
    
    func didTapSearch() {
        goToSearchView?()
    }
}
