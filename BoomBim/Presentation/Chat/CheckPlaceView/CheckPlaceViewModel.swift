//
//  CheckPlaceViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import CoreLocation

final class CheckPlaceViewModel {
    
    var onComplete: (() -> Void)?
    
    private let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func getPlace() -> Place {
        return place
    }
}
