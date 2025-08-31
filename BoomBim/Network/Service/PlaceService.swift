//
//  PlaceService.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import Alamofire
import RxSwift
import CoreLocation

// 좌표 DTO (서버와 주고받는 형태)
struct Coord: Codable {
    let latitude: Double
    let longitude: Double
}

// 뷰포트 조회 요청 바디
struct OfficialPlaceRequest: Encodable {
    let topLeft: Coord
    let bottomRight: Coord
    let memberCoordinate: Coord
    let zoomLevel: Int
}

// 서버 응답의 단일 공식 장소
struct OfficialPlaceItem: Decodable {
    let id: Int
    let name: String
    let coordinate: Coord
    let distance: Double
    let congestionLevelName: String
    let congestionMessage: String
}

struct OfficialPlaceListResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [OfficialPlaceItem]
}

typealias UserPlaceRequest = OfficialPlaceRequest

struct UserPlaceItem: Decodable {
    let type: String
    let memberPlaceId: Int
    let name: String
    let coordinate: Coord
    let distance: Double
    let congestionLevelName: String
    let congestionMessage: String
}

struct UserPlaceListResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [UserPlaceItem]
}

struct RegisterPlaceRequest: Encodable {
    let uuid: String
    let name: String
    let latitude: Double
    let longitude: Double
}

struct RegisterPlaceId: Decodable {
    let memberPlaceId: Int
}

struct RegisterPlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: RegisterPlaceId
}

struct PostPlaceRequest: Encodable {
    let memberPlaceId: Int
    let congestionLevelId: Int
    let congestionMessage: String
    let latitude: Double
    let longitude: Double
}

struct ReportData: Decodable {
    let memberCongestionId: Int
    let memberPlaceName: String
}

struct PostPlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: ReportData
}

final class PlaceService: Service {
    static let shared = PlaceService()
    override private init() {}
    
    func fetchOfficialPlace(body: OfficialPlaceRequest) -> Single<OfficialPlaceListResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.officialPlace
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func fetchUserPlace(body: UserPlaceRequest) -> Single<UserPlaceListResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.userPlace
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func registerReport(body: RegisterPlaceRequest) -> Single<RegisterPlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.registerPostPlace
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func postReport(body: PostPlaceRequest) -> Single<PostPlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.postPlace
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
}
