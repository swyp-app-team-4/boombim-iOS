//
//  CheckPlaceViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import CoreLocation

final class CheckPlaceViewModel {
    enum Mode {
        case justComplete, returnPlace
    }
    
    var onComplete: (() -> Void)?
    var onPlaceComplete: ((Place) -> Void)?
    
    private let place: Place
    private let mode: Mode
    
    init(place: Place, mode: Mode) {
        self.place = place
        self.mode = mode
    }
    
    func getPlace() -> Place {
        return place
    }
    
    func didTapNext() {
        switch mode {
        case .justComplete:
            guard let onComplete else { return }
            onComplete()
        case .returnPlace:
            guard let onPlaceComplete else { return }
            onPlaceComplete(place)
        }
    }
}
