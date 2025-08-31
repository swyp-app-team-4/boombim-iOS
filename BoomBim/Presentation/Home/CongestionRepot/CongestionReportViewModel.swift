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
    var goToSearchPlaceView: (() -> Void)?
    var backToHome: (() -> Void)?
    
    // 내부 저장소 (가장 최근 선택값을 보관)
    private let selectedPlaceRelay = BehaviorRelay<Place?>(value: nil)
    
    // VC에서 읽기 전용으로 구독 (메인스레드 보장)
    var selectedPlace: Driver<Place?> { selectedPlaceRelay.asDriver() }
    var currentSelectedPlace: Place? { selectedPlaceRelay.value }
    
    // Coordinator가 호출할 setter
    func setSelectedPlace(_ place: Place) {
        selectedPlaceRelay.accept(place)
    }
    
    private let service: KakaoLocalService
    
    private(set) var currentCoordinate: CLLocationCoordinate2D?
    
    init(service: KakaoLocalService) {
        self.service = service
    }
    
    // MARK: Action
    func didTapSearch() {
        print("didTapSearch")
        goToSearchPlaceView?()
    }
    
    func didTapExit() {
        print("didTapExit")
        backToHome?()
    }
    
    func didTapShare() {
        print("didTapShare")
        backToHome?()
    }
    
    func postCongestionReport() {
        
    }
}
