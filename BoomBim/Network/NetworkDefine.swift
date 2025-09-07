//
//  NetworkDefine.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

enum NetworkDefine {
    static let apiHost = "https://api.boombim.p-e.kr/"
    static let apiKakao = "https://dapi.kakao.com/"
    
    enum Auth {
        enum AuthType: String {
            case naver = "naver"
            case kakao = "kakao"
            case apple = "apple"
        }
        
        static let login = "api/oauth2/login/"
        static let refresh = "api/reissue"
        static let logout = "api/oauth2/logout"
        static let withdraw = "api/member"
    }
    
    enum Profile {
        static let nickname = "api/member/name"
        static let image = "api/member/profile"
        static let profile = "api/member"
        static let favorite = "api/member/favorite"
        static let answer = "api/member/my-answer"
        static let question = "api/member/my-question"
    }
    
    enum Vote {
        static let create = "api/vote"
        static let fetch = "api/vote"
        static let finish = "api/vote"
        static let answer = "api/vote/answer"
    }
    
    enum Search {
        static let keyword = "v2/local/search/keyword.json"
        static let category = "v2/local/search/category.json"
    }
    
    enum Fcm {
        static let token = "api/alarm/fcm-token"
        static let alarm = "api/alarm/history?deviceType=IOS"
    }
    
    enum Place {
        case regionNews
        case nearByOfficialPlace
        case rankByOfficialPlace
        case favoritePlace
        case officialPlace
        case userPlace
        case registerPostPlace
        case postPlace
        case officialPlaceDetail(id: Int)
        case userPlaceDetail(id: Int)
        case registerFavoritePlace
        case deleteFavoritePlace(type: FavoritePlaceType, id: Int)
        case aiRequest
        
        var path: String {
            switch self {
            case .regionNews:
                return "api/region"
            case .nearByOfficialPlace:
                return "official-place/nearby-non-congested"
            case .rankByOfficialPlace:
                return "official-place/top-congested"
            case .favoritePlace:
                return "favorite"
            case .officialPlace:
                return "official-place"
            case .userPlace:
                return "member-place"
            case .registerPostPlace:
                return "member-place/resolve"
            case .postPlace:
                return "member-congestion/create"
            case .officialPlaceDetail(let id):
                return "official-place/\(id)/overview"
            case .userPlaceDetail(let id):
                return "member-place/\(id)"
            case .registerFavoritePlace:
                return "favorite"
            case .deleteFavoritePlace(let type, let id):
                return "favorite?placeId=\(id)&placeType=\(type)"
            case .aiRequest:
                return "clova/congestion-message"
            }
        }
    }
}
