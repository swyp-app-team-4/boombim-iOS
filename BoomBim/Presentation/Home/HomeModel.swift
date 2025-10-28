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

struct RecommendPlaceItem: Hashable {
    let id = UUID()
    let image: String
    let title: String
    let address: String
    let congestion: CongestionLevel
}

struct FavoritePlaceItem: Hashable {
    let placeId: Int
    let placeType: FavoritePlaceType
    let image: String
    let title: String
    let update: String
    let congestion: CongestionLevel?
}

struct CongestionRankPlaceItem: Hashable {
    let id = UUID()
    let rank: Int
    let image: String
    let title: String
    let address: String
    let update: String
    let congestion: CongestionLevel
}

enum HomeSection: Int, CaseIterable {
    case region
    case recommendPlace
    case favoritePlace
    case congestionRank
    
    var headerImage: UIImage? {
        switch self {
        case .region: return .iconBroadcast
        case .recommendPlace: return nil
        case .favoritePlace: return nil
        case .congestionRank: return nil
        }
    }

    var headerTitle: String? {
        switch self {
        case .region: return "지역 소식"
        case .recommendPlace: return "내 근처 한적한 스팟"
        case .favoritePlace: return "관심 장소"
        case .congestionRank: return "지금 붐비는 장소 TOP 5"
        }
    }
    
    var headerButton: Bool? {
        switch self {
        case .region: return false
        case .recommendPlace: return false
        case .favoritePlace: return false
        case .congestionRank: return true
        }
    }
    
    var cellSeparator: Bool? {
        switch self {
        case .region: return false
        case .recommendPlace: return false
        case .favoritePlace: return false
        case .congestionRank: return true
        }
    }
}

enum HomeItem: Hashable {
    case region([RegionItem])
    case recommendPlace(RecommendPlaceItem)
    case favoritePlace(FavoritePlaceItem)
    case favoriteEmpty
    case congestionRank(CongestionRankPlaceItem)
}
