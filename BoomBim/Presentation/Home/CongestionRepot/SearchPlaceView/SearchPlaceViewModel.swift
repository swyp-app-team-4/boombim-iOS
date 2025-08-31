//
//  SearchPlaceViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class SearchPlaceViewModel {
    let disposeBag = DisposeBag()
    
    var goToMapPickerView: ((CLLocationCoordinate2D) -> Void)?
    var goToCheckPlaceView: ((Place) -> Void)?
    var backToHome: (() -> Void)?
    
    let query = BehaviorRelay<String>(value: "")
    let results = BehaviorRelay<[Place]>(value: [])
    
    struct Input {
        let searchText: Observable<String>          // 검색어 변경 스트림
//        let currentLocation: Observable<CLLocationCoordinate2D>
    }
    struct Output {
        let places: Observable<[Place]>
        let myCoordinate: Observable<Coordinate?> // 뷰에서 카메라 이동 등에 활용
        let results: Observable<[Place]>
    }
    
    private let service: KakaoLocalService
    private let locationRepo: LocationRepositoryType
    
    init(service: KakaoLocalService, locationRepo: LocationRepositoryType) {
        self.service = service
        self.locationRepo = locationRepo
    }
    
    func transform(input: Input) -> Output {
        // 1) 권한 요청(미결정이면)
        locationRepo.requestAuthorizationIfNeeded()
        // 초기 프리워밍(필요 시)
        locationRepo.getCoordinate(ttl: 180).subscribe().disposed(by: disposeBag)
        
        let myCoord = Observable
            .merge(locationRepo.coordinate)
            .share(replay: 1, scope: .whileConnected)
        
        let places = myCoord
            .compactMap { $0 }
            .take(1)
            .flatMapLatest { [service] coord in
                service.searchNearbyAcrossCategories(x: coord.longitude, y: coord.latitude)
                    .asObservable()
                    .catchAndReturn([])
            }
            .share(replay: 1, scope: .whileConnected)
        
        let results = input.searchText
            .skip(1)
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(myCoord.compactMap { $0 }) { (query: $0, coord: $1) }
            .flatMapLatest { [service] pair -> Observable<[Place]> in
                let (query, coord) = (pair.query, pair.coord)
                guard !query.isEmpty else { return .just([]) }
                return service.searchByKeyword(query: query, x: coord.longitude, y: coord.latitude)
                    .asObservable()
                    .catchAndReturn([])
            }
            .do(onNext: { [weak self] in self?.results.accept($0) }) // 기존 BehaviorRelay도 유지하고 싶으면
            .share(replay: 1, scope: .whileConnected)
        
        return Output(places: places, myCoordinate: myCoord, results: results)
    }
    
    func didTapExit() {
        print("didTapExit")
        backToHome?()
    }
    
    func didTapShare() {
        print("didTapShare")
        backToHome?()
    }

    func didTapNextButton(place: Place) {
        print("didTapNextButton")
        goToCheckPlaceView?(place)
    }
}
