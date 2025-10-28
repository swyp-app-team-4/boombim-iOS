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
    let officialPlaceId: Int
    let officialPlaceName: String
    let legalDong: String
    let placeType: String
    let imageUrl: String
    let coordinate: Coord
    let distance: Double
    let congestionLevelName: String
    let congestionMessage: String
    var isFavorite: Bool
}

struct OfficialPlaceListResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [OfficialPlaceItem]
}

typealias UserPlaceRequest = OfficialPlaceRequest

// PLACE 전용
struct UserPlaceItem: Decodable {
    let type: String          // "PLACE"
    let memberPlaceId: Int
    let name: String
    let placeType: String     // "MEMBER_PLACE" (원하면 유지)
    let coordinate: Coord
    let distance: Double
    let congestionLevelName: String
    let congestionMessage: String
    let createdAt: String
    var isFavorite: Bool
}

// CLUSTER 전용
struct ClusterItem: Decodable {
    let type: String          // "CLUSTER"
    let coordinate: Coord
    let clusterSize: Int
    let congestionLevelCounts: [String:Int]
}

// 둘을 아우르는 합타입
enum UserPlaceEntry: Decodable {
    case place(UserPlaceItem)
    case cluster(ClusterItem)

    private enum CodingKeys: String, CodingKey { case type }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "PLACE":
            self = .place(try UserPlaceItem(from: decoder))
        case "CLUSTER":
            self = .cluster(try ClusterItem(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: c, debugDescription: "Unknown type")
        }
    }
}

// 응답 래퍼
struct UserPlaceListResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [UserPlaceEntry]
}

//struct UserPlaceListResponse: Decodable {
//    let code: Int
//    let status: String
//    let message: String
//    let data: [UserPlaceItem]
//}

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

struct UserPlaceDetailRequest: Encodable {
    let memberPlaceId: Int
}

struct UserPlaceDetailResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: UserPlaceDetailInfo
}

struct UserPlaceDetailInfo: Decodable {
    let memberPlaceSummary: MemberPlaceSummary
    let memberCongestionItems: [MemberCongestionItem]
    let hasNext: Bool
    let nextCursor: Int
    let size: Int
}

struct MemberPlaceSummary: Decodable {
    let memberPlaceId: Int
    let name: String
    let placeType: String
    let address: String
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
    let isFavorite: Bool
}

struct MemberCongestionItem: Decodable {
    let memberCongestionId: Int
    let memberProfile: String
    let memberName: String
    let congestionLevelName: String
    let congestionLevelMessage: String
    let createdAt: String
}

struct OfficialPlaceDetailRequest: Encodable {
    let officialPlaceId: Int
}

struct OfficialPlaceDetailResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: OfficialPlaceDetailInfo
}

struct OfficialPlaceDetailInfo: Decodable {
    let officialPlaceId: Int
    let officialPlaceName: String
    let legalDong: String
    let placeType: String
    let poiCode: String
    let imageUrl: String
    let congestionLevelName: String
    let congestionMessage: String
    let observedAt: String
    let centroidLatitude: Double
    let centroidLongitude: Double
    let polygonCoordinates: String
    let demographics: [Demographic]
    let forecasts: [Forecast]
    let isFavorite: Bool
}

struct Demographic: Decodable {
    let category: DemographicCategory
    let subCategory: String
    let rate: Double
}

enum DemographicCategory: String, Decodable {
    case gender = "GENDER"
    case ageGroup = "AGE_GROUP"
    case residency = "RESIDENCY"
}

enum GenderCategory: String {
    case MALE = "MALE"
    case FEMALE = "FEMALE"
}

enum ResidencyCategory: String {
    case RESIDENT = "RESIDENT"
    case NON_RESIDENT = "NON_RESIDENT"
}

enum AgeCategory: String, CaseIterable {
    case s0 = "0s"
    case s10 = "10s"
    case s20 = "20s"
    case s30 = "30s"
    case s40 = "40s"
    case s50 = "50s"
    case s60 = "60s"
    case s70 = "70s"
}

struct Forecast: Decodable {
    let forecastTime: String
    let congestionLevelName: String
    let forecastPopulationMin: Int
    let forecastPopulationMax: Int
}

struct NearbyOfficialPlaceRequest: Encodable {
    let latitude: Double
    let longitude: Double
}

struct NearbyOfficialPlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [NearbyOfficialPlaceInfo]
}

struct NearbyOfficialPlaceInfo: Decodable {
    let officialPlaceId: Int
    let officialPlaceName: String
    let legalDong: String
    let imageUrl: String
    let congestionLevelName: String
    let observedAt: String
    let distanceMeters: Double
}

struct FavoritePlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [FavoritePlaceInfo]
}

struct FavoritePlaceInfo: Decodable {
    let favoriteId: Int
    let placeId: Int
    let placeType: FavoritePlaceType
    let name: String
    let imageUrl: String?
    let congestionLevelName: String?
    let observedAt: String?
    let updatedToday: Bool?
    let todayUpdateCount: Int?
}

struct RankOfficialPlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: [RankOfficialPlaceInfo]
}

struct RankOfficialPlaceInfo: Decodable {
    let officialPlaceId: Int
    let officialPlaceName: String
    let legalDong: String
    let imageUrl: String
    let congestionLevelName: String
    let densityPerM2: Double
    let observedAt: String
}

enum FavoritePlaceType: String, Encodable, Decodable {
    case OFFICIAL_PLACE = "OFFICIAL_PLACE"
    case MEMBER_PLACE = "MEMBER_PLACE"
}

struct RegisterFavoritePlaceRequest: Encodable {
    let placeType: FavoritePlaceType
    let placeId: Int
}

struct RegisterFavoritePlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: FavoritePlaceId
}

struct FavoritePlaceId: Decodable {
    let favoriteId: Int
}

struct RemoveFavoritePlaceRequest: Encodable {
    let placeType: FavoritePlaceType
    let placeId: Int
}

struct RemoveFavoritePlaceResponse: Decodable {
    let code: Int
    let status: String
    let message: String
}

struct AiMessageRequest: Encodable {
    let memberPlaceName: String
    let congestionLevelName: String
    let congestionMessage: String
}

struct AiMessageResponse: Decodable {
    let code: Int
    let status: String
    let message: String
    let data: AiMessageData
}

struct AiMessageData: Decodable {
    let generatedCongestionMessage: String
}

final class PlaceService: Service {
    static let shared = PlaceService()
    override private init() {}
    
    // MARK: - 홈화면 정보
    func getRegionNews() -> Single<[RegionNewsResponse]> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.regionNews.path
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        return requestGet(url, method: .get, header: headers, body: RegionNewsRequest(date: dateString))
    }
    
    func getNearbyOfficialPlace(body: NearbyOfficialPlaceRequest) -> Single<NearbyOfficialPlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.nearByOfficialPlace.path
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestGet(url, method: .get, header: headers, body: body)
    }
    
    func getRankOfficialPlace() -> Single<RankOfficialPlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.rankByOfficialPlace.path
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestGet(url, method: .get, header: headers)
    }
    
    func getFavoritePlace() -> Single<FavoritePlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.favoritePlace.path
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestGet(url, method: .get, header: headers)
    }
    
    // MARK: - 지도 페이지
    func fetchOfficialPlace(body: OfficialPlaceRequest) -> Single<OfficialPlaceListResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.officialPlace.path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func fetchUserPlace(body: UserPlaceRequest) -> Single<UserPlaceListResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.userPlace.path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func registerReport(body: RegisterPlaceRequest) -> Single<RegisterPlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.registerPostPlace.path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func postReport(body: PostPlaceRequest) -> Single<PostPlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.postPlace.path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func getOfficialPlaceDetail(body: OfficialPlaceDetailRequest) -> Single<OfficialPlaceDetailResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.officialPlaceDetail(id: body.officialPlaceId).path
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestGet(url, method: .get, header: headers)
    }
    
    func getUserPlaceDetail(body: UserPlaceDetailRequest) -> Single<UserPlaceDetailResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.userPlaceDetail(id: body.memberPlaceId).path
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return requestGet(url, method: .get, header: headers)
    }
    
    func registerFavoritePlace(body: RegisterFavoritePlaceRequest) -> Single<RegisterFavoritePlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.registerFavoritePlace.path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func removeFavoritePlace(body: RemoveFavoritePlaceRequest) -> Single<RemoveFavoritePlaceResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.deleteFavoritePlace(type: body.placeType, id: body.placeId).path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .delete, header: headers, body: body)
    }
    
    func requestAi(body: AiMessageRequest) -> Single<AiMessageResponse> {
        let url = NetworkDefine.apiHost + NetworkDefine.Place.aiRequest.path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return request(url, method: .post, header: headers, body: body)
    }
}
