//
//  LocationStore.swift
//  BoomBim
//
//  Created by 조영현 on 8/31/25.
//

import Foundation
import CoreLocation

public struct LocationCache: Codable {
    public let lat: Double
    public let lon: Double
    public let timestamp: TimeInterval

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
    public var date: Date { Date(timeIntervalSince1970: timestamp) }
}

private enum LocationStoreKey {
    static let last = "com.boombim.location.last"
}

public final class LocationStore {
    public static let shared = LocationStore()
    private let ud = UserDefaults.standard
    private init() {}

    public func save(_ loc: CLLocation) {
        let cache = LocationCache(lat: loc.coordinate.latitude,
                                  lon: loc.coordinate.longitude,
                                  timestamp: loc.timestamp.timeIntervalSince1970)
        if let data = try? JSONEncoder().encode(cache) {
            ud.set(data, forKey: LocationStoreKey.last)
        }
    }

    public func load() -> LocationCache? {
        guard let data = ud.data(forKey: LocationStoreKey.last),
              let cache = try? JSONDecoder().decode(LocationCache.self, from: data) else { return nil }
        return cache
    }

    public func clear() {
        ud.removeObject(forKey: LocationStoreKey.last)
    }

    /// TTL(초) 기준 신선한 캐시인지
    public func isFresh(ttl: TimeInterval) -> Bool {
        guard let cache = load() else { return false }
        return Date().timeIntervalSince(cache.date) < ttl
    }
}
