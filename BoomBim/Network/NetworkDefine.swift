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
        static let regionNews = "api/region"
        static let officialPlace = "official-place"
        static let userPlace = "member-place"
        static let registerPostPlace = "member-place/resolve"
        static let postPlace = "member-congestion/create"
    }
}
