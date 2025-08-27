//
//  LabelManager.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import Foundation
import KakaoMapsSDK

// 전역 캐시: LabelManager 인스턴스별(styleID -> PoiStyle)
private enum _PoiStyleCache {
    static let lock = NSLock()
    static var storage: [ObjectIdentifier: [String: PoiStyle]] = [:]

    static func withLock<T>(_ work: () -> T) -> T {
        lock.lock(); defer { lock.unlock() }
        return work()
    }
}

extension LabelManager {

    /// 캐시에 있는지 조회 (SDK가 get API를 제공하지 않으므로 우리가 저장한 것을 반환)
    func getPoiStyle(styleID: String) -> PoiStyle? {
        _PoiStyleCache.withLock {
            let key = ObjectIdentifier(self)
            return _PoiStyleCache.storage[key]?[styleID]
        }
    }

    /// 이미 등록되어 있으면 무시, 없으면 addPoiStyle + 캐시
    func addPoiStyleCaching(_ style: PoiStyle) {
        _PoiStyleCache.withLock {
            let key = ObjectIdentifier(self)
            var dict = _PoiStyleCache.storage[key] ?? [:]
            if dict[style.styleID] == nil {
                // 실제 SDK 등록
                self.addPoiStyle(style)
                // 캐시
                dict[style.styleID] = style
                _PoiStyleCache.storage[key] = dict
            }
        }
    }

    /// styleID가 없으면 build()로 만들어 등록한다 (편의용)
    func ensurePoiStyle(styleID: String, build: () -> PoiStyle) {
        if getPoiStyle(styleID: styleID) == nil {
            addPoiStyleCaching(build())
        }
    }

    /// 필요 시 캐시에서 제거(레이어나 스타일 초기화 시 함께 호출)
    func removePoiStyleFromCache(styleID: String) {
        _PoiStyleCache.withLock {
            let key = ObjectIdentifier(self)
            _PoiStyleCache.storage[key]?[styleID] = nil
        }
    }

    /// 이 LabelManager에 대해 캐시 전체 제거
    func clearPoiStyleCache() {
        _PoiStyleCache.withLock {
            let key = ObjectIdentifier(self)
            _PoiStyleCache.storage[key] = nil
        }
    }
}
