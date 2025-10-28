//
//  NetworkDefine.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

enum NetworkDefine {
    static let apiHost = "https://boombim.co.kr/"
    static let apiKakao = "https://dapi.kakao.com/"
    
    enum Auth {
        enum AuthType: String {
            case naver = "naver"
            case kakao = "kakao"
            case apple = "apple"
        }
        
        static let login = "api/app/oauth2/login/"
        static let refresh = "api/app/reissue"
        static let logout = "api/app/oauth2/logout"
        static let withdraw = "api/app/member"
    }
    
    enum Profile {
        static let nickname = "api/app/member/name"
        static let image = "api/app/member/profile"
        static let profile = "api/app/member"
        static let favorite = "api/member/favorite"
        static let answer = "api/member/my-answer"
        static let question = "api/member/my-question"
        static let alarm = "api/alarm/status"
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
                return "api/app/public/official-place/nearby-non-congested"
            case .rankByOfficialPlace:
                return "api/app/public/official-place/top-congested"
            case .favoritePlace:
                return "api/app/favorite"
            case .officialPlace:
                return "api/app/public/official-place"
            case .userPlace:
                return "api/app/member-place"
            case .registerPostPlace:
                return "api/app/member-place/resolve"
            case .postPlace:
                return "api/app/member-congestion"
            case .officialPlaceDetail(let id):
                return "api/app/public/official-place/\(id)/overview"
            case .userPlaceDetail(let id):
                return "api/app/member-place/\(id)"
            case .registerFavoritePlace:
                return "api/app/favorite"
            case .deleteFavoritePlace(let type, let id):
                return "api/app/favorite?placeId=\(id)&placeType=\(type)"
            case .aiRequest:
                return "api/app/clova/congestion-message"
            }
        }
    }
}
