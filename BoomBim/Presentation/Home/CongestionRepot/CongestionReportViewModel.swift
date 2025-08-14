//
//  CongestionReportViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class CongestionReportViewModel {
    var goToMapPickerView: ((CLLocationCoordinate2D) -> Void)?
    var backToHome: (() -> Void)?
    
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
