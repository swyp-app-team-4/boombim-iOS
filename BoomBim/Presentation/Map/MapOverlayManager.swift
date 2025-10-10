//
//  MapOverlayManager.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import KakaoMapsSDK
import UIKit
import CoreLocation

enum OverlayGroup: String, CaseIterable {
    case official
    case favorite
    case realtime
}

/// 2) 그룹별 스타일 설정값
struct GroupVisual {
    let icon: UIImage
    let fill: UIColor
    let stroke: UIColor
    let zPOI: Int      // LabelLayer z
    let zShape: Int    // ShapeLayer z
}

typealias IconProvider = (String) -> UIImage

struct POIItem {
    let id: String
    let point: MapPoint
    let styleKey: String  // 아이템별 아이콘 식별자 (예: "congestion.relaxed")
}

struct POIClusterItem {
    let point: MapPoint
    let itemCount: Int
    let styleKey: String  // 아이템별 아이콘 식별자 (예: "congestion.relaxed")
}

final class MapOverlayManager {
    private weak var map: KakaoMap?

    // 그룹별 레이어/캐시
    private var poiLayers:   [OverlayGroup: [POIKind: LabelLayer]] = [:]
    private var shapeLayers: [OverlayGroup: ShapeLayer] = [:]

    private enum POIKind: String {
        case place = "place"
        case cluster = "cluster"
    }

    // Prefix builders to namespace POIs per kind
    private func poiIDPrefix(_ g: OverlayGroup, kind: POIKind) -> String { "poi.\(g.rawValue).\(kind.rawValue)" }
    
    init(map: KakaoMap) { self.map = map }
    
    // VC에서 받도록 콜백 노출
    var onPoiTapped: ((OverlayGroup, String, CLLocationCoordinate2D) -> Void)?
    
    // 탭 핸들러 해제 관리(메모리 누수 방지)
    private var poiTapDisposers: [String: DisposableEventHandler] = [:]

    // ----- ID 생성 규칙 (그룹별로 유니크) -----
    private func poiStyleID(_ g: OverlayGroup) -> String { "poi.style.\(g.rawValue)" }
    private func poiLayerID(_ g: OverlayGroup, kind: POIKind) -> String { "poi.layer.\(g.rawValue).\(kind.rawValue)" }
    private func polyStyleSetID(_ g: OverlayGroup) -> String { "poly.styleset.\(g.rawValue)" }
    private func shapeLayerID(_ g: OverlayGroup) -> String { "shape.layer.\(g.rawValue)" }
    
    private var poiStyleRegistry: [String: String] = [:] // styleKey -> styleID
    private func ensurePoiStyle(styleKey: String, icon: UIImage, on map: KakaoMap) -> String {
        if let id = poiStyleRegistry[styleKey] { return id }
        let styleID = "poi.style.\(styleKey)" // 유니크
        let mgr = map.getLabelManager()
        let iconStyle = PoiIconStyle(symbol: icon, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let per = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
        mgr.addPoiStyle(PoiStyle(styleID: styleID, styles: [per]))
        poiStyleRegistry[styleKey] = styleID
        return styleID
    }

    // ----- 그룹 리소스 보장 -----
    private func ensureResources(for g: OverlayGroup, visual: GroupVisual) {
        guard let map = map else { return }

        // 1) POI 스타일 + 레이어
        let labelMgr = map.getLabelManager() // LabelLayer가 있어야 POI 생성 가능
        if labelMgr.getPoiStyle(styleID: poiStyleID(g)) == nil {
            let iconStyle = PoiIconStyle(symbol: visual.icon, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let per = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
            let style = PoiStyle(styleID: poiStyleID(g), styles: [per])
            labelMgr.addPoiStyle(style) // 1회 등록. 같은 ID는 중복등록 안됨
        }
        
        // Ensure per-kind POI layers
        var groupLayers = poiLayers[g] ?? [:]
        if groupLayers[.place] == nil {
            let opt = LabelLayerOptions(layerID: poiLayerID(g, kind: .place),
                                        competitionType: .none,
                                        competitionUnit: .symbolFirst,
                                        orderType: .rank,
                                        zOrder: visual.zPOI)
            groupLayers[.place] = labelMgr.addLabelLayer(option: opt)
        }
        if groupLayers[.cluster] == nil {
            let opt = LabelLayerOptions(layerID: poiLayerID(g, kind: .cluster),
                                        competitionType: .none,
                                        competitionUnit: .symbolFirst,
                                        orderType: .rank,
                                        zOrder: visual.zPOI)
            groupLayers[.cluster] = labelMgr.addLabelLayer(option: opt)
        }
        poiLayers[g] = groupLayers

        // 2) 폴리곤 스타일셋 + 레이어
        let shapeMgr = map.getShapeManager()
        if shapeLayers[g] == nil {
            shapeLayers[g] = shapeMgr.addShapeLayer(layerID: shapeLayerID(g), zOrder: visual.zShape)
        }
        
        if shapeMgr.getShapeLayer(layerID: polyStyleSetID(g)) == nil {
            let per = PerLevelPolygonStyle(color: visual.fill,
                                           strokeWidth: 2,
                                           strokeColor: visual.stroke,
                                           level: 0)
            let polyStyle = PolygonStyle(styles: [per])
            let set = PolygonStyleSet(styleSetID: polyStyleSetID(g), styles: [polyStyle])
            shapeMgr.addPolygonStyleSet(set) // 같은 styleID로 overwrite 불가
        }
    }

    // ----- 데이터 바인딩: POI -----
    /// items: (고유ID, 위치)
    func setPOIs(for g: OverlayGroup,
                 items: [POIItem],
                 visual: GroupVisual,
                 iconProvider: IconProvider,
                 onTapID: ((OverlayGroup, String) -> Void)? = nil)
    {
        ensureResources(for: g, visual: visual)
        guard let layer = poiLayers[g]?[.place], let map = map else { return }
        
        layer.clearAllItems()
        
        let keysToRemove = poiTapDisposers.keys.filter { $0.hasPrefix("\(g.rawValue).\(POIKind.place.rawValue).") }
        for key in keysToRemove {
            poiTapDisposers[key]?.dispose()
            poiTapDisposers.removeValue(forKey: key)
        }
        
        var options = [PoiOptions]()
        var positions = [MapPoint]()
        options.reserveCapacity(items.count)
        positions.reserveCapacity(items.count)

        for item in items {
            let icon = iconProvider(item.styleKey)
            var resizedIcon = icon.resized(to: CGSize(width: 28, height: 28))
            
            let styleID = ensurePoiStyle(styleKey: item.styleKey, icon: resizedIcon, on: map)

            var opt = PoiOptions(styleID: styleID,
                                 poiID: "\(poiIDPrefix(g, kind: .place)).\(item.id)")
            opt.rank = 0
            opt.clickable = true
            options.append(opt)
            positions.append(item.point)
        }

        _ = layer.addPois(options: options, at: positions) { [weak self] pois in
            guard let self, let pois else { return }
            for (i, poi) in pois.enumerated() {
                // 개별 POI 탭 핸들러
                if let onTapID {
                    let itemID = items[i].id
                    let disposer = poi.addPoiTappedEventHandler(target: self) { _ in
                        return { _ in
                            onTapID(g, itemID)
                        }
                    }
                    self.poiTapDisposers["\(g.rawValue).\(POIKind.place.rawValue).\(itemID)"] = disposer
                }
                poi.show()
            }
            layer.visible = true
        }
    }
    
    /// Clustering
    func setPOIs(for g: OverlayGroup,
                 items: [POIClusterItem],
                 visual: GroupVisual,
                 iconProvider: IconProvider)
    {
        ensureResources(for: g, visual: visual)
        guard let layer = poiLayers[g]?[.cluster], let map = map else { return }
        
        layer.clearAllItems()
        
        let keysToRemove = poiTapDisposers.keys.filter { $0.hasPrefix("\(g.rawValue).\(POIKind.cluster.rawValue).") }
        for key in keysToRemove {
            poiTapDisposers[key]?.dispose()
            poiTapDisposers.removeValue(forKey: key)
        }
        
        var options = [PoiOptions]()
        var positions = [MapPoint]()
        options.reserveCapacity(items.count)
        positions.reserveCapacity(items.count)

        for item in items {
            let baseIcon = UIImage.iconClusteringGreen // TODO: 각 클러스터링마다 가장 큰 값에 따라 이미지 변경
            var resizedIcon = baseIcon.resized(to: CGSize(width: 50, height: 50)) // TODO: Size 확인 필요
            resizedIcon = resizedIcon.withAlpha(0.9)

            // 배지 스타일로 중앙에 개수 텍스트 합성
            let countText = "\(item.itemCount)"
            let finalIcon = resizedIcon.withCenteredBadgeText(
                countText,
                font: Typography.Body01.semiBold.font,
                textColor: .grayScale10
            )

            // 스타일 캐시 충돌 방지를 위해 styleKey에 count를 포함
            let styleKey = "\(item.styleKey).count.\(item.itemCount)"
            let styleID = ensurePoiStyle(styleKey: styleKey, icon: finalIcon, on: map)

            let clusterID = "\(Int(item.point.wgsCoord.longitude * 1_000_000))_\(Int(item.point.wgsCoord.latitude * 1_000_000))_\(item.itemCount)"
            var opt = PoiOptions(styleID: styleID, poiID: "\(poiIDPrefix(g, kind: .cluster)).\(clusterID)")
            opt.rank = 0
            opt.clickable = true
            options.append(opt)
            positions.append(item.point)
        }

        _ = layer.addPois(options: options, at: positions) { [weak self] pois in
            guard let self, let pois else { return }
            for poi in pois {
                poi.show()
            }
            layer.visible = true
        }
    }

    // ----- 데이터 바인딩: 폴리곤 -----
    /// rings: 폴리곤 외곽선 배열들(복수 지역 가능)
    func setPolygons(for g: OverlayGroup,
                     rings: [[MapPoint]],
                     visual: GroupVisual)
    {
        ensureResources(for: g, visual: visual)
        guard let layer = shapeLayers[g] else { return }

        layer.clearAllShapes()
        for (idx, ring) in rings.enumerated() {
            var opt = MapPolygonShapeOptions(shapeID: "poly.\(g.rawValue).\(idx)",
                                             styleID: polyStyleSetID(g),
                                             zOrder: 0)
            let polygon = MapPolygon(exteriorRing: ring, hole: nil, styleIndex: 0)
            opt.polygons = [polygon]
            let shp = layer.addMapPolygonShape(opt)
            shp?.show()
        }
        layer.visible = true
    }

    // ----- 보이기/숨기기 -----
    func show(_ g: OverlayGroup) {
        poiLayers[g]?.values.forEach { $0.visible = true }
        shapeLayers[g]?.visible = true
    }
    func hide(_ g: OverlayGroup) {
        poiLayers[g]?.values.forEach { $0.visible = false }
        shapeLayers[g]?.visible = false
    }
    func showOnly(_ g: OverlayGroup) {
        OverlayGroup.allCases.forEach { group in
            if group == g { show(group) } else { hide(group) }
        }
    }
    func clear(_ g: OverlayGroup) {
        poiLayers[g]?.values.forEach { $0.clearAllItems() }
        shapeLayers[g]?.clearAllShapes()
    }
}

