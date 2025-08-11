//
//  MyPageViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

final class MyPageViewModel {
    var goToSettingsView: (() -> Void)?
    var goToProfileView: (() -> Void)?
    
    func didTapSettings() {
        goToSettingsView?()
    }
    
    func didTapProfile() {
        goToProfileView?()
    }
}
