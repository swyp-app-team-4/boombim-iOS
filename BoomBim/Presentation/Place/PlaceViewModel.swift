//
//  PlaceViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

final class PlaceViewModel {
    private let place: PlaceItem
    
    var placeName: String { place.name }
    var placeDetail: String { place.detail }
    var placeCongestion: String { place.congestion }
    
    init(place: PlaceItem) {
        self.place = place
    }
}
