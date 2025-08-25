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
}
