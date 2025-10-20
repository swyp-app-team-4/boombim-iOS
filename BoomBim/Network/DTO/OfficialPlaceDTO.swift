//
//  OfficialPlaceDTO.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import Foundation
import CoreLocation

enum OfficialPlaceMappingError: Error {
    case badPolygon, badDate
}

private let seoulDF: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.calendar = Calendar(identifier: .gregorian)
    f.timeZone = TimeZone(identifier: "Asia/Seoul")
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return f
}()

extension OfficialPlaceDTO {
    func toDomain() throws -> OfficialPlace {
        // polygonCoordinates: String -> [[Double]] (lon,lat 순)
        guard let data = polygonCoordinates.data(using: .utf8),
              let raw = try? JSONDecoder().decode([[Double]].self, from: data),
              raw.allSatisfy({ $0.count == 2 })
        else { throw OfficialPlaceMappingError.badPolygon }

        let polygon: [CLLocationCoordinate2D] = raw.map { pair in
            CLLocationCoordinate2D(latitude: pair[1], longitude: pair[0]) // (lat, lon)로 변환
        }

        let ds: [OfficialPlace.Demographic] = demographics.map {
            .init(category: $0.category, subCategory: $0.subCategory, rate: $0.rate)
        }

        let fs: [OfficialPlace.Forecast] = try forecasts.map { f in
            guard let d = seoulDF.date(from: f.forecastTime) else { throw OfficialPlaceMappingError.badDate }
            return .init(time: d, level: f.congestionLevelName, min: f.forecastPopulationMin, max: f.forecastPopulationMax)
        }

        return OfficialPlace(
            id: id,
            name: name,
            poiCode: poiCode,
            centroid: .init(latitude: centroidLatitude, longitude: centroidLongitude),
            polygon: polygon,
            demographics: ds,
            forecasts: fs
        )
    }
}
