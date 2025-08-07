//
//  SearchModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import Foundation

struct SearchResponse: Codable {
    let items: [SearchItem]
}

struct SearchItem: Codable {
    let title: String
    let link: String
    let category: String
    let description: String
    let telephone: String?
    let address: String
    let roadAddress: String?
}
