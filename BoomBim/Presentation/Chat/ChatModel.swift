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
    let profileImage: [String]
    let people: Int
    let update: String
    let title: String
    let roadImage: String?
    let congestion: CongestionLevel
    let isVoting: Bool
}

struct QuestionChatItem: Hashable {
    let id = UUID()
    let profileImage: [String]
    let people: Int
    let update: String
    let title: String
    let relaxed: Int
    let normal: Int
    let busy: Int
    let crowded: Int
    let isVoting: Bool
}
