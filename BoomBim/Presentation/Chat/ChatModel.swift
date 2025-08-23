//
//  ChatModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/23/25.
//

import Foundation
import UIKit

struct VoteChatItem: Hashable {
    let id = UUID()
    let profileImage: [URL?]
    let people: Int
    let update: String
    let title: String
    let roadImage: URL?
    let congestion: CongestionLevel
    let isVoting: Bool
}
