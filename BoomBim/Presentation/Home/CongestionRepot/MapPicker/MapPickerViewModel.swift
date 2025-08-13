//
//  MapPickerViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import CoreLocation

final class MapPickerViewModel {
    
    private let currentLocation: CLLocationCoordinate2D
    
    init(currentLocation: CLLocationCoordinate2D) {
        self.currentLocation = currentLocation
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D {
        return currentLocation
    }
}
