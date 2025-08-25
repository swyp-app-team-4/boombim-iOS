//
//  AskQuestionViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class AskQuestionViewModel {
    let disposeBag = DisposeBag()
    
    var goToMapPickerView: ((CLLocationCoordinate2D) -> Void)?
    var backToHome: (() -> Void)?
    
    let query = BehaviorRelay<String>(value: "")
    let results = BehaviorRelay<[Place]>(value: [])
    
    struct Input {
        let currentLocation: Observable<CLLocationCoordinate2D>
    }
    struct Output {
        let places: Observable<[Place]>
    }
    
    private let service: KakaoLocalService
    
    private(set) var currentCoordinate: CLLocationCoordinate2D?
    
    init(service: KakaoLocalService) {
        self.service = service
    }
    
    // 검색 관련
    func bindSearch() {
        query
            .skip(1)
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                print("query : \(query)")
                self?.search(query: query)
            })
            .disposed(by: disposeBag)
    }

    private func search(query: String) {
        guard let currentCoordinate = currentCoordinate else { return }
        print("currentCoordinate : \(currentCoordinate.longitude),\(currentCoordinate.latitude)")
        service.searchByKeyword(query: query, x: currentCoordinate.longitude, y: currentCoordinate.latitude)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onSuccess: { owner, items in
                print("items : \(items)")
                owner.results.accept(items)
            }, onFailure: { owner, error in
                print("search error:", error)
            })
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        let places = input.currentLocation
            .take(1)
            .flatMapLatest { [service] coord in
                service.searchNearbyAcrossCategories(x: coord.longitude, y: coord.latitude)
                    .asObservable()
                    .catchAndReturn([])
            }
            .share(replay: 1, scope: .whileConnected)

        return Output(places: places)
    }
    
    func setCurrentCoordinate(_ coord: CLLocationCoordinate2D) {
        currentCoordinate = coord
    }
    
    // MARK: Action
    func didTapSearch() {
        print("didTapSearch")
        guard let currentCoordinate = self.currentCoordinate else { return }
        goToMapPickerView?(currentCoordinate)
    }
    
    func didTapExit() {
        print("didTapExit")
        backToHome?()
    }
    
    func didTapShare() {
        print("didTapShare")
        backToHome?()
    }
}
