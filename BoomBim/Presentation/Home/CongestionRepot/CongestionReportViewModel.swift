//
//  CongestionReportViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

final class CongestionReportViewModel {
    var goToMapPickerView: (() -> Void)?
    var backToHome: (() -> Void)?
    
    func didTapSearch() {
        print("didTapSearch")
        goToMapPickerView?()
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
