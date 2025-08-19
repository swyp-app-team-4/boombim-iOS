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
    let image: UIImage
    let title: String
    let address: String
    let congestion: CongestionLevel
}

struct PlaceItem: Hashable {
    let id = UUID()
    let name: String
    let detail: String
    let congestion: String // 혼잡도
}

enum HomeSection: Int, CaseIterable {
    case region
    case recommendPlace1
    case recommendPlace2
    case favorites
    case congestion
    
    var headerImage: UIImage? {
        switch self {
        case .region: return .iconBroadcast
        case .recommendPlace1: return nil
        case .recommendPlace2: return nil
        case .favorites: return nil
        case .congestion: return nil
        }
    }

    var headerTitle: String? {
        switch self {
        case .region: return "지역 소식"
        case .recommendPlace1: return "지금 여기가 덜 붐벼요!"
        case .recommendPlace2: return nil
        case .favorites: return "관심 장소"
        case .congestion: return "붐비는 장소"
        }
    }
}

enum HomeItem: Hashable {
    case region([RegionItem])
    case imageText(ImageTextItem)
    case place(PlaceItem)
}
