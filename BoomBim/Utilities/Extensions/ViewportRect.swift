//
//  ViewportRect.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import CoreLocation

extension ViewportRect {
    var topLeftCoord: CLLocationCoordinate2D {
        .init(latitude: top, longitude: left)
    }
    var bottomRightCoord: CLLocationCoordinate2D {
        .init(latitude: bottom, longitude: right)
    }
    var centerCoord: CLLocationCoordinate2D {
            .init(latitude: (top + bottom) / 2.0, longitude: (left + right) / 2.0)
        }
}
