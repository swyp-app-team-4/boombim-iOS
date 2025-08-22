//
//  MyPageModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import Foundation
import UIKit

enum FavoriteSection {
    case main
}

struct VoteItem: Hashable {
    let id = UUID()
    let image: UIImage
    let title: String
    let congestion: CongestionLevel
    let people: Int
    let isVoting: Bool
}

struct QuestionItem: Hashable {
    let id = UUID()
    let image: UIImage
    let title: String
    let congestion: CongestionLevel
    let people: Int
    let isQuesting: Bool
}
