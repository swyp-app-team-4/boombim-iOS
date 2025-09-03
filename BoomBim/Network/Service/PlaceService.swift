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
    let address: String
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

struct RegionNewsRequest: Encodable {
    let date: String
}

struct RegionNewsResponse: Decodable {
    let regionDate: String
    let startTime: String
    let endTime: String
    let posName: String
    let area: String
    let peopleCnt: Int
}

struct PlaceDetailInfo: Decodable {
    let id: Int
    let name: String
    let poiCode: String
    let observedAt: String
    let centroidLatitude: Double
    let centroidLongitude: Double
    let polygonCoordinates: [[Double]]
    let demographics: [Demographic]
    let forecasts: [Forecast]
}

struct Demographic: Decodable {
    let category: DemographicCategory
    let subCategory: String   // 혼합 타입(성별/연령/거주여부)이므로 String으로 받는게 안전
    let rate: Double
}

enum DemographicCategory: String, Decodable {
    case gender = "GENDER"
    case ageGroup = "AGE_GROUP"
    case residency = "RESIDENCY"
}

struct Forecast: Decodable {
    let forecastTime: Date
    let congestionLevelName: String
    let forecastPopulationMin: Int
    let forecastPopulationMax: Int
}

final class PlaceService: Service {
    static let shared = PlaceService()
    override private init() {}
    
    func getRegionNews() -> Single<[RegionNewsResponse]> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.regionNews
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        return requestGet(url, method: .get, header: headers, body: RegionNewsRequest(date: dateString))
    }
    
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
