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

struct UserProfile: Decodable {
    let name: String
    let profile: String?
    let email: String
    let socialProvider: String
    let voteCnt: Int
    let questionCnt: Int
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

typealias MyFavorite = FavoritePlaceInfo

struct AnswerInfo: Decodable {
    let voteId: Int
    let profile: [String]
    let day: String
    let posName: String
    let popularRes: [String]
    let relaxedCnt: Int
    let commonly: Int
    let slightlyBusyCnt: Int
    let crowedCnt: Int
    let voteAllCnt: Int
    let voteStatus: VoteStatus
}

struct MyAnswer: Decodable {
    let day: String
    let res: [AnswerInfo]
}

struct QuestionInfo: Decodable {
    let voteId: Int
    let profile: [String]
    let day: String
    let posName: String
    let popularRes: [String]
    let relaxedCnt: Int
    let commonly: Int
    let slightlyBusyCnt: Int
    let crowedCnt: Int
    let voteAllCnt: Int
    let voteStatus: VoteStatus
}

struct MyQuestion: Decodable {
    let day: String
    let res: [QuestionInfo]
}
