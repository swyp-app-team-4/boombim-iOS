//
//  ServerErrorResponse.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

struct ServerErrorResponse: Decodable {
    let status: Int?
    let code: Int?
    let message: String?
    let time: String?
}
