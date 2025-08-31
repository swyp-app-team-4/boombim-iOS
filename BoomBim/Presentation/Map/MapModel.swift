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

// MARK: - Request DTO
//struct OfficialPlacesRequest: Encodable {
//    struct Coord: Encodable { let latitude: Double; let longitude: Double }
//    let topLeft: Coord
//    let bottomRight: Coord
//    let memberCoordinate: Coord
//}

// MARK: - Response DTO
struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: T
}

struct DemographicDTO: Decodable {
    let category: String       // AGE_GROUP, GENDER, RESIDENCY
    let subCategory: String    // 20s, FEMALE, RESIDENT ...
    let rate: Double
}

struct ForecastDTO: Decodable {
    let forecastTime: String   // "yyyy-MM-dd'T'HH:mm:ss"
    let congestionLevelName: String
    let forecastPopulationMin: Int
    let forecastPopulationMax: Int
}

struct OfficialPlaceDTO: Decodable {
    let id: Int
    let name: String
    let poiCode: String
    let centroidLatitude: Double
    let centroidLongitude: Double
    let polygonCoordinates: String    // JSON 문자열: [[lon,lat], [lon,lat], ...]
    let demographics: [DemographicDTO]
    let forecasts: [ForecastDTO]
}

// MARK: - Domain
struct OfficialPlace {
    struct Demographic { let category: String; let subCategory: String; let rate: Double }
    struct Forecast { let time: Date; let level: String; let min: Int; let max: Int }

    let id: Int
    let name: String
    let poiCode: String
    let centroid: CLLocationCoordinate2D
    let polygon: [CLLocationCoordinate2D]     // 그리기용 좌표열
    let demographics: [Demographic]
    let forecasts: [Forecast]
}
