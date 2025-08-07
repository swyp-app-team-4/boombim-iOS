//
//  SocialProvider.swift
//  SwypTeam4
//
//  Created by 조영현 on 7/31/25.
//

import Foundation

enum SocialProvider: String, Codable {
    case apple
    case kakao
    case naver
}

/** 소셜 로그인으로부터 받아오는 Token 정보 */ 
struct TokenInfo: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let idToken: String
}


