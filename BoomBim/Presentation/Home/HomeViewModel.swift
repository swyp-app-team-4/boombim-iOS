//
//  HomeViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

final class HomeViewModel {
    var goToSearchView: (() -> Void)?
    
    func didTapSearch() {
        goToSearchView?()
    }
}
