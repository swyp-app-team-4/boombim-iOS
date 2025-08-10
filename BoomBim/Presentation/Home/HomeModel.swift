//
//  HomeModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import Foundation

struct RegionItem: Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
}

struct ImageTextItem: Hashable {
    let id = UUID()
    let imageName: String
    let title: String
}

struct PlaceItem: Hashable {
    let id = UUID()
    let name: String
    let detail: String
    let badgeText: String? // e.g., 혼잡도
}

enum HomeSection: Int, CaseIterable {
    case region
    case imageText
    case favorites
    case crowded

    var headerTitle: String? {
        switch self {
        case .region: return nil
        case .imageText: return nil
        case .favorites: return "관심 장소"
        case .crowded: return "붐비는 장소"
        }
    }
}

enum HomeItem: Hashable {
    case region(RegionItem)
    case imageText(ImageTextItem)
    case place(PlaceItem)
}
