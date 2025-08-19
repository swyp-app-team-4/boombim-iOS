//
//  HomeModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import Foundation
import UIKit

struct RegionItem: Hashable {
    let id = UUID()
    let iconImage: UIImage?
    let organization: String?
    let title: String
    let description: String
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
    let congestion: String // 혼잡도
}

enum HomeSection: Int, CaseIterable {
    case region
    case imageText
    case favorites
    case crowded
    
    var headerImage: UIImage? {
        switch self {
        case .region: return .iconBroadcast
        case .imageText: return nil
        case .favorites: return nil
        case .crowded: return nil
        }
    }

    var headerTitle: String? {
        switch self {
        case .region: return "지역 소식"
        case .imageText: return "지금 여기가 덜 붐벼요!"
        case .favorites: return "관심 장소"
        case .crowded: return "붐비는 장소"
        }
    }
}

enum HomeItem: Hashable {
    case region([RegionItem])
    case imageText(ImageTextItem)
    case place(PlaceItem)
}
