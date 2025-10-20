//
//  NetworkError.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

enum NetworkError: Error {
    case disconnected
    case timeout
    case invalidResponse
    case unknown

    var localizedDescription: String {
        switch self {
        case .disconnected:
            return "인터넷 연결이 없습니다."
        case .timeout:
            return "서버 응답이 지연되고 있습니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
