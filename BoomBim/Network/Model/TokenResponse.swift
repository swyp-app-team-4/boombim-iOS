//
//  TokenResponse.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
