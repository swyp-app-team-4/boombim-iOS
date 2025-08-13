//
//  MapModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import Foundation
import CoreLocation

struct Place: Hashable {
    let id: String
    let name: String
    let coord: CLLocationCoordinate2D
    let address: String?
    let distance: Double?

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ViewportRect: Equatable {
    // Kakao rect: left,bottom,right,top (경도,위도)
    let x: Double
    let y: Double
    let left: Double
    let bottom: Double
    let right: Double
    let top: Double
}
