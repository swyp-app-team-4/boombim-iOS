//
//  HomeViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

final class HomeViewModel {
    var goToCongestionReportView: (() -> Void)?
    var goToSearchView: (() -> Void)?
    var goToNotificationView: (() -> Void)?
    var goToPlaceView: ((PlaceItem) -> Void)?
    
    func didTapFloating() {
        goToCongestionReportView?()
    }
    
    func didTapSearch() {
        goToSearchView?()
    }
    
    func didTapNotification() {
        goToNotificationView?()
    }
    
    func didSelectPlace(_ place: PlaceItem) {
        goToPlaceView?(place)
    }
}
