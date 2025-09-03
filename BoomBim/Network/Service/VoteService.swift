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
    let profile: [String]
    let voteDuplicationCnt: Int
    let createdAt: String
    let posName: String
    let posImage: String
    let relaxedCnt: Int
    let commonly: Int
    let slightlyBusyCnt: Int
    let crowedCnt: Int
    let allType: String
    let voteFlag: Bool
}

struct MyVoteItemResponse: Decodable {
    let voteId: Int
    let profile: [String]
    let voteDuplicationCnt: Int
    let createdAt: String
    let posName: String
    let relaxedCnt: Int
    let commonly: Int
    let slightlyBusyCnt: Int
    let crowedCnt: Int
    let allType: String
    let voteStatus: VoteStatus
    let voteFlag: Bool
}

struct VoteListResponse: Decodable {
    let voteResList: [VoteItemResponse]            // “투표하기” 리스트
    let myVoteResList: [MyVoteItemResponse]          // “내 질문” 리스트 (필드 차이는 optional로 커버)
}

struct FinishVoteRequest: Encodable {
    let voteId: Int
}

enum VoteAnswerType: String, Encodable {
    case RELAXED, COMMONLY, BUSY, CROWDED
    
    init(index: Int) {
        switch index {
        case 0: self = .RELAXED
        case 1: self = .COMMONLY
        case 2: self = .BUSY
        case 3: self = .CROWDED
        default:
            self = .CROWDED
        }
    }
}

struct CastVoteRequest: Encodable {
    let voteId: Int
    let voteAnswerType: VoteAnswerType
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

enum EndVoteError: LocalizedError {
    case forbidden        // 403: 권한 없음(내 투표 아님 등)
    case notFound         // 404
    case conflict         // 409: 이미 종료
    case server
    case unknown

    static func from(status: Int?) -> EndVoteError {
        switch status {
        case 403: return .forbidden
        case 404: return .notFound
        case 409: return .conflict
        case .some(let s) where 500...599 ~= s: return .server
        default: return .unknown
        }
    }

    var errorDescription: String? {
        switch self {
        case .forbidden: return "해당 투표를 종료할 권한이 없어요."
        case .notFound:  return "투표를 찾을 수 없어요."
        case .conflict:  return "이미 종료된 투표예요."
        case .server:    return "서버 오류가 발생했어요. 잠시 후 다시 시도해 주세요."
        case .unknown:   return "알 수 없는 오류가 발생했어요."
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
        let url = NetworkDefine.apiHost + NetworkDefine.Vote.fetch
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let access = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(access)"
        }
        
        print("body: \(body)")
        
        return requestGet(url, method: .get, header: headers, body: body)
    }
    
    func finishVote(_ body: FinishVoteRequest) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Vote.finish
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestVoid(url, method: .patch, header: headers, body: body)
    }
    
    func castVote(_ body: CastVoteRequest) -> Single<Void> {
        let url = NetworkDefine.apiHost + NetworkDefine.Vote.answer
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let access = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(access)"
        }
        
        return requestVoid(url, method: .post, header: headers, body: body)
    }
}
