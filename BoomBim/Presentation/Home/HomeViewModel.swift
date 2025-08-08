//
//  HomeViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

final class HomeViewModel {
    var goToSearchView: (() -> Void)?
    var goToNotificationView: (() -> Void)?
    
    func didTapSearch() {
        goToSearchView?()
    }
    
    func didTapNotification() {
        goToNotificationView?()
    }
}
