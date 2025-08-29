//
//  VoteService.swift
//  BoomBim
//
//  Created by 조영현 on 8/29/25.
//

import Foundation
import RxSwift
import Alamofire

struct CreateVoteRequest: Encodable {
    let posId: String
    let posLatitude: Double
    let posLongitude: Double
    let userLatitude: Double
    let userLongitude: Double
    let posName: String
}

enum VoteStatus: String, Decodable {
    case PROGRESS, END
}

struct VoteListRequest: Encodable {
    let latitude: Double
    let longitude: Double
}

struct VoteItemResponse: Decodable {
    let voteId: Int
    let profile: String?
    let voteDuplicationCnt: Int
    let createdAt: Date                    // ISO8601(소수초) 대응
    let posName: String
    let posImage: String?                  // myVote에는 없으니 optional
    let relaxedCnt: Int
    let commonly: Int
    let slightlyBusyCnt: Int
    let crowedCnt: Int
    let allType: String
    let voteFlag: Bool
    let voteStatus: VoteStatus?            // others에는 없으니 optional
}

struct VoteListResponse: Decodable {
    let voteResList: [VoteItemResponse]            // “투표하기” 리스트
    let myVoteResList: [VoteItemResponse]          // “내 질문” 리스트 (필드 차이는 optional로 커버)
}

enum CreateVoteError: LocalizedError {
    case outOfRadius        // 403
    case userNotFound       // 404
    case duplicatePlace     // 409
    case server             // 5xx
    case unknown

    static func from(status: Int?) -> CreateVoteError {
        switch status {
        case 403: return .outOfRadius
        case 404: return .userNotFound
        case 409: return .duplicatePlace
        case .some(let s) where 500...599 ~= s: return .server
        default: return .unknown
        }
    }

    var errorDescription: String? {
        switch self {
        case .outOfRadius:    return "현재 위치에서 500m 이내에서만 투표할 수 있어요."
        case .userNotFound:   return "존재하지 않는 사용자입니다. 다시 로그인해 주세요."
        case .duplicatePlace: return "이미 이 장소에 투표하셨어요."
        case .server:         return "서버 오류가 발생했어요. 잠시 후 다시 시도해 주세요."
        case .unknown:        return "알 수 없는 오류가 발생했어요."
        }
    }
}

final class VoteService: Service {
    static let shared = VoteService()
    
    override private init() {}
    
    func createVote(_ body: CreateVoteRequest) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Vote.create
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let access = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(access)"
        }
        
        return requestVoid(url, method: .post, header: headers, body: body)
    }
    
    func fetchVoteList(_ body: VoteListRequest) -> Single<VoteListResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Vote.create
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let access = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(access)"
        }
        
        return requestGet(url, method: .post, header: headers, body: body)
    }
}
